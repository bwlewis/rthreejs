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
#' @param showLabels If TRUE then display text labels near each node, may not work well with nodeType="sphere"
#' @param attraction Numeric value specifying attraction of connected nodes to each other, larger values indicate more attraction
#' @param repulsion Numeric value specifying repulsion of all nodes to each other, larger values indicate greater repulsion
#' @param max_iterations Integer value specifying the maximum number of rendering iterations before stopping
#' @param nodeType circle or sphere nodes
#' @param stroke Node stroke color, applies only to nodeType="cicrle"
#' @param img Optional node image, applies only to nodeType="sphere"--see notes
#' @param width optional widget width
#' @param height optional widget height
#'
#' @note All colors must be specified as color names like "red", "blue", etc. or
#' as hexadecimal color values without alpha channel, for example "#FF0000", "#0a3e55"
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
#' @references
#' Original code by DAvid Piegza: \url{https://github.com/davidpiegza/Graph-Visualization}.
#' The three.js project \url{http://threejs.org}.
#' 
#' @examples
#' data(LeMis)
#' g <- graphjs(nodes=LeMis$nodes, edges=LeMis$edges, main="Les Mis&eacute;rables")
#' print(g)
#' @export
graphjs <- function(nodes, edges, main="", curvature=0, bg="white", fg="black", showLabels=FALSE,
                    attraction=1, repulsion=1, max_iterations=1500, nodeType=c("circle", "sphere"),
                    stroke="black", img, width=NULL, height=NULL)
{
  nodeType = (match.arg(nodeType) == "sphere") + 1
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
           nodeType=nodeType,
           curvature=curvature,
           stroke=stroke)
  if(!missing(img)) x$img = texture(img)
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
graphOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "graph", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderGraph <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, graphOutput, env, quoted = TRUE)
}
