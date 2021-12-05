require("RMySQL")
library(RMySQL)

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))

#get input DF from parsed function 
parsedDF <- read.csv("~/www/Hockey/files/parseDF")


#get midseasonRankings from DB 
selection_rank = db





all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

