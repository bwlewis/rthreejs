library("shiny")
library("jpeg")
library("threejs")
library("maps")
data(world.cities, package="maps")

shinyServer(function(input, output) {

  h <- 100

  cull <- reactive({
     world.cities[order(world.cities$pop,decreasing=TRUE)[1:input$N],]
  })

  values <- reactive({
    cities <- cull()
    value <- h * cities$pop / max(cities$pop)
    # THREE.Color only accepts RGB form, drop the A value:
    col <- sapply(heat.colors(10), function(x) substr(x,1,7))
    names(col) <- c()
    # Extend palette to data values
    col <- col[floor(length(col)*(h-value)/h) + 1]
    list(value=value, color=col, cities=cities)
  })

  output$globe <- renderGlobe({
    v <- values()
    globe.js(img="globe-1/world.jpg",lat=v$cities$lat, long=v$cities$long, value=v$value, color=v$color)
  })
  
})
