
#TODO: Squash bug: First table is in each tibble twice! 

library(rvest)
library(RSelenium)
library(httr)
library(tidyverse)

#Initialize firefox browser
rD <- rsDriver(browser="firefox", port=4545L, verbose=F)
remDr <- rD[["client"]]
Sys.sleep(5)

#scraping parameters
startSeason <- '2019-20'
endSeason <- '2020-21'

#find how many years you need to iterate through for the for loop
numSeasons <- strtoi(substring(endSeason,1,4)) - strtoi(substring(startSeason,1,4)) + 1
currentSeason <- startSeason
#seasonsList will be a list of tibbles for each season,
seasonsList <- list()
for(i in 1:numSeasons){
 
  #Nav to main page
  remDr$navigate(paste("https://www.quanthockey.com/nhl/seasons/",currentSeason,"-nhl-players-stats.html", sep=""))
  #Get html off main page
  pageHtml <- read_html(remDr$getPageSource()[[1]])
  #Get table off main page
  table <- pageHtml %>% html_element("#AjaxRefresh") %>% html_table() 
  
  #Loop through pages 2 to maxPage
  #TODO: Scrape the value for maxPage
  maxPage <- 20
  for(page in 2:maxPage){
    # Nav to next table page 
    remDr$navigate(paste("javascript:PaginateStats('Season','Players','",currentSeason,"','0','",currentSeason,"','reg','P','DESC','",page,"','NHL','en',true);", sep=""))
    #Get html
    pageHtml <- read_html(remDr$getPageSource()[[1]])
    #Get table off page "page"
    table <- rbind(table, pageHtml %>% html_element("#AjaxRefresh") %>% html_table())
    Sys.sleep(2) 
    
  }
  #TODO: Clean data - remove header rows, rename header, checks
  #TODO: Add calculated stat?
  
  #add table for currentSeason to seasonsDF
  seasonsList[[i]] <- table
  names(seasonsList)[[i]] <- currentSeason
  #Iterate currentSeason string ex: '2019-2020' --> '2020-2021'
  currentSeason <- paste(strtoi(substring(currentSeason,1,4))+1, strtoi(substring(currentSeason,6,8))+1, sep="-")
  Sys.sleep(1)
}

#Close browser 
remDr$close()
#Kill Java to open ports/reset to be ready to be run again
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)


####################
print(seasonsList[[1]], n=300)
