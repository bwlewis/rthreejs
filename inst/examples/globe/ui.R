library("shiny")
library("threejs")

shinyUI(fluidPage(
  titlePanel("Relative population of world cities from the R maps package"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("N", "Number of cities to plot", value=5000, min = 100, max = 10000, step = 100),
      hr(),
      p("Use the mouse zoom to zoom in/out."),
      p("Click and drag to rotate.")
    ),
    mainPanel(
      globeOutput("globe")
    )
  )
))
