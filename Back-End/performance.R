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

all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}
