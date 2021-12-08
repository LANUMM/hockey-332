#TODO: Error check parse data for logic errors
#TODO: Input year of draft as user input and consider in error check ^ 
#TODO: Clean back up so it runs on the Server

library(stringi)#, lib.loc="~/www/Hockey/rpkg")
library(stringr)#, lib.loc="~/www/Hockey/rpkg")
library(gridExtra)#, lib.loc="~/www/Hockey/rpkg")
library(stringi)#, lib.loc="~/www/Hockey/rpkg")
library(stringr)#, lib.loc="~/www/Hockey/rpkg")
library(gridExtra)#, lib.loc="~/www/Hockey/rpkg")
library(RMySQL)#, lib.loc"~/www/Hockey/rpkg")

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
  # Have user input for Year
  #RUN ERROR CHECK CODE
  
  #Get the leauge ID
  myReq <- paste("SELECT MAX(league_id) FROM League")
  requestData = dbSendQuery(mydb,myReq)
  latestLeagueID = data.frame(fetch(requestData, n = -1))[[1]] 
  
  #For each team update Team table (team_id AUTO, leauge_id, Team name) (get team_id)
  ##and then Roster table for each player on the team (team_id, player_id, year, pick) 
  for(t in unique(myDF$DraftTeam)){
    teamData <- myDF[myDF$DraftTeam == t, ]
    
    #Update Team table
    myReq <- paste("INSERT INTO Team(league_id, team_name) VALUES(",latestLeagueID, ",'",teamData$DraftTeam[1],"')", sep="")
    print(paste("Team table statements:", myReq))
    dbSendQuery(mydb,myReq)
    
    #Update Roster
    
    #Get latest teamID 
    myReq <- paste("SELECT MAX(team_id) FROM Team")
    requestData = dbSendQuery(mydb,myReq)
    latestTeamID = data.frame(fetch(requestData, n = -1))[[1]] 
    
    print(latestTeamID)
    #Update Roster table
    for(i in c(1:nrow(teamData))){
      myReq <- paste("INSERT INTO Roster(team_id, player_id, year) VALUES(",latestTeamID, ",",teamData$player_id[i],",",thisYear,")", sep="")
      print(myReq)
      dbSendQuery(mydb,myReq)
    }
    
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

#setwd("~/www/Hockey/files")
#data=readLines('myfile')
data=readLines('C:\\Users\\matth\\Downloads\\mock2.txt')
capture<-str_match_all(data,"\\u0029\\s(.+)\\s\\u002D\\s(.+)\\s(.+)\\s\\u0028([A-Za-z]+)\\s\\u002D\\s([A-Za-z]+)")
names<-c("DraftTeam","FirstName","LastName","Team","Posistion")
temp<-do.call(rbind,capture)
df<-data.frame(DraftTeam=temp[,2],FirstName=temp[,3],LastName=temp[,4],Team=temp[,5],Position=temp[,6])
#remove '
df$FirstName <- lapply(df$FirstName,str_remove_all,pattern="'")
df$LastName <- lapply(df$LastName,str_remove_all,pattern="'")

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))

#Insert parsed data into DB
draftToDB(df)

#Close connections

all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

#Run again for saftey
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}