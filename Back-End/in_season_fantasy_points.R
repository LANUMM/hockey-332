library(caret) # definitely required
library(data.table)
library(dplyr) # definitely required
library(ggplot2)
library(lattice)
library(magrittr)
library(padr)
library(Matrix)
library(RcppRoll)
library(RMySQL) # one of these SQL connections required
library(RSQLite) # one of these SQL connections required
library(xgboost) # definitely required
library(zoo)

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_stats_od = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG 
df_stats_od = data.frame(fetch(selection_stats_od, n = -1)) #dataframe 

selection_stats_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG 
df_stats_g = data.frame(fetch(selection_stats_g, n = -1)) #dataframe 

df_od_pred_pts <- 6*df_stats_od$g + 4*df_stats_od$a + 2*df_stats_od$ppp + (.9)*as.double(df_stats_od$sog) + 1*as.double(df_stats_od$blk)
g_pred_p = 5*df_stats_g$so + .6*df_stats_g$sv + 5*df_stats_g$w

#return both stats as CTS (fantasy points)

for(i in df_od_pred_pts){
  dbSendQuery(mydb, "UPDATE Skaters SET fantasy_score=5;")
}

dbSendQuery(mydb, "UPDATE Skaters SET fantasy_score=5 WHERE ;")
dbSendQuery(mydb, "UPDATE Skaters SET fantasy_score=5 WHERE ;")

all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

