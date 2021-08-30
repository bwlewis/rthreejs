library(threejs)
# scatterplots
z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x, y, z, color=rainbow(length(z)))
scatterplot3js(x, y, z, color=rainbow(length(z)), axisLabels=c("a", "b", "c"))

# graphs
data(LeMis, package="threejs")
g <- graphjs(LeMis, main="Les Mis&eacute;rables")
g <- graphjs(LeMis, main="Les Mis&eacute;rables", brush=TRUE)
