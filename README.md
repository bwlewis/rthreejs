# Three.js and R

Three.js widgets for R and shiny. The package includes

* graphjs: an interactive network visualization widget
* scatterplot3js: a 3-d scatterplot widget similar to, but more limited than, the scatterplot3d function
* globejs: a somewhat silly widget that plots data and images on a 3-d globe

The widgets are easy to use and render directly in RStudio, in R markdown, in
Shiny applications, and from command-line R via a web browser.  They produce
high-quality interactive visualizations with just a few lines of R code.

Visualizations optionally use accelerated WebGL graphics, falling back to
non-accelerated graphics for systems without WebGL when possible.

See https://threejs.org for details on three.js.

See https://bwlewis.github.io/rthreejs for R examples.

This project is based on the htmlwidgets package. See http://htmlwidgets.org
for details and links to many other visualization widgets for R.

# New in version 0.3.0 (June, 2017)

The new 0.3.0 package version introduces major changes. The `scatterplot3js()`
function generally works as before but with more capabilities.  The `graphjs()`
function is very different with a new API more closely tied to the igraph
package.

The threejs package now depends on igraph.  If you're doing serious network
analysis, you're probably already using igraph (or you should be). Threejs now
uses external graph layouts (either from igraph or elsewhere). This gives much
greater graph layout flexibility, something I was looking for, but also removes
the cute (but slow and crude) force-directed JavaScript animation previously
used. To partially make up for that, several new graph animation and
interaction schemes are newly available.

See https://bwlewis.github.io/rthreejs/animation/animation.html
and https://bwlewis.github.io/rthreejs/advanced/advanced.html for short tutorials on the
new graph animation capabilities.

Performance of `graphjs()` is generally much improved using extensive buffering
and custom WebGL shaders where needed. See
https://bwlewis.github.io/rthreejs/ego/index.html for an example.

## Summary of changes

The `scatterplot3js()` function was substantially improved and updated.

- The new `pch` option supports many point styles with size control.
- Interactive rotation and zooming are greatly improved and panning is now supported: press and hold the right mouse button (or touch equivalent) and move the mouse to pan.
- Mouse over labels are supported in WebGL renderings.
- The `points3d()` interface has changed to support pipelining.
- Lines are supported too, see `lines3d()`.
- Support for crosstalk selection handles (see `demo("crosstalk", package="threejs")`).
- Set the experimental `use.orbitcontrols=TRUE` option for more CPU-efficient (but less fluid) rendering (good for laptops), also applies to `graphjs()`.

The `graphjs()` function is completely new.

- Greater variety of WebGL vertex rendering ("pch") options, including spheres
  and much higher-performance options for large graphs.
- Graph layout is now external; for instance use one of the many superb
  igraph package graph layout options.
- Graph animation is supported, see the examples.
- Interactive (click-able) graph animation is supported, see `demo(package="threejs")` for examples.
- Limited brushing is available to highlight portions of the graph, see the `brush=TRUE` option.
- Support for crosstalk selection handles.

## Known issues

- RStudio on Windows systems may not be able to render the WebGL graphics emitted
  by threejs. RStudio users running on Windows systems may need to use the plot
  "pop out" button to see visualizations in an external browser. We expect this
  to be a temporary problem until the underlying graphics rendering system used
  by RStudio is updated later in 2017.
- The fallback Canvas rendering code has diverged too much from the baseline
  WebGL code and no longer works. We have temporarily disabled Canvas
  rendering with an error message. See https://github.com/bwlewis/rthreejs/issues/67
  for details.
- Crosstalk filter handles are used in a non-standard and experimental way to
  control graph animation. Don't rely on this experimental feature.

## Install

Use the devtools package to install threejs directly from GitHub on any
R platform (Mac, Windows, Linux, ...). You'll need the 'devtools' package.
```r
if(!require("devtools")) install.packages("devtools")
devtools::install_github("bwlewis/rthreejs")
```

## Examples

See `?scatterplot3d` for more examples and detailed help.
```r
z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x, y, z, color=rainbow(length(z)))
```

The following example plots an undirected graph with 4039 vertices and 88234
edges from the Stanford SNAP network
repository http://snap.stanford.edu/data/facebook_combined.txt.gz.
```r
data(ego)
graphjs(ego, bg="black")
```

The next example illustrates the globe widget by plotting the relative
population of some cities using data from the R maps package on a globe. It's
based on the JavaScript WebGL Globe Toolkit (https://github.com/dataarts) by
the Google Creative Lab Data Arts Team.
```r
runApp(system.file("examples/globe", package="threejs"))
```

For detailed help on the widgets and additional examples, see
```r
?scatterplot3js
?globejs
?graphjs
```


# Status
<a href="https://travis-ci.org/bwlewis/rthreejs">
<img src="https://travis-ci.org/bwlewis/rthreejs.svg?branch=master" alt="Travis CI status"></img>
</a>
<a href="https://codecov.io/github/bwlewis/rthreejs/">
<img src="https://codecov.io/github/bwlewis/rthreejs/coverage.svg?branch=master"/>
</a>
<a href="https://www.r-pkg.org/pkg/threejs">
<img src="https://www.r-pkg.org/badges/version/threejs"/>
</a>
<a href="https://cranlogs.r-pkg.org/badges/threejs">
<img src="https://cranlogs.r-pkg.org/badges/threejs"/>
</a>
