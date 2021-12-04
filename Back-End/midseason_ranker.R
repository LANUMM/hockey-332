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

db = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host') # remove '' when fields filled?
selection_TAVG = dbSendQuery(db, "select * from table_name") # remove ""? # pull TAVG dataframe for all players
df_TAVG = data.frame(fetch(selection_TAVG, n = -1)) # dataframe of offense and defense player stats

ALl_pred2 <- df_TAVG
All_pred2[All_pred2==0] <- NA
All_pred2 <- All_pred2[-c(is.na(All_pred2))]
meanAll <- mean(all_pred2)
sdAll <- sd(all_pred2)
ZAll <- ((all_pred2 - meanAll) / (sdAll))
rank_result <- rank(ZAll, na.last = TRUE, ties.method = "first")
#return rank result midseason
#line 21 error for no reason

