library("shiny")
library("threejs")

shinyUI(fluidPage(
  
  titlePanel("Hello Three.js"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("shininess", "Shininess", value=10, min = 0, max = 100, step = 1),
      sliderInput("specular", "Specular", value=60, min = 0, max = 100, step = 1),
      sliderInput("diffuse_r", "Diffuse Red", value=50, min = 0, max = 100, step = 1),
      sliderInput("diffuse_g", "Diffuse Green", value=50, min = 0, max = 100, step = 1),
      sliderInput("diffuse_b", "Diffuse Blue", value=50, min = 0, max = 100, step = 1)
    ),
    mainPanel(
      helloOutput("hello")
    )
  )
))
