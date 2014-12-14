library("shiny")
library("threejs")
library("maps")
data(world.cities, package="maps")

# We had some rendering problems serving these images directly, it
# seems to work more reliably if we send them as dataURIs.
earth   <- texture(system.file("htmlwidgets/lib/globe/world.jpg",package="threejs"))
moon    <- texture(system.file("htmlwidgets/lib/globe/moon.jpg",package="threejs"))
mars    <- texture(system.file("htmlwidgets/lib/globe/mars.jpg",package="threejs"))
jupiter <- texture(system.file("htmlwidgets/lib/globe/jupiter.jpg",package="threejs"))
col <- list(
    earth=list(img=earth,bodycolor="#0000ff",emissive="#0000ff",lightcolor="#9999ff"),
    moon=list(img=moon,bodycolor="#555555", emissive="#444444", lightcolor="#555555"),
    mars=list(img=mars,bodycolor="#aaaaaa", emissive="#000000", lightcolor="#aaaaaa"),
    jupiter=list(img=jupiter,bodycolor="#222222", emissive="#000000", lightcolor="#aaaaaa")
)

shinyServer(function(input, output) {

  h <- 100 # height of the bar

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
    p <- input$map
    atmo <- ifelse(input$map=="earth", TRUE, FALSE)
    args = c(col[[input$map]] , list(lat=v$cities$lat, long=v$cities$long, value=v$value, color=v$color, atmosphere=atmo))
    do.call(globejs, args=args)
  })
  
})
