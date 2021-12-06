library(stringi, lib.loc="~/www/Hockey/rpkg")
library(stringr, lib.loc="~/www/Hockey/rpkg")
library(gridExtra, lib.loc="~/www/Hockey/rpkg")
library(stringi, lib.loc="~/www/Hockey/rpkg")
library(stringr, lib.loc="~/www/Hockey/rpkg")
library(gridExtra, lib.loc="~/www/Hockey/rpkg")

#DELETE LOCAL LIBRARY STATEMENTS LATER
library(stringi)
library(stringr)
library(gridExtra)
library(stringi)
library(stringr)
library(gridExtra)
setwd("~/www/Hockey/files")

data=readLines('C:\\Users\\matth\\Downloads\\mock1.txt')


capture<-str_match_all(data,"\\u0029(.+)\\s\\u002D\\s(.+)\\s(.+)\\s\\u0028([A-Za-z]+)\\s\\u002D\\s([A-Za-z]+)")
names<-c("DraftTeam","FirstName","LastName","Team","Posistion")
temp<-do.call(rbind,capture)
df<-data.frame(DraftTeam=temp[,2],FirstName=temp[,3],LastName=temp[,4],Team=temp[,5],Position=temp[,6])
#remove '
df$FirstName <- lapply(df$FirstName,str_remove_all,pattern="'")
df$LastName <- lapply(df$LastName,str_remove_all,pattern="'")

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))

draftToDB(df)
#Save so it can be read by ideal draft
#write.csv(df,"~/www/Hockey/files/parseDF", row.names = FALSE)
#png("~/www/Hockey/test1.png", height = 50*nrow(df), width = 200*ncol(df))
grid.table(df)
dev.off()

#######################################################################################
# Function to insert the uploaded leauge into the DB
# Input: data frame of leauge info
# Output: N/A
#######################################################################################
draftToDB <- function(myDF){

  #This season
  thisYear <- 2021
  
  #Add pick
  myDF$pick <- c(1:nrow(myDF))
  myDF$player_id <- c()
  #assign player_id
  
  for(p in myDF$pick){
    myDF$player_id[p] <-findPlayerID(myDF$FirstName[p], myDF$LastName[p], myDF$Position[p], thisYear)
  }
  
  print(myDF)
  
  
  
  #Close DB Connection
  all_cons <- dbListConnections(MySQL())
  for (con in all_cons){
    dbDisconnect(con)
  }
}

#######################################################################################
# Function to assign player ID
# Input: fName, lName, pos, year
# Output: the suggested player_id for a given row
#######################################################################################
findPlayerID <- function(fName, lName, pos, year){
  #Find whole name
  fullN <- paste(fName,lName, sep=" ")
  
  #Get players with that name from Skaters
  myRequest <- paste("SELECT player_id, pos, year ",
                     "FROM Skaters ",
                     "WHERE Skaters.player='", fullN,"'", sep="")
  
  mySkaters = dbSendQuery(mydb,myRequest)
  skaterInfo = data.frame(fetch(mySkaters, n = -1)) #dataframe
  # Get players with that name from Goalies
  myRequest <- paste("SELECT player_id, year ",
                     "FROM Goalies ",
                     "WHERE Goalies.player='", fullN,"'", sep="")
  
  myGoalies = dbSendQuery(mydb,myRequest)
  goaliesInfo = data.frame(fetch(myGoalies, n = -1)) #dataframe
  #combine skaters and goalies
  playerInfo <- rbind(goaliesInfo, skaterInfo)
  #Get all potential player IDs
  playerIDs <- unique(skaterInfo$player_id)
  
  #If no case found check for just last name
  if(length(playerIDs) == 0){
    #Check for unique last name
    myReq <- paste("SELECT player_id, pos, year ",
                   "FROM Skaters ",
                   "WHERE Skaters.player like '%",lName,"%'", sep="")
    
    mySkaters = dbSendQuery(mydb,myReq)
    skaterInfo = data.frame(fetch(mySkaters, n = -1)) #dataframe
    
    myReq <- paste("SELECT  player_id, pos, year ",
                   "FROM Goalies ",
                   "WHERE Goalies.player like '%",lName,"%'", sep="")
    
    myGoalies = dbSendQuery(mydb,myReq)
    goaliesInfo = data.frame(fetch(myGoalies, n = -1)) #dataframe
    
    playerInfo <- rbind(skaterInfo,goaliesInfo)
    
    playerIDs <- unique(playerInfo$player_id)
    
  }
  
  #If only one ID is returned assign that one ID 
  if(length(playerIDs) == 1){
    return(playerIDs)
    #If there are multiple players with that name
  }
  if(length(playerIDs)>1){
    for(i in c(1:nrow(playerInfo))){
      if(playerInfo$year[i] == year){
        return(playerInfo$player_id[i])
      }
    }
  }else{
    return(0)
  }
}





