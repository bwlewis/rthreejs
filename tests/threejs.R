# Check for a specially modified three.js library that supports shiny's
# renderUI:

d = system.file("htmlwidgets",package="threejs")
ok = length(grep("var THREE=window.THREE=",
                 readLines(paste(d, grep("three.min.js", dir(d, recursive=TRUE), value=TRUE), sep="/"), n=5)) > 0)
if(!ok) stop("The threejs package requires a modified version of the three.min.js JavaScript library. See the package README.md.")

library(threejs)
# scatterplots
N <- 100
i <- sample(3, N, replace=TRUE)
x <- matrix(rnorm(N * 3), ncol=3)
lab <- c("small", "bigger", "biggest")
scatterplot3js(x, color=rainbow(N), labels=lab[i], size=i, renderer="canvas")

z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x,y,z, color=rainbow(length(z)),
      labels=sprintf("x=%.2f, y=%.2f, z=%.2f", x, y, z))

scatterplot3js(x,y,z, color=rainbow(length(z)), axisLabels=c("a","b","c"))

# globes
data(flights, package="threejs")
dest   <- factor(sprintf("%.2f:%.2f",flights[,3], flights[,4]))
freq <- sort(table(dest), decreasing=TRUE)
frequent_destinations <- names(freq)[1:10]
idx <- dest %in% frequent_destinations
frequent_flights <- flights[idx, ]
ll <- unique(frequent_flights[,3:4])
globejs(lat=ll[,1], long=ll[,2], arcs=frequent_flights,
        arcsHeight=0.3, arcsLwd=2, arcsColor="#ffff00", arcsOpacity=0.15,
        atmosphere=TRUE, color="#00aaff", pointsize=0.5)

# graphs
data(LeMis, package="threejs")
g <- graphjs(LeMis$edges, main="Les Mis&eacute;rables")
g <- graphjs(LeMis$edges, LeMis$nodes, main="Les Mis&eacute;rables")
