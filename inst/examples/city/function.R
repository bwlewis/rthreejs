library(dplyr)
library(readxl)
library(magrittr)
#library(mosaic)
library(text2vec)
library(stringi)
library(tm)
library(rjson)
library(urltools)
library(stringr)
library(httr)
library(RCurl)


apiKey <- ""
# change to api for prod
# change to developper to sandbox
apiUrl <-"https://api.majestic.com/api/json?app_api_key="

#historic : all period
#refresh : 90 last days
modeUrl <- "historic"

#autoriser la bonne IP !!!!!!!!!!!
httr::set_config( config( ssl_verifypeer = 0L ) )

MAJESTIC <- FALSE
REVERSEDNS <- FALSE

snail <- function(x) {
  result <- c()
  #http://stackoverflow.com/questions/6322413/shifting-a-data-frame-in-r
  
  while(!is.null(x)) {
    
    #Steal the first row.
    result <- c(result,as.vector(head(x,1),mode='numeric'))
    #print(result)
    if (!is.null(nrow(x))) {
      x <- x[c(2:nrow(x)),]
    }
    else
      x <- NULL
    
    
    #Steal the right items.
    if (!is.null(ncol(x))) {    
      result <- c(result,x[,ncol(x)])
      #print(result)
      x <- x[,c(1:(ncol(x)-1))]
    }
    
    #Steal the bottom row.
    if (!is.null(nrow(x))) {    
      result <- c(result,rev(as.vector(x[ncol(x),],mode='numeric')))
      #print(result)
      x <- x[c(1:(nrow(x)-1)),]
    }
    
    
    #Steal the left items.
    if (!is.null(ncol(x))) {    
      result <- c(result,rev(x[,1]))
      #print(result)    
      x <- x[,c(2:ncol(x))]
    }
    
  }
  
  return(rev(result))
  
}

getCurlMultiHandle <- function(r) {
  result <- content(r)$DataTables$Results$Data
  #print(result)
  return(result)
}

getCurlMultiHandle2 <- function() {
  #result <- content(response)$DataTables$Results$Data
  return("top")
  #return(x)
}

prepareUrl <- function(file) {
  
  #file <- "./data/internal_html_planetecroisiere_ga.xlsx"
  
  filexlsx <- file
  
  if (!grepl("xlsx",file)) {
    file.copy(file,paste(file,".xlsx",sep=""))
    filexlsx <- paste(file,".xlsx",sep="")
  }
    
  urls <-  read_excel(filexlsx, 
                      sheet = 1, 
                      col_names = TRUE, 
                      na = "",
                      skip=1)
  
  # last line is always NA
  urls <- head(urls,-1)
  
  #urls2 <- select(urls,Address,Level,`GA Sessions`)
  
  # get sitename
  sitename <- urls[1,]$Address
  # crawler generate NA columns
  #urls <- urls[colSums(!is.na(urls)) > 0]
  # sort by Level and remove sitename
  urls <- arrange(urls,Level) %>%
    filter(grepl(sitename,Address) 
           & !grepl(".jpg",Address)
           & !grepl(".css",Address)
           & !grepl(".js",Address)
           & !grepl(".png",Address)
           & !grepl(".gif",Address)
           & !grepl(".pdf",Address)) %>%
    mutate(Name=gsub(sitename,"",Address)) %>%
    # limit first 4000 urls
    head(4000)
  
  urls[1,]$Name <- "home"
  
  ###################
  # create matrix
  nburls <- nrow(urls)
  side <- ceiling(sqrt(nburls))
  mat <- matrix(1:(side*side), ncol = side)
  ##############
  
  # find the snail path
  y <- snail(mat)
  
  # Level -> Depth ( Position )
  pos <- arrayInd(y, dim(mat)) %>%
    # reduce rows to have the same size
    head(nrow(urls)) %>%
    set_colnames(c("X","Y"))
  
  # fusion
  urls <- cbind(urls,pos)
  
  # Heigth -> Trafic
  # Width -> Inlinks
  # Length -> Wordcount
  # Animation -> Rescode
  # Color -> Category
  
  # replace NA by 0
  urls[is.na(urls)] <- 0
  
  #change to numeric for ntile
  urls$`GA Sessions` <- as.numeric(urls$`GA Sessions`)
  urls$`Status Code` <- round(as.numeric(urls$`Status Code`)/100)
  
  urls$Inlinks <- as.numeric(urls$Inlinks)
  
  ##tout passer à 1
  #urls$Height <- 0
  # FIX ga sessions according website
  #urls$Height[which(urls$`GA Sessions`>0)] <- ntile(urls$`GA Sessions`[which(urls$`GA Sessions`>0)],5)
  
  urls$Height <- urls$`GA Sessions`
  
  urls$Width <- 1
  urls$Width[which(urls$Inlinks>10)] <- ntile(urls$Inlinks[which(urls$Inlinks>10)], 5)
  #urls$Width[which(urls$`Word Count`>10)] <- ntile(urls$Wordcount[which(urls$`Word Count`>10)], 5)
  #urls$Width <- urls$Inlinks
  
  #urls$Length <- ntile(urls$`Word Count`, 5) 
  
  urls <- select(urls,Level,X,Y,Address,Height,`GA Sessions`,Width,Inlinks,`Status Code`)
  colnames(urls)[6] <- "Trafic"  
  colnames(urls)[9] <- "Status"
  
  urls <- arrange(urls,Address) %>%
    #remove wellknow extension
    mutate(Address2=gsub(".xml","",Address)) %>%
    mutate(Address2=gsub(".php","",Address2)) %>%
    mutate(Address2=gsub(".asp","",Address2)) %>%
    mutate(Address2=gsub(".aspx","",Address2)) %>%
    mutate(Address2=gsub(".html","",Address2)) %>%
    #remove sitename
    mutate(Address2=gsub(sitename,"",Address2)) %>%
    # replace all number
    mutate(Address2=gsub('[0-9]+', 'NUM', Address2)) %>%
    mutate(Address2=gsub('/NUM/NUM/NUM/', 'Article', Address2)) %>%
    mutate(Address2=gsub('/NUM/NUM/', 'Article', Address2)) %>%
    mutate(Address2=gsub('/NUM/', 'Listing', Address2))
  
    it <- itoken(urls$Address2, preprocessor = tolower,
                 tokenizer = word_tokenizer, chunks_number = 3, progressbar = FALSE)

    
    stopwords_fr <- stopwords(kind = "fr")
    stopwords_en <- stopwords(kind = "en")
    # todo remove brand and specifics words
    stopwords <- c(stopwords_fr,stopwords_en,"NUM","id")
    
    # keep only 2 and 3 grams
    vocab <- create_vocabulary(it, ngram = c(1L, 1L), stopwords=stopwords)

    urls_vocab <- data.frame(vocab$vocab) %>%
      arrange(-terms_counts)

    urls_vocab_filtered <- data.frame(vocab$vocab) %>%
      arrange(-terms_counts) %>%
      filter(terms_counts > 5 & nchar(terms)>3)

    # thresold >> 20
    #filter(urls_vocab_filtered, !(terms %in% stopwords)) %>%
    schemas <- arrange(urls_vocab_filtered,-terms_counts) %>%
      select(terms)
    
    #print(schemas)

    urls$Category <- "no match"

    for (j in nrow(schemas):1)
    {
      cat <- schemas[j,1]
      #print(cat)
      urls$Category[which(stri_detect_fixed(urls$Address2,schemas[j,1],case_insensitive=TRUE))] <- schemas[j,1]
    }

    urls$Category[1] <- "home"
    #DEBUG
    #urls$Level[1] <- 1
    #print(urls$Category[1])
    #print(urls$Address[1])
    #print(urls[1,])
    
    urls$CategoryName <-  urls$Category
    urls$Category <- as.numeric(as.factor(urls$Category))
    
    urls <- select(urls,-Address2)
    
    #init
    urls$Majestic[1:length(urls$Address)] <- 0

    #print(sitename)
    if (MAJESTIC) {

      #loader    
      withProgress(message = 'Creating your city', value = 0, {
        
      #TODO : FIX
      uris <- urls$Address

      iterator_max <- floor(length(uris)/100)
      iterator <- 1
      
      #TODO : check 100 by 100
      while( iterator <= iterator_max ) {
        
        if(iterator>1)
          start <- (iterator*100-100)+1
        else
          start <- iterator*100-100
        
        end <- iterator*100
        
        paquet <- uris[start:end]
        
        #cat(start," : ",end,"\r\n")
        
        url_majestic <- paste(apiUrl,apiKey,"&cmd=GetIndexItemInfo","&datasource=",modeUrl,sep="")
        
        for(i in 1:length(paquet)){
          
          url_majestic <- paste(url_majestic,"&item",(i-1),"=",url_encode(paquet[i]),sep="")
          
        }  
        
        url_majestic <- paste(url_majestic,"&items=",(length(paquet)-1),sep="")
        
        cpt <- 0
        result <- NULL
        
        tryCatch({
          result <- majesticGetInfoUrlBatch(url_majestic)
          Sys.sleep(2)
        },
        error = {
          cpt <- 0
          result <- NULL
        },
        finally = {
          #print(cpt)
          
          if(!is.null(result)) {
            for (j in 1:length(result)) {
            
                if(result[[j]]$CitationFlow>0) {
                majestic <- (result[[j]]$TrustFlow/result[[j]]$CitationFlow)*100
                
                if (majestic>50 & majestic<100) cpt <- 1
                else if (majestic>=100) cpt <- 2
                
                start <- start +1
                #print(start)
                urls$Majestic[start] <- cpt
                
              }
              
            }
          }
        })
        
        iterator <- iterator + 1
      
        incProgress(1/iterator_max, detail = paste("Majestic API part", iterator))
        
      }
      
    })      
      
    }

  return(c(pos=urls,block=nburls,blocks_x=side,blocks_z=side,sitename=sitename))
  
}



majesticGetInfoUrlBatch <- function(url) {
  
  req <- GET(url)
  if (length(content(req))>0)
    res <- content(req)$DataTables$Results$Data
  else {
    print("error detected")
    #print(url)
    res <- NULL
  }
}

#
# get majestic data
#
majesticGetInfoUrl <- function(u) {
  
  u <- url_encode(u)

  url <- paste(apiUrl,apiKey,"&cmd=GetIndexItemInfo&items=1&item0=",u,"&datasource=",modeUrl,sep="")
  
  req <-GET(url)
  
  print(req)
  
  #result <- fromJSON( req )
  result <- content(req)$DataTables$Results$Data
  
  return(result)
}


testGoogleIP <- function(ip) {
  
  if(grepl("66.249.",ip)) return(TRUE)
  
  if (REVERSEDNS) {
    url <- paste("https://api.openresolve.com/reverse/",ip,sep="")
    
    req <-getURL(
      url
      #,httpheader = c(
      #  "accept-encoding" = "gzip"
      #) 
      #, verbose = TRUE
    );
    
    
    result <- fromJSON( req )
    
    #print(result)
    
    if (is.null(result)) return(FALSE)
    if (length(result$AnswerSection)==0) return(FALSE)  
    if (length(result$AnswerSection[[1]]$Target)==0) return(FALSE)  
    
    result <- result$AnswerSection[[1]]$Target
    
    if (grepl("googlebot",result)) return(TRUE)
    else return(FALSE)
  }
  
  return(FALSE)
  
}  

importLogs <- function(name) {
  
  if (grepl(".gz",name))
    filename <- gzfile(name) 
  else 
    filename <- name
  
  maxfields <- max(count.fields(filename))
  
  logs <- read.table(filename, stringsAsFactors=FALSE, 
                     col.names = paste0("V",seq_len(maxfields)), fill = TRUE)
  
  # detect field
  log100 <- logs[1:20,]
  idxURL <- which(grepl("/",log100)==TRUE & grepl("\\[",log100)==FALSE)
  idxIP  <- which(grepl("\\d+\\.\\d+\\.\\d+\\.\\d+", log100)==TRUE)
  idxMozilla <- which(grepl("Mozilla",log100)==TRUE)

  #FIX : take the first
  if (length(idxURL)>1)
    idxURL <- idxURL[1]  
    
  #FIX : take the first
  if (length(idxIP)>1)
    idxIP <- idxIP[1]
  
  logs <- select(logs,c(idxIP,idxURL,idxMozilla))
  colnames(logs) <- c("vIP","vURL","vUSERAGENT")
 
  logs <- filter(logs,grepl("Googlebot",vUSERAGENT)
                 & !grepl(".jpg",vURL)
                 & !grepl(".png",vURL)
                 & !grepl(".css",vURL)
                 & !grepl(".js",vURL)
                 & !grepl(".gif",vURL)
                 & !grepl(".ico",vURL)
                 & !grepl("POST ",vURL)
                 & !grepl(".pdf",vURL))     
 
  logs <- mutate(logs, vURL=gsub("GET ","",vURL) ) %>%
            mutate( vURL= gsub("HTTP\\/1.1","",vURL) )
   
  return(logs)
  
}  

processLogs <- function(logs) {
    
    logs_google <- logs   
    
    logs_ip <- group_by(logs_google,vIP) %>%
      summarize(count=n())
    
    logs_ip$test <- FALSE
    

      for (k in 1:nrow(logs_ip)) {
        current_ip <- logs_ip$vIP[k]
        logs_ip$test[k] <- testGoogleIP(current_ip)
      }        
      logs_ip <- filter(logs_ip, test==TRUE)
           
    
    logs_ip$count <- NULL
    logs_ip$test <- NULL         
    
    logs <- merge(logs_google, logs_ip, by = "vIP") %>%
      filter(!grepl("Mobile",vUSERAGENT))
    
    #GROUP BY IP
    logs <- group_by(logs,vURL) %>%
      summarize(count=n())    
    
  return(logs)
  
}

categorize <- function(file) {
  
  schemas <- read.csv(file, stringsAsFactors=FALSE, header=FALSE,
                      quote="",
                      blank.lines.skip=TRUE,
                      strip.white=TRUE)  
  
  for (j in 1:nrow(schemas))
  {
    cat <- schemas[j,1]
    #print(cat)
    if (grepl("*",cat)) {
      cat <- gsub("*", "", cat )
      urls$Category[which(stri_detect_fixed(urls$Address2,cat,case_insensitive=TRUE))] <- schemas[j,2]
    }
    else {
      urls$Category[which(urls$Address2==cat)] <- schemas[j,2]
    }
  }
  
}
