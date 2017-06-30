library(threejs)
library(crosstalk)
library(d3scatter) # devtools::install_github("jcheng5/d3scatter")

z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
sd <- SharedData$new(data.frame(x=x, y=y, z=z))
bscols(
  scatterplot3js(x, y, z, color=rainbow(length(z)), brush=TRUE, crosstalk=sd, width=450),
  d3scatter(sd, ~x, ~y, width=450)
)
