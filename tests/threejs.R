library(threejs)
# scatterplots
z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x, y, z, color=rainbow(length(z)))
scatterplot3js(x, y, z, color=rainbow(length(z)), axisLabels=c("a", "b", "c"))

# globes
data(flights, package="threejs")
dest   <- factor(sprintf("%.2f:%.2f", flights[, 3], flights[, 4]))
freq <- sort(table(dest), decreasing=TRUE)
frequent_destinations <- names(freq)[1:10]
idx <- dest %in% frequent_destinations
frequent_flights <- flights[idx, ]
ll <- unique(frequent_flights[, 3:4])
globejs(lat=ll[, 1], long=ll[, 2], arcs=frequent_flights,
        arcsHeight=0.3, arcsLwd=2, arcsColor="#ffff00", arcsOpacity=0.15,
        atmosphere=TRUE, color="#00aaff", pointsize=0.5)

# graphs
data(LeMis, package="threejs")
g <- graphjs(LeMis, main="Les Mis&eacute;rables")
g <- graphjs(LeMis, main="Les Mis&eacute;rables", brush=TRUE)
