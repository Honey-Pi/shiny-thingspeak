
library(shiny)
library(highcharter)

# Define UI for application
shinyUI(fluidPage(

    # Application title
    titlePanel("Shiny ThingSpeak"),

    # Sidebar with a slider input for number of results
    sidebarLayout(
        sidebarPanel(
            numericInput("channelid", "Channel-ID:", 651397, min = 1, max = 99999999),
            sliderInput("results",
                        "Number of results:",
                        min = 1,
                        max = 8000,
                        value = 50),
            textInput('GETargs',"Further GET Parameters", placeholder="&timescale=10&timezone=Europe/Berlin"),
            actionButton('sendGET','Get Channel Data'),
            HTML('<br><p>You need to set your channel to public.</p><p>Learn more about <a href="https://de.mathworks.com/help/thingspeak/readdata.html" target="_blank"/>ThingSpeak API</a>.</p><p><i>non-commercial use only.</i> &copy; <a href="https://javan.de" target="_blank">javan.de</a> 2020</p>')
        ),

        # Show a plot of the generated distribution
        mainPanel(
            #verbatimTextOutput('GETresponse'),
            highchartOutput("highchartPlot", height = 600),
            dataTableOutput("table")
        )
    )
))
