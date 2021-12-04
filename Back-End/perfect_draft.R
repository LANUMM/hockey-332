require("RMySQL")
library(RMySQL)

mydb <- dbConnect(MySQL(), user = 'g1117489', password = '4jU2vUv9', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))

#get input DF from parsed function 


#get midseasonRankings from DB 






all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

