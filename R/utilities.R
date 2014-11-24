#' texture Convert a matrix or raster image to a three.js texture
#'
#' Convert matrix or raster image image representations in R into
#' JSON-formatted arrays suitable for use as three.js DataTexture
#' RGBA textures.
#'
#' @param data  A data matrix representing a grayscale image or a
#' raster image object with optional alpha channel.
#' @param alpha The default alpha level in [0,1] to use if not
#' specified in the raster image format.
#'
#' @return JSON-formatted string suitable for use as a three.js
#' texture.
#'
#' @note
#' Due to browser
#' "same origin policy" security restrictions, loading textures
#' from a file system in three.js may lead to a security exception,
#' see 
#' \url{https://github.com/mrdoob/three.js/wiki/How-to-run-things-locally}.
#' References to file locations work in Shiny apps, but not in stand-alone
#' examples. The \code{texture} function facilitates transfer of image
#' texture data from R using the three.js \code{DataTexture} function.
#' Binary image data are encoded and inserted into three.js without using
#' files.
#'
#' Note that this method limits each image dimension to a power of two
#' (see \url{https://github.com/mrdoob/three.js/issues/1277}). Also note
#' that this is not that efficient for large images. Consider using shiny
#' and file references in that case.
#'
#' @references
#' The threejs project \url{http://threejs.org}.
#' \url{https://github.com/mrdoob/three.js/wiki/How-to-run-things-locally}.
#' 
#' @examples
#' ## dontrun
#' library("png")
#' img <- readPNG(system.file("img", "Rlogo.png", package="png"))
#' texture(img)
#' 
#' @importFrom rjson toJSON
#' @export
texture = function(data, alpha=1)
{ 
  d = dim(data)
  if(length(d)<2) stop("data must be a matrix or raster image")
  dnew = 2^ceiling(log(d,2))
  if(length(d)==2) dnew=c(dnew,4)
  x = array(0,dnew)
  if(length(d)==2)
  {
    a = data - min(data)
    a = floor(255*(a/max(a)))
    x[1:d[1],1:d[2],1] = a
    x[1:d[1],1:d[2],2] = a
    x[1:d[1],1:d[2],3] = a
    x[1:d[1],1:d[2],4] = floor(255*alpha)
  } else
  {
    a = data[,,1:3] - min(data[,,1:3])
    a = floor(255*(a/max(a)))
    x[1:d[1],1:d[2],1] = a[,,1]
    x[1:d[1],1:d[2],2] = a[,,2]
    x[1:d[1],1:d[2],3] = a[,,3]
    if(d[3]>3)
      x[1:d[1],1:d[2],4] = floor(255*data[,,3])
    else
      x[1:d[1],1:d[2],4] = floor(255*alpha)
  }
  toJSON(as.vector(t(cbind(as.vector(t(x[,,1])),as.vector(t(x[,,2])),as.vector(t(x[,,3])),as.vector(t(x[,,4]))))))
}
