
library(shiny)
require(httr)
library(dplyr)
library(tidyr)

# Highchart
library(highcharter)
library(xts)
library(lubridate)

# Define server logic required to draw
shinyServer(function(input, output) {
    
    observeEvent(input$sendGET, {
        
        # params
        getargs <- input$GETargs
        if( is.null(input$GETargs) ) getargs <- ""
        url <- sprintf("https://api.thingspeak.com/channels/%d/feeds.json?results=%d", input$channelid,  input$results)
    
        # do the request to thingspeak
        res <- GET(sprintf("%s%s",url, getargs), timeout(15))
        
        # print get response
        output$GETresponse <- renderPrint(content(res))
        
        # setup dataframe format
        char <- rawToChar(res$content)
        df_origin <- jsonlite::fromJSON(char)
        df <- as.data.frame(df_origin$feeds)
        channel <- as.data.frame(df_origin$channel)
        field1_title <- channel$field1
        field2_title <- channel$field2
        field3_title <- channel$field3
        field4_title <- channel$field4
        field5_title <- channel$field5
        field6_title <- channel$field6
        field7_title <- channel$field7
        field8_title <- channel$field8
        df$datetime <- ymd_hms(df$created_at, tz="UTC")
        df$entry_id <- NULL
        df$created_at <- NULL
        # convert dataframe to ts
        df <- xts(df, order.by = df$datetime)
        df$datetime <- NULL
        storage.mode(df) <- "numeric"
        
        # display table
        output$table <- renderDataTable(df)

        # display highchart plot
        output$highchartPlot <- renderHighchart({

            # draw chart
            hc <- highchart(type = "stock") %>%
                hc_chart(animation = TRUE) %>%
                hc_xAxis(
                    type = "datetime",
                    labels = list(rotation = 45)
                ) %>%
                hc_yAxis_multiples(
                    list(
                        title = list(text = "fields 1 to 4"),
                        showFirstLabel = TRUE,
                        showLastLabel = TRUE,
                        opposite = TRUE,
                        reversed = FALSE
                    ),
                    list(
                        title = list(text = "fields 5 to 8"),
                        showFirstLabel = TRUE,
                        showLastLabel = TRUE,
                        opposite = FALSE,
                        reversed = FALSE
                    )
                ) %>%
                # add series for Axis 0
                hc_add_series(data = df$field1, yAxis = 0, name = paste0(field1_title), type = "line") %>%
                hc_add_series(data = df$field2, yAxis = 0, name = paste0(field2_title), type = "line") %>%
                hc_add_series(data = df$field3, yAxis = 0, name = paste0(field3_title), type = "line") %>%
                hc_add_series(data = df$field4, yAxis = 0, name = paste0(field4_title), type = "line") %>%
                # add series for Axis 1
                hc_add_series(data = df$field5, yAxis = 1, name = paste0(field5_title), type = "line") %>%
                hc_add_series(data = df$field6, yAxis = 1, name = paste0(field6_title), type = "line") %>%
                hc_add_series(data = df$field7, yAxis = 1, name = paste0(field7_title), type = "line") %>%
                hc_add_series(data = df$field8, yAxis = 1, name = paste0(field8_title), type = "line")
            # add theme
            hc <- hc %>% hc_add_theme(hc_theme_google())
            # add plot options
            hc <- hc %>% hc_plotOptions(series = list(
                compare = "series",
                showInNavigator = TRUE
            ))
            # set rangeSelector
            hc <- hc %>% hc_rangeSelector(
                verticalAlign = "bottom",
                # select week by default
                selected = 2, 
                buttons = list(
                    list(type = "hour", count = 12, text = "12h"),
                    list(type = "hour", count = 23, text = "1d"),
                    list(type = "day", count = 7, text = "7d"),
                    list(type = "day", count = 14, text = "14d"),
                    list(type = "day", count = 30, text = "1m"),
                    list(type = "all", text = "All")
                )
            )
            # set tooltip
            hc <- hc %>% hc_tooltip(
                pointFormat = '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b><br/>', # ({point.change}%)
                valueDecimals = 2,
                split = TRUE,
                crosshairs = TRUE
            )

            # return
            hc
        })
        
    })

})
