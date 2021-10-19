require(rvest)
require(RSelenium)
require(httr)
require(tidyverse)

rD <- rsDriver(browser="firefox", port=4545L, verbose=F)
remDr <- rD[["client"]]

remDr$navigate("https://www.quanthockey.com/nhl/seasons/2020-21-nhl-players-stats.html")
#TODO: initialize data.frame with first page data
pageHtml <- remDr$getPageSource()[[1]]
table <- mainPage %>% html_element("#AjaxRefresh") %>% html_table() 
#TODO: scrape the max page number rather than hard coding. 
maxPage <- 20

#
for(page in 2:maxPage){
  #TODO: 
}

