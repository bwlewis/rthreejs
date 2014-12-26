#' Convert a PNG image file to a three.js texture
#'
#' Convert file image representations in R into JSON-formatted arrays
#' suitable for use as three.js textures. This function is automatically
#' invoked for images used in the \code{globejs} function.
#'
#' @param data  A data matrix representing a grayscale image or 
#' a file name referring to a PNG image file.
#'
#' @return JSON-formatted list with image, width, and height fields
#' suitable for use as a three.js
#' texture created with the base64texture function. The image field
#' contains a base64 dataURI encoding of the image.
#'
#' @note
#' Due to browser
#' "same origin policy" security restrictions, loading textures
#' from a file system in three.js may lead to a security exception,
#' see 
#' \url{https://github.com/mrdoob/three.js/wiki/How-to-run-things-locally}.
#' References to file locations work in Shiny apps, but not in stand-alone
#' examples. The \code{texture} function facilitates transfer of image
#' texture data from R into three.js textures. Binary image data are
#' encoded and inserted into three.js without using files as dataURIs.
#'
#' @references
#' The threejs project \url{http://threejs.org}.
#' \url{https://github.com/mrdoob/three.js/wiki/How-to-run-things-locally}.
#' 
#' @examples
#' ## dontrun
#' img <- system.file("img", "Rlogo.png", package="png")
#' texture(img)
#' 
#' @importFrom rjson toJSON
#' @importFrom base64 img
#' @export
texture = function(data)
{ 
# Encode the file as a dataURI
  d = img(data)
  list(img=gsub("\".*","",substr(d,11,nchar(d))), dataURI=TRUE)
}
