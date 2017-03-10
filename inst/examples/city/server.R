library(shiny)
library(threejs)
library(dplyr)
library(readxl)
library(RColorBrewer)

source("./function.R")

options(shiny.maxRequestSize = 10000*1024^2)

my_checkboxGroupInput <- function(variable, label, choices, selected, colors){
  #print(variable)
  choices_names <- choices
  if(length(names(choices))>0) my_names <- names(choices)
  div(id=variable,class="form-group shiny-input-checkboxgroup shiny-input-container shiny-bound-input",
      HTML(paste0('<label class="control-label" for="',variable,'">',label,'</label>')),
      div( class="shiny-options-group",
           HTML(paste0('<div class="checkbox" style="color:', colors,'">',
                       '<label>',
                       '<input type="checkbox" name="', variable, 
                       '" value="', choices, 
                       '"', ifelse(choices %in% selected, 'checked="checked"', ''), 
                       '/>',
                       '<span>', choices_names,'</span>',
                       '</label>',
                       '</div>', collapse = " "))
      )
  )
}

shinyServer(function(input, output, session)
{
  h <- 100 # height of the bar
  v <- NULL
  
  # close the R session when Chrome closes
  # session$onSessionEnded(function() { 
  #  stopApp()
  #  q("no") 
  #})

  values <- reactive({
    
    if (!is.null(input$fileXLSX)) {
      inFile <- input$fileXLSX
      
      v <- prepareUrl(inFile$datapath)

      v$pos.Target[1:length(v$pos.Address)] <- 0
      v$pos.Googlebot[1:length(v$pos.Googlebot)] <- 0
      
      output$chart1 <- renderText(paste(toString(length(v$pos.Address))," Pages in the Structure",sep=""))
      output$chart2 <- renderText(paste(toString(sum(v$pos.Trafic))," SEO visits",sep=""))    
      
      # add SFcrawl + trafic >0
      count_active <- length(v$pos.Trafic[which((v$pos.Trafic>0)==TRUE)])
      output$chart3 <- renderText(paste(count_active," Active pages",sep=""))    
      
      updateSliderInput(session, "inlink", max = max(v$pos.Inlinks))
      updateSliderInput(session, "traffic", max = max(v$pos.Trafic))
      updateSliderInput(session, "depth", max = max(v$pos.Level))      
      
    }
    

    if (!is.null(input$fileXLSX) & !is.null(input$fileLOG)) {

      #FIX prevent to reload  
      if (TRUE) {
        
        inFile <- input$fileLOG
        
        logsSummary <- NULL
        
        #loader    
        withProgress(message = 'Creating your city', value = 0, {
        
          for(i in 1:nrow(inFile)) {
            
            logs <- importLogs(input$fileLOG[[i, 'datapath']])
            
            if(is.null(logsSummary)) {
              logsSummary <- logs
            }
            else {
              logsSummary <- rbind(logsSummary,logs)
            }      
            
            incProgress(1/(nrow(inFile)+1), detail = paste("Log : Import part", i))
            
          }
          
          incProgress(1/(nrow(inFile)+1), detail = paste("Log : Fusion", i))
        
        logsSummary <- processLogs(logsSummary)
        
        })
        
  
        #merge liste des V
        sitename <- gsub("/$","",v$sitename)
        
        df1 <- data.frame(pos.Address=as.character(gsub(sitename,"",v$pos.Address)),stringsAsFactors=FALSE)
        
        colnames(logsSummary) <- c("pos.Address","count")
        #PATCH invisible character ! 3 hours lost
        logsSummary$pos.Address <- gsub(" ","",logsSummary$pos.Address)
        
        #Filter Amp pages, robots.txt and sitemap
        logsSummary <- filter(logsSummary, !grepl("/amp/",pos.Address)
                      & !grepl("robots.txt",pos.Address)
                      & !grepl("/sitemap",pos.Address ))
        

        
        df3 <- merge(df1, logsSummary, by = "pos.Address", all.x=TRUE)
        df3[is.na(df3)] <- 0
        
        v$pos.Googlebot <- df3$count
        
        #v$pos.Width[which(v$pos.Googlebot>0)] <- ntile(v$pos.Googlebot[which(v$pos.Googlebot>0)], 5)
        v$pos.Width <- v$pos.Googlebot
        
        # if no traffic and googlebot>0 : add +1
        #ind <- which(v$pos.Googlebot>0 & v$pos.Height==0)
        #v$pos.Height[ind] <- 1

        
        #display unique pages
        count_activepage <- length(which(df3$count>0))
        output$chart4 <- renderText(paste(count_activepage," Unique Pages crawled by Google",sep=""))
        
        DForphan <- setdiff(logsSummary$pos.Address,df1$pos.Address)
        
        DForphan <- c(DForphan, rep("", length(df1$pos.Address) - length(DForphan)))
        v$DForphan <- DForphan
        
        #nb orphan pages
        output$chart5 <- renderText(paste(length(DForphan[which(DForphan!="")])," Orphan Pages",sep=""))
        
        #seo visits on orphan pages
        #TODO : call API Analytics
        #output$chart6 <- renderText(paste("SEO Visits on Orphan Pages",sep=""))
        
        #active orphan pages with trafic
        #count_orphan <- length(v$pos.Trafic[which((v$pos.Trafic>0)==TRUE)])
        #output$chart7 <- renderText(paste("Active Orphan Pages",sep=""))
        
        updateSliderInput(session, "bot", max = max(v$pos.Googlebot))
      
      }
      
    } 
    
    
    v
  })
  
  # Check boxes
  output$choose_columns <- renderUI({
    
    v <- values()

    # If missing input, return to avoid error later in function
    if(is.null(v)) {
      #print("v is null")
      return()
    }
    
    #print("v not null")
    
    nbcolor <- max(v$pos.Category)
    qual_col_pals <- brewer.pal.info[brewer.pal.info$category == 'qual',]
    col <- unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))    
    
    names(col) <- c()
    
    df <- as.data.frame(v) %>%
          select(pos.Category,pos.CategoryName) %>%
          unique() %>%
          arrange(pos.Category)
    
    df$pos.Color <- col[df$pos.Category]
    
    
    my_checkboxGroupInput("columns", "Categories:",
                                   choices = df$pos.CategoryName,
                                   #selected = "",
                                  selected = df$pos.CategoryName, 
                                  colors= df$pos.Color)
    
  })  

  output$city <- renderCity({
    v <- values()

    # If missing input, return to avoid error later in function
    if(is.null(v)) {
      #print("v is null 2")
      return()
    }
    
    if (!is.null(input$fileXLSX)) {    
      ind <- which(v$pos.Inlinks<input$inlink[1] | v$pos.Inlinks>input$inlink[2])
      v$pos.Height[ind] <- 0
      # 
      ind <- which(v$pos.Trafic<input$traffic[1] | v$pos.Trafic>input$traffic[2])
      v$pos.Height[ind] <- 0
      #
      ind <- which(v$pos.Level<input$depth[1] | v$pos.Level>input$depth[2])
      v$pos.Height[ind] <- 0
      
    }
    
    if (!is.null(input$fileXLSX) & !is.null(input$fileLOG)) {
      ind <- which(v$pos.Googlebot<input$bot[1] | v$pos.Googlebot>input$bot[2])
      v$pos.Height[ind] <- 0  
    }
    
    #print("v not null 2")
    if (!is.null(input$columns)) {
      
      keep <- input$columns
      ind <- which(!(v$pos.CategoryName %in% keep))
      v$pos.Height[ind] <- 0
      
    }
    
    if (!is.null(input$fileXLSX) & !is.null(input$fileCSV)) {
      inFile <- input$fileCSV
      
      #print(inFile)
      
      targets <- read.csv(inFile$datapath, stringsAsFactors=FALSE, header=FALSE,
                          quote="",
                          blank.lines.skip=TRUE,
                          strip.white=TRUE)
      
      v$pos.Target[1:length(v$pos.Address)] <- 0
      
      for(i in 1:nrow(targets)) {
        target <- targets$V1[i]
        #print(target)
        ind <- which(target==v$pos.Address)
        #print(ind)
        #if (ind>0)
        v$pos.Target[ind] <- 10
      }
      
      output$chart8 <- renderText(paste(toString(nrow(targets))," Objective Pages",sep=""))
      
    }     
    
    #print(v$pos.Height)
    nbcolor <- max(v$pos.Category)
    qual_col_pals <- brewer.pal.info[brewer.pal.info$category == 'qual',]
    col <- unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
    
    names(col) <- c()
    h <- v$block
    # Extend palette to data values
    #v$pos.Color <- col[floor(length(col) * (h - v$pos.Category) / h) + 1]
    v$pos.Color <- col[v$pos.Category]
    #
    v$pos.Color <- substr(v$pos.Color, 1, 7)
    v$pos.Color <- gsub("#","0x",v$pos.Color)
    
    #TODO : add specific pages and color base
    #v$pos.Target <- 0
    
    args <- c(block=v$block,
              blocks_x=v$blocks_x,
              blocks_z=v$blocks_z,
              sitename=v$sitename,
              height_max=max(v$pos.Trafic),
              weight_max=max(v$pos.Googlebot),
              list(
                  posx=v$pos.X, 
                  posy=v$pos.Y,
                  poslevel=v$pos.Level,
                  posheight=v$pos.Height,
                  posname=v$pos.Name,
                  postrafic=v$pos.Trafic,
                  posinlink=v$pos.Inlinks,
                  posrescode=v$pos.Status,
                  poswidth=v$pos.Width,
                  poscategory=v$pos.Color,
                  poscategoryname=v$pos.CategoryName,
                  posaddress=v$pos.Address,
                  posmajestic=v$pos.Majestic,
                  postarget=v$pos.Target,
                  posgooglebot=v$pos.Googlebot
                  #value=v$value
                  #color=v$color, 
                  #atmosphere=TRUE
                  )
              )

    do.call(cityjs, args=args)
  })
  
  
  output$exportData <- downloadHandler(
    filename = "extract.csv",
    content = function(file) {
      
        v <- values()

        # If missing input, return to avoid error later in function
        if(is.null(v)) {
          return()
        }
        
        v$pos.Selected[1:length(v$pos.Address)] <- 1

        #print(v[which(v$pos.Selected==1)]$pos.Selected)
                
        if (!is.null(input$fileXLSX)) {    
          ind <- which(v$pos.Inlinks<input$inlink[1] | v$pos.Inlinks>input$inlink[2])
          if(length(ind)>0) {
            #cat("ind1",ind)
            v$pos.Selected[ind] <- 0
          }
          # 
          ind <- which(v$pos.Trafic<input$traffic[1] | v$pos.Trafic>input$traffic[2])
          if(length(ind)>0) {
            #cat("ind2",ind)
            v$pos.Selected[ind] <- 0
          }
        }
        
        if (!is.null(input$fileXLSX) & !is.null(input$fileLOG)) {
          ind <- which(v$pos.Googlebot<input$bot[1] | v$pos.Googlebot>input$bot[2])
          v$pos.Selected[ind] <- 0
        }
        
        ind <- which(v$pos.Selected==1)
        v$pos.Level <- v$pos.Level[ind]
        v$pos.Trafic <- v$pos.Trafic[ind]
        v$pos.Status <- v$pos.Status[ind]
        v$pos.CategoryName <- v$pos.CategoryName[ind]
        v$pos.Address <- v$pos.Address[ind]
        v$pos.Inlinks <- v$pos.Inlinks[ind]
        
      
        extract <- data.frame(
          address=v$pos.Address,          
          #level=v$pos.Level,
          trafic=v$pos.Trafic,
          inlink=v$pos.Inlinks,
          rescode=v$pos.Status,
          categoryname=v$pos.CategoryName
          #majestic=v$pos.Majestic,
          #postarget=v$pos.Target
        )        
        
        if (length(v$pos.Googlebot)>1) {
          v$pos.Googlebot <- v$pos.Googlebot[ind]
          extract <- cbind(extract,crawl_googlebot=v$pos.Googlebot)          
        }

        write.csv2(extract,file,row.names=FALSE)
        
      
    }
  )  

  output$exportOrphan <- downloadHandler(
    filename = "orphan.csv",
    content = function(file) {
      
      v <- values()
      
      # If missing input, return to avoid error later in function
      if(is.null(v)) {
        return()
      }
      
      if(is.null(v$DForphan)) {
        return()
      }
      
      
      extract <- v$DForphan[which(v$DForphan!="")]
      
      write.csv2(extract,file,row.names=FALSE)
      
    }
  )  
  
    
})

