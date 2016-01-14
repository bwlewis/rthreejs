# Check for a specially modified three.js library that supports shiny's
# renderUI:

d = system.file("htmlwidgets",package="threejs")
ok = length(grep("var THREE=window.THREE=",readLines(paste(d,grep("three.min.js",dir(d,recursive=TRUE),value=TRUE),sep="/"),n=5))>0)
if(!ok) stop("The threejs package requires a modified version of the three.min.js JavaScript library. See the package README for more information.")
