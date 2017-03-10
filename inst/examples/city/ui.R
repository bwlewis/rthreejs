library("shiny")
library("threejs")
library("tools")

shinyUI(fluidPage(
  titlePanel("SEO-viz"),
  tags$head(
    tags$style(HTML("
                    .legend { list-style: none; }
                    .legend li { float: left; margin-right: 10px; }

                    #choose_columns .checkbox { float:left;width:50%; }

                    .myclass {clear:both;}

                    .legend span { border: 1px solid #ccc; width: 12px; height: 12px; margin: 2px; }

                    .legend .status200 { color:#FFFFFF;background-color: #996633; }
                    .legend .status300 { color:#FFFFFF;background-color: #0066FF; }
                    .legend .status400 { color:#FFFFFF;background-color: #0000FF; }
                    .legend .status500 { color:#FFFFFF;background-color: #CC0000; }

                    #info {
	                    position: absolute;
                      top: 0px;
                      width: 100%;
                      text-align: center;
                      z-index: 100;
                      display:block;
                      color:#FFFFFF;
                    }

                    "))
  ),
  sidebarLayout(
    sidebarPanel(
      p("Instructions :"),
      p(a("How it works ?", href="https://data-seo.com/2017/03/10/seo-viz-how-it-works/")),
      # tags$hr(),
      # tags$div("Majestic : CF/TF ",tags$ul(
      #   tags$li(tags$span("Batiment (>50%)",class="")),
      #   tags$li(tags$span("Batiment + 1 Antenne (>100%)",class="")),
      #   class="legend"
      # )),      
      # tags$hr(),
      
      sliderInput("inlink", "Inlinks:",
                  min = 0, max = 10000, value = c(0,10000)),
      
      sliderInput("traffic", "SEO Traffic:",
                  min = 0, max = 10000, value = c(0,10000)), 
      
      sliderInput("bot", "Googlebot Crawl Frequency:",
                  min = 0, max = 10000, value = c(0,10000)),   
      
      #sliderInput("depth", "Depth:",
      #            min = 0, max = 20, value = c(0,20)),         
      
      uiOutput("choose_columns"),
      #sliderInput("N", "Number of urls to plot", value=20, min = 10, max = 1000, step = 10),
      tags$div(class = "myclass"),
      p('Step 1 : Export your data from ScreamingFrog with your GA sessions'),      
      fileInput('fileXLSX', 'Choose XLSX file to upload (e.g. .xlsx ) Limit first 4000 urls',
                accept = c(
                  'text/xlsx'
                )
                , multiple = FALSE
      ),
      p('Step 2 : Load your log files'),      
      fileInput('fileLOG', 'Choose file to upload',
                accept = c(
                  'text/csv',
                  'text/log',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv',
                  '.1',
                  '.log',
                  '.gz'
                )
                , multiple = TRUE
      ),      
      p('Step 3 : Import your objective pages'),      
      fileInput('fileCSV', 'Choose CSV file to upload (e.g. .csv )',
                accept = c(
                  'text/csv',
                  'txt',
                  'text'
                )
                , multiple = FALSE
      ),      
      p("Use the mouse zoom to zoom in/out."),
      p("Click and drag to rotate."),
      tags$hr(), 
      downloadButton('exportData', 'Export Data'),
      downloadButton('exportOrphan', 'Export Orphan Page'),
      tags$hr(), 
      p("Sponsors :",a("OVH", href="https://www.ovh.com"),a("- Majestic", href="https://www.majestic.com")),
      tags$hr(),  
      p("My blogs :", a("data-seo.com", href="https://data-seo.com")," | ",a("data-seo.fr", href="https://data-seo.fr"))
    ),
    mainPanel(
      div("", id="info"),
      cityOutput("city"),
      p(htmlOutput("date1"),
        htmlOutput("date2")),
      p(htmlOutput("chart1"),
        htmlOutput("chart2"),
        htmlOutput("chart3"),
        htmlOutput("chart4"),
        htmlOutput("chart5"),
        htmlOutput("chart6"),
        htmlOutput("chart7"),
        htmlOutput("chart8"))
    )
  )
))
