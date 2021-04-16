


server <- function(input, output, session){
    
   rv <- reactiveValues(ACC = ACC, drawnPoly = drawnPoly, pal=pal) 
   
  
    #initial empty map
    output$mymap <- renderLeaflet({
        leaflet( )  %>%
        addTiles() %>%
        setView(2.15,41.39,zoom=11.5)
    })
    
    #set year selection and enable load action  button   
    year <- reactive({
        return(input$year)
    })
  
    ## load button - download data file if necessary and read file and set default values 
    ## for input dates
    ##
    
    observeEvent(input$load,{
       
        rv$ACC <- load_data(year())
     
        data_inici <- as.Date(paste("01-01-",year(), sep=""), format="%d-%m-%Y" )
        data_fi <- as.Date(paste("31-12-",year(), sep=""), format="%d-%m-%Y" )
        
        updateDateInput(session,"dataini", value = data_inici)
        updateDateInput(session,"datafi", value =  data_fi)
          
        # get discrete domain
        domain <- levels(rv$ACC$Typology)
        
        
        updateSelectInput(session, "tipuslist",
                          choices = c("Sense selecció (tots)", domain))
        
        # create palette
        rv$pal <-colorFactor( palette = primary.colors(length(domain)),
                           domain = domain)
     
    })  
  
    ## Data in plygon - reactive function retrieves data in polygon
    ##
    
    DataInPoly <- reactive({
      if (is.null(input$newpoly)){rv$ACC}  
      else {
          data <- DataInSelection()
          subset(data,enPoli(Longitude, Latitude, input$newpoly))   
      }
    })


    ## reactive function retrieves data in user selection 
    ##
    
    DataInSelection <- reactive({

        d <- subset(isolate(rv$ACC), ((Date >= input$dataini
                                      & Date <=  input$datafi)
                                      & WeekDay %in% input$diesetmana 
                                      & (Hour >= input$horaIni & Hour <= input$horaFi)))
        
        if (!is.null(input$tipuslist) && input$tipuslist != "Sense selecció (tots)" ){
           
            d <- subset(d, Typology %in% input$tipuslist)  
        }
        
        d
    })
    
   
    ## reactive function retrieves selected data, contained in polygon or not depending in 
    ##  option selection
    ##
    
    Data <- reactive ({
        if (input$opt == "optTot"){
            data <- DataInSelection()
        }else{ data <- DataInPoly()}
        
        data
    })

    ## Filter button is pressed , redraw map with data in selection as cluster an circle
    ## markers and polygon if it exists
    ## Output data grid to the data exploration tab
    ## Output summaries (number of observations selected and daily mean)
    ## Also output 1 plot out of 3 (depending on radio button selection  )
    ##
    
    observeEvent(input$filter, {
      
       # data, obsevations that meet filter criteria and inside poligon 
       data <- Data()
       
       # dataS, obsevations that meet filter criteria 
       dataSel <- DataInSelection()
       
       n <- nrow(data)
       nSel <- nrow(dataSel)
       
       # output map  
       output$mymap <- renderLeaflet({
          
          if ( !is.null(nSel) && nSel >= 0){ 
              set.seed(1234)
       
              m <-  leaflet(DataInSelection() )  %>%
                    addTiles() %>%
                    setView(2.15,41.39,zoom=11.5) %>%
                    addCircleMarkers(
                       color = rv$pal(dataSel$Typology),
                       clusterOptions = markerClusterOptions(),
                       opacity = 1,
                       label= paste( dataSel$Typology, dataSel$Date, sep = "\n")
                       ) %>%
                    addDrawToolbar(  targetGroup = "polys", 
                      polylineOptions = FALSE,
                       circleOptions = FALSE,
                       rectangleOptions = FALSE,
                       markerOptions = FALSE,
                       circleMarkerOptions = FALSE, 
                       singleFeature = TRUE, editOptions = editToolbarOptions()
                   )
   
             if (!is.null(rv$drawnPoly) ){
                
                  m <-  addPolygons(map =m , group= "polys",data=rv$drawnPoly,  color="blue")
              }

          } else {
              m <- leaflet( )  %>%
                  addTiles() %>%
                  setView(2.15,41.39,zoom=11.5)
          }
       
          m 
          
        })
       
        #output data grid
        output$grid <- DT::renderDataTable({data})
        
        #output summaries 
       
        if ( n > 0 ){
            
           # number of accidents in selection
           output$NumAcc <- renderText({paste("Number of accidents: ",n)})
           
           # dayly mean of accidents in selection
           output$DailyMean <- renderText({
               dataDia <- data %>% group_by(Date) %>% mutate(ndia = sum(n())) 
               dataDia <- aggregate(dataDia$ndia, by=list(dataDia$Date), FUN=mean)
               mitjanadia <-  sum(dataDia$x) / as.numeric(input$datafi - input$dataini)
               paste("Average accidents per day:", round(mitjanadia, digits =2)) 
             
           })
           
           # hourly mean of accidents in selection
           
           output$HourlyMean <- renderText({
             dataDia <- data %>% group_by(Date) %>% mutate(ndia = sum(n())) 
             dataDia <- aggregate(dataDia$ndia, by=list(dataDia$Date), FUN=mean)
             mitjanadia <-  sum(dataDia$x) / (as.numeric(input$datafi - input$dataini) * (input$slider_hours[2] - input$slider_hours[1]))
             paste("Average accidents per hour:", round(mitjanadia, digits =2)) 
             
           })
           
           # Render plot depending on selection 
           output$plot <- renderPlot({
           data <- isolate(Data())
             
           # bar plot tipus accident
           if (input$optplot == "optTipus"){
             
                datasum <- data %>% group_by(Typology) %>%
                          summarise( count = n(), percent = round(100* n() / nrow(data)),2) %>%
                          mutate(lab.ypos = 100 - (cumsum(percent)  -  0.5*percent), label = paste0(count," - ", percent, "%"))

                
                d <- ggplot(datasum, aes(x=reorder(Typology, count) ,y=count,fill=Typology))+
                  geom_bar(stat ="identity"  ) +
                  geom_text(aes(label= label, group=Typology,hjust=-0.2)) +
                  coord_flip()+
                  theme (legend.position="none", 
                         panel.background = element_rect(fill = "white", color = "white"),
                         panel.grid.major.x = element_line(color="grey95"),
                         panel.grid.major.y = element_line(color="grey95"),
                         panel.grid.minor.x = element_line(color="grey95"),
                         panel.grid.minor.y = element_line(color="grey95"),
                         axis.ticks = element_blank()
                         ) +
                  labs(x="",y="Number of accidents") +
                  scale_fill_manual(values = rv$pal(datasum$Typology) )+
                  scale_y_continuous( expand=expansion(mult = c(0, .2)))
               
                
             # bar plot week days of accidents        
             } else if(input$optplot == "optDia"){
             
                  datasum <- data %>% group_by(WeekDay) %>%
                        summarise( count = n(), percent = round(100* n() / nrow(data)),2) %>%
                        mutate(lab.ypos = 100 - (cumsum(percent)  -  0.5*percent), label = paste0(percent, "%"))

                  d <- ggplot(datasum , aes(x= WeekDay ,y=count)) +
                          geom_bar(stat = "identity") +
                          geom_text(aes(label= label, group=WeekDay,vjust= 1), color ="white") +
                          theme_minimal() +
                          labs(x= "Week day" , y="Number of accidents")
                  
              # bar plot hours of the accidents
             } else if (input$optplot == "optHora"){
               
                  d <- ggplot(data,  ) +
                          geom_bar( mapping = aes(stat = "count", y = Hour)) +
                          coord_flip() +
                          theme_minimal() +  
                          labs(y= "Number of accidents" , x="Hour")
             }
             
             d
             
           })
           
        }
       
    })
    
    ## get drawn polygon data to filter data within it ##
    
    latlongs<-reactiveValues()   #temporary to hold coords
    latlongs$df2 <- data.frame(Longitude = numeric(0), Latitude = numeric(0))
    
    ## new plygon is drawn
    ##
    
    observeEvent(input$mymap_draw_new_feature, {
      
        coor<-unlist(input$mymap_draw_new_feature$geometry$coordinates)
        Longitude<-coor[seq(1,length(coor), 2)] 
        Latitude<-coor[seq(2,length(coor), 2)]
        
        isolate(latlongs$df2<-rbind(latlongs$df2, cbind(Longitude, Latitude)))
        poly<-Polygon(cbind(latlongs$df2$Longitude, latlongs$df2$Latitude))
        
        session$sendCustomMessage("newpoly", poly)
        
        polys <-Polygons(list(poly),    ID=input$mymap_draw_new_feature$properties$`_leaflet_id`)
        spPolys <-SpatialPolygons(list(polys))
        
        rv$drawnPoly <-SpatialPolygonsDataFrame(spPolys,
                                               data=data.frame(notes=NA, 
                                              row.names=row.names(spPolys)))
    
        latlongs$df2 <- data.frame(Longitude = numeric(0), Latitude = numeric(0))   #clear df
    })
    
    
    ## Delete polygon
    ##
    
    observeEvent(input$mymap_draw_deleted_features, { 
      
        session$sendCustomMessage("newpoly", as.null())
        rv$drawnPoly <- as.null()
        updateRadioButtons(session, "opt", selected = "optTot")
        
      ### intentando click automatico ###
       click( session$ns("filtre"))
          
      
    
    }) 
    
    output$HelpBox = renderUI({
      if (input$action %% 2){
        #helpText(" ")
        includeMarkdown("helpfile.md")
      } else {
        return()
      }
    })
   
}