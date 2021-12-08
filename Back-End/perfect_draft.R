require("RMySQL")
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


mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))

#get input DF from parsed function 


#get midseasonRankings from DB 
selection_MidRank_od = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_MidRank_od = data.frame(fetch(selection_MidRank_od, n = -1)) #dataframe
df_MidRank_od <- df_MidRank_od$mid_rank

selection_MidRank_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_MidRank_g = data.frame(fetch(selection_MidRank_g, n = -1)) #dataframe
df_MidRank_g <- df_MidRank_g$mid_rank








all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

