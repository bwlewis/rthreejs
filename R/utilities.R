#' Convert an image file or uri to a three.js texture
#'
#' Convert file image representations in R into JSON-formatted arrays
#' suitable for use as three.js textures. This function is automatically
#' invoked for images used in the \code{globejs} function.
#'
#' @param data A character string file name referring to an image file,
#' or referring to an image uri (see the examples).
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
#' \dontrun{
#' # A big image (may take a while to download):
#' img <- paste("http://eoimages.gsfc.nasa.gov/",
#'              "images/imagerecords/73000/73909/",
#'              "world.topo.bathy.200412.3x5400x2700.jpg", sep="")
#' t <- texture(img)
#' }
#' 
#' @importFrom base64enc dataURI
#' @export
texture = function(data)
{
  ext = gsub(".*\\.","", data)
  if(grepl("^http", data))
  {
    u = url(data, open="rb")
    data = tempfile()
    on.exit(unlink(data))
    writeBin(readBin(u, what="raw", n=10e6), data, useBytes=TRUE)
    close(u)
  }
# Encode the file as a dataURI
  if(nchar(ext) < 1) ext = "png"
  img = dataURI(file=data, mime=sprintf("image/%s", ext))
  list(img=img, dataURI=TRUE)
}
