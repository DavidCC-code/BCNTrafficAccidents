
ui <-  navbarPage(  "Barcelona City Traffic Accident Explorer", id="nav",
       tabPanel("Interactive Map", 
                useShinyjs(),
                tags$script("Shiny.addCustomMessageHandler('newpoly', function(value) {
                             Shiny.setInputValue('newpoly', value);
                             });"
                            ),
               
         div(class="outer",
                   
              tags$head(
              # Include our custom CSS
                includeCSS("styles.css"),
                includeScript("gomap.js")
              ),
                    
             leafletOutput("mymap", width="100%", height = "100%" ),                  
              
             
             #panel - help
             absolutePanel(id = "help", class = "panel panel-default", fixed = TRUE,
                           draggable = TRUE, top = 60, left = 60, right = "auto", bottom = "auto",
                           width = "auto", height = "auto",
                           
                  actionButton("action", label = "Help"),    
                  uiOutput("HelpBox")  
             
              ),
             
              #panel- load data and filters  
              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                   width = 400, height = "auto",
                                      
                  h2("Load and filter data"),  
                  
                  fluidRow(
                        column(5,selectInput("year", "Choose a year:",
                              c("",
                               "2018",
                               "2019",
                               "2020" ))
                        ),
                        column(5, actionButton("load", "Load"))
                        
                        
                  ),
                  tags$style(type='text/css', "#load { width:100%; margin-top: 25px;}"),

                  dateInput("dataini", "From:", value = "" ),
                  dateInput("datafi", "to:", value = ""),
                  
                  
                  #day_choice_list global list with days of the week
                  checkboxGroupInput("diesetmana", "Week days:",
                                     choices =  day_choice_list,
                                     selected =  day_choice_list,
                                     inline = TRUE
                                     ),
                  
                  h2("Hour range:"),
                  
                  fluidRow(
                     column(5,numericInput("horaIni", "Between hour: ", value= 0, min = 0, max = 23,step = 1)),
                     column(5, numericInput("horaFi", "and: ", value = 23, min = 0 , max = 23, step = 1))),
                  
                   
                  ## select input for tiups accident filter
                  selectInput(
                     inputId = "tipuslist", label = "Tipus accident :",
                     choices = c(""),
                     multiple = TRUE,
                     selected = "Sense selecció (tots)"
                     
                  ),
                  
                  
                  radioButtons("opt", "Map selection:",
                               c("All" = "optTot",
                                 "In polygon " = "optPoligon" ),
                               inline = TRUE),
                  
                  
                  actionButton("filter", "Aplica filtres")
                  
             ),
             
             
             
             #panel- summaries and plots 
             absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                           draggable = TRUE, bottom = 20, left = 20, right = "auto", top = "auto",
                           width = "33%", height = "auto",
                           
                           h2("Selectiom summary:"),
                           textOutput("NumAcc"),
                           textOutput("DailyMean"),
                           textOutput("HourlyMean"),
                           
                           radioButtons("optplot", "",
                                        c("Accident typology" = "optTipus",
                                          "Week day " = "optDia",
                                          "Hour " = "optHora"),
                                        inline = TRUE),
                           
                           plotOutput("plot")
                           
                           
             )  
                          
         )
      ),
      
      tabPanel("Data Grid", 
                DT::dataTableOutput("grid") 
               
      )
   
     
  )