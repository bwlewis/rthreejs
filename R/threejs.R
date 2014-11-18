
#' Tools for creating threejs and d3.js graphics from R
#'
#' Tools for creating threejs and d3.js graphics from R
#'
#' @name threejs-package
#' @aliases threejs
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
