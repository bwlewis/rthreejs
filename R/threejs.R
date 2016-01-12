#' Interactive 3D graphics including point clouds and globes using three.js and htmlwidgets.
#'
#' Interactive 3D graphics including point clouds and globes using three.js and htmlwidgets.
#'
#' @name threejs-package
#' @references
#' \url{http://threejs.org}
#' \url{http://www.html5rocks.com/en/tutorials/three/intro/}
#' @aliases threejs
#' @examples
#' \dontrun{
#' library("shiny")
#' runApp(system.file("examples/globe",package="threejs"))
#' runApp(system.file("examples/scatterplot",package="threejs"))
#'
#' # See also help for globe.js and scatterplot3.js
#' }
#' 
#' @docType package
NULL


#' Shiny bindings for threejs widgets
#'
#' Output and render functions for using threejs widgets within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{"100\%"},
#'   \code{"400px"}, \code{"auto"}) or a number, which will be coerced to a
#'   string and have \code{"px"} appended.
#' @param expr An expression that generates threejs graphics.
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @importFrom htmlwidgets shinyWidgetOutput
#' @importFrom htmlwidgets shinyRenderWidget
#'
#' @name threejs-shiny
NULL
