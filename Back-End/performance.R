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
selection_TAVG = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_TAVG = data.frame(fetch(selection_TAVG, n = -1)) #dataframe
selection_pred_pts = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_pred_pts = data.frame(fetch(selection_pred_pts, n = -1)) #dataframe

df_TAVG <- df_TAVG$mid_pred_fantasy_scr
df_pred_pts <- df_pred_pts$pred_fantasy_score

df_perform_class <- c()
df_index <- c(1:length(df_TAVG))
for (i in df_index) {
  if (df_TAVG[i] > (1.05 * df_pred_pts[i])) {
    df_perform_class[i] = 'Good'
  }else if (df_TAVG[i] < (.95 * df_pred_pts[i])) {
    df_perform_class[i] = 'Poor'
  }else {
    df_perform_class[i] = 'Nuetral'
  } 
}

selection_TAVG_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_TAVG_g = data.frame(fetch(selection_TAVG_g, n = -1)) #dataframe
selection_pred_pts_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_pred_pts_g = data.frame(fetch(selection_pred_pts_g, n = -1)) #dataframe

df_TAVG_g <- df_TAVG_g$mid_pred_fantasy_scr
df_pred_pts_g <- df_pred_pts_g$pred_fantasy_score

df_perform_class_g <- c()

df_index_g <- c(1:length(df_TAVG_g))
for (i in df_index_g) {
  if (df_TAVG_g[i] > (1.05 * df_pred_pts_g[i])) {
    df_perform_class_g[i] = 'Good'
  }else if (df_TAVG_g[i] < (.95 * df_pred_pts_g[i])) {
    df_perform_class_g[i] = 'Poor'
  }else {
    df_perform_class_g[i] = 'Nuetral'
  } 
}

#needs a duplicate for goalies
e <- 1
for(i in df_perform_class){
  myRequest <- paste("UPDATE Skaters SET performance=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}

e <- 1
for(i in df_perform_class_g){
  myRequest <- paste("UPDATE Goalies SET performance=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}

all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}
