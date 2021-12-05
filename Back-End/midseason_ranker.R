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

ALl_pred2 <- df_TAVG
All_pred2[All_pred2==0] <- NA
All_pred2 <- All_pred2[-c(is.na(All_pred2))]
meanAll <- mean(all_pred2)
sdAll <- sd(all_pred2)
ZAll <- ((all_pred2 - meanAll) / (sdAll))
rank_result <- rank(ZAll, na.last = TRUE, ties.method = "first")
#return rank result midseason
#line 21 error for no reason

all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}