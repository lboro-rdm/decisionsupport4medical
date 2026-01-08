library(shiny)
library(ggplot2)
library(tidyverse)


# Baseline data (Single-Use)
single_use_baseline <- list(
  cost_per_patient = 285.19,
  device_cost = 379579.50,
  waste_device = 637.79,
  waste_plastic = 194.07,
  decon_cost = 0,
  patients = 1357
)

server <- function(input, output, session) {
  
  model_data <- eventReactive(input$recalc, {
    
    # Single-use costs
    su_total_cost <- single_use_baseline$cost_per_patient * input$patients
    
    # Hybrid calculations
    hybrid_devices_needed <- ceiling(input$patients / input$cycles)
    hybrid_procurement <- hybrid_devices_needed * input$unit_cost
    hybrid_decon_total <- input$patients * input$decon_cost
    
    hybrid_total_cost <- hybrid_procurement +
      hybrid_decon_total +
      12000  # fixed staffing/overhead
    
    data.frame(
      Option = c("Single-Use", "Hybrid"),
      Total_Cost = c(su_total_cost, hybrid_total_cost),
      Device_Waste = c(input$patients, hybrid_devices_needed),
      Plastic_Waste = c(single_use_baseline$waste_plastic, 510)
    )
  }, ignoreInit = TRUE)
  
  
  output$costPlot <- renderPlot({
    ggplot(model_data(), aes(x = Option, y = Total_Cost, fill = Option)) +
      geom_bar(stat = "identity", width = 0.6) +
      theme_minimal() +
      labs(
        title = "Total Lifecycle Cost Comparison",
        y = "Total Cost (£)",
        x = ""
      ) +
      scale_y_continuous(
        labels = scales::label_number(big.mark = ",", prefix = "£")
      ) +
      scale_fill_manual(
        values = c("Single-Use" = "#e74c3c", "Hybrid" = "#2ecc71")
      )
  })
  
  output$wastePlot <- renderPlot({
    waste_long <- model_data() %>%
      pivot_longer(
        cols = c(Device_Waste, Plastic_Waste),
        names_to = "Waste_Type",
        values_to = "Units"
      )
    
    ggplot(waste_long, aes(x = Option, y = Units, fill = Waste_Type)) +
      geom_bar(stat = "identity", position = "dodge") +
      theme_minimal() +
      labs(
        title = "Environmental Impact (Units of Waste)",
        y = "Total Units",
        x = ""
      ) +
      scale_fill_brewer(palette = "Set2")
  })
  
  output$costTable <- renderTable({
    res <- model_data()
    res$Cost_Per_Patient <- res$Total_Cost / input$patients
    
    colnames(res) <- c(
      "Strategy",
      "Total Cost (£)",
      "Device Waste (Units)",
      "Plastic Waste (Units)",
      "Cost per Patient (£)"
    )
    
    res
  })
}
