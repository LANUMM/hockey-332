#we definitely don't need all of these packages in this boy
#install.packages(c("caret", "dplyr", "ggplot2", "RMySQL", "xgboost"))
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

#REQUIRE ITERATION OVER  ALL PRLAYERS AND ALL STATS

## load data
# we must connect to the SQL database and pull the table containing all player stats

mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_CTS = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_CTS = data.frame(fetch(selection_CTS, n = -1)) #dataframe
selection_GP = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_GP = data.frame(fetch(selection_GP, n = -1)) #dataframe

pred_upd <- ((df_CTS * 56) / (df_GP))

#loop end
T_AVG <- mean(df_pred_upd) #df_pred_upd is output of loop
#push to sql, move to uc4
  #loop on team
  # fantasy score calc needed
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}