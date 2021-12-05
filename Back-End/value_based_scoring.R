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
selection_od = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_od = data.frame(fetch(selection_od, n = -1)) #dataframe
selection_g = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_g = data.frame(fetch(selection_g, n = -1)) #dataframe
#rank is rank pulled from sql pertaining to sepcific player

#pos is postition pulled

position_od = c("C", "LW", "RW", "D", "F")

meanSkate_res <- c()

sdSkate_res <- c()



# compute position average (not goalies)

for (i in position_od){
  
  # search df_od for all players at a position 'i' #if this doesnt work nicely for some reason, consider regular expressions
  
  df_od_reader = which(str_detect(df_od$positioncol, i))
  
  df_od_i <- df_od$fantasypointcol[df_od$fantasypointcol == df_od_reader]
  
  df_od_id <- df_od$playerid[df_od$playerid == df_od_reader]
  
  # remove zero values and compute position mean
  
  od_pred2 <- df_od_i
  
  od_pred2[od_pred2==0] <- NA
  
  od_pred2 <- od_pred2[-c(is.na(od_pred2))]
  
  meanSkate <- mean(od_pred2)
  
  sdSkate <- sd(od_pred2)
  
  # append mean to meanSkate_res
  
  append(meanSkate_res, meanSkate)
  
  append(sdSkate_res, sdSkate)
  
  return (rankdown <- df_od_id[rank+1])
  
}



sorted_df_g <- df_g[order(df_g$rank),]

ZSkate <- ((df_od$fantasypointcol[rank] - meanSkate_res[which(position_od==pos)]) / (sdSkate_res[which(position_od==pos)])) + 4

ZSkate_under <- ((df_od$fantasypointcol[which(playerid==rankdown)]- meanSkate_res[which(position_od==pos)]) / (sdSkate_res[which(position_od==pos)])) + 4 #justify



Val_score1 = (ZSkate / ZSkate_under)

df_Val_score2 = (df_od_i$fantasypointcol[rank] / meanSkate_res) #check for ector vs scalar problems



rankg = rank[which(playerid==sorted_df_g$playerid)]

g_pred2 <- sorted_df_g

g_pred2$fantasypointcol[g_pred2==0] <- NA

g_pred2$fantasypointcol <- g_pred2$fantasypointcol[-c(is.na(g_pred2$fantasypointcol))]

meanGoal <- mean(g_pred2$fantasypointcol)

sdGoal <- sd(g_pred2$fantasypointcol)

ZGoal <- ((g_pred2$fantasypointcol[rankg] - meanGoal) / (sdGoal)) + 4



df_val_score3 = (df_od$fantasypointcol[rank] / meanGoal)



ZSkate_underg <- ((g_pred2$fantasypointcol[rankg+1] - meanGoal) / (sdGoal)) + 4

Val_score1g = (Zgoal / ZSkate_underg)

df_Val_score2g = (g_pred2$fantasypointcol[rankg] / meanSkate_res) #check for vector vs scalar problems

df_val_score3g = (g_pred2$fantasypointcol[rankg] / meanGoal) #add $ for al late calc in boost code



#this code may need to be seperated between g and od


all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

