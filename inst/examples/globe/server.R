library("shiny")
library("threejs")
data(world.cities, package="maps")

earth_dark <- list(img=system.file("images/world.jpg", package="threejs"),
                   bodycolor="#0011ff",
                   emissive="#000010",
                   lightcolor="#99ddff")

shinyServer(function(input, output)
{
  h <- 100 # height of the bar
  cull <- reactive({
     world.cities[order(world.cities$pop, decreasing=TRUE)[1:input$N], ]
  })

  values <- reactive({
    cities <- cull()
    value <- h * cities$pop / max(cities$pop)
    col <- rainbow(10, start=2.8 / 6, end=3.4 / 6)
    names(col) <- c()
    # Extend palette to data values
    col <- col[floor(length(col) * (h - value) / h) + 1]
    list(value=value, color=col, cities=cities)
  })

  output$globe <- renderGlobe({
    v <- values()
    p <- input$map
    args <- c(earth_dark, list(lat=v$cities$lat, long=v$cities$long, value=v$value, color=v$color, atmosphere=TRUE))
    do.call(globejs, args=args)
  })
})
