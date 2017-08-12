#' Interactive 3D Graph Visualization
#'
#' Make interactive 3D plots of \code{\link{igraph}} objects.
#'
#' @param g an \code{\link{igraph}} graph object or a list of \code{igraph} objects (see notes)
#' @param layout optional graph layout or list of layouts (see notes)
#' @param vertex.color optional vertex color or vector of colors as long as the number of vertices in \code{g}
#' @param vertex.size optional vertex size or vector of sizes
#' @param vertex.shape optional vertex shape or vector of shapes
#' @param vertex.label optional mouse-over vertex label or vector of labels
#' @param edge.color optional edge color or vector of colors as long as the number of edges in \code{g}
#' @param edge.width optional edge width (single scalar value, see notes)
#' @param edge.alpha optional single numeric edge transparency value
#' @param main plot title text
#' @param bg plot background color
#' @param width the widget container \code{div} width in pixels
#' @param height the widget container \code{div} height in pixels
#' @param ... optional additional arguments passed to \code{\link{scatterplot3js}}
#'
#' @section Interacting with the plot:
#' Press and hold the left mouse button, or touch or trackpad equivalent, and move
#' the mouse to rotate the plot. Press and hold the right mouse button
#' to pan. Use the mouse scroll wheel to zoom.
#' If \code{vertex.label}s are specified (see below), moving the mouse pointer over
#' a point will display the label. Altenatively use \code{vertex.shape} to plot
#' character names as shown in the examples below.
#' Set the optional experimental \code{use.orbitcontrols=TRUE} argument to
#' use a more CPU-efficient but somewhat less fluid mouse/touch interface.
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
#' The current version of the package only supports uniform edge widths specified by
#' a single scalar value. This choice was made for performance reasons to support large
#' visualizations.
#'
#' @section Graph animation:
#' Specifying a list of three-column layout matrices in \code{layout} displays
#' a linear interpolation from one layout to the next, providing a simple mechanism
#' for graph animation. Each layout must have the same number of rows as the number
#' of vertices in the graph.
#'
#' Specify the optional \code{fpl} (frames per layout) parameter to control the
#' number of interpolating animation frames between layouts. See the examples.
#'
#' Optionally specify a list of graph objects in \code{g} to vary the displayed edges
#' and edge colors from one layout to the next, with the restriction that each graph
#' object must refer to a uniform number of vertices.
#'
#' The lists of graphs may optionally include varying vertex and edge colors.
#' Alternatively, specify a list of \code{vertex.color} vectors (one
#' for each layout) to animate vertex colors. Similarly, optionally specify a
#' list of \code{edge.color} vectors to animate edge colors.
#'
#' Optionally provide a list of \code{main} title text strings to vary the
#' title with each animation layout.
#'
#' None of the other plot parameters may be animated.
#'
#' @section Click animation:
#' Specify the option \code{click=list} to animate the graph when specified vertices
#' are clicked interactively, where \code{list} is a named list of animation entries.
#' Each entry must itself be a list with the following entries
#' \itemize{
#' \item{g}{ optional a single igraph object with the same number of vertices
#'    as \code{g} above (if specified this must be the first entry)}
#' \item{layout}{ - optional a single igraph layout, or differential layout if \code{cumulative=TRUE}}
#' \item{vertex.color}{ - optional single vector of vertex colors}
#' \item{edge.color}{ - optional single vector of edge colors}
#' \item{cumulative}{ - optional boolean entry, if \code{TRUE} then vertex positions are
#'   added to current plot, default is \code{FALSE}}
#' }
#' At least one of \code{g} or \code{layout} must be specified in each animation list entry.
#' The layouts and colors may be alternatively imbedded in the igraph object itself.
#' Each animation list entry must be named by a number corresponding to the vertex
#' enumeration in \code{g}. An animation sequence is triggered when a corresponding
#' vertex is clicked. For instance, to trigger animations when vertices number 1 or 5 are
#' clicked, include list entries labeled \code{"1"} and \code{"5"}.
#' See the demos in \code{demo(package="threejs")} for detailed examples.
#'
#' @section Other interactions:
#' Specify the argument \code{brush=TRUE} to highlight a clicked vertex and
#' its directly connected edges (click off of a vertex to reset the display).
#' Optionally set the \code{highlight=<hex color>} and \code{lowlight=<hex color>}
#' to manually control the brushing display colors.
#'
#' @section Crosstalk:
#' \code{graphjs()} works with
#' crosstalk selection (but not filtering yet); see https://rstudio.github.io/crosstalk/.
#' Enable crosstalk by supplying the optional agrument \code{crosstalk=df}, where \code{df} is a
#' crosstalk-SharedData data.frame-like object with the same number of rows as graph vertices
#' (see the examples).
#'
#' @note
#' Edge transparency values specified as part of \code{edge.color} are ignored, however
#' you can set an overall transparency for edges with \code{edge.alpha}.
#'
#' @return
#' An htmlwidget object that is displayed using the object's show or print method.
#' (If you don't see your widget plot, try printing it with the \code{print} function.)
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
#' # SNAP Facebook ego network dataset
#' data("ego")
#' (graphjs(ego, bg="black"))
#'
#' \dontrun{
#' # A shiny example
#' shiny::runApp(system.file("examples/graph", package="threejs"))
#'
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
#'  graphjs(graph_list, main=paste(1:5),
#'    vertex.color=rainbow(5), vertex.shape="sphere", edge.width=3)
#'
#' # see `demo(package="threejs") for more animation demos.
#'
#' # A crosstalk example
#' library(crosstalk)
#' library(DT)
#' data(LeMis)
#' sd = SharedData$new(data.frame(Name = V(LeMis)$label))
#' print(bscols(
#'   graphjs(LeMis, brush=TRUE, crosstalk=sd),
#'   datatable(sd, rownames=FALSE, options=list(dom='tp'))
#' ))
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
  # Check for package version < 0.3.0 options
  warn_upgrade <- FALSE
  nodes <- list(...)$nodes
  edges <- list(...)$edges
  if(! missing(g) && is.list(g) && is.data.frame(g[[1]]) && "edges" %in% names(g))
  {
    warn_upgrade <- TRUE
    edges <- g$edges
    nodes <- g$nodes
  }
  if(! missing(g) && is.data.frame(g))
  {
    warn_upgrade <- TRUE
    edges <- g
  }
  if(! missing(layout) && is.data.frame(layout))
  {
    warn_upgrade <- TRUE
    nodes <- layout
    layout <- function(x) layout_with_fr(x, dim=3)
  }
  if(! is.null(edges))
  {
    warn_upgrade <- TRUE
    if(! missing(g) && "color" %in% names(g)) edge.color <- g$color
    g <- igraph::graph_from_data_frame(edges[, 1:2])
    igraph::V(g)$color <- "orange"
  }
  if(! is.null(nodes))
  {
    warn_upgrade <- TRUE
    nodes <- nodes[order(nodes$id), ]
    igraph::V(g)$name <- nodes$label
    vertex.label <- nodes$label
    vertex.size <- nodes$size
    vertex.color <- nodes$color
  }
  tryCatch(rm(list=c("nodes", "edges")), warning=invisible)
  if(warn_upgrade)
  {
    warning("Please upgrade to the new graphjs() interface in version >= 0.3.0 of the threejs package.\n  See ?graphjs for help.")
  }

  # check for list of graphs (edge animation)
  if (is.list(g) && "igraph" %in% class(g[[1]]))
  {
    from <- lapply(g, as_edgelist, names=FALSE)
    to   <- lapply(from, function(x) x[, 2])
    from <- lapply(from, function(x) x[, 1])
    if (missing(edge.color)) edge.color <- lapply(g, function(x) {
      ifel(is.null(E(x)$color), NA, E(x)$color)
    })
    if (missing(layout)) layout <- lapply(g, function(x) {
      ifel(is.null(x$layout), layout_with_fr(x, dim=3, niter=50), x$layout)
    })
    else if (is.function(layout)) layout <- lapply(g, layout)
    else if (!is.list(layout)) layout <- list(layout)
    if (missing(vertex.color)) vertex.color <- lapply(g, function(x) ifel(is.null(V(x)$color), "orange", V(x)$color))
    g <- g[[1]]
  } else # single plot
  {
    if (!("igraph" %in% class(g))) stop("g must be an igraph object")
    from <- as_edgelist(g, names=FALSE)
    to   <- from[, 2]
    from <- from[, 1]
    if (missing(layout)) layout <- list(ifel(is.null(g$layout), layout_with_fr(g, dim=3, niter=50), g$layout))
    else if (is.function(layout)) layout <- list(layout(g))
    else if (!is.list(layout)) layout <- list(layout)
    if (missing(vertex.color)) vertex.color <- list(ifel(is.null(V(g)$color), "orange", V(g)$color))
    if (missing(edge.color)) edge.color <- ifel(is.null(E(g)$color), NA, E(g)$color)
  }
  # other options
  if (missing(vertex.size)) vertex.size <- ifel(is.null(V(g)$size), 2, V(g)$size / 7)
  if (missing(vertex.shape)) vertex.shape <- ifel(is.null(V(g)$shape), "circle", V(g)$shape)
  if (missing(vertex.label)) vertex.label <- ifel(is.null(V(g)$label), NA, V(g)$label)
  if (missing(edge.width)) edge.width <- ifel(is.null(E(g)$width), 1, E(g)$width)
  if (length(edge.width) > 1)
  {
    warning("mulitple edge widths not yet supported")
    edge.width <- edge.width[1]
  }
  if (missing(edge.alpha))
  {
    if (length(E(g)) > 1000) edge.alpha <- 0.3
    else edge.alpha <- 1
    if (!is.null(E(g)$alpha)) edge.alpha <- E(g)$alpha
  }

  # normalize coordinates
  layout <- Map(norm_coords, layout)

  if (!is.list(main)) main <- as.list(main)

  # map options to scatterplot3js options
  pch <- gsub("circle", "@", vertex.shape)
  u <- unique(vertex.shape)
  if ("pie" %in% u) pch <- gsub("pie", "@", pch)
  if ("sphere" %in% u) pch <- gsub("sphere", "o", pch)
  if ("square" %in% u) pch <- gsub("square", ".", pch)
  if ("csquare" %in% u) pch <- gsub("csquare", ".", pch)
  if ("rectangle" %in% u) pch <- gsub("rectangle", ".", pch)
  if ("crectangle" %in% u) pch <- gsub("crectangle", ".", pch)
  if ("vrectangle" %in% u) pch <- gsub("vrectangle", ".", pch)
  opts <- list(...)
  names(opts)[names(opts) == "vertex.alpha"] <- "alpha" # rename for scatterplot3js

  # click animation
  if ("click" %in% names(opts))
  {
    opts$click <- lapply(opts$click, gopts)
    names(opts$click) <- paste(as.integer(names(opts$click)) - 1)
  }

  options <- c(list(x=layout, pch=pch, size=vertex.size, color=vertex.color, from=from, to=to,
                    lwd=edge.width, linealpha=edge.alpha, axis=FALSE, grid=FALSE, center=TRUE,
                    bg=bg, main=main, xlim=c(-1, 1), ylim=c(-1, 1), zlim=c(-1, 1)), opts)
  if (!all(unlist(Map(is.na, edge.color)))) options$lcol <- edge.color
  if (!(length(vertex.label) == 1 && is.na(vertex.label))) options$labels <- vertex.label
  options$options <- TRUE
  opt <- do.call("scatterplot3js", args=options)
  ans <- htmlwidgets::createWidget(
          name = "scatterplotThree",
          x = opt,
          width = width,
          height = height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          dependencies = crosstalk::crosstalkLibs(),
          package = "threejs")
  ans$call <- match.call()
  ans$vcache <- layout
  ans
}
