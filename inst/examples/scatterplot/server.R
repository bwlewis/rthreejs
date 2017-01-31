library("shiny")
library("threejs")

set.seed(1)
if (!exists("example_data")) example_data <- matrix(runif(50 * 3), ncol = 3)

shinyServer(function(input, output)
{
  output$scatterplot <- renderScatterplotThree({
    num.ticks <- input$nticks
    if (num.ticks == 0) num.ticks <- NULL
    else num.ticks <- rep(num.ticks, 3)
    data <- example_data
    colnames(data) <- NULL
    color <- rep(rainbow(input$colors), length.out = nrow(data))
    sizes <- rep(c(0.5, 1, 2)[1:input$sizes], length.out = nrow(data))
    scatterplot3js(x = data,
                    num.ticks = num.ticks,
                    color = color,
                    size = sizes,
                    label.margin = "80px 10px 10px 10px",
                    grid = input$grid)
  })
})
