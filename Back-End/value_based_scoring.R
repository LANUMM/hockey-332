library(caret)#, lib.loc"~/www/Hockey/rpkg") # definitely required
library(data.table)#, lib.loc"~/www/Hockey/rpkg")
library(dplyr)#, lib.loc"~/www/Hockey/rpkg") # definitely required
library(ggplot2)#, lib.loc"~/www/Hockey/rpkg")
library(lattice)#, lib.loc"~/www/Hockey/rpkg")
library(magrittr)#, lib.loc"~/www/Hockey/rpkg")
library(padr)#, lib.loc"~/www/Hockey/rpkg")
library(Matrix)#, lib.loc"~/www/Hockey/rpkg")
library(RcppRoll)#, lib.loc"~/www/Hockey/rpkg")
library(RMySQL)#, lib.loc"~/www/Hockey/rpkg") # one of these SQL connections required
library(xgboost)#, lib.loc"~/www/Hockey/rpkg") # definitely required
library(zoo)#, lib.loc"~/www/Hockey/rpkg")

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_od = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_od = data.frame(fetch(selection_od, n = -1)) #dataframe
selection_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_g = data.frame(fetch(selection_g, n = -1)) #dataframe
#rank is rank pulled from sql pertaining to sepcific player

#pos is postition pulled

position_od = c("C", "LW", "RW", "D", "F")

meanSkate_res <- c()

sdSkate_res <- c()





# compute position average (not goalies)

for (i in position_od){
  
  # search df_od for all players at a position 'i' #if this doesnt work nicely for some reason, consider regular expressions
  
  df_od_reader = which(str_detect(df_od$pos, i))
  
  df_od_i <- df_od$mid_pred_fantasy_scr[df_od$mid_pred_fantasy_scr == df_od_reader]
  
  df_od_id <- df_od$player_id[df_od$player_id == df_od_reader]
  
  # remove zero values and compute position mean
  
  od_pred2 <- df_od_i
  
  od_pred2[which(is.na(od_pred2))] <- 0
  
  od_pred2 <- na.omit(od_pred2)
  
  meanSkate <- mean(od_pred2)
  
  sdSkate <- sd(od_pred2)
  
  # append mean to meanSkate_res
  
  meanskate_res <- append(meanSkate_res, meanSkate)
  
  sdSkate_res <- append(sdSkate_res, sdSkate)
  
  return (rankdown <- df_od_id[rank+1])
  
}



sorted_df_g <- df_g[order(df_g$mid_rank),]

ZSkate <- ((df_od$mid_pred_fantasy_scr[rank] - meanSkate_res[which(position_od==df_g$pos)]) / (sdSkate_res[which(position_od==df_g$pos)])) + 4

ZSkate_under <- ((df_od$mid_pred_fantasy_scr[which(df_g$player_id==rankdown)]- meanSkate_res[which(position_od==df_g$pos)]) / (sdSkate_res[which(position_od==df_g$pos)])) + 4 #justify



Val_score1 = (ZSkate / ZSkate_under)

df_Val_score2 = (df_od_i$mid_pred_fantasy_scr[rank] / meanSkate_res) #check for ector vs scalar problems



rankg = rank[which(df_g$playerid==sorted_df_g$playerid)]

g_pred2 <- sorted_df_g

g_pred2[which(is.na(g_pred2))] <- 0

od_pred2$mid_pred_fantasy_scr <- na.omit(mid_pred_fantasy_scr)



meanGoal <- mean(g_pred2$mid_pred_fantasy_scr)

sdGoal <- sd(g_pred2$mid_pred_fantasy_scr)

ZGoal <- ((g_pred2$mid_pred_fantasy_scr[rankg] - meanGoal) / (sdGoal)) + 4



df_val_score3 = (df_od$mid_pred_fantasy_scr[rank] / meanGoal)



ZSkate_underg <- ((g_pred2$mid_pred_fantasy_scr[rankg+1] - meanGoal) / (sdGoal)) + 4

Val_score1g = (Zgoal / ZSkate_underg)

df_Val_score2g = (g_pred2$mid_pred_fantasy_scr[rankg] / meanSkate_res) #check for vector vs scalar problems

df_val_score3g = (g_pred2$mid_pred_fantasy_scr[rankg] / meanGoal) #add $ for al late calc in boost code

#probably needs to be split and needs reworking for sure

#this code may need to be seperated between g and od

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

