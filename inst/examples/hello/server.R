library("shiny")
library("png")
library("threejs")

shinyServer(function(input, output) {
    
  output$hello <- renderHello({
    r <- gsub(" ","0",sprintf("%2x",floor(2.55*input$diffuse_r)))
    g <- gsub(" ","0",sprintf("%2x",floor(2.55*input$diffuse_g)))
    b <- gsub(" ","0",sprintf("%2x",floor(2.55*input$diffuse_b)))
    diffuse <- sprintf("#%s%s%s",r,g,b)
    specular <- sprintf("#%s",paste(rep(gsub(" ","0", sprintf("%2x",floor(2.55*input$specular))),3),collapse=""))
    helloThree.js(img=texture(system.file("img/Rlogo.jpg",package="threejs")),
                  ambient=diffuse,specular=specular, shininess=input$shininess)
  })
  
})
