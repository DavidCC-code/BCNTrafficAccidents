library(shiny)
library(shinyjs)
library(leaflet)
library(leaflet.extras)
library(colorRamps)
library(scales)
library(lattice)
library(dplyr)
library(sp)
library(DT)
library(ggplot2)


  ## load and tidy data

  url2020 <-  "https://opendata-ajuntament.barcelona.cat/data/dataset/834b8920-0685-4e16-8e20-faf13645f4f3/resource/86a3b39c-3cbc-4efd-977a-92ec9cb1b48a/download/2020_accidents_tipus_gu_bcn.csv"
  url2019 <- "https://opendata-ajuntament.barcelona.cat/data/dataset/834b8920-0685-4e16-8e20-faf13645f4f3/resource/4bf617c6-7fe0-4e6a-b010-1c6fef544a31/download/2019_accidents_tipus_gu_bcn_.csv"
  url2018 <- "https://opendata-ajuntament.barcelona.cat/data/dataset/834b8920-0685-4e16-8e20-faf13645f4f3/resource/1f43e605-4ace-4134-a18b-5a329bf9000c/download/2018_accidents_tipus_gu_bcn_.csv"
  
  file2020 <- "./data/2020_accidents_tipus_gu_bcn.csv"
  file2019 <- "./data/2019_accidents_tipus_gu_bcn.csv"
  file2018 <- "./data/2018_accidents_tipus_gu_bcn.csv"
 
  ACC <- data.frame()
  drawnPoly <-as.null()
  pal <- as.null()
  
  
  day_choice_list = list("Monday" = "01 - Monday",
                         "Tuesday" = "02 - Tuesday",
                         "Wednesday" = "03 - Wednesday",
                         "Thrusday" = "04 - Thursday",
                         "Fridays" = "05 - Friday",
                         "Saturday" = "06 - Saturday",
                         "Sunday" = "07 - Sunday")
  
  # Function to translates all descriptions from catalan to english
  translate <- function( DF){
    
    #translate and normalize column names that slightly change over the years
    names(DF)[names(DF)=="Codi_expedient"] <- "FileCode"
    names(DF)[names(DF)=="Codi_districte"] <- "DistrictCode"
    names(DF)[names(DF)=="Nom_districte"] <- "DistrictName"
    names(DF)[names(DF)=="Codi_barri"] <- "QuarterCode"
    names(DF)[names(DF)=="Nom_barri"] <- "QuarterName"
    names(DF)[names(DF)=="Codi_carrer"] <- "StreetCode"
    names(DF)[names(DF)=="Nom_carrer"] <- "StreetName"
    names(DF)[names(DF)=="Num_postal."] <- "PostalCode"
    names(DF)[names(DF)=="Dia_setmana"] <- "WeekDay"
    names(DF)[names(DF)=="Descripcio_dia_setmana"] <- "WeekDay"
    names(DF)[names(DF)=="Any"] <- "Year"
    names(DF)[names(DF)=="NK_Any"] <- "Year"
    names(DF)[names(DF)=="Mes_any"] <- "MonthNumber"
    names(DF)[names(DF)=="Mes"] <- "MonthNumber"
    names(DF)[names(DF)=="Nom_mes"] <- "Month"
    names(DF)[names(DF)=="Dia_de_mes"] <- "Day"
    names(DF)[names(DF)=="Dia_mes"] <- "Day"
    names(DF)[names(DF)=="Hora_de_dia"] <- "Hour"
    names(DF)[names(DF)=="Hora_dia"] <- "Hour"
    names(DF)[names(DF)=="Descripcio_tipus_accident"] <- "Typology"
    names(DF)[names(DF)=="Tipus_accident"] <- "Typology"
    names(DF)[names(DF)=="Longitud"] <- "Longitude"
    names(DF)[names(DF)=="Latitud"] <- "Latitude"

    DF[DF$Typology =="Abast",]$Typology = "Rear end" 
    DF[DF$Typology =="Abast multiple",]$Typology = "Multiple rear end" 
    DF[DF$Typology =="Altres",]$Typology = "Other"
    DF[DF$Typology =="Atropellament",]$Typology = "Run over" 
    DF[DF$Typology =="Bolcada (més de dues rodes)",]$Typology = "Rollover (more than 2 wheels vehicle)"
    DF[DF$Typology =="Caiguda (dues rodes)",]$Typology = "Fall (two wheel vehicle)"
    DF[DF$Typology =="Caiguda interior vehicle",]$Typology = "Fall (passanger in vehicle)" 
    DF[DF$Typology =="Col.lisió frontal",]$Typology =  "Frontal collision"
    DF[DF$Typology =="Col.lisió fronto-lateral",]$Typology =  "Side-frontral collision" 
    DF[DF$Typology =="Col.lisió lateral",]$Typology = "Side collision"
    DF[DF$Typology =="Desconegut",]$Typology = "Unknown"
    DF[DF$Typology =="Encalç",]$Typology =  "Rear end"            
    DF[DF$Typology =="Resta sortides de via",]$Typology = "Other off road"
    DF[DF$Typology =="Sortida de via amb bolcada",]$Typology = "Off road and rollover"
    DF[DF$Typology =="Sortida de via amb xoc o col.lisió",]$Typology = "Off road with collision"
    DF[DF$Typology =="Xoc amb animal a la calçada",]$Typology = "Collision with animal"
    DF[DF$Typology =="Xoc contra element estàtic",]$Typology =  "Collision with obstruction" 
    
    # translate and add a numeric order to avoid alphabetical order 
    DF[DF$WeekDay == "Dilluns", "WeekDay"] <- "01 - Monday"
    DF[DF$WeekDay == "Dimarts", "WeekDay"] <- "02 - Tuesday"
    DF[DF$WeekDay == "Dimecres", "WeekDay"] <- "03 - Wednesday"
    DF[DF$WeekDay == "Dijous", "WeekDay"] <- "04 - Thursday"
    DF[DF$WeekDay == "Divendres", "WeekDay"] <- "05 - Friday"
    DF[DF$WeekDay == "Dissabte", "WeekDay"] <- "06 - Saturday"
    DF[DF$WeekDay == "Diumenge","WeekDay"] <- "07 - Sunday"
 
    DF
  }
  
  
  ################################################################
  ## function for reading data depending on year selected
  ##  also does some normalization of column names 
  ##  and translates text data from catalan to english
  ################################################################
  load_data <- function (year){
    
    if (year == "2018") {
      url = url2018   
      file = file2018
      coma = ","
    } else if (year == "2019"){
      url = url2019 
      file = file2019
      coma = ","
    } else if (year == "2020"){
      url = url2020  
      file = file2020
      coma = ";"
    }   
    
    if (year != ""){

        if (!file.exists(file)){
          download.file(url,file)
        } 
       
        ACC <- read.csv(file, encoding="UTF-8", sep = coma)
   
        ACC$Longitud <- as.numeric(ACC$Longitud)
        ACC$Latitud <- as.numeric(ACC$Latitud)
        
        ACC <- translate(ACC)
    
        ACC$Typology <- as.factor(ACC$Typology) 
        ACC$Date <- as.Date(with(ACC, paste(Year, MonthNumber, Day,sep="-")), "%Y-%m-%d")
        
    
        # retrieve only  desired columns columns  
        ACC[, colnames(ACC) %in% c("FileCode", "Date","MonthNumber", "Year", "Month", "Day","WeekDay","Hour", 
                                   "Typology", "DistrictCode", "DistrictName","QuarterCode","QuarterName",
                                   "StreetCode","StreetName", "PostalCode", "Longitude","Latitude")]
    }
  }
  
  

 
  ## Function enPoli determines whether  a point is inside a poligon or not
  ##   
  ## lon : vector of longitudes
  ## lat : vector of latitudes  
  ## poligono: spatial polygon
  enPoli <- function(lon, lat, poligono){
    
     res <- vector()
     for (p in 1:length(lon)){
        x = lat[p]
        y = lon[p]
        inside <- FALSE
        
        polinumcoords = length(poligono$coords)
     
        for (ii in polinumcoords){
        
            polyPoints <- do.call("rbind",poligono$coords)
        
            i = 1
            j = polinumcoords - 1
            while( i < polinumcoords){
          
              xi <- as.numeric(polyPoints[i,2])
              yi <- as.numeric(polyPoints[i,1])
              xj <- as.numeric(polyPoints[j,2])
              yj <- as.numeric(polyPoints[j,1])
         
             intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
             if (intersect) inside = !inside
          
             j = i
             i = i + 1
          }
        }
      res <- c(res, inside)  
     }    
     
    return (res)
    
  }