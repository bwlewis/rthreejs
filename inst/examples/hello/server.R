library("shiny")
library("png")
library("threejs")

last_index <- 0

shinyServer(function(input, output) {

# Silly examples follow
# Example image plot
  require(grDevices) # for colours
  x <- y <- seq(-4*pi, 4*pi, len = 27)
  r <- sqrt(outer(x^2, y^2, "+"))
  f <- tempfile(fileext=".jpg")
  jpeg(quality=100,width=250,height=250,file=f)
  image(z = z <- cos(r^2)*exp(-r/6), col  = gray((0:32)/32))
  image(z, axes = FALSE, main = "Math can be beautiful ...",
           xlab = expression(cos(r^2) * e^{-r/6}))
  contour(z, add = TRUE, drawlabels = FALSE)
  dev.off()
  image_texture <- texture(f)

# Example plot
  f <- tempfile(fileext=".jpg")
  jpeg(quality=100,width=250,height=250,file=f)
  coplot(lat ~ long | depth, data = quakes, pch = 21, bg = "green3")
  dev.off()
  plot_texture <- texture(f)

# Rlogo
  rlogo_texture <- texture(system.file("images/Rlogo.jpg",package="threejs"))

# Image choices
  tex <- list(rlogo_texture, image_texture, plot_texture)


  output$hello <- renderHello({
    update <- last_index != as.numeric(input$select)
    last_index <<- as.numeric(input$select)
    r <- gsub(" ","0",sprintf("%2x",floor(2.55*input$diffuse_r)))
    g <- gsub(" ","0",sprintf("%2x",floor(2.55*input$diffuse_g)))
    b <- gsub(" ","0",sprintf("%2x",floor(2.55*input$diffuse_b)))
    diffuse <- sprintf("#%s%s%s",r,g,b)
    specular <- sprintf("#%s",paste(rep(gsub(" ","0", sprintf("%2x",floor(2.55*input$specular))),3),collapse=""))
    helloThree.js(img=c(tex[[last_index]], UPDATE_IMAGE=update),
                  ambient=diffuse,specular=specular, shininess=input$shininess)
  })
  
})
