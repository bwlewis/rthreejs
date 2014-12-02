library("shiny")
library("threejs")

shinyUI(fluidPage(
  
  titlePanel("Three.js Globe"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("N", "Number of largest population cities to plot", value=1000, min = 100, max = 10000, step = 100),
      sliderInput("multiplier", "Height multiplier", value=100, min = 1, max = 200, step = 20)
    ),
    mainPanel(
      globeOutput("globe")
    )
  )
))
