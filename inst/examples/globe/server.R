library("shiny")
library("threejs")
data(world.cities, package="maps")

# We had some rendering problems serving these images directly, it
# seems to work more reliably if we send them as dataURIs.
earth_dark   <- system.file("images/world.jpg",package="threejs")
moon    <- system.file("images/moon.jpg",package="threejs")
mars    <- system.file("images/mars.jpg",package="threejs")
jupiter <- system.file("images/jupiter.jpg",package="threejs")
col <- list(
    earth_dark=list(img=earth_dark,bodycolor="#0011ff",emissive="#0011ff",lightcolor="#99ddff"),
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
    col <- rainbow(10,start=2.8/6,end=3.4/6)
    names(col) <- c()
    # Extend palette to data values
    col <- col[floor(length(col)*(h-value)/h) + 1]
    list(value=value, color=col, cities=cities)
  })

  output$globe <- renderGlobe({
    v <- values()
    p <- input$map
    atmo <- ifelse(input$map=="earth_dark", TRUE, FALSE)
    args = c(col[[input$map]] , list(lat=v$cities$lat, long=v$cities$long, value=v$value, color=v$color, atmosphere=atmo))
    do.call(globejs, args=args)
  })
  
})
