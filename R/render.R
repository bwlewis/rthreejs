setClass("pointLight", representation(color="character", position="numeric"))

#' Directly render threejs scenes
#'
#' Directly render low-level JSON-encoded threejs scenes and objects.
#' Objects with an 'animations' field will be animated using the
#' threejs THREE.animationMixer function.
#'
#' @param scene A JSON-encoded threejs scene or object that can be added to a threejs scene (for instance, a group).
#' @param height The container div height.
#' @param width The container div width.
#' @param bg The container background color.
#' @param camera_position A three-element coordinate position vector of the threejs perspective camera.
#' @param camera_lookat A three-element coordinate position vector that the camera looks at.
#' @param ambient The ambient light color.
#' @param lights Either a single 'pointLight' object, or a list of them.
#' @param ... Optional additional parameters passed to the rendering code.
#'
#' @examples
#' render(gzfile(system.file("extdata/pump.json.gz", package="threejs")), bg="black")
#'
#' @importFrom methods new
#' @export
render <- function(
  scene,
  height = NULL,
  width = NULL,
  bg="white",
  camera_position=c(-5, 3, 10),
  camera_lookat=c(-1, 2, 4),
  ambient="#555555",
  lights=new("pointLight", color="white", position=c(-5, 3, 10)),
  ...)
{
  i <- grep("^#", bg)
  if (length(i) > 0) bg <- substr(bg, 1, 7)
  if (class(lights) != "list") lights <- list(lights)
  x <- list(datauri=jsuri(scene), bg=bg, camera_position=camera_position, camera_lookat=camera_lookat, ambient=ambient, lights=lights)
  additional_args <- list(...)
  if (length(additional_args) > 0) x <- c(x, additional_args)

  htmlwidgets::createWidget(
      name = "render",
      x = x,
      width = width,
      height = height,
      htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
      package = "threejs")
}
