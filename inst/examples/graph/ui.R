library("shiny")
library("threejs")

data("LeMis")

shinyUI(fluidPage(

  titlePanel("Shiny three.js graph example"),

  sidebarLayout(
    sidebarPanel(
      selectInput("select", label = h3("Vertex shape"),
                  choices = list("Spheres" = "o", "Circles" = "@", "Labels" = "Labels"), selected = 1),
      p("Use the mouse zoom to rotate, zoom, and pan.")
    ),
    mainPanel(
        scatterplotThreeOutput("graph")
    )
  )
))
