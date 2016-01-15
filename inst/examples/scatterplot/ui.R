library("shiny")
library("threejs")

shinyUI(fluidPage(

  titlePanel("Shiny three.js scatterplot example"),

  sidebarLayout(
    sidebarPanel(
      numericInput("nticks", "Number of ticks", 6, min = 0, max = 10, step = 1),
      numericInput("colors", "Number of colors", 5, min = 1, max = 8, step = 1),
      numericInput("sizes", "Number of sizes (only affects canvas renderings)", 2, min = 1, max = 3, step = 1),
      selectInput("renderer", label="Rendering method",
         choices = list("Auto"="auto", "Canvas"="canvas", "WebGL"="webgl"),
         selected = 1),
      checkboxInput("grid", label = "Grid", value = TRUE),
      p("Use the mouse zoom to zoom in/out.")
    ),
    mainPanel(
        scatterplotThreeOutput("scatterplot")
    )
  )
))
