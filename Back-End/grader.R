#require(caret, lib.loc"~/www/Hockey/rpkg") # definitely required
#library(data.table, lib.loc"~/www/Hockey/rpkg")
#library(dplyr, lib.loc"~/www/Hockey/rpkg") # definitely required
#library(ggplot2, lib.loc"~/www/Hockey/rpkg")
#library(lattice, lib.loc"~/www/Hockey/rpkg")
#library(magrittr, lib.loc"~/www/Hockey/rpkg")
#library(padr, lib.loc"~/www/Hockey/rpkg")
#library(Matrix, lib.loc"~/www/Hockey/rpkg")
#library(RcppRoll, lib.loc"~/www/Hockey/rpkg")
#library(RMySQL, lib.loc"~/www/Hockey/rpkg") # one of these SQL connections required
#library(xgboost, lib.loc"~/www/Hockey/rpkg") # definitely required
#library(zoo, lib.loc"~/www/Hockey/rpkg")

require(caret)
require(data.table)
require(dplyr) # definitely required
require(ggplot2)
require(lattice)
require(magrittr)
require(padr)
require(Matrix)
require(RcppRoll)
require(RMySQL) # one of these SQL connections required
require(xgboost) # definitely required
require(zoo)


#######################################################################################
# Function to generate the sum of pred_fantasy_score for all teams in a league
# Input: myLeague_id the league_id of the league you want the teams data for
# Output: scoreDF a DF of team IDs in the given league and the sum of the pred_fantasy_score for the players on that team
#######################################################################################
#pred_fantasy_score
teamSumScore <- function(myLeague_id){
  scoreDF <- data.frame()
  #Get team_ids for that league
  myRequest <- paste("select team_id from Team where Team.league_id=", myLeague_id)
  myData = dbSendQuery(mydb,myRequest)
  teamIDs = data.frame(fetch(myData, n = -1)) #dataframe
  
  #for every team in the league, find all the players and sum the stat in question 
  for(i in teamIDs){
    myRequest <- paste("SELECT player_id FROM Roster WHERE team_id=", i)
    myData = dbSendQuery(mydb,myRequest)
    playerIDs = data.frame(fetch(myData, n = -1)) #dataframe
    #Return the sum of the fantasy_score for all of the players on the given roster
    idReq<- paste(playerIDs$player_id, collapse=" OR player_id=")
    myRequest <- paste("SELECT SUM(Y.fantasy_score) ",
                       "FROM (SELECT fantasy_score FROM Skaters WHERE player_id=", idReq,
                       " UNION ",
                       "SELECT fantasy_score FROM Goalies WHERE player_id=", idReq, ") Y", sep="")
    
    myData = dbSendQuery(mydb,myRequest)
    teamScore = data.frame(fetch(myData, n = -1)) #dataframe
    teamScore <- teamScore$SUM.Y.fantasy_score.
    scoreDF <- rbind(scoreDF, c(i,teamScore))
  }
  return(scoreDF)
}

# PULL FROM A FANTASY TEAM, NOT PLAYER ID
mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))

#All league data
myData = dbSendQuery(mydb, "SELECT league_id FROM League")
leagueIDs = data.frame(fetch(myData, n = -1)) #dataframe

for(i in league_id){
  scoreDF <- teamSumScore(i)
  
  
  
}
# ABOVE MUST BE ITERATED OVER A LEAGUE
df_TAVG = c(10,11,12,10,9,12,15,14)
num_teams <- length(df_TAVG)
bin_width = ceiling(num_teams / 5) #check
sort_df = sort(df_TAVG, decreasing = T)
sort_df[1:bin_width] <- "A"
sort_df[(1+bin_width):((2*bin_width))] <- "B"
sort_df[(1+2*bin_width):((3*bin_width))] <- "C"
sort_df[(1+3*bin_width):(4*bin_width)] <- "D"
sort_df[(1+4*bin_width):(5*bin_width)] <- "F"
sorted_df <- sort_df[1:num_teams]
match_sort <- sort(df_TAVG, decreasing = T)
matched_grades <- cbind(match_sort,sorted_df)
print(matched_grades)
# PUSH MATCHED_GRADES WITH

e <- 1
for(i in df_od_pred_pts){
  myRequest <- paste("UPDATE Skaters SET fantasy_score=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}


all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}
#check 


#pred_fantasy_score
teamSumScore <- function(myLeague_id){
  scoreDF <- data.frame()
  #Get team_ids for that league
  myRequest <- paste("select team_id from Team where Team.league_id=", myLeague_id)
  myData = dbSendQuery(mydb,myRequest)
  teamIDs = data.frame(fetch(myData, n = -1)) #dataframe
  
  #for every team in the league, find all the players and sum the stat in question 
  for(i in teamIDs){
    myRequest <- paste("SELECT player_id FROM Roster WHERE team_id=", i)
    myData = dbSendQuery(mydb,myRequest)
    playerIDs = data.frame(fetch(myData, n = -1)) #dataframe
    #Return the sum of the fantasy_score for all of the players on the given roster
    idReq<- paste(playerIDs$player_id, collapse=" OR player_id=")
    myRequest <- paste("SELECT SUM(Y.fantasy_score) ",
          "FROM (SELECT fantasy_score FROM Skaters WHERE player_id=", idReq,
          " UNION ",
          "SELECT fantasy_score FROM Goalies WHERE player_id=", idReq, ") Y", sep="")
        
    myData = dbSendQuery(mydb,myRequest)
    teamScore = data.frame(fetch(myData, n = -1)) #dataframe
    teamScore <- teamScore$SUM.Y.fantasy_score.
    scoreDF <- rbind(scoreDF, c(i,teamScore))
  }
  return(scoreDF)
}
