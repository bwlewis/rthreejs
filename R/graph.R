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

  stop("IMPLEMENTATION CHANGING")

}
