# This example decomposes the `LeMis` character co-occurence network
# into six clusters using the igraph `cluster_louvain` method. The
# example displays a reduced network consisting of the most (globally)
# central character from each cluster, as measured by Page Rank.
#
# When a user clicks on one of the vertices, its corresponding cluster
# is expanded to show all vertices in that cluster.
#
# See `demo("click_animation2", package="threejs") for a related example.

library(threejs)
data(LeMis)
N  <- length(V(LeMis))

# Vertex page rank values (a measure of network centrality for each vertex)
pr <- page_rank(LeMis)$vector
# order the page rank values
i <- order(pr, decreasing=TRUE)

# Vertex cluster membership
cl <- unclass(membership(cluster_louvain(LeMis)))

# Find the index of the highest page rank vertex in each cluster
idx <- aggregate(seq(1:N)[i], by=list(cl[i]), FUN=head, 1)$x
# Create a default force-directed layout for the whole network
l1 <- norm_coords(layout_with_fr(LeMis, dim=3))
# Collapse the layout to just the idx vertices
l0 <- Reduce(rbind, Map(function(i) l1[idx[i],], cl))

# Create grouped vertex colors, setting all but idx vertices transparent
col <- rainbow(length(idx), alpha=0)[cl]
col[idx] <- rainbow(length(idx), alpha=1)

# animation layouts, one for each of the idx vertices, and
# animation color schemes, one scheme for each idx vertex
click <- Map(function(i)
{
  x <- l0
  x[cl == i, ] <- l1[cl == i, ]
  c <- col
  c[cl == i] <- rainbow(length(idx), alpha=1)[i]
  list(layout=x, vertex.color=c)
}, seq(idx))
names(click) <- paste(idx)

(graphjs(LeMis, layout=l0, click=click, vertex.color=col, fps=20, font.main="96px Arial"))
