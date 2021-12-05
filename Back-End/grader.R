library(caret, lib.loc"~/www/Hockey/rpkg") # definitely required
library(data.table, lib.loc"~/www/Hockey/rpkg")
library(dplyr, lib.loc"~/www/Hockey/rpkg") # definitely required
library(ggplot2, lib.loc"~/www/Hockey/rpkg")
library(lattice, lib.loc"~/www/Hockey/rpkg")
library(magrittr, lib.loc"~/www/Hockey/rpkg")
library(padr, lib.loc"~/www/Hockey/rpkg")
library(Matrix, lib.loc"~/www/Hockey/rpkg")
library(RcppRoll, lib.loc"~/www/Hockey/rpkg")
library(RMySQL, lib.loc"~/www/Hockey/rpkg") # one of these SQL connections required
library(xgboost, lib.loc"~/www/Hockey/rpkg") # definitely required
library(zoo, lib.loc"~/www/Hockey/rpkg")

# PULL FROM A FANTASY TEAM, NOT PLAYER ID
mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_leagueId = dbSendQuery(mydb, "select * from League") # remove ""? # select TAVG
df_leagueId = data.frame(fetch(selection_leagueId, n = -1)) #dataframe
selection_TAVG = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_TAVG = data.frame(fetch(selection_TAVG, n = -1)) #dataframe

myTeamScore <- data.frame()
for (i in df_league$league_id) {
  myRequest <- paste("SELECT * from Team WHERE league_id=",i)
  selection_TeamId = dbSendQuery(mydb, myRequest) # remove ""? # select TAVG
  df_Team = data.frame(fetch(selection_TeamId, n = -1)) #dataframe
  df_TeamId <- df_Team$team_id
  for(z in df_TeamId){
    
  }
  
  
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
