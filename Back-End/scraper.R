




#######################################################################################
# Returns raw data scraped from Hockey-reference.com (2008-2021) with "season" added (skaterDF, goalieDF)
#######################################################################################

scrapeAll <- function(){
   startYear <- 2008
   endYear <- 2021
   
   skaterDF <- data.frame()
   goalieDF <- data.frame()
   
   for(i in c(startYear:endYear)){
      skaterDF <- rbind(skaterDF, cbind(scrapeSkaters(i),year=i))
      goalieDF <- rbind(goalieDF, cbind(scrapeGoalies(i),year=i))
     
   }
   return(c(skaterDF, goalieDF))
}


#######################################################################################
# Function to scrape season skater statistics from Hockey-reference.com
#######################################################################################

scrapeSkaters <- function(S) {
   # The function takes parameter S which is a string and represents the season (YYYY)
   # Returns: data frame      
   
   require(XML)
   require(httr)

   # Define certificate file, needed since website is HTTPS
   cafile <- system.file("CurlSSL", "cacert.pem", package = "RCurl")
   
   cafile <- "/etc/ssl/certs/ca-certificates.crt"

   
   # Read secure page
   ## create the URL to scrape data from
   URL <- paste("https://www.hockey-reference.com/leagues/NHL_",S, "_skaters.html", sep="")
   page <- GET(URL,config(cainfo=cafile))
   
   # Use regex to extract the desired table from the page
   x <- text_content(page) #will give a deprecation warning, but that is OK
   tab <- sub('.*(<table class="sortable stats_table".*?>.*</table>).*', '\\1', x)
   
   ## grab the data from the page
   tables <- readHTMLTable(tab)
   ds.skaters <- tables$stats
   
   ds.skaters <- ds.skaters[which(ds.skaters$Rk!="Rk"),]
 
   ## Convert to lower case character data (otherwise will be treated as factors)
   for(i in 1:ncol(ds.skaters)) {
      ds.skaters[,i] <- as.character(ds.skaters[,i])
      names(ds.skaters) <- tolower(colnames(ds.skaters))
   }

   ## finally fix the columns - NAs forced by coercion warnings
   for(i in c(1, 3, 6:19)) {
      ds.skaters[,i] <- as.numeric(ds.skaters[, i])
   }
      
   cn <- colnames(ds.skaters)
   ds.skaters <- cbind(ds.skaters,ppp=rowSums(ds.skaters[,which(cn=="pp")]))
   cn <- colnames(ds.skaters)
   
      ## fix a couple of the column names
   #colnames(ds.skaters)
   names(ds.skaters)[11] <- "pim"
   names(ds.skaters)[14] <- "ppg"
   names(ds.skaters)[15] <- "shg"
   names(ds.skaters)[18] <- "ppa"
   names(ds.skaters)[19] <- "sha"
   names(ds.skaters)[20] <- "sog"
     
   ## remove the header and totals row
   ds.skaters <- ds.skaters[!is.na(ds.skaters$rk), ]
   
   ## add the year too
   ds.skaters$season <- S

   ## remove any ' from players names (will case parsing issues later otherwise)   
   ds.skaters$player <- gsub("'","",ds.skaters[,"player"])
   
   ds.skaters <- cbind(ds.skaters, ppp=ds.skaters$ppa+ds.skaters$ppg)
   ds.skaters <- cbind(ds.skaters, shp=ds.skaters$sha+ds.skaters$shg)
   
   ## return the dataframe of subset of all categories 
 ######  #ALTERED TO RETURN rk #########################################
   return(ds.skaters[,c(1:9,11,14:15,18:20,24:25,29,32)])   
}

#######################################################################################
# Function to scrape season goalie statistics from Hockey-reference.com
#######################################################################################

scrapeGoalies <- function(S) {
   # The function takes parameter S which is a string and represents the season (YYYY)
   # Returns: data frame      
   
   require(XML)
   require(httr)
   
   # Define certicificate file, needed since website is HTTPS
   cafile <- system.file("CurlSSL", "cacert.pem", package = "RCurl")
   
   cafile <- "/etc/ssl/certs/ca-certificates.crt"
   
   
   # Read secure page
   ## create the URL to scrape data from
   URL <- paste("https://www.hockey-reference.com/leagues/NHL_",S, "_goalies.html", sep="")
   page <- GET(URL,config(cainfo=cafile))
   
   # Use regex to extract the desired table from the page
   x <- text_content(page) #will give a deprecation warning, but that is OK
   tab <- sub('.*(<table class="sortable stats_table".*?>.*</table>).*', '\\1', x)
   
   ## grab the data from the page
   tables <- readHTMLTable(tab)
   ds.goalies <- tables$stats
   
   ds.goalies <- ds.goalies[which(ds.goalies$Rk!="Rk"),]
   
   ## Convert to lower case character data (otherwise will be treated as factors)
   for(i in 1:ncol(ds.goalies)) {
      ds.goalies[,i] <- as.character(ds.goalies[,i])
      names(ds.goalies) <- tolower(colnames(ds.goalies))
   }
   
   ## finally fix the columns - NAs forced by coercion warnings
   for(i in c(1, 3, 6:19)) {
      ds.goalies[,i] <- as.numeric(ds.goalies[, i])
   }
   
   cn <- colnames(ds.goalies)


   
   ## remove the header and totals row
   ds.goalies <- ds.goalies[!is.na(ds.goalies$rk), ]
   
   ## add the year too
   ds.goalies$season <- S
   
   ## remove any ' from players names (will case parsing issues later otherwise)   
   ds.goalies$player <- gsub("'","",ds.goalies[,"player"])
   
   
   ## return the dataframe of subset of all categories 
   return(ds.goalies[,c(2:7,12,13,15)])   
}

#######################################################################################
# Process duplicate values in each year. 
#Input: Player DF for ONE YEAR. 
#Output: Player DF with instances of changed teams dealt with (1 row for each player)
#           adds the teams to tm ex) (MTL, COL)
#######################################################################################
fixTeamDupes <- function(playerDF){
   
   dupeIx <- c()
   
   
   for(i in c(1:(nrow(playerDF)-1))){
      while(!is.na(playerDF$rk[i+1]) && playerDF$rk[i]==playerDF$rk[i+1]){
         playerDF$tm[i] <- paste(playerDF$tm[i], ",", playerDF$tm[i+1], sep="")
         playerDF <- playerDF[-(i+1), ]
         dupeIx <- c(dupeIx, i)
      }
   }
   
   for(i in unique(dupeIx)){
      playerDF$tm[i] <- substring(playerDF$tm[i], 5)
   }
   return(playerDF)
}

sk2017 <- scrapeSkaters(2017)

dupeIx <- c()


for(i in c(1:(nrow(sk2017)-1))){
   while(!is.na(sk2017$rk[i+1]) && sk2017$rk[i]==sk2017$rk[i+1]){
      sk2017$tm[i] <- paste(sk2017$tm[i], ",", sk2017$tm[i+1], sep="")
      sk2017 <- sk2017[-(i+1), ]
      dupeIx <- c(dupeIx, i)
   }
}

for(i in unique(dupeIx)){
   sk2017$tm[i] <- substring(sk2017$tm[i], 5)
}
