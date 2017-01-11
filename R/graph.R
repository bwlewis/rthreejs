#' Interactive 3D Graph Visualization
#'
#' Make interactive 3D plots of \code{\link{igraph}} objects.
#'
#' @param g an \code{igraph} graph object from the igraph package
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
#' the animation section below. Alpha levels specified in colors are ignored, however
#' you can set an overall transparency for edges with \code{edge.alpha}.
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
#' Specifying a list of three column layout matrices in \code{layout} displays
#' a linear interpolation from one layout to the next, providing a simple mechanism
#' for graph animation. Specify the optional \code{fpl} parameter to control the
#' number of interpolating animation frames between layouts. See the examples.
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
#' # Les Miserables Character Coappearance Data
#' data("LeMis")
#' (graphjs(LeMis))
#'
#' # Facebook ego network SNAP dataset (a nice medium-sized network)
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
#'   main=c("random layout", "sphere layout", "drl layout", "fr layout"),
#'   fpl=300)
#' }
#'
#'
#' @importFrom igraph layout_with_fr norm_coords V E as_edgelist
#' @export
graphjs <- function(g, layout,
                    vertex.color, vertex.size, vertex.shape, vertex.label,
                    edge.color, edge.width, edge.alpha,
                    main="", bg="white",
                    width=NULL, height=NULL, ...)
{
  if(!("igraph" %in% class(g))) stop("g must be an igraph object")
  # options
  if(missing(layout)) layout <- ifel(is.null(g$layout), function(g) layout_with_fr(g, dim=3, niter=50), g$layout)
  if(missing(vertex.color)) vertex.color <- ifel(is.null(V(g)$color), "orange", V(g)$color)
  if(missing(vertex.size)) vertex.size <- ifel(is.null(V(g)$size), 2, V(g)$size / 7)
  if(missing(vertex.shape)) vertex.shape <- ifel(is.null(V(g)$shape), "circle", V(g)$shape)
  if(missing(vertex.label)) vertex.label <- ifel(is.null(V(g)$label), NA, V(g)$label)
  if(missing(edge.color)) edge.color <- ifel(is.null(E(g)$color), NA, E(g)$color)
  if(missing(edge.width)) edge.width <- ifel(is.null(E(g)$width), 1, E(g)$width)
  if(missing(edge.alpha))
  {
    if(length(E(g)) > 1000) edge.alpha <- 0.4
    else edge.alpha <- 1
  }

  # transform to points and lines
  if(is.function(layout)) layout <- layout(g)
  g <- as_edgelist(g)

  # animation
  scenes <- NA
  if(is.list(layout))
  {
    scenes <- length(layout)
    layout <- Reduce(rbind, Map(norm_coords, layout))
  }

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
  options <- c(list(x=layout, pch=pch, size=vertex.size, color=vertex.color, from=g,
                  lwd=edge.width, linealpha=edge.alpha, lcol=edge.color,
                  axis=FALSE, grid=FALSE, center=TRUE, bg=bg, main=main), list(...))
  if(!(length(vertex.label) == 1 && is.na(vertex.label))) options$labels <- vertex.label
  if(!(length(edge.color) == 1 && is.na(edge.color))) options$lcol <- edge.color
  if(!is.na(scenes)) options$scenes <- scenes
  do.call("scatterplot3js", args=options)
}
