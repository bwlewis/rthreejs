#' Les Miserables Character Coappearance Data
#'
#' Les Miserables Character Coappearance Data
#'
#' @docType data
#' @name LeMis
#' @keywords datasets
#' @source
#' Mike Bostock's D3.js force-directed graph example  \url{http://bl.ocks.org/mbostock/4062045}.
#' Data based on character coappearence in Victor Hugo's Les Miserables, compiled by Donald Knuth
#' (\url{http://www-cs-faculty.stanford.edu/~uno/sgb.html}).
#' @usage data(LeMis)
#' @format An igraph package graph object.
#'
NULL


#' Global flight example data from Callum Prentice.
#'
#' Global flight example data from Callum Prentice.
#'
#' @docType data
#' @name flights
#' @keywords datasets
#' @source See Callum Prentice
#' \url{https://raw.githubusercontent.com/callumprentice/callumprentice.github.io/master/apps/flight_stream/js/flights_one.js}
#' @usage data(flights)
#' @format A data frame with 34,296 observations of 4 variables, origin_lat, origin_long, dest_lat, and dest_long.
NULL


#' Facebook social circles
#'
#' A facebook social network subgraph obtained from the Stanford SNAP repository.
#'
#' @docType data
#' @name ego
#' @keywords datasets
#' @source Stanford SNAP network repository
#' \url{http://snap.stanford.edu/data/facebook_combined.txt.gz}
#' @references
#' J. McAuley and J. Leskovec. Learning to Discover Social Circles in Ego Networks. NIPS, 2012.
#' @usage data(ego)
#' @format An igraph package undirected graph object with 4039 vertices and 88234 edges. The
#' graph includes a force-directed layout with vertices colored by the \code{\link{cluster_fast_greedy}}
#' algorithm from the igraph package.
NULL
