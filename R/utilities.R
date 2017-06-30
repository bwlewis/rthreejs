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
texture <- function(data)
{
  ext <- gsub(".*\\.", "", data)
  if (grepl("^http", data))
  {
    u <- url(data, open="rb")
    data <- tempfile()
    on.exit(unlink(data))
    writeBin(readBin(u, what="raw", n=10e6), data, useBytes=TRUE)
    close(u)
  }
# Encode the file as a dataURI
  if (nchar(ext) < 1) ext <- "png"
  img <- dataURI(file=data, mime=sprintf("image/%s", ext))
  list(img=img, dataURI=TRUE)
}

# internal non-braindead if-else
ifel <- function(a, b, c)
{
  if (isTRUE(a)) return(b)
  c
}

# parse graph options from a list
# @param g
# @return list
# internal function
gopts <- function(g)
{
  color <- NULL
  lcol <- NULL
  from <- g$from
  to <- g$to
  alpha <- NULL
  if ("igraph" %in% class(g[[1]]))
  {
    from <- as_edgelist(g[[1]])
    to   <- from[, 2] - 1
    from <- from[, 1] - 1
    layout <- g[[1]]$layout
    color <- gcol(V(g[[1]])$color)
    alpha <- color$alpha
    color <- color$color
    lcol <- gcol(E(g[[1]])$color)$color
  }
  if ("layout" %in% names(g)) layout <- g$layout
  if ("vertex.color" %in% names(g))
  {
    color <- gcol(g$vertex.color)
    alpha <- color$alpha
    color <- color$color
  }
  if ("edge.color" %in% names(g)) lcol <- gcol(g$edge.color)$color
  ans <- list(layout=layout, from=from, to=to, color=color, lcol=lcol, alpha=alpha, cumulative=g$cumulative)
  if (!is.null(ans$cumulative) && !ans$cumulative) ans$cumulative <- NULL
  ans <- ans[!vapply(ans, is.null, TRUE)]
  if (!("layout" %in% names(ans))) stop("missing layout")
  # re-order y, z, flip y, convert to vector (centering handled by JavaScript)
  ans$layout <- ans$layout[, c(1, 3, 2), drop=FALSE]
  ans$layout[, 3] <- 1 - ans$layout[, 3]
  ans$layout <- signif(as.vector(t(ans$layout)), 8)
  ans
}

#' A basic internal color format parser
#' @param x a character-valued color name
#' @return a list of 3-hex-digit color values and scalar numeric alpha values
#' @importFrom grDevices col2rgb rgb
gcol <- function(x)
{
  if (is.null(x)) return(list(color=NULL, alpha=NULL))
  c <- col2rgb(x, alpha=TRUE)
  a <- as.vector(c[4, ] / 255)   # alpha values
  list(color = apply(c, 2, function(x) rgb(x[1], x[2], x[3], maxColorValue=255)), alpha = a)
}

# internal function used in scatterplot3js
indexline <- function(x) # zero index and make sure each element is an array in JavaScript
{
  a <- as.integer(x) - 1L
  if (length(a) == 1) a <- list(a)
  a
}
