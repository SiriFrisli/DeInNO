server <- function(input, output, session) {
  output$overview_table <- renderDataTable({
    req(input$selected_regions, input$selected_year)
    
    filtered <- income_data |>
      filter(Kommunenavn %in% input$selected_regions,
             År %in% input$selected_year) |>
      arrange(Kommunenavn)
    
    datatable(
      filtered,
      rownames = FALSE,
      extensions = 'Buttons',
      options = list(
        pageLength = 25,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        autoWidth = TRUE
      )
    )
  })
  selected_region <- reactiveVal(NULL)
  observeEvent(input$norway_map_shape_click, {
    selected_region(input$norway_map_shape_click$id)
  })
  output$norway_map <- renderLeaflet({
    leaflet(kommune_map) |>
      addProviderTiles("CartoDB.Positron") |>
      addPolygons(
        color = "#444444",
        weight = 1,
        fillOpacity = 0.2,
        layerId = ~Kommunenummer,
        label = ~Kommunenavn,
        highlightOptions = highlightOptions(
          weight = 2,
          color = "black",
          bringToFront = TRUE
        )
      ) |>
      leaflet.extras::addSearchOSM()
  })
  output$region_income_plot <- renderPlotly({
    req(selected_region())
    
    region_row <- kommune_map |>
      filter(Kommunenummer == selected_region())
    
    plot_data <- region_row |>
      st_drop_geometry() |>
      pivot_longer(cols = starts_with("bracket_"),
                   names_to = "bracket",
                   values_to = "percent") |>
      mutate(bracket = str_replace_all(bracket, "bracket_", ""),
             bracket = str_replace_all(bracket, "_", "–"))
    
    correct_order <- unique(plot_data$bracket)
    plot_data <- plot_data |>
      mutate(bracket = factor(bracket, levels = correct_order))
    
    plot_ly(plot_data,
            x = ~bracket,
            y = ~percent,
            color = ~År,
            type = "bar") |>
      layout(title = paste("Income Distribution in", region_row$Kommunenavn[1]),
             xaxis = list(title = "Income Bracket"),
             yaxis = list(title = "Percent of Households", ticksuffix = "%"))
  })
}

shinyApp(ui, server)

