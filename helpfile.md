---
title: "Traffic Accidents Explorer Help"
author: "David Contreras Carretero"
date: "8/4/2021"
output: html_document
---
# Barcelona's traffic accidents explorer

This applications allow the user to explore Barcelona's traffic accidents as reported by local police and published by citys's hall in its open data service. ( https://opendata-ajuntament.barcelona.cat/ca)<br>
The data belongs to the datase "Accidents gestionats per la Guàrdia Ubana a la ciutat de Barcelona segons tipologia" - Tràffic accidents managed by *Guàrdia Urbana* (local police denomination) by typology. 

Data files contain all descriptions in catalan and have been translated to English by the author. Two tipologies "Abast" and "Encalç" has been translated as "Rear end", because both are a collision by means of rear vehicle reaching the back of front vehicle.*

## Choose year to explore and display data
First you must select which year to explore (2018,2019 or 2020). You need to select one year from the list and click the load button. If file has not been downloaded previously it is downloaded from: <br> https://opendata-ajuntament.barcelona.cat/data/ca/dataset/accidents-tipus-gu-bcn

Once data file is downloaded and loaded into the application beginning and end date selectors are initialized to first and last day of the year. 

## Filter data to display on the map
You can select what data to be displayed using parameters:
- Benining and end date, to explore a specific period within the selected year.
- Days of the wee, you can select to explorer only certain days of the week.
- Data in polygon, select all or in polygon to explore all data or only those contained in the drawn polygon (see explore data in polygon section)
- Accident typology, accident class according to *Guàrdia Urbana de Barcelona* classification. 

Once set the desired parameters click button apply filters to see the results displayed on map and the summary panel updated. If you are not sure if your display has been updated click apply filters button.

## Summary panel 
This panel displays the total number of accidents selected, the daily mean and three possible plots:

- A distribution of the accidents by typology in a bar plot.
- A distribution of accidents by day of the week.
- And a distribution by the hour when the accident happened according to local police.

## Explore data in polygon
Once the map its been populated with data a drawing tool bar is displayed, it allows you to draw a polygon on the map. Just click the polygon icon button and start clicking on the map.<br>
Use the edit button to modify your polygon and the trash bin button to delete your polygon. 
You will be able to draw only one polygon at a time. 

## Data Grid
Data grid tab will display always the same data selected in the interactive map tab.

*_To try to most accurately translate all typologies the following references have been veery helpfull:_
   _"ROAD ACCIDENT INVESTIGATION GUIDELINES FOR ROAD ENGINEERS" https://www.who.int/roadsafety/news/piarc_manual.pdf_
   _https://reconstruccionaccidentestrafico.com/ca/tipus-de-col%c2%b7lisio-entre-vehicles-en-accidents-de-transit/_