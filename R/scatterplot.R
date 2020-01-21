#' Interactive 3D Scatterplots
#'
#' A 3D scatterplot widget using three.js. Many options
#' follow the \code{scatterplot3d} package.
#'
#' @param x Either a vector of x-coordinate values or a  three-column
#' data matrix with columns corresponding to the x,y,z
#' coordinate axes. Column labels, if present, are used as axis labels.
#' @param y (Optional) vector of y-coordinate values, not required if
#' \code{x} is a matrix.
#' @param z (Optional) vector of z-coordinate values, not required if
#' \code{x} is a matrix.
#' @param width The container div width.
#' @param height The container div height.
#' @param axis A logical value that when \code{TRUE} indicates that the
#' axes will be displayed.
#' @param num.ticks A three-element or one-element vector with the suggested number of
#' ticks to display per axis. If a one-element vector, this number of ticks will be used
#' for the axis with the smallest \code{axis.scale}, and the number of ticks on the remaining
#' axes will be increased proportionally to the \code{axis.scale} values. Set to NULL to not display
#' ticks. The number of ticks may be adjusted by the program.
#' @param x.ticklabs A vector of tick labels of length \code{num.ticks[1]}, or
#' \code{NULL} to show numeric labels.
#' @param y.ticklabs A vector of tick labels of length \code{num.ticks[2]}, or
#' \code{NULL} to show numeric labels.
#' @param z.ticklabs A vector of tick labels of length \code{num.ticks[3]}, or
#' \code{NULL} to show numeric labels.
#' @param color Either a single hex or named color name (all points same color),
#' or a vector of  hex or named color names as long as the number of data
#' points to plot.
#' @param size The plot point radius, either as a single number or a
#' vector of sizes of length \code{nrow(x)}.
#' @param cex.symbols Equivalent to the \code{size} parameter.
#' @param flip.y Reverse the direction of the y-axis (the default value of
#' TRUE produces plots similar to those rendered by the R
#' \code{scatterplot3d} package).
#' @param grid Set FALSE to disable display of a grid.
#' @param stroke A single color stroke value (surrounding each point). Set to
#' null to omit stroke (only available in the canvas renderer).
#' @param renderer Select from available plot rendering techniques of
#' 'auto' or 'canvas'. Set to 'canvas' to explicitly use non-accelerated Canvas
#' rendering, otherwise WebGL is used if available.
#' @param signif Number of significant digits used to represent point
#' coordinates. Larger numbers increase accuracy but slow plot generation
#' down.
#' @param bg  The color to be used for the background of the device region.
#' @param xlim Optional two-element vector of x-axis limits. Default auto-scales to data.
#' @param ylim Optional two-element vector of y-axis limits. Default auto-scales to data.
#' @param zlim Optional two-element vector of z-axis limits. Default auto-scales to data.
#' @param pch Optional point glyphs, see notes.
#' @param axis.scale Three-element vector to scale each axis as displayed on the plot,
#' after first scaling them all to a unit length. Default \code{c(1,1,1)} thus results
#' in the axes of equal length. If \code{NA}, the displayed axes will be scaled to the
#' ratios determined from \code{c(xlim,ylim,zlim)}.
#' @param elementId Use an explicit element ID for the widget (rather than an automatically generated one). Useful if you have other JavaScript that needs to explicitly discover and interact with a specific widget instance.
#' @param ... Additional options (see note).
#'
#' @return
#' An htmlwidget object that is displayed using the object's show or print method.
#' (If you don't see your widget plot, try printing it with the \code{print} function.)
#'
#' @section Scaling the axes:
#' With the default values, the displayed axes are scaled to equal one-unit length. If
#' you instead need to maintain the relative distances between points in the original data,
#' and the same distance between the tick labels, pass \code{num.ticks=6} (or any other single
#' number) and \code{axis.scale=NA}
#' @section Interacting with the plot:
#' Press and hold the left mouse button (or touch or trackpad equivalent) and move
#' the mouse to rotate the plot. Press and hold the right mouse button (or touch
#' equivalent) to pan. Use the mouse scroll wheel or touch equivalent to zoom.
#' If \code{labels} are specified (see below), moving the mouse pointer over
#' a point will display the label.
#'
#' @section Detailed plot options:
#' Use the optional \code{...} argument to explicitly supply \code{axisLabels}
#' as a three-element character vector, see the examples below. A few additional
#' plot options are also supported:
#' \itemize{
#'   \item{"lights"}{ a list of \code{light_ambient} and \code{light_directional} objects}
#'   \item{"cex.lab"}{ font size scale factor for the axis labels}
#'   \item{"cex.axis"}{ font size scale factor for the axis tick labels}
#'   \item{"font.axis"}{ CSS font string used for all axis labels}
#'   \item{"font.symbols"}{ CSS font string used for plot symbols}
#'   \item{"font.main"}{ CSS font string used for main title text box}
#'   \item{"labels"}{ character vector of length \code{x} of point labels displayed when the mouse moves over the points}
#'   \item{"main"}{ Plot title text}
#'   \item{"top"}{ Top location in pixels from top of the plot title text}
#'   \item{"left"}{ Left location in pixels from center of the plot title text}
#' }
#' The default CSS font string is "48px Arial". Note that the format of this
#' font string differs from, for instance, the usual `par(font.axis)`.
#'
#' Use the \code{pch} option to specify points styles in WebGL-rendered plots.
#' \code{pch} may either be a single character value that applies to all points,
#' or a vector of character values of the same length as \code{x}. All
#' character values are used literally ('+', 'x', '*', etc.) except for the
#' following special cases:
#' \itemize{
#'   \item{"o"}{ Plotted points appear as 3-d spheres.}
#'   \item{"@"}{ Plotted points appear as stroked disks.}
#'   \item{"."}{ Points appear as tiny squares.}
#' }
#' Character strings of more than one character are supported--see the examples.
#' The \code{@} and {.} option exhibit the best performance, consider using
#' one of those to plot large numbers of points.
#'
#' Set the optional experimental \code{use.orbitcontrols=TRUE} argument to
#' use a more CPU-efficient but somewhat less fluid mouse/touch interface.
#'
#' @section Plotting lines:
#' See \code{\link{lines3d}} for an alternative interface.
#' Lines are optionally drawn between points specified in \code{x, y, z} using
#' the following new plot options.
#' \itemize{
#'   \item{"from"}{ A numeric vector of indices of line starting vertices corresponding to entries in \code{x}.}
#'   \item{"to"}{ A numeric vector exactly as long as \code{from} of indices of line ending vertices corresponding
#'       to entries in \code{x}.}
#'   \item{"lcol"}{ Either a single color value or vector of values as long as from; line colors
#'      default to interpolating their vertex point colors.}
#'   \item{"lwd"}{ A single numeric value of line width (for all lines), defaults to 1.}
#'   \item{"linealpha"}{ A single numeric value between 0 and 1 inclusive setting the transparency of all plot lines,
#'      defaulting to 1.}
#' }
#'
#' @section Highlighting selected points:
#' Specify the argument \code{brush=TRUE} to highlight a clicked point (currently
#' limited to single-point selection).
#' Optionally set the \code{highlight=<color>} and \code{lowlight=<color>}
#' to manually control the brushing display colors. This feature works with
#' crosstalk.
#'
#' @section Crosstalk:
#' The \code{scatterplot3js()} and \code{graphjs()} functions work with
#' crosstalk selection (but not filtering yet); see https://rstudio.github.io/crosstalk/.
#' Enable crosstalk with the optional agrument \code{crosstalk=df}, where \code{df} is a
#' crosstalk-SharedData data.frame-like object with the same number of rows as points
#' (\code{scatterplot3js()}) or graph vertices (\code{graphjs()}) (see the examples).
#'
#' @note
#' Points with missing values are omitted from the plot, please try to avoid missing values
#' in \code{x, y, z}.
#'
#' @references
#' The three.js project: \url{http://threejs.org}. The HTML Widgets project: \url{http://htmlwidgets.org}.
#'
#' @examples
#' # Example 1 from the scatterplot3d package (cf.)
#' z <- seq(-10, 10, 0.1)
#' x <- cos(z)
#' y <- sin(z)
#' scatterplot3js(x, y, z, color=rainbow(length(z)))
#'
#' # Same example with explicit axis labels
#' scatterplot3js(x, y, z, color=rainbow(length(z)), axisLabels=c("a", "b", "c"))
#'
#' # Same example showing multiple point styles with pch
#' scatterplot3js(x, y, z, color=rainbow(length(z)),
#'                pch=sample(c(".", "o", letters), length(x), replace=TRUE))
#'
#' # Point cloud example, should run this with WebGL!
#' N     <- 20000
#' theta <- runif (N) * 2 * pi
#' phi   <- runif (N) * 2 * pi
#' R     <- 1.5
#' r     <- 1.0
#' x <- (R + r * cos(theta)) * cos(phi)
#' y <- (R + r * cos(theta)) * sin(phi)
#' z <- r * sin(theta)
#' d <- 6
#' h <- 6
#' t <- 2 * runif (N) - 1
#' w <- t^2 * sqrt(1 - t^2)
#' x1 <- d * cos(theta) * sin(phi) * w
#' y1 <- d * sin(theta) * sin(phi) * w
#' i <- order(phi)
#' j <- order(t)
#' col <- c( rainbow(length(phi))[order(i)],
#'          rainbow(length(t), start=0, end=2/6)[order(j)])
#' M <- cbind(x=c(x, x1), y=c(y, y1), z=c(z, h*t))
#' scatterplot3js(M, size=0.5, color=col, bg="black", pch=".")
#'
#' # Plot generic text using 'pch' (we label some points in this example)
#' set.seed(1)
#' x <- rnorm(5); y <- rnorm(5); z <- rnorm(5)
#' scatterplot3js(x, y, z, pch="@") %>%
#'    points3d(x + 0.1, y + 0.1, z, color="red", pch=paste("point", 1:5))
#'
#' \dontrun{
#'   # A shiny example
#'   shiny::runApp(system.file("examples/scatterplot", package="threejs"))
#' }
#'
#' \dontrun{
#'   # A crosstalk example
#'   library(crosstalk)
#'   library(d3scatter) # devtools::install_github("jcheng5/d3scatter")
#'   z <- seq(-10, 10, 0.1)
#'   x <- cos(z)
#'   y <- sin(z)
#'   sd <- SharedData$new(data.frame(x=x, y=y, z=z))
#'   print(bscols(
#'     scatterplot3js(x, y, z, color=rainbow(length(z)), brush=TRUE, crosstalk=sd),
#'     d3scatter(sd, ~x, ~y, width="100%", height=300)
#'   ))
#' }
#'
#' @seealso scatterplot3d, rgl, points3d, lines3d, light_ambient, light_directional
#' @importFrom stats na.omit
#' @importFrom crosstalk is.SharedData
#' @export
scatterplot3js <- function(
  x, y, z,
  height = NULL,
  width = NULL,
  axis = TRUE,
  num.ticks = c(6, 6, 6),
  x.ticklabs = NULL,
  y.ticklabs = NULL,
  z.ticklabs = NULL,
  color = "steelblue",
  size = cex.symbols,
  stroke = "black",
  flip.y = TRUE,
  grid = TRUE,
  renderer = c("auto", "canvas"),
  signif = 8,
  bg = "#ffffff",
  cex.symbols = 1,
  xlim, ylim, zlim,
  axis.scale = c(1,1,1),
  pch="@",
  elementId=NULL, ...)
{
  if(is.null(elementId))
  {
    elementId <- paste0(sample(c(letters, LETTERS, 0:9), 10, replace=TRUE), collapse="")
  }
  # validate input
  if (!missing(y) && !missing(z)) {
    if (is.matrix(x))
      stop("Specify either: A three-column matrix x or, Three vectors x, y, and z. See ?scatterplot3js for help.")
    x <- cbind(x = x, y = y, z = z)
  }
  if (is.list(x))
  {
    if (!all(lapply(x, ncol) == 3)) stop("x must be a three column matrix")
    x <- lapply(x, function(y) {
        ans <- if (is.data.frame(y)) as.matrix(y) else y
        na.omit(ans)
      })
  } else
  {
    if (ncol(x) != 3) stop("x must be a three column matrix")
    if (is.data.frame(x)) x <- as.matrix(x)
    if (!is.matrix(x)) stop("x must be a three column matrix")
    x <- list(na.omit(x))
  }
  NROW <- nrow(x[[1]])
  if (missing(pch)) pch <- rep("@", NROW)
  if (length(pch) != NROW) pch <- rep_len(pch, NROW)
  renderer <- match.arg(renderer)
  if(renderer == "canvas")
  {
    stop("Canvas rendering temporarily disabled in this version.")
  }

  # Strip alpha channel from colors and standardize color values
  if (!is.list(color)) color <- list(color)
  color <- lapply(color, function(x) col2rgb(x, alpha=TRUE))
  a <- lapply(color, function(x) as.vector(x[4, ]) / 255)   # alpha values
  color <- lapply(color, function(y) apply(y, 2, function(x) rgb(x[1], x[2], x[3], maxColorValue=255)))

  bg <- sub("^(#[[:xdigit:]]{6}+).*$", "\\1", bg, perl = TRUE)

  options <- c(as.list(environment()), list(...))
  options <- options[!(names(options) %in% c("x", "y", "z", "i", "j", "a"))]
  vcache <- x # cache un-transformed points for re-use

  # javascript does not like dots in names
  names(options) <- gsub("\\.", "", names(options))

  if (!is.null(options$highlight)) options$highlight <- gcol(options$highlight)$color
  if (!is.null(options$lowlight)) options$lowlight <- gcol(options$lowlight)$color

  # re-order so z points up as expected.
  x <- lapply(x, function(y) y[, c(1, 3, 2), drop=FALSE])

  # set axis labels if they exist
  if (!is.null(colnames(x[[1]])) && is.null(options$axisLabels))
    options$axisLabels <- colnames(x[[1]])[1:3]
  # Avoid asJson named vector warning
  colnames(x[[1]]) <- NULL

  # Scale x to the output axis.scale ratio.
  n <- NROW
  mn <- Reduce(pmin, lapply(x, function(y) apply(y[, 1:3, drop=FALSE], 2, min)))
  mx <- Reduce(pmax, lapply(x, function(y) apply(y[, 1:3, drop=FALSE], 2, max)))
  if (!missing(xlim) && length(xlim) == 2) {
    mn[1] <- xlim[1]
    mx[1] <- xlim[2]
  }
  if (!missing(ylim) && length(ylim) == 2) {
    mn[3] <- ylim[1]
    mx[3] <- ylim[2]
  }
  if (!missing(zlim) && length(zlim) == 2) {
    mn[2] <- zlim[1]
    mx[2] <- zlim[2]
  }
  if(any(is.na(axis.scale))) {
    axis.scale <- mx - mn
  } else {
    if(length(axis.scale)!=3) {
      stop("axis.scale must be a vector of length three")
    }
    #reorder like the x
    axis.scale <- axis.scale[c(1,3,2)]
  }
  #scale axis.scale so that the min value == 1; code below depends on it
  axis.scale <- axis.scale / min(axis.scale)

  x <- lapply(x, function(x) ((x[, 1:3, drop=FALSE] - rep(mn, each = n)) / rep((mx - mn)/axis.scale, each = n)))

  if (flip.y)
  {
    x <- lapply(x, function(y)
      {
        y[, 3] <- axis.scale[3] - y[, 3]
        y
      })
  }

  if ("center" %in% names(options) && options$center) # not yet documented, useful for graph
  {
    x <- lapply(x, function(y) 2 * (y - axis.scale/2))
# FIXME adjust scale/tick marks
  }
  if (!("linealpha" %in% names(options))) options$linealpha <- 1
  if (!("alpha" %in% names(options))) options$alpha <- a

  # convert matrix to a array required by scatterplotThree.js and strip
  x <- lapply(x, function(y) as.vector(t(signif(y, signif))))
  options$vertices <- x

  # Ticks
  if (!is.null(num.ticks))
  {
    if (length(num.ticks) != 3) {
      if(length(num.ticks) != 1) {
        stop("num.ticks must have length 3")
      }
      num.ticks <- round(max(1,num.ticks) * axis.scale)
    }
    else {
      num.ticks <- pmax(1, num.ticks[c(1, 3, 2)])
    }

    t1 <- seq(from=mn[1], to=mx[1], length.out=num.ticks[1])
    p1 <- (t1 - mn[1]) / (mx[1] - mn[1]) * axis.scale[1]
    t2 <- seq(from=mn[2], to=mx[2], length.out=num.ticks[2])
    p2 <- (t2 - mn[2]) / (mx[2] - mn[2]) * axis.scale[2]
    t3 <- seq(from=mn[3], to=mx[3], length.out=num.ticks[3])
    p3 <- (t3 - mn[3]) / (mx[3] - mn[3]) * axis.scale[3]
    if (flip.y) t3 <- t3[length(t3):1]

    pfmt <- function(x, d=2)
    {
      ans <- sprintf("%.2f", x)
      i <- (abs(x) < 0.01 & x != 0)
      if (any(i))
      {
        ans[i] <- sprintf("%.2e", x)
      }
      ans
    }

    options$xticklab <- pfmt(t1)
    options$yticklab <- pfmt(t2)
    options$zticklab <- pfmt(t3)
    if (!is.null(x.ticklabs)) options$xticklab <- x.ticklabs
    if (!is.null(y.ticklabs)) options$zticklab <- y.ticklabs
    if (!is.null(z.ticklabs)) options$yticklab <- z.ticklabs
    options$xtick <- p1
    options$ytick <- p2
    options$ztick <- p3
  }

  names(axis.scale) <- NULL
  options$axislength <- axis.scale

  # lines
  if ("from" %in% names(options))
  {
    if (!("to" %in% names(options))) stop("both from and to must be specified")
    if (!is.list(options$from)) options$from <- list(options$from)
    if (!is.list(options$to)) options$to <- list(options$to)
    options$from <- Map(indexline, options$from)
    options$to <- Map(indexline, options$to)
    if (!("lwd" %in% names(options))) options$lwd <- 1L
    if ("lcol" %in% names(options)) # discard alpha, normalize line colors
    {
      if (!is.list(options$lcol)) options$lcol <- list(options$lcol)
      lc <- Map(function(x) col2rgb(x, alpha=FALSE), options$lcol)
      options$lcol <- Map(function(x) apply(x, 2, function(x) rgb(x[1], x[2], x[3], maxColorValue=255)), lc)
    }
  }
  # validate animation frames
  if (length(options$from) != length(options$to)) stop("mismatched line from/to animation coordinates")
  N <- length(options$from) - length(options$vertices)
  if (N > 0) # not enough vertex positions, replicate as needed
  {
    options$vertices <- c(options$vertices, replicate(N, options$vertices[[length(options$vertices)]], FALSE))
  }

  # crosstalk
  options$crosstalk_key <- NULL
  options$crosstalk_group <- NULL
  if (is.SharedData(options$crosstalk))
  {
    options$crosstalk_key <- options$crosstalk$key()
    options$crosstalk_group <- options$crosstalk$groupName()
  }
  options$crosstalk <- NULL

  # Experimental deferred animation, desgined for interactive use with crosstalk
  # (this is not documented yet and may change significantly)
  if (!is.null(options$defer) && options$defer)
  {
    names(options$vertices) = NULL
    names(options$color) = NULL
    names(options$alpha) = NULL
    names(options$from) = NULL
    names(options$to) = NULL
    names(options$main) = NULL
    options$defer <- list(
      vertices=options$vertices,
      color=options$color,
      alpha=options$alpha,
      from=options$from,
      to=options$to,
      main=options$main
    )
    options$fpl <- -1
    options$fps <- NULL
    options$vertices <- list(options$vertices[[1]])
    options$color <- list(options$color[[1]])
    options$alpha <- list(options$alpha[[1]])
    if(!is.null(options$from))
    {
      options$from <- list(options$from[[1]])
      options$to <- list(options$to[[1]])
    }
  }

  # Don't create the widget; instead only return the options
  if (!is.null(options$options) && options$options) return(options)

  ans <- htmlwidgets::createWidget(
          name = "scatterplotThree",
          x = options,
          width = width,
          height = height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          dependencies = crosstalk::crosstalkLibs(),
          package = "threejs",
          elementId=elementId)
  ans$call <- match.call()
  ans$vcache <- vcache # cached, un-transformed points for re-use (see points3d)
  ans$points3d <- function(...) stop("Syntax for adding points has changed: See ?points3d for examples.")
  ans
}


setOldClass("scatterplotThree")
#' Extract a matrix of vertex coordinates from a threejs widget
#'
#' @param ... a \code{scatterplotThree} object from the threejs package.
#' @seealso points3d
#' @importFrom igraph vertices
#' @importFrom methods setOldClass setMethod
#' @export
setMethod("vertices", signature(...="scatterplotThree"),
  function(...) {
    list(...)[[1]]$vcache
  })

#' Add points to a 3D scatterplot
#'
#' @param s A non-animated scatterplot object returned by \code{\link{scatterplot3js}}.
#' @param x Either a vector of x-coordinate values or a  three-column
#' data matrix with columns corresponding to the x,y,z
#' coordinate axes. Column labels, if present, are used as axis labels.
#' @param y (Optional) vector of y-coordinate values, not required if
#' \code{x} is a matrix.
#' @param z (Optional) vector of z-coordinate values, not required if
#' \code{x} is a matrix.
#' @param color Either a single hex or named color name (all points same color),
#' or a vector of  hex or named color names as long as the number of points in \code{x}.
#' @param pch Optional point glyphs or text strings, see \code{\link{scatterplot3js}}.
#' @param size The plot point radius, either as a single number or a
#' vector of sizes of length \code{nrow(x)}.
#' @param labels Character vector of length \code{x} of point labels displayed when the mouse moves over the points.
#' @return A new scatterplot htmlwidget object.
#' @note This function replaces the old \code{points3d} approach used by \code{scatterplot3d}.
#' @examples
#' \dontrun{
#'  # Adding point labels to a scatterplot:
#'  x <- rnorm(5)
#'  y <- rnorm(5)
#'  z <- rnorm(5)
#'  scatterplot3js(x, y, z, pch="o") %>%
#'    points3d(x + 0.1, y + 0.1, z, color="red", pch=paste("point", 1:5))
#'
#' # Adding point labels to a graph, obtaining the graph vertex coordinates
#' # with the `vertices()` function:
#' data(LeMis)
#' graphjs(LeMis) %>% points3d(vertices(.), color="red", pch=V(LeMis)$label)
#'
#' }
#' @export
points3d <- function(s, x, y, z, color="orange", pch="@", size=1, labels="")
{
  stopifnot(inherits(s, "scatterplotThree"))
  options <- s$x
  N <- length(options$vertices)  # number of animation frames, update last one
  # validate input
  if (!missing(y) && !missing(z)) {
    if (is.matrix(x))
      stop("Specify either: A three-column matrix x or, Three vectors x, y, and z. See ?scatterplot3js for help.")
    x <- cbind(x = x, y = y, z = z)
  }
  if (is.list(x))
  {
    if (!all(lapply(x, ncol) == 3)) stop("x must be a three column matrix")
    x <- lapply(x, function(y) {
        ans <- if (is.data.frame(y)) as.matrix(y) else y
        na.omit(ans)
      })
  } else
  {
    if (ncol(x) != 3) stop("x must be a three column matrix")
    if (is.data.frame(x)) x <- as.matrix(x)
    if (!is.matrix(x)) stop("x must be a three column matrix")
    x <- list(na.omit(x))
  }
  if (length(x) > 1) warning("Animation not supported, only last frame used")
  x <- x[[1]]
  colnames(x) <- NULL
  NROW <- nrow(x)
  if (length(color) != NROW) color <- rep_len(color, NROW)
  if (length(pch) != NROW) pch <- rep_len(pch, NROW)
  if (length(size) != NROW) size <- rep_len(size, NROW)
  if (length(labels) != NROW) labels <- rep_len(labels, NROW)

  # use scatterplot3js to scale/transform vertices as required
  oldlen <- length(options$vertices[[N]]) / 3
  if(is.list(s$vcache)) x <- rbind(s$vcache[[N]], x)
  else x <- rbind(s$vcache, x)
  center <- options$center
  if (is.null(center)) center <- FALSE
  args <- list(x=x, center=center, flip.y=options$flipy, options=TRUE, axis=options$axis,
               color=color, num.ticks=options$numticks, x.ticklabs=options$xticklabs,
               y.ticklabs=options$yticklabs, z.ticklabs=options$zticklabs,
               axis.scale=options$axisscale)
  if (!is.null(options$xlim) || !is.symbol(options$xlim)) args$xlim <- options$xlim
  if (!is.null(options$ylim) || !is.symbol(options$ylim)) args$ylim <- options$ylim
  if (!is.null(options$zlim) || !is.symbol(options$zlim)) args$zlim <- options$zlim
  t <- do.call("scatterplot3js", args=args)

  # update animated options
  options$vertices[[N]] <- t$vertices[[1]]
  if (is.null(options$color[[N]])) options$color[[N]] <- rep_len("orange", oldlen)
  if (length(options$color[[N]]) < oldlen) options$color[[N]] <- rep_len(options$color[[N]], oldlen)
  options$color[[N]] <- c(options$color[[N]], t$color[[1]])
  if (length(options$alpha[[N]]) < oldlen) options$alpha[[N]] <- rep_len(options$alpha[[N]], oldlen)
  options$alpha[[N]] <- c(options$alpha[[N]], t$alpha[[1]])
  # update static options
  if (length(options$pch) < oldlen) options$pch <- rep_len(options$pch, oldlen)
  options$pch <- c(options$pch, pch)
  if (length(options$size) < oldlen) options$size <- rep_len(options$size, oldlen)
  options$size <- c(options$size, size)
  if (is.null(options$labels)) options$labels <- rep_len("", oldlen)
  options$labels <- c(options$labels, labels)
  options$xticklab <- t$xticklab
  options$yticklab <- t$yticklab
  options$zticklab <- t$zticklab
  options$xtick <- t$xtick
  options$ytick <- t$ytick
  options$ztick <- t$ztick


  ans <- htmlwidgets::createWidget(
          name = "scatterplotThree",
          x = options,
          width = s$width,
          height = s$height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          dependencies = crosstalk::crosstalkLibs(),
          package = "threejs")
  ans$call <- match.call()
  ans$vcache <- x
  ans
}

#' Add lines to a 3D scatterplot
#'
#' @param s A scatterplot object returned by \code{\link{scatterplot3js}}.
#' @param from A vector of integer indices of starting points.
#' @param to A vector of integer indices of ending points of the same length as \code{from}.
#' @param color Either a single color value or vector of values as long as \code{from} of line colors;
#'        line colors default to interpolating their vertex point colors.
#' @param lwd A single numeric value of line width (applies to all lines).
#' @param alpha A single numeric value of line alpha (applies to all lines).
#' @return A new scatterplot htmlwidget object.
#' @note This function replaces the old \code{points3d} approach used by \code{scatterplot3d}.
#' @examples
#' \dontrun{
#'  x <- rnorm(5)
#'  y <- rnorm(5)
#'  z <- rnorm(5)
#'  scatterplot3js(x, y, z, pch="@", color=rainbow(5)) %>%
#'    lines3d(c(1, 2), c(3, 4), lwd=2)
#' }
#' @export
lines3d <- function(s, from, to, lwd=1, alpha=1, color)
{
  stopifnot(inherits(s, "scatterplotThree"))
  options <- s$x
  lf <- length(from)
  if(lf != length(to)) stop("`from` and `to` must be the same length")
  N <- length(options$vertices)  # number of animation frames, update last one
  from <- Map(indexline, list(from))
  to <- Map(indexline, list(to))
  lcol <- NULL
  if (! missing(color)) # discard alpha, normalize line colors
  {
    lcol <- list(color)
    lc <- Map(function(x) col2rgb(x, alpha=FALSE), lcol)
    lcol <- unlist(Map(function(x) apply(x, 2, function(x) rgb(x[1], x[2], x[3], maxColorValue=255)), lc))
    lcol <- rep_len(lcol, lf)
  }
  if (is.null(options$from))
  {
    options$from <- list(unlist(from))
    options$to <- list(unlist(to))
    if (! missing(color)) options$lcol <- list(unlist(lcol))
  } else {
    if(is.list(options$from[[N]])) options$from[[N]] <- c(unlist(options$from[[N]]), unlist(from))
    else options$from[[N]] <- c(options$from[[N]], unlist(from))
    if(is.list(options$to[[N]])) options$to[[N]] <- c(unlist(options$to[[N]]), unlist(to))
    else options$to[[N]] <- c(options$to[[N]], unlist(to))
    if (! missing(color)) options$lcol[[N]] <- c(unlist(options$lcol[[N]]), unlist(lcol))
  }
  options$lwd <- lwd
  options$linealpha <- alpha
  ans <- htmlwidgets::createWidget(
          name = "scatterplotThree",
          x = options,
          width = s$width,
          height = s$height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          dependencies = crosstalk::crosstalkLibs(),
          package = "threejs")
  ans$vcache <- s$vcache
  ans$call <- match.call()
  ans
}

#' Plot illumination
#' @param color the light color
#' @param position the light position as an (x, y, z) coordinate vector with entries in [-1, 1]
#' @return An object for use with the \code{lights} argument in \code{scatterplot3js} and \code{graphjs}.
#' @export
light_directional <- function(color = "#eeeeee", position = c(0, 0, 0))
{
  if(length(position) != 3) stop("Specify position as x, y, z coordinate vector, each in range [-1, 1].")
  list(type = "directional", color = color, position = position)
}

#' Plot illumination
#' @param color the ambient light color
#' @return An object for use with the \code{lights} argument in \code{scatterplot3js} and \code{graphjs}.
#' @export
light_ambient <- function(color = "#eeeeee")
{
  list(type = "ambient", color = color)
}


#' @rdname threejs-shiny
#' @export
scatterplotThreeOutput <- function(outputId, width="100%", height="500px") {
    shinyWidgetOutput(outputId, "scatterplotThree", width, height, package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderScatterplotThree <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) expr <- substitute(expr) # force quoted
    shinyRenderWidget(expr, scatterplotThreeOutput, env, quoted = TRUE)
}
