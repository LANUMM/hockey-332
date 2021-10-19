
#Install packages before use. 
#Install firefox

require(rvest)
require(RSelenium)
require(httr)
require(tidyverse)

mainPage <- read_html("https://www.quanthockey.com/nhl/seasons/2020-21-nhl-players-stats.html")
table <- mainPage %>% html_element("#AjaxRefresh") %>% html_table()

myDF <- data.frame(table)
myDF

rD <- rsDriver(browser="firefox", port=4545L, verbose=F)
remDr <- rD[["client"]]

remDr$navigate("https://www.quanthockey.com/nhl/seasons/2020-21-nhl-players-stats.html")

page <- 2

remDr$navigate(paste("javascript:PaginateStats('Season','Players','2020-21','0','2020-21','reg','P','DESC','",page,"','NHL','en',true);", sep=""))

<<<<<<< HEAD
html <- remDr$getPageSource()[[1]]
=======
rD <- rsDriver(browser="firefox", port=4545L, verbose=F)
remDr <- rD[["client"]]
>>>>>>> 731f38fcc8452ac3cca65869d4a841e42be18c77

remDr$navigate("https://www.quanthockey.com/nhl/seasons/2020-21-nhl-players-stats.html")

