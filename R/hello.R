#' hello
#'
#' Threejs hello world example
#'
#' @param width The container div width.
#' @param height The container div height.
#'
#' @references
#' The threejs project \url{http://threejs.org}.
#' 
#' @examples
#' ## dontrun
#' # A stand-alone example
#' library("threejs")
#' hello()
#' 
#' @seealso scatterplot3d, rgl, scatterplotx3
#' @importFrom rjson toJSON
#' @export
hello <- function(
  height = NULL,
  width = NULL)
{
  # create widget
  htmlwidgets::createWidget(
      name = "hello",
      x = list(data=1),
               width = width,
               height = height,
               htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
               package = "threejs")
}
