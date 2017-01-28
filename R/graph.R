#' Interactive 3D Graph Visualization
#'
#' Make interactive 3D plots of \code{\link{igraph}} objects.
#'
#' @param g an \code{\link{igraph}} graph object or a list of \code{igraph} objects (see notes)
#' @param layout optional graph layout or list of layouts (see notes)
#' @param vertex.color optional vertex color or vector of colors as long as the number of vertices in \code{g}
#' @param vertex.size optional vertex size or vector of sizes
#' @param vertex.shape optional vertex shape or vector of shapes
#' @param vertex.label optional vertex label or vector of labels
#' @param edge.color optional edge color or vector of colors as long as the number of edges in \code{g}
#' @param edge.width optional edge width or vector of edge widths
#' @param edge.alpha optional single numeric edge transparency value
#' @param main plot title text
#' @param bg plot background color
#' @param width the widget container \code{div} width in pixels
#' @param height the widget container \code{div} height in pixels
#' @param ... optional additional arguments passed to \code{\link{scatterplot3js}}
#'
#' @section Interacting with the plot:
#' Press and hold the left mouse button (or touch or trackpad equivalent) and move
#' the mouse to rotate the plot. Press and hold the right mouse button (or touch
#' equivalent) to pan. Use the mouse scroll wheel or touch equivalent to zoom.
#' If \code{vertex.label}s are specified (see below), moving the mouse pointer over
#' a point will display the label.
#'
#' @section Layout options:
#' Use the \code{layout} parameter to control the visualization layout by supplying
#' either a three-column matrix of vertex \code{x, y, z} coordinates, or a function
#' that returns such a layout. The igraph \code{\link{layout_with_fr}} force-directed
#' layout is used by default (note that only 3D layouts are supported). Also see
#' the animation section below.
#'
#' @section Vertex options:
#' Optional parameters beginning with \code{vertex.} represent a subset of the igraph package
#' vertex visualization options and work similarly, see \code{link{igraph.plotting}}.
#' Vertex shapes in \code{graphjs} act somewhat differently, and are mapped to the
#' \code{pch} option in \code{\link{scatterplot3js}}. In particular, \code{pch}
#' character symbols or even short text strings may be specified. The \code{vertex.label}
#' option enables a mouse-over label display instead of plotting lables directly near the vertices.
#' (Consider using the text \code{pch} options for that instead.)
#'
#' @section Edge options:
#' Optional parameters beginning with \code{edge.} represent a subset of the igraph
#' edge visualization options and work similarly as the \code{vertex.} options above.
#'
#' @section Graph animation:
#' Specifying a list of three-column layout matrices in \code{layout} displays
#' a linear interpolation from one layout to the next, providing a simple mechanism
#' for graph animation. Each layout must have the same number of rows as the number
#' of vertices in the graph.
#' Specify the optional \code{fpl} (frames per layout) parameter to control the
#' number of interpolating animation frames between layouts. See the examples.
#'
#' Optionally specify a list of graph objects in \code{g} to vary the displayed edges
#' and edge colors from one layout to the next, with the restriction that each graph
#' object must refer to a uniform number of vertices.
#'
#' @note
#' Edge transparency values specified as part of \code{edge.color} are ignored, however
#' you can set an overall transparency for edges with \code{edge.alpha}.
#'
#' @return
#' An htmlwidget object that is displayed using the object's show or print method.
#' (If you don't see your widget plot, try printing it with the \code{print}) function.
#'
#' @seealso \code{\link{igraph.plotting}}, \code{\link{scatterplot3js}}
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#'
#' @examples
#' set.seed(1)
#' g <- sample_islands(3, 10, 5/10, 1)
#' i <- cluster_optimal(g)
#' (graphjs(g, vertex.color=c("orange", "green", "blue")[i$membership], vertex.shape="sphere"))
#'
#' # Les Miserables Character Co-appearance Data
#' data("LeMis")
#' (graphjs(LeMis))
#'
#' # ...plot Character names
#' (graphjs(LeMis, vertex.shape=V(LeMis)$label))
#'
#' # SNAP Facebook ego network dataset (a nice medium-sized network)
#' data("ego")
#' (graphjs(ego, bg="black"))
#'
#' \dontrun{
#' # A graph amination that shows several layouts
#' data("LeMis")
#' graphjs(LeMis,
#'   layout=list(
#'     layout_randomly(LeMis, dim=3),
#'     layout_on_sphere(LeMis),
#'     layout_with_drl(LeMis, dim=3),  # note! somewhat slow...
#'     layout_with_fr(LeMis, dim=3, niter=30)),
#'   main=list("random layout", "sphere layout", "drl layout", "fr layout"),
#'   fpl=300)
#'
#' # A simple graph animation illustrating edge modification
#' g <- make_ring(5) - edges(1:5)
#' graph_list <- list(
#'  g + edge(1, 2),
#'  g + edge(1, 2) + edge(2, 3),
#'  g + edge(1, 2) + edge(2, 3) + edge(3, 4),
#'  g + edge(1, 2) + edge(2, 3) + edge(3, 4) + edge(4, 5),
#'  g + edge(1, 2) + edge(2, 3) + edge(3, 4) + edge(4, 5) + edge(5, 1))
#'  graphjs(graph_list, main=paste(1:5), fpl=200,
#'    vertex.color=rainbow(5), vertex.shape="sphere", edge.width=3)
#' }
#'
#' @importFrom igraph layout_with_fr norm_coords V E as_edgelist
#' @export
graphjs <- function(g, layout,
                    vertex.color, vertex.size, vertex.shape, vertex.label,
                    edge.color, edge.width, edge.alpha,
                    main="", bg="white",
                    width=NULL, height=NULL, ...)
{
  # check for list of graphs (edge animation)
  if(is.list(g) && "igraph" %in% class(g[[1]]))
  {
    from <- lapply(g, as_edgelist)
    to   <- lapply(from, function(x) x[, 2])
    from <- lapply(from, function(x) x[, 1])
    if(missing(edge.color)) edge.color <- lapply(g, function(x) { ifel(is.null(E(x)$color), NA, E(x)$color) })
    if(missing(layout)) layout <- lapply(g, function(x) {ifel(is.null(x$layout), layout_with_fr(x, dim=3, niter=50), x$layout)})
    else if(is.function(layout)) layout <- lapply(g, layout)
    else if(!is.list(layout)) layout <- list(layout)
    if(missing(vertex.color)) vertex.color <- lapply(g, ifel(is.null(V(g)$color), "orange", V(g)$color))
    g <- g[[1]]
  } else # single plot
  {
    if(!("igraph" %in% class(g))) stop("g must be an igraph object")
    from <- as_edgelist(g)
    to   <- from[, 2]
    from <- from[, 1]
    if(missing(layout)) layout <- list(ifel(is.null(g$layout), layout_with_fr(g, dim=3, niter=50), g$layout))
    else if(is.function(layout)) layout <- list(layout(g))
    else if(!is.list(layout)) layout <- list(layout)
    if(missing(vertex.color)) vertex.color <- list(ifel(is.null(V(g)$color), "orange", V(g)$color))
    if(missing(edge.color)) edge.color <- ifel(is.null(E(g)$color), NA, E(g)$color)
  }
  # other options
  if(missing(vertex.size)) vertex.size <- ifel(is.null(V(g)$size), 2, V(g)$size / 7)
  if(missing(vertex.shape)) vertex.shape <- ifel(is.null(V(g)$shape), "circle", V(g)$shape)
  if(missing(vertex.label)) vertex.label <- ifel(is.null(V(g)$label), NA, V(g)$label)
  if(missing(edge.width)) edge.width <- ifel(is.null(E(g)$width), 1, E(g)$width)
  if(length(edge.width) > 1)
  {
    warning("mulitple edge widths not yet supported")
    edge.width <- edge.width[1]
  }
  if(missing(edge.alpha))
  {
    if(length(E(g)) > 1000) edge.alpha <- 0.3
    else edge.alpha <- 1
    if(!is.null(E(g)$alpha)) edge.alpha <- E(g)$alpha
  }

  # normalize coordinates
  layout <- Map(norm_coords, layout)

# XXX check for mismatch in from,to,layout lengths and adjust as required

  if(!is.list(main)) main <- as.list(main)

  # map options to scatterplot3js options
  pch <- gsub("circle", "@", vertex.shape)
  u <- unique(vertex.shape)
  if("pie" %in% u) pch <- gsub("pie", "@", pch)
  if("sphere" %in% u) pch <- gsub("sphere", "o", pch)
  if("square" %in% u) pch <- gsub("square", ".", pch)
  if("csquare" %in% u) pch <- gsub("csquare", ".", pch)
  if("rectangle" %in% u) pch <- gsub("rectangle", ".", pch)
  if("crectangle" %in% u) pch <- gsub("crectangle", ".", pch)
  if("vrectangle" %in% u) pch <- gsub("vrectangle", ".", pch)
  options <- c(list(x=layout, pch=pch, size=vertex.size, color=vertex.color,
                  from=from, to=to, lwd=edge.width, linealpha=edge.alpha,
                  axis=FALSE, grid=FALSE, center=TRUE, bg=bg, main=main), list(...))
  if(!all(unlist(Map(is.na, edge.color)))) options$lcol <- edge.color
  if(!(length(vertex.label) == 1 && is.na(vertex.label))) options$labels <- vertex.label
  do.call("scatterplot3js", args=options)
}
