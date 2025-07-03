library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(DT)
library(leaflet)
library(leaflet.extras)
library(sf)
library(geojsonsf)

# Load helper functions
source("~/DeInNO/ssb_api_helpers.R")

# Load initial data
income_data <- get_income_data()
# income_data$region <- gsub(" \\(2020-2023\\)", "", as.character(income_data$region))

kommune_geo <- read_sf("~/DeInNO/kommuner2021.json")
kommune_map <- kommune_geo |>
  left_join(income_data |>
              group_by(Region) |>
              rename("bracket_under_150K" = "Inntekt1",
                     "bracket_150_249K" = "Inntekt2",
                     "bracket_250_349K" = "Inntekt3",
                     "bracket_350_449K" = "Inntekt4",
                     "bracket_450_549K" = "Inntekt5",
                     "bracket_550_749K" = "Inntekt6",
                     "bracket_over_750K" = "Inntekt7",
                     "År" = "Tid"),
            by = c("Kommunenummer" = "Region"))
kommune_map <- st_transform(kommune_map, crs = 4326)

income_data <- income_data |>
  left_join(kommune_geo |>
              select(Kommunenummer, Kommunenavn),
            by = c("Region" = "Kommunenummer")) |>
  select(Kommunenavn, År = Tid, "Antall husholdninger" = Hushold, 
         "Samlet inntekt under 150K" = "Inntekt1",
         "Samlet inntekt 150-249K" = "Inntekt2",
         "Samlet inntekt 250-349K" = "Inntekt3",
         "Samlet inntekt 350-449K" = "Inntekt4",
         "Samlet inntekt 450-549K" = "Inntekt5",
         "Samlet inntekt 550-749K" = "Inntekt6",
         "Samlet inntekt over 750K" = "Inntekt7")

