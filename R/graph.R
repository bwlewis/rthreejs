#' graphjs Three.js 3D force-directed graph
#'
#' @param ... Additional options (see note).
#'
#' @return
#' An htmlwidget object that is displayed using the object's show or print method.
#' (If you don't see your widget plot, try printing it with the \code{print}) function. The
#' returned object includes a special \code{points3d} function for adding points to the
#' plot similar to \code{scatterplot3d}. See the note below and examples for details.
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#' 
#' @export
graphjs <- function(nodes, edges, main="", curvature=0, bg="white", fg="black", showLabels=FALSE,
                    attraction=1, repulsion=1, max_iterations=1500, nodeType=0, stroke="black", img, width=NULL, height=NULL)
{
  # create widget
  x = list(nodes=nodes, edges=edges, main=main, bg=bg, fg=fg, showLabels=showLabels, attraction=attraction, repulsion=repulsion, iterations=max_iterations, nodeType=nodeType, curvature=curvature, stroke=stroke)
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
