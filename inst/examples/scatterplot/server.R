library("shiny")
library("threejs")

set.seed(1)
if(!exists("example_data")) example_data <- matrix(runif(50 * 3), ncol=3)

shinyServer(function(input, output)
{
  output$scatterplot <- renderScatterplotThree({
    num.ticks <- input$nticks
    if(num.ticks == 0) num.ticks <- NULL
    else num.ticks <- rep(num.ticks,3)
    color <- rep(rainbow(input$colors),length.out=nrow(example_data))
    sizes <- rep(c(0.5, 1, 2)[1:input$sizes], length.out=nrow(example_data))
    labs <- sprintf("x=%.2f, y=%.2f, z=%.2f", example_data[,1], example_data[,2], example_data[,3])
    scatterplot3js(x=example_data,
                    num.ticks=num.ticks,
                    color=color,
                    size=sizes,
                    labels=labs,
                    label.margin="80px 10px 10px 10px",
                    renderer=input$renderer,
                    grid=input$grid)
  })
})
