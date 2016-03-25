#' Interactive 3D Force-directed Graphs
#'
#' Plot interactive force-directed graphs.
#'
#' @param edges Either a list with \code{edges} and \code{nodes} data frames as described below,
#' or a graph object produced from the \code{igraph} package (see \code{\link{igraph2graphjs}}),
#' or an edge data frame with at least columns:
#'   \itemize{
#'     \item \code{from} Integer node id identifying edge 'from' node
#'     \item \code{to} Integer node id identifying the edge 'to' node
#'     \item \code{size} Nonnegative numeric edge line width
#'     \item \code{color} Edge color specified like node color above
#'   }
#' Each row of the data frame identifies a graph edge.
#' @param nodes Optional node (vertex) data frame with at least columns:
#' \itemize{
#'   \item \code{label} Node character labels
#'   \item \code{id}    Unique integer node ids (corresponding to node ids used by \code{edges})
#'   \item \code{size}  Positive numeric node plot size
#'   \item \code{color} A character color value, either color names ("blue", "red", ...) or 3-digit hexadecimal values ("#0000FF", "#EE0011")
#' }
#' Each row of the data frame defines a graph node. If the \code{nodes} argument is missing it will be
#' inferred from the \code{edges} argument.
#' @param main Plot title
#' @param curvature Zero implies that edges are straight lines. Specify a positive number to curve the edges, useful to distinguish multiple edges in directed graphs (the z-axis of the curve depends on the sign of \code{edge$from - edge$to}). Larger numbers = more curvature, with 1 a usually reasonable value.
#' @param bg Plot background color specified similarly to the node colors described above
#' @param fg Plot foreground text color
#' @param showLabels If \code{TRUE} then display text labels near each node
#' @param attraction Numeric value specifying attraction of connected nodes to each other, larger values indicate more attraction
#' @param repulsion Numeric value specifying repulsion of all nodes to each other, larger values indicate greater repulsion
#' @param max_iterations Integer value specifying the maximum number of rendering iterations before stopping
#' @param opacity Node transparency, 0 <= opacity <= 1
#' @param stroke If TRUE, stroke each node with a black circle
#' @param width optional widget width
#' @param height optional widget height
#'
#' @note All colors must be specified as color names like "red", "blue", etc. or
#' as hexadecimal color values without opacity channel, for example "#FF0000", "#0a3e55"
#' (upper or lower case hex digits are allowed).
#'
#' The plot responds to the following mouse controls (touch analogs may also be
#' supported on some systems):
#' \itemize{
#' \item  \code{scrollwheel} zoom
#' \item  \code{left-mouse button + move} rotate
#' \item  \code{right-mouse button + move} pan
#' \item  \code{mouse over} identify node by appending its label to the title
#' }
#' Double-click or tap on the plot to reset the view.
#'
#' Basic support for plotting \code{igraph} objects is provided by the
#' \code{\link{igraph2graphjs}} function.
#' @return
#' An htmlwidget object that is displayed using the object's show or print method.
#' (If you don't see your widget plot, try printing it with the \code{print}) function.
#'
#' @seealso \code{\link{LeMis}}
#' @references
#' Original code by David Piegza: \url{https://github.com/davidpiegza/Graph-Visualization}.
#'
#' The three.js project \url{http://threejs.org}.
#' @examples
#' data(LeMis)
#' g <- graphjs(LeMis, main="Les Mis&eacute;rables", showLabels=TRUE)
#' print(g)
#'
#' \dontrun{
#' # The next example uses the `igraph` package.
#' library(igraph)
#' set.seed(1)
#' g <- sample_islands(3, 10, 5/10, 1)
#' i <- cluster_optimal(g)
#' g <- set_vertex_attr(g, "color", value=c("yellow", "green", "blue")[i$membership])
#' print(graphjs(g))
#' }
#' @importFrom jsonlite toJSON
#' @importFrom methods slotNames
#' @export
graphjs <- function(edges, nodes, main="", curvature=0, bg="white", fg="black", showLabels=FALSE,
                    attraction=1, repulsion=1, max_iterations=1500, opacity = 1, stroke=TRUE, width=NULL, height=NULL)
{
  # check input
  if("igraph" %in% class(edges))
  {
    ig = igraph2graphjs(edges)
    nodes = ig$nodes
    edges = ig$edges
  }
  if(!is.data.frame(edges))
  {
    if(is.list(edges))
    {
      nodes = edges[["nodes"]]
      edges = edges[["edges"]]
    } else stop("edges must be either a list, igraph object or data frame, see help('graphjs')")
  }
  if(is.null(edges$size)) edges$size = 1
  if(is.null(edges$color)) edges$color = "lightgray"
  if(!all(c("from", "size", "to", "color") %in% names(edges)))
    stop("The edges data frame must contain 'from', 'to' variables")
  if (missing(nodes))
  {
    nodes = data.frame(id=unique(c(edges$from, edges$to)), size=1, color="orange", stringsAsFactors=FALSE)
    nodes$label = nodes$id
  }
  if(is.null(nodes$label)) nodes$label = nodes$id
  if(is.null(nodes$size)) nodes$size = 1
  if(is.null(nodes$color)) nodes$color = "orange"
  if(!all(c("id", "size", "label", "color") %in% names(nodes)))
    stop("The nodes data frame must contain 'id', 'size', 'label', and 'color' variables")

  stroke = switch(as.character(stroke), "TRUE"="black", "white")

  # create widget
  x = list(nodes=nodes,
           edges=edges,
           main=main,
           bg=bg,
           fg=fg,
           showLabels=showLabels,
           attraction=attraction,
           repulsion=repulsion,
           iterations=max_iterations,
           curvature=curvature,
           opacity=opacity,
           stroke=stroke)
  ans = htmlwidgets::createWidget(
          name = "graph",
          x = toJSON(x, auto_unbox=TRUE),
          width = width,
          height = height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          package = "threejs")
  ans
}

#' @rdname threejs-shiny
#' @export
graphOutput = function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "graph", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderGraph = function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) {
      expr <- substitute(expr)
    } # force quoted
    shinyRenderWidget(expr, graphOutput, env, quoted = TRUE)
}

#' Convert from node and edge graph representation to a sparse adjacency matrix representation
#'
#' @param edges A data frame with at least the columns "from" and "to"
#' referring to edges between ids in the \code{nodes} data frame. If the data
#' frame includes a numeric "size" variable then graph is assumed to be weighted
#' and the corresponding matrix entries are set to the size values.
#' @param nodes Optional data frame with at least a column named "id"
#' corresponding to the \code{from} and \code{to} node ids in the \code{edges}
#' argument. The size of the matrix is determined by  number of rows in the data
#' frame. If \code{nodes} is missing it will be inferred from the \code{edges}. If
#' \code{nodes} has a "label" column, the matrix row and column names will be set
#' to the corresponding node labels.
#' @param symmetric Set to \code{FALSE} for directed graphs, or leave as \code{TRUE} for undirected graphs.
#' @return A sparse matrix
#' @seealso \code{\link{graphjs}}, \code{\link{graph2Matrix}}
#' @importFrom Matrix sparseMatrix
#' @examples
#' data(LeMis)
#' M <- graph2Matrix(LeMis$edges, LeMis$nodes)
#' G <- matrix2graph(M)
#' @export
graph2Matrix = function(edges, nodes, symmetric=TRUE)
{
  if (!is.data.frame(edges) || !(c("from", "to") %in% names(edges)))
    stop("edges must be a data frame with 'from' and 'to' columns")
  if (missing(nodes))
  {
    nodes = data.frame(id=unique(c(edges$from, edges$to)))
  }
  if (symmetric)
  {
    # Enforce ordering edges$from <= edges$to
    idx = edges[,"from"] > edges[,"to"]
    if(any(idx))
    {
      x = edges[idx, "from"]
      edges[idx, "from"] = edges[idx, "to"]
      edges[idx, "to"] = x
    }
  }
  N  = nrow(nodes)
  id = seq(1, N)
  x = 1
  if (!is.null(edges$size) && is.numeric(edges$size)) x = edges$size
  names(id) = nodes[,"id"]
  M = sparseMatrix(i=id[as.character(edges$from)], j=id[as.character(edges$to)], x=x, dims=c(N, N), symmetric=symmetric)
  if(!is.null(nodes$label)) colnames(M) = rownames(M) = nodes$label
  M
}

#' Convert a matrix or column-sparse matrix to a list of edges and nodes for
#' use by \code{\link{graphjs}}.
#' @param M either a matrix or any of the possible column sparse matrix objects from the \link{Matrix} package.
#' @return A list with node and edges data frame entries used by \code{\link{graphjs}}.
#' @note Numeric graphs are assumed to be weighted and the edge "size" values are set to the corresponding matrix entries.
#' @seealso \code{\link{graphjs}}, \code{\link{graph2Matrix}}
#' @importFrom Matrix Matrix
#' @examples
#' data(LeMis)
#' M <- graph2Matrix(LeMis$edges, LeMis$nodes)
#' G <- matrix2graph(M)
#' @export
matrix2graph = function(M)
{
  M = Matrix(M)
  if(!any(grepl("CMatrix", class(M)))) stop("M must be a matrix or CsparseMatrix object")
  n = nrow(M)
  size = 1
  if("x" %in% slotNames(M)) size = as.numeric(M@x)
  nodes = data.frame(id=1:n, label=1:n, size=1, color="orange")
  if(!is.null(colnames(M))) nodes$label = colnames(M)
  dp = diff(M@p)
  edges = data.frame(from=M@i + 1, to=rep(seq_along(dp), dp), size=size, color="lightgray")
  list(nodes=nodes, edges=edges)
}


#' Convert \code{igraph} graph objects to a simpler form used by \code{\link{graphjs}}
#' @param ig A graph object from \code{igraph}
#' @return A list with node and edges data frame entries used by \code{\link{graphjs}}.
#' @export
#' @examples
#' \dontrun{
#'   library(igraph)
#'   g <- make_ring(10) %>%
#'        set_edge_attr("weight", value = 1:10) %>%
#'        set_edge_attr("color", value = "red") %>%
#'        set_vertex_attr("name", value = letters[1:10])
#'   (G <- igraph2graphjs(g))
#'
#'   # Can also directly run:
#'   graphjs(g)
#' }
igraph2graphjs = function(ig)
{
  E = igraph::as_edgelist(ig)
  nodes = data.frame(id=1:igraph::vcount(ig))
  vattr = data.frame(igraph::vertex_attr(ig), stringsAsFactors=FALSE)
  if(length(vattr) > 0 && nrow(vattr) == nrow(nodes)) nodes = cbind(nodes, vattr)
  nv = names(nodes)
  nv[which(nv %in% "name")] = "label"
  names(nodes) = nv
  if(!is.numeric(E))
  {
    if(is.null(nodes$label)) stop("can't determine edge list")
    n = nodes$id
    names(n) = nodes$label
    E = cbind(n[E[, 1]], n[E[, 2]])
  }
  edges = data.frame(from=E[,1], to=E[,2], stringAsFactors=FALSE)
  eattr = data.frame(igraph::edge_attr(ig), stringsAsFactors=FALSE)
  if(length(eattr) > 0 && nrow(eattr) == nrow(edges)) edges = cbind(edges, eattr)
  # adjust variable names as required
  ne = names(edges)
  ne[which(ne %in% c("weight", "width"))] = "size"
  names(edges) = ne
  list(edges=edges, nodes=nodes)
}
