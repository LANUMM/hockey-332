#######################################################################################
# Returns processed data scraped from Hockey-reference.com (2008-2021) with "season" added (skaterDF, goalieDF)
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
   
   
   
   
   return(list(skaterDF, goalieDF))
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
   
   ## dataframe of subset of all categories 
   ds.skaters <- ds.skaters[,c(1:9,11,14:15,18:20,24:25,29,32)]
   
   ## deal with team changes
   ds.skaters <- fixTeamDupes(ds.skaters)
   
   ## return cleaned data
   return(ds.skaters)
 
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
   
   ## dataframe of subset of all categories 
   ds.goalies <- ds.goalies[,c(1:7,12,13,15)]
   
   ## deal with team changes
   ds.goalies <- fixTeamDupes(ds.goalies)
   
   ## return cleaned data
   return(ds.goalies)
}

#######################################################################################
# Process duplicate values in each year. 
#Input: Player DF for ONE YEAR. 
#Output: Player DF with instances of changed teams dealt with (1 row for each player)
#           adds the teams to tm ex) (MTL, COL)
#           also removes rk
#######################################################################################
fixTeamDupes <- function(playerDF){
   
   ## Keeps track of the index of where dupes occur 
   dupeIx <- c()
   
   ## For every row in playeDF check to see if the next row has the same rk 
   for(i in c(1:(nrow(playerDF)-1))){
      while(!is.na(playerDF$rk[i+1]) && playerDF$rk[i]==playerDF$rk[i+1]){
         #Add the team they were on to the row with the summary data
         playerDF$tm[i] <- paste(playerDF$tm[i], ",", playerDF$tm[i+1], sep="")
         #remove the duplicate row
         playerDF <- playerDF[-(i+1), ]
         #add the index of the dupelicate row so we can remove "TOT" later
         dupeIx <- c(dupeIx, i)
      }
   }
   #Get rid of "TOT" on duplicate columns
   for(i in unique(dupeIx)){
      playerDF$tm[i] <- substring(playerDF$tm[i], 5)
   }
   #remove rk column
   playerDF <- playerDF[, -1]
   
   return(playerDF)
}



#Multiple instances of the same name and same year


allData <- scrapeAll()

allGoalies <- allData[[2]]
allSkaters <- allData[[1]]


for(i in unique(allGoalies$player)){
   
}

allGoalies[allGoalies$player == "Alex Auld"]

           