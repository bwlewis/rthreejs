library("shiny")
library("threejs")

set.seed(1)
if(!exists("example_data")) example_data <- matrix(runif(50*3),ncol=3)

shinyServer(function(input, output) {
    
  output$scatterplot <- renderScatterplotThree({
    num.ticks <- input$nticks
    if(num.ticks==0) num.ticks <- NULL
    else num.ticks <- rep(num.ticks,3)
    color <- palette()[rep(1:input$colors, length.out=nrow(example_data))]
    color <- gsub("[0-9]","",color)
    sizes <- rep(c(0.5, 1, 2)[1:input$sizes], length.out=nrow(example_data))
    scatterplot3.js(x=example_data,
                    num.ticks=num.ticks,
                    color=color,
                    size=sizes,
                    grid=input$grid)
  })
  
})
