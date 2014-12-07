#' scatterplot3.js Three.js 3D scatterplot widget.
#'
#' A 3D scatterplot widget using d3.js and three.js.
#'
#' @param x A data matrix with three columns corresponding to the x,y,z
#' coordinate axes. Column labels, if present, are used as axis labels.
#' @param width The container div width.
#' @param height The container div height.
#' @param num.ticks A three-element vector with the suggested number of
#' ticks to display per axis. Set to NULL to not display ticks.
#' @param color Either a single hex or named color name, or
#' a vector of color names of length \code{nrow(x)} (see note below).
#' @param size The plot point radius, either as a single number or a
#' vector of sizes of length \code{nrow(x)}.
#' @param grid Set FALSE to disable display of a grid.
#' @param stroke A single color stroke value (surrounding each point). Set to
#' null to omit stroke.
#'
#' @note
#' The three.js color specifications used in this function accept RGB colors
#' specified by color names or hex color value like \code{"#ff22aa"}. Most
#' of R's color palette functions return RGBA hex color value strings, and
#' the extra alpha specification is not compatible with the three.js color
#' specification used here (by the \code{THREE.Color} javascript function).
#' When using R color palette hex values, it is necessary to truncate the
#' last two alpha characters, for example with the \code{substr} function as
#' illustrated in the example below.
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#' 
#' @examples
#' ## dontrun
#' # A stand-alone example
#' set.seed(1)
#' x <- matrix(rnorm(100*3),ncol=3)
#' scatterplot3.js(x, color=substr(heat.colors(100), 1, 7))
#'
#' # A shiny example
#' library("shiny")
#' runApp(system.file("examples/scatterplot",package="threejs"))
#' 
#' @seealso scatterplot3d, rgl
#' @importFrom rjson toJSON
#' @export
scatterplot3.js <- function(
  x,
  height = NULL,
  width = NULL,
  axis = TRUE,
  num.ticks = c(6,6,6),
  color = "steelblue",
  stroke = "black",
  size = 1,
  grid = TRUE)
{
  # validate input
  if(ncol(x)!=3) stop("x must be a three column matrix")
  if(is.data.frame(x)) x = as.matrix(x)
  if(!is.matrix(x)) stop("x must be a three column matrix")

  # create options
  options = as.list(environment())[-1]
  # javascript does not like dots in names
  i = grep("\\.",names(options))
  if(length(i)>0) names(options)[i] = gsub("\\.","",names(options)[i])

  # Our s3d.js Javascript code assumes a coordinate system in the unit box.
  # Scale x to fit in there.
  n = nrow(x)
  mn = apply(x,2,min)
  mx = apply(x,2,max)
  x = (x - rep(mn, each=n))/(rep(mx - mn, each=n))
  
  # convert matrix to a JSON array required by scatterplotThree.js and strip
  # them (required by s3d.js)
  if(length(colnames(x))==3) options$labels = colnames(x)
  colnames(x)=c()
  x = toJSON(Reduce(c,apply(x,1,list)))

  # R does a nice job of making reasonable ticks.
  if(!is.null(num.ticks))
  {
    if(length(num.ticks)!=3) stop("num.ticks must have length 3")
    options$xticklab = as.character(axisTicks(c(mn[1],mx[1]),FALSE,nint=num.ticks[1]))
    options$yticklab = as.character(axisTicks(c(mn[2],mx[2]),FALSE,nint=num.ticks[2]))
    options$zticklab = as.character(axisTicks(c(mn[3],mx[3]),FALSE,nint=num.ticks[3]))
    # handle mismatched x-z ticks when the grid is indicated
    if(grid && (length(options$xticklab) != length(options$zticklab)))
    {
      s = sapply(seq(from=1,to=1.5,length.out=20),function(s)s*(length(axisTicks(c(mn[1],mx[1]),FALSE,nint=6))==length(axisTicks(s*c(mn[3],mx[3]),FALSE,nint=6))))
      if(max(s)>0)
      {
        s = min(s[s>0])
        mn[3] = s*mn[3]
        mx[3] = s*mx[3]
        options$zticklab = as.character(axisTicks(c(mn[3],mx[3]),FALSE,nint=num.ticks[3]))
      }
    }
    options$xtick = seq(from=0,to=1,length.out=length(options$xticklab))
    options$ytick = seq(from=0,to=1,length.out=length(options$yticklab))
    options$ztick = seq(from=0,to=1,length.out=length(options$zticklab))
  }

  # create widget
  htmlwidgets::createWidget(
      name = "scatterplotThree",
      x = list(data=x, options=options),
               width = width,
               height = height,
               htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
               package = "threejs")
}

#' @rdname threejs-shiny
#' @export
scatterplotThreeOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "scatterplotThree", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderScatterplotThree <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, scatterplotThreeOutput, env, quoted = TRUE)
}
