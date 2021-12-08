#we definitely don't need all of these packages in this boy
#install.packages(c("caret", "dplyr", "ggplot2", "RMySQL", "xgboost"))
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

#REQUIRE ITERATION OVER  ALL PRLAYERS AND ALL STATS

## load data
# we must connect to the SQL database and pull the table containing all player stats

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_CTS = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_CTS = data.frame(fetch(selection_CTS, n = -1)) #dataframe

selection_CTS_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_CTS_g = data.frame(fetch(selection_CTS_g, n = -1)) #dataframe
print(df_CTS_g)

df_CTS_g1 <- (df_CTS_g$fantasy_score)
df_GP_g <- df_CTS_g$gp

df_CTS_g1 <- as.numeric(df_CTS_g1)
df_GP_g <- as.numeric(df_GP_g)

df_CTS_g1[which(is.na(df_CTS_g1))] <- 0
df_GP_g[which(is.na(df_GP_g))] <- 0

print(df_CTS_g1)

df_pred_upd_g <- ((rep(84, length(df_CTS_g1)) * df_CTS_g1) / (df_GP_g))

#loop end
T_AVG_g <- mean(df_pred_upd_g) #df_pred_upd is output of loop
#push to sql, move to uc4
  #loop on team
  # fantasy score calc needed

df_CTS1 <- df_CTS$fantasy_score
df_GP <- df_CTS$gp

df_CTS1 <- as.numeric(df_CTS1)
df_GP <- as.numeric(df_GP)

df_GP[which(is.na(df_GP))] <- 0

df_pred_upd <- ((rep(84, length(df_CTS1)) * df_CTS1) / (df_GP))





#loop end
T_AVG <- mean(df_pred_upd) #df_pred_upd is output of loop

e <- 1
for(i in df_pred_upd){
  myRequest <- paste("UPDATE Skaters SET mid_pred_fantasy_scr=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}

e <- 1
for(i in df_pred_upd_g){
  myRequest <- paste("UPDATE Goalies SET mid_pred_fantasy_scr=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}