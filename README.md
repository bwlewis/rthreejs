# Three.js and R

Three.js widgets for R and shiny. The package includes

* graphjs: an interactive force directed graph widget
* scatterplot3js:  a 3-d scatterplot widget similar to the scatterplot3d function
* globejs:  a widget that plots data and images on a 3-d globe
* cityjs : a widget that generate a 3-d city with your SEO data

The widgets are easy to use and render directly in RStudio, in R markdown, in
Shiny applications, and from command-line R via a web browser.  They produce
high-quality interactive visualizations with just a few lines of R code.

Visualizations optionally use accelerated WebGL graphics, falling back to
non-accelerated graphics for systems without WebGL when possible. When WebGL is
available, the scatterplot3js function can produce fluid, interactive
pointclouds with hundreds of thousands of points.

See http://threejs.org for details on three.js.

This project is based on the htmlwidgets package. See
https://github.com/ramnathv/htmlwidgets for details and links to amazingly cool
visualization widgets for R.


## Install

Use the devtools package to install threejs directly from GitHub on any
R platform (Mac, Windows, Linux, ...). You'll need the 'devtools' package.

Test 3D City
```r
if(!require("devtools")) install.packages("devtools")
devtools::install_github("voltek62/seo-viz")
```


## Examples

```r
runApp(system.file("examples/city", package="threejs"))
```

## Test

Example : /data/internal_html_simple.xlsx

First line  : Internal - HTML				
Second line : Address;Status Code;Level;Inlinks;GA Sessions



