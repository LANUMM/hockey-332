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
selection_Zg = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_Zg = data.frame(fetch(selection_Zg, n = -1)) #dataframe
selection_Zod = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_Zod = data.frame(fetch(selection_Zod, n = -1)) #dataframe

df_Z <- append(df_Zod$Zscore,df_Zg$Zscore)
rank_result <- rank(df_Z, na.last = TRUE, ties.method = "first")
df_Zod_split <- df_Z[1:length(df_Zod)]
df_Zg_split <- df_Z[-(1:length(df_Zod))]
#
e <- 1
for(i in df_Zod_split){
  myRequest <- paste("UPDATE Skaters SET pre_rank=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}
e <- 1
for(i in df_Zg_split){
  myRequest <- paste("UPDATE Goalies SET pre_rank=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}
#return rank result