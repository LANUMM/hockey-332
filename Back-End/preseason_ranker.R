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
selection_Zg = dbSendQuery(db, "select * from table_name") # remove ""? # select goalies only Z score for both
df_Zg = data.frame(fetch(selection_Zg, n = -1)) #dataframe of goalie statsselection_g = dbSendQuery(db, "select * from table_name") # remove ""? # select goalies only
selection_Zod = dbSendQuery(db, "select * from table_name") # remove ""? # select goalies only
df_Zod = data.frame(fetch(selection_Zod, n = -1)) #dataframe of goalie statsselection_g = dbSendQuery(db, "select * from table_name") # remove ""? # select goalies only

df_Z <- append(df_Zod,df_Zg)
rank_result <- rank(df_Z, na.last = TRUE, ties.method = "first")
#return rank result
