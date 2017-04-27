library("shiny")
library("threejs")

data("LeMis")

shinyServer(function(input, output)
{
  output$graph <- renderScatterplotThree({
    v <- input$select
    if (v == "Labels") v <- V(LeMis)$label
    graphjs(LeMis, vertex.shape=v)
  })
})
