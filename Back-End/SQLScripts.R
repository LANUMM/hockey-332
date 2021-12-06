
require(RMySQL) 

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))


###
myRequest <- paste("SELECT <<Roster>>",
                   "FROM Team, <<Roster>>",
                   "WHERE Team.league_id=1 AND <<Roster>>.team_id=Team.team_id")
myData = dbSendQuery(mydb,myRequest)
myData = data.frame(fetch(myData, n = -1)) #dataframe
myData

#INSERT ROSTER 


all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}
