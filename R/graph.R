#' Interactive 3D Force-directed Graphs
#'
#' Plot interactive force-directed graphs.
#'
#' @param nodes A node (vertex) data frame with at least columns:
#' \itemize{
#'   \item \code{label} Node character labels
#'   \item \code{id}    Unique integer node ids (corresponding to edges below)
#'   \item \code{size}  Positive numeric node plot size
#'   \item \code{color} A character color value, either color names ("blue", "red", ...) or 3-digit hexadecimal values ("#0000FF", "#EE0011")
#' }
#' Each row of the data frame defines a graph node.
#' @param edges An edge data frame with at least columns:
#' \itemize{
#'   \item \code{from} Integer node id identifying edge 'from' node
#'   \item \code{to} Integer node id identifying the edge 'to' node
#'   \item \code{size} Nonnegative numeric edge line width
#'   \item \code{color} Edge color specified like node color above
#' }
#' Each row of the data frame identifies a graph edge.
#' @param main Plot title
#' @param curvature Zero implies that edges are straight lines. Specify a positive number to curve the edges, useful to distinguish multiple edges in directed graphs. Larger numbers = more curvature, with 1 a usually reasonable value.
#' @param bg Plot background color specified similarly to the node colors described above
#' @param fg Plot foreground text color
#' @param showLabels If TRUE then display text labels near each node
#' @param attraction Numeric value specifying attraction of connected nodes to each other, larger values indicate more attraction
#' @param repulsion Numeric value specifying repulsion of all nodes to each other, larger values indicate greater repulsion
#' @param max_iterations Integer value specifying the maximum number of rendering iterations before stopping
#' @param opacity Node transparency, 0 <= opacity <= 1
#' @param stroke Node stroke color
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
#' Press the 'r' key to reset the view.
#'
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
#' g <- graphjs(LeMis$nodes, LeMis$edges, main="Les Mis&eacute;rables")
#' print(g)
#' @export
graphjs <- function(nodes, edges, main="", curvature=0, bg="white", fg="black", showLabels=FALSE,
                    attraction=1, repulsion=1, max_iterations=1500, opacity = 1, stroke="black", width=NULL, height=NULL)
{
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
          x = jsonlite::toJSON(x, auto_unbox=TRUE),
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
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, graphOutput, env, quoted = TRUE)
}

#' Convert from node and edge graph representation to a sparse adjacency matrix representation
#'
#' @param nodes A data frame with at least a column named "id" as used by \code{\link{graphjs}}. The size of the matrix is determined by  number of rows in the data frame.
#' @param edges A data frame with at least the columns "from" and "to" referring to edges between ids in the \code{nodes} data frame.
#' @param symmetric Set to \code{FALSE} for directed graphs, or leave as \code{TRUE} for undirected graphs.
#' @return A sparse matrix
#' @seealso \code{\link{graphjs}}, \code{\link{graph2Matrix}}
#' @importFrom Matrix sparseMatrix
#' @examples
#' data(LeMis)
#' M <- graph2Matrix(LeMis$nodes, LeMis$edges)
#' G <- matrix2graph(M)
#' @export
graph2Matrix = function(nodes, edges, symmetric=TRUE)
{
  N  = nrow(nodes)
  id = seq(1, N)
  names(id) = nodes[,"id"]
  sparseMatrix(i=id[as.character(edges$from)], j=id[as.character(edges$to)], x=1, dims=c(N, N), symmetric=symmetric)
}

#' Convert a matrix or column-sparse matrix to a list of edges and nodes for
#' use by \code{\link{graphjs}}.
#' @param M either a matrix or any of the possible column sparse matrix objects from the \link{Matrix} package.
#' @return A list with node and edges data frame entries.
#' @seealso \code{\link{graphjs}}, \code{\link{graph2Matrix}}
#' @importFrom Matrix Matrix
#' @examples
#' data(LeMis)
#' M <- graph2Matrix(LeMis$nodes, LeMis$edges)
#' G <- matrix2graph(M)
#' @export
matrix2graph = function(M)
{
  M = Matrix(M)
  if(!any(grepl("CMatrix", class(M)))) stop("M must be a matrix or CsparseMatrix object")
  n = nrow(M)
  nodes = data.frame(id=1:n, label=1:n, size=1, color="orange")
  dp = diff(M@p)
  edges = data.frame(from=M@i + 1, to=rep(seq_along(dp), dp), size=1, color="lightgray")
  list(nodes=nodes, edges=edges)
}
