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

db = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host') # remove '' when fields filled? #needs to pull gaolies and skaters
selection_TAVG = dbSendQuery(db, "select * from table_name") # remove ""? # select TAVG 
df_TAVG = data.frame(fetch(selection_TAVG, n = -1)) #dataframe 
selection_pred_pts = dbSendQuery(db, "select * from table_name") # remove ""? # select (preseason) fantasy points prediction (df_g/od_pred_pts)
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
#return df_perform_class to SQL (column)
