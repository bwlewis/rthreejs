# Three.js and R

Three.js widgets for R and shiny. The package includes

* scatterplot3js:  a 3-d scatterplot widget similar to the scatterplot3d function
* globejs:  a widget that plots data and images on a 3-d globe

The widgets are easy to use and render directly in RStudio, in R markdown, in
Shiny applications, and from command-line R via a web browser.  They produce
high-quality interactive visualizations with just a few lines of R code.

Visualizations optionally use accelerated WebGL graphics, falling back to
non-accelerated graphics for systems without WebGL. When WebGL is available,
the scatterplot3js function can produce fluid, interactive pointclouds with
hundreds of thousands of points.

See http://threejs.org for details on three.js.

See http://bwlewis.github.io/rthreejs  for an example.

This project is based on the new htmlwidgets package. See
https://github.com/ramnathv/htmlwidgets for details and links to amazingly cool
visualization widgets for R.

## What's new

The latest version includes mouse-over labels for labeling scatterplot3js
points, thanks to contributions from  Alexey Stukalov,
https://github.com/alyst, thanks Alexey!

We also simplified the globe plots and added powerful new arc-drawing
capabilities.


## NOTE!

These examples generally run best in WebGL-enabled viewers, including at least
Chrome, and recent versions of Internet Explorer web browsers. Users have had
some issues with Firefox on Windows. Safari on Mac OS X seems to fall back to
Canvas (not WebGL) rendering, but works.  We try to maintain basic support for
non-WebGL equipped browsers, but the performance and rendering quality will
generally be inferior to WebGL visualizations.

The examples run inside RStudio, acting similarly to normal R plots.  RStudio
renders them using Canvas right now, but an upcoming version of
RStudio will support WebGL.

## Install

Use the devtools package to install threejs directly from GitHub on any
R platform (Mac, Windows, Linux, ...). You'll need the 'devtools' package.
```r
if(!require("devtools")) install.packages("devtools",repos="http://cran.rstudio.com/")
devtools::install_github("bwlewis/rthreejs")
```

## Examples

The following example illustrates the 3D scatterplot widget.
```r
library("shiny")
runApp(system.file("examples/scatterplot",package="threejs"))
```

The next example illustrates the globe widget by plotting the relative
population of some cities using data from the R maps package on a globe. It's
based on the JavaScript WebGL Globe Toolkit (https://github.com/dataarts) by
the Google Creative Lab Data Arts Team.
```r
runApp(system.file("examples/globe",package="threejs"))
```

For detailed help on the widgets and additional examples, see
```r
?scatterplot3js
?globejs
```

# Licenses

## Three.js

The MIT License

Copyright (c) 2010-2014 three.js authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Globe example

Includes ideas and images from the dat.globe JavaScript WebGL Globe Toolkit
https://github.com/dataarts/webgl-globe

Copyright 2011 Data Arts Team, Google Creative Lab
Licensed under the Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0.
