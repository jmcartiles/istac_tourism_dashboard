




# load packages
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinythemes))
suppressPackageStartupMessages(library(istacbaser))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(xts))
suppressPackageStartupMessages(library(dygraphs))
suppressPackageStartupMessages(library(DT))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(shinyjs))
suppressPackageStartupMessages(library(leaflet))
suppressPackageStartupMessages(library(rgdal))
suppressPackageStartupMessages(library(rgeos))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(billboarder))
suppressPackageStartupMessages(library(sunburstR))






# datasets
load(file = "data/egt_gasto_2528.RData")
load(file = "data/egt_gasto_2529.RData")
load(file = "data/egt_gasto_2530.RData")
load(file = "data/egt_perfil_2597.RData")
load(file = "data/egt_perfil_2587.RData")
load(file = "data/egt_perfil_2588.RData")
load(file = "data/egt_perfil_2589.RData")
load(file = "data/egt_motivo_2646.RData")
load(file = "data/egt_motivo_2609.RData")
load(file = "data/egt_motivo_2610.RData")




# elements
source("description_elements.R", encoding = "utf-8")
source("authors_elements.R", encoding = "utf-8")
source("ui_expenditure_elements.R", encoding = "utf-8")
source("ui_profile_elements.R", encoding = "utf-8")
source("ui_travelcharacteristics_elements.R", encoding = "utf-8")
source("server_functions.R", encoding = "utf-8")




# load map
islas<-readOGR(dsn="data/islas_shp/islas_suav.shp", encodin = "UTF-8")

islas<-spTransform(islas, CRS("+init=epsg:4326"))
bounds<-bbox(islas)




# user interface
ui <- fluidPage(
  titlePanel("", windowTitle = "Canary Islands Tourism Dashboard"),
  useShinyjs(),
  theme = shinytheme(theme = "flatly"),
  navbarPage(tagList(a("ISTAC",
                       href="http://www.gobiernodecanarias.org/istac/"),
                     " || ",
                     a("Turismo",
                       href="http://www.gobiernodecanarias.org/istac/temas_estadisticos/sectorservicios/hosteleriayturismo/")),
             
             tabPanel("Descripción",
                      description.mainpanel),
             
             navbarMenu("Gasto turístico",
                        tabPanel(icon = icon("line-chart"),"01. Gasto turístico total en Canarias según países de residencia",
                                 sidebarLayout(
                                   gasto.sidebarpanel.2528,
                                   gasto.mainpanel.2528)),
                        tabPanel(icon = icon("line-chart"),"02. Gasto turístico total en Canarias según NUTS1 de residencia",
                                 sidebarLayout(
                                   gasto.sidebarpanel.2529,
                                   gasto.mainpanel.2529)),
                        tabPanel(icon = icon("line-chart"),"03. Gasto turístico total por islas según países de residencia",
                                 sidebarLayout(
                                   gasto01.sidebarpanel,
                                   gasto01.mainpanel)),
                         tabPanel(icon = icon("globe"), "04. Mapa gasto turístico total por islas según países de residencia",
                                  sidebarLayout(
                                    gasto02.sidebarpanel,
                                    gasto02.mainpanel)),
                        tabPanel(icon = icon("chart-pie"), "05. Reparto del gasto turístico por islas y países de residencia",
                                 sidebarLayout(
                                   gasto03.sidebarpanel,
                                   gasto03.mainpanel))
                        ),
             
             navbarMenu("Perfil del turista",
             tabPanel(icon = icon("address-card"),"01. Turistas por islas según grupos de edad, sexos y países de residencia",
                      sidebarLayout(
                        perfil01.sidebarpanel,
                        perfil01.mainpanel)),
             tabPanel(icon = icon("address-card"),"02. Turistas según sexos por NUTS1 de residencia",
                      sidebarLayout(
                        perfil.sidebarpanel.2587,
                        perfil.mainpanel.2587)),
             tabPanel(icon = icon("address-card"),"03. Turistas según grupos de edad por NUTS1 de residencia",
                      sidebarLayout(
                        perfil.sidebarpanel.2588,
                        perfil.mainpanel.2588)),
             tabPanel(icon = icon("address-card"),"04. Turistas según grupos de edad y sexos por tipos de alojamiento",
                      sidebarLayout(
                        perfil.sidebarpanel.2589,
                        perfil.mainpanel.2589))
             ),
             
             navbarMenu("Características del viaje",
             tabPanel(icon = icon("coffee"),"01. Turistas por islas según países de residencia y motivos de la estancia",
                      sidebarLayout(
                        caractviaje01.sidebarpanel,
                        caractviaje01.mainpanel
                        )),
             tabPanel(icon = icon("coffee"),"02. Turistas según aspectos en la elección de Canarias como destino turístico por tipos de alojamiento",
                      sidebarLayout(
                        caractviaje.sidebarpanel.2609,
                        caractviaje.mainpanel.2609
                        )),
             tabPanel(icon = icon("coffee"),"03. Turistas según formas de conocer Canarias como destino turístico por países de residencia",
                      sidebarLayout(
                        caractviaje.sidebarpanel.2610,
                        caractviaje.mainpanel.2610))
             ),
             
             tabPanel("Autores",
                      authors.mainpanel
                      )
             
             )
)




# server application
server <- function(input, output) {
  

  
  # show/hide sidebar panel
  observeEvent(input$showSidebar, {
    shinyjs::show(id = "Sidebar")
  })
  observeEvent(input$hideSidebar, {
    shinyjs::hide(id = "Sidebar")
  })
  
  ## input dataframes
  # expenditure
  df.input.2528 <- reactive({
    data2528 <- df.gasto.2528 %>%
      filter(indicadoresgasto == input$indgasto2528,
             paisesresidencia %in% input$residencia2528,
             indicadores == input$indicador2528,
             periodicidad == input$period2528)
    return(data2528)
  })
  
  df.input.2529 <- reactive({
    data2529 <- df.gasto.2529 %>%
      filter(indicadoresgasto == input$indgasto2529,
             NUTS1 %in% input$nuts12529,
             indicadores == input$indicador2529,
             periodicidad == input$period2529)
    return(data2529)
  })
  
  df.input.1 <- reactive({
    data1 <- b1.gasto %>%
      filter(indicadoresgasto == input$indgasto1,
             paisesresidencia %in% input$residencia1,
             indicadores == input$indicador1,
             periodicidad == input$period1,
             islas %in% input$isla1)
    return(data1)
  })
  
  df.input.13 <- reactive({
    data3 <- b1.gasto %>%
      filter(indicadoresgasto != "Gasto total",
             paisesresidencia != "TOTAL PAÍSES",
             islas != "CANARIAS",
             indicadores == "Valor absoluto",
             periodicidad == input$period3,
             periodos == input$periods3) %>%
      mutate(V1 = paste(indicadoresgasto, paisesresidencia, islas, sep = "-"),
             V2 = valor) %>%
      select(V1, V2)
    return(data3)
  })
  
  # profile
  df.input.2 <- reactive({
    data2 <- b2.perfil %>%
      filter(edades == input$edad2,
             paisesresidencia %in% input$residencia2,
             sexos == input$sexo2,
             periodicidad == input$period2,
             islas == input$isla2)
    return(data2)
  })
  
  df.input.2587 <- reactive({
    data2587 <- df.perfil.2587 %>%
      filter(NUTS1 %in% input$nuts12587,
             Sexos == input$sexo2587,
             periodicidad == input$period2587)
    return(data2587)
  })
  
  df.input.2588 <- reactive({
    data2588 <- df.perfil.2588 %>%
      filter(NUTS1 %in% input$nuts12588,
             Edades == input$edad2588,
             periodicidad == input$period2588)
    return(data2588)
  })
  
  df.input.2589 <- reactive({
    data2589 <- df.perfil.2589 %>%
      filter(`Tipos de alojamiento` %in% input$alojamiento2589,
             Sexos == input$sexo2589,
             Edades == input$edad2589,
             periodicidad == input$period2589)
    return(data2589)
  })
   
  # travel characteristics
   df.input.3 <- reactive({
     data3 <- b3.motivos %>%
       filter(paisesresidencia %in% input$residencia3,
              motivos == input$motivo3,
              periodicidad == input$period3,
              islas == input$isla3)
     return(data3)
   })
   df.input.2609 <- reactive({
     data2609 <- df.motivo.2609 %>%
       select(-c(fecha, periodicidad)) %>%
       filter(Periodos %in% input$period2609) %>% 
       rename(aspectos = "Aspectos en la elección de Canarias") %>%
       filter(aspectos %in% input$aspeleccion2609) %>% 
       select(-Periodos) %>%
       reshape(idvar = "aspectos", timevar = "Tipos de alojamiento", direction = "wide") # %>%

     names(data2609) <- gsub("valor.", "", names(data2609))
     data2609 <- data2609[, -grep("TOTAL ALOJAMIENTOS", names(data2609))]
     data2609$Periodo <- input$period2609
     return(data2609)
   })
   df.input.2610 <- reactive({
     data2610 <- df.motivo.2610 %>%
       select(-c(fecha, periodicidad)) %>%
       filter(Periodos %in% input$period2610) %>% 
       rename(residencia = "Países de residencia") %>%
       filter(residencia %in% input$residencia2610) %>% 
       select(-Periodos) %>%
       reshape(idvar = "residencia", timevar = "Formas de conocer Canarias", direction = "wide") # %>%
     
     names(data2610) <- gsub("valor.", "", names(data2610))
     # data2610 <- data2610[, -grep("TOTAL PAÍSES", names(data2610))]
     data2610$Periodo <- input$period2610
     return(data2610)
   })
   # 
   # data2609 <- df.motivo.2609 %>%
   #   select(-c(fecha, periodicidad)) %>%
   #   filter(Periodos %in% "2017") %>% 
   #   filter(`Aspectos en la elección de Canarias` %in% "Clima o sol") %>% 
   #   select(-Periodos) %>%
   #   reshape(idvar = "Tipos de alojamiento", timevar = "Aspectos en la elección de Canarias", direction = "wide") %>%
   #   mutate(totrow = rowSums(.[,2:dim(.)[2]])) %>%
   #   mutate_if(is.numeric, funs(./totrow)) %>%
   #   select(-totrow)
   
   
   # table using input dataframes
   
   # expenditure
   output$df2528 <- DT::renderDataTable({
     df.input.2528() %>% setNames(c("Indicadores de gasto","Países de residencia","Indicadores","Periodos","Valor","Fecha","Periodicidad"))
   })

   output$df2529 <- DT::renderDataTable({
     df.input.2529() %>% setNames(c("Indicadores de gasto","NUTS1","Indicadores","Periodos","Valor","Fecha","Periodicidad"))
   })

   output$df1 <- DT::renderDataTable({
     df.input.1() %>% setNames(c("Indicadores de gasto","Países de residencia","Islas","Indicadores","Periodos","Valor","Fecha","Periodicidad"))
   })

   # profile
   output$df2 <- DT::renderDataTable({
     df.input.2() %>% setNames(c("Edades","Sexos","Países de residencia","Islas","Periodos","Valor","Fecha","Periodicidad"))
   })
   
   output$df2587 <- DT::renderDataTable({
     df.input.2587()
   })
   
   output$df2588 <- DT::renderDataTable({
     df.input.2588()
   })
   
   output$df2589 <- DT::renderDataTable({
     df.input.2589()
   })

   # travel characteristics
   output$df3 <- DT::renderDataTable({
     df.input.3() %>% setNames(c("Motivos","Países de residencia","Islas","Periodos","Valor","Fecha","Periodicidad"))
   })
   output$df2609 <- DT::renderDataTable({
     df.input.2609()
   })
   output$df2610 <- DT::renderDataTable({
     df.input.2610()
   })
   
   
   ## graphs using input dataframes
   
   # expenditure
   output$dygraph2528 <- renderDygraph({
     data2528 <- df.input.2528()[,c("paisesresidencia", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "paisesresidencia", direction = "wide")
     colnames(data2528) <- gsub("valor.", "", colnames(data2528))
     
     # change in axis labels when data is in %
     if (any(grepl("Variación", df.input.2528()$indicadores) == TRUE)) {
       is.variation.2528 <- TRUE
     } else {
       is.variation.2528 <- FALSE
     }
     
     custom_dygraph(data2528, euros = TRUE, is.variation = is.variation.2528)
     
   })
   
   output$dygraph2529 <- renderDygraph({
     data2529 <- df.input.2529()[,c("NUTS1", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "NUTS1", direction = "wide")
     colnames(data2529) <- gsub("valor.", "", colnames(data2529))
     
     # change in axis labels when data is in %
     if (any(grepl("Variación", df.input.2529()$indicadores) == TRUE)) {
       is.variation.2529 <- TRUE
     } else {
       is.variation.2529 <- FALSE
     }
     
     custom_dygraph(data2529, euros = TRUE, is.variation = is.variation.2529)
     
   })
   
   output$df1graph <- renderDygraph({
     data1 <- df.input.1()[,c("paisesresidencia", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "paisesresidencia", direction = "wide")
     colnames(data1) <- gsub("valor.", "", colnames(data1))
     
       # nums <- unlist(lapply(data1, is.numeric))
       # min.value <- min(data1[,nums]) - 10
       # max.value <- max(data1[,nums]) + 10
       # per.axis.range.1 <- c(min.value, max.value)
     
     # change in axis labels when data is in %
     if (any(grepl("Variación", df.input.1()$indicadores) == TRUE)) {
       is.variation.1 <- TRUE
     } else {
       is.variation.1 <- FALSE
     }
     
     custom_dygraph(data1, euros = TRUE, is.variation = is.variation.1)
     
   })
   
   output$df13graph <- renderSunburst({
     sunburst(df.input.13(), legend = FALSE)
   })
   
   # profile
   output$dygraph2587 <- renderDygraph({
     data2587 <- df.input.2587()[,c("NUTS1", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "NUTS1", direction = "wide")
     colnames(data2587) <- gsub("valor.", "", colnames(data2587))
     
     custom_dygraph(data2587, euros = FALSE, is.mill = FALSE)
   })
   
   output$dygraph2588 <- renderDygraph({
     data2588 <- df.input.2588()[,c("NUTS1", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "NUTS1", direction = "wide")
     colnames(data2588) <- gsub("valor.", "", colnames(data2588))
     
     custom_dygraph(data2588, euros = FALSE, is.mill = FALSE)
   })
   
   output$df2graph <- renderDygraph({
     data2 <- df.input.2()[,c("paisesresidencia", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "paisesresidencia", direction = "wide")
     colnames(data2) <- gsub("valor.", "", colnames(data2))
     
     custom_dygraph(data2, euros = FALSE)
     
   })
   
   output$dygraph2589 <- renderDygraph({
     data2589 <- df.input.2589()[,c("Tipos de alojamiento", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "Tipos de alojamiento", direction = "wide")
     colnames(data2589) <- gsub("valor.", "", colnames(data2589))
     
     custom_dygraph(data2589, euros = FALSE, is.mill = FALSE)
     
   })
   
   # travel characteristics
   output$df3graph <- renderDygraph({
     data3 <- df.input.3()[,c("paisesresidencia", "fecha", "valor")] %>%
       reshape(., idvar = "fecha", timevar = "paisesresidencia", direction = "wide")
     colnames(data3) <- gsub("valor.", "", colnames(data3))
     
     custom_dygraph(data3, euros = FALSE)
     
   })
   
   output$billboarderbar2609 <- renderBillboarder(
     # dodge bar chart !
     billboarder() %>%
       bb_barchart(
         data = df.input.2609() %>%
           select(-Periodo) %>%
           mutate(totrow = rowSums(.[,2:dim(.)[2]])) %>%
           mutate_if(is.numeric, funs(./totrow)) %>%
           select(-totrow) %>%
           mutate_if(is.numeric, funs(round(.*100,2)))
       ) %>%
       bb_data(
         names = names(df.input.2609())[2:dim(df.input.2609())[2]]
       ) %>% 
       bb_y_grid(show = TRUE) %>%
       bb_y_axis(tick = list(format = suffix("%")),
                 label = list(text = "", position = "outer-top")) %>% 
       # bb_legend(position = "inset", inset = list(anchor = "bottom-center")) %>% 
       bb_labs(title = "",
               caption = "")
     
   )
   
   output$billboarderbar2610 <- renderBillboarder(
     # dodge bar chart !
     billboarder() %>%
       bb_barchart(
         data = df.input.2610() %>%
           select(-Periodo) %>%
           mutate(totrow = rowSums(.[,2:dim(.)[2]])) %>%
           mutate_if(is.numeric, funs(./totrow)) %>%
           select(-totrow) %>%
           mutate_if(is.numeric, funs(round(.*100,2)))
       ) %>%
       bb_data(
         names = names(df.input.2610())[2:dim(df.input.2610())[2]]
       ) %>% 
       bb_y_grid(show = TRUE) %>%
       bb_y_axis(tick = list(format = suffix("%")),
                 label = list(text = "", position = "outer-top")) %>% 
       # bb_legend(position = "inset", inset = list(anchor = "bottom-center")) %>% 
       bb_labs(title = "",
               caption = "")
     
   )
   
   
   # download input dataframes
   
   # expenditure
   output$download2528 <- button_download_csv(df.input.2528())
   output$download2529 <- button_download_csv(df.input.2529())
   output$download1 <- button_download_csv(df.input.1())

   # profile
   output$download2 <- button_download_csv(df.input.2())
   output$download2587 <- button_download_csv(df.input.2587())
   output$download2588 <- button_download_csv(df.input.2588())
   output$download2589 <- button_download_csv(df.input.2589())
   
   # travel characteristics
   output$download3 <- button_download_csv(df.input.3())
   output$download2609 <- button_download_csv(df.input.2609())
   output$download2610 <- button_download_csv(df.input.2610())
   
   
   # map

     
     getDataSet<-reactive({
       
       # Get a subset of the income data which is contingent on the input variables
       dataSet<- b1.gasto %>%
         filter(indicadoresgasto == input$indgastom,
                paisesresidencia %in% input$residenciam,
                indicadores == input$indicadorm,
                year(fecha) == input$anyom,
                periodicidad == "Anual",
                islas != "CANARIAS") %>%
         mutate(mislas = tolower(islas))
       # Copy our GIS data
       islas@data<- islas@data %>%
         mutate(mislas = tolower(isla))
       
       joinedDataset <- islas
       
       # Join the two datasets together
       joinedDataset@data <- suppressWarnings(left_join(joinedDataset@data, dataSet, by="mislas"))
       #joinedDataset@data <- suppressWarnings(sp::merge(joinedDataset@data, dataSet, by="mislas",all.x = TRUE))
       
       joinedDataset
     })
     
     # Due to use of leafletProxy below, this should only be called once
     output$islasMap<-renderLeaflet({
       
     
       leaflet() %>%
         addProviderTiles(providers$CartoDB.Positron,
                          options = providerTileOptions(noWrap = TRUE)
         ) %>%
         
         # Centre the map in the middle of our co-ordinates
         setView(mean(bounds[1,]),
                 mean(bounds[2,]),
                 zoom=7 # set to 10 as 9 is a bit too zoomed out
         ) 
       
  
       
     })
     
     
     
     observe({
       theData<-getDataSet()
       
       # colour palette mapped to data
       pal <- colorQuantile("YlGn", theData$valor, n = 9)
       
       # set text for the clickable popup labels
       islas_popup <- paste0("<strong>Isla: </strong>",
                             str_to_title(theData@data$mislas),
                             "<br><strong>",
                             input$indgastom,
                             ": </strong>",
                             ifelse(is.na(theData$valor),"No disponible",formatC(theData$valor, format="f", big.mark=',', digits = ifelse(input$indicadorm == "Valor absoluto", 0, 2))),
                             ifelse(is.na(theData$valor),"",ifelse(input$indicadorm == "Valor absoluto", " €", "%"))
       )
       
       # If the data changes, the polygons are cleared and redrawn, however, the map (above) is not redrawn
       leafletProxy("islasMap", data = theData) %>%
         clearShapes() %>%
         addPolygons(data = theData,
                     fillColor = pal(theData$valor),
                     fillOpacity = 0.8,
                     color = "#BDBDC3",
                     weight = 2,
                     popup = islas_popup)
       
     })

    }
# 
 # run application 
shinyApp(ui = ui, server = server)
# 
# 
