library(shiny)

fluidPage(
  titlePanel("Decision Support: Single-Use vs. Hybrid Medical Devices"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Adjust parameters to see the impact on costs and waste."),
      
      sliderInput(
        "patients",
        "Total Number of Patients:",
        min = 500,
        max = 3000,
        value = 1400
      ),
      
      sliderInput(
        "cycles",
        "Max Reuse Cycles (Hybrid):",
        min = 1,
        max = 250,
        value = 200
      ),
      
      numericInput(
        "unit_cost",
        "Cost per Hybrid Device (£):",
        value = 500,
        min = 100
      ),
      
      numericInput(
        "decon_cost",
        "Decontamination Cost per Use (£):",
        value = 10,
        min = 0
      ),
      
      hr(),
      actionButton("recalc", "Update Model")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Financial Comparison",
          plotOutput("costPlot"),
          tableOutput("costTable")
        ),
        
        tabPanel(
          "Environmental Impact",
          plotOutput("wastePlot"),
          p(
            "Note: Hybrid models significantly reduce device mass waste ",
            "but increase plastic packaging waste due to sterilization requirements."
          )
        )
      )
    )
  )
)
