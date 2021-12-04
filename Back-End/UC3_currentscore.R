#we definitely don't need all of these packages in this boy
#install.packages(c("caret", "dplyr", "ggplot2", "RMySQL", "xgboost"))
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

#REQUIRE ITERATION OVER  ALL PRLAYERS AND ALL STATS

## load data
# we must connect to the SQL database and pull the table containing all player stats
db = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host') # remove '' when fields filled?
selection_CTS = dbSendQuery(db, "select * from table_name") # remove ""? # select offense and defense players only
df_CTS = data.frame(fetch(selection_CTS, n = -1)) # dataframe of offense and defense player stats
selection_GP = dbSendQuery(db, "select * from table_name") # remove ""? # select offense and defense players only
df_GP = data.frame(fetch(selection_GP, n = -1)) # dataframe of offense and defense player stats
pred_upd <- ((df_CTS * 56) / (df_GP))

#loop end
T_AVG <- mean(df_pred_upd) #df_pred_upd is output of loop
#push to sql, move to uc4
  #loop on team
  # fantasy score calc needed