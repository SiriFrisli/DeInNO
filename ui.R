library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(plotly)
library(leaflet)
library(PxWebApiData)


ui <- dashboardPage(
  dashboardHeader(title = "Exploring Regional Development and Inequality in Norway"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("globe")),
      menuItem("Explore by Region", tabName = "regions", icon = icon("map")),
      menuItem("Trends Over Time", tabName = "trends", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    tabItems(tabItem(tabName = "overview",
                     h2("Household income Distribution Overview"),
                     
                     fluidRow(box(width = 4,
                           pickerInput("selected_regions",
                                       "Choose municipalities:",
                                       choices = sort(unique(income_data$Kommunenavn)),
                                       options = list(`actions-box` = TRUE),
                                       multiple = TRUE)),
                           box(width = 4,
                               pickerInput("selected_year",
                                       "Select year:",
                                       choices = sort(unique(income_data$År), decreasing = TRUE),
                                       options = list(`actions-box` = TRUE),
                                       multiple = TRUE))),
              dataTableOutput("overview_table")),
             
             tabItem(tabName = "regions",
                     h2("Explore by Region"),
                     fluidRow(box(width = 12,
                                  leafletOutput("norway_map", height = 600))),
                     fluidRow(box(width = 12,
                                  h4("Household income distribution in selected municipality:"),
                                  plotlyOutput("region_income_plot", height = 350)))),
      tabItem(tabName = "trends",
              h2("Trends Over Time"),
              plotlyOutput("trendPlot")
              )
    )
  )
)
