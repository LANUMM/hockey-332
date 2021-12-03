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
# PULL FROM A FANTASY TEAM, NOT PLAYER ID
db = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host') # remove '' when fields filled?
selection_TAVG = dbSendQuery(db, "select * from table_name") # remove ""? # select offense and defense players only
df_TAVG = data.frame(fetch(selection_TAVG, n = -1)) # dataframe of offense and defense player stats
# ABOVE MUST BE ITERATED OVER A LEAGUE
df_TAVG = c(10,11,12,10,9,12,15,14)
num_teams <- length(df_TAVG)
bin_width = ceiling(num_teams / 5) #check
sort_df = sort(df_TAVG, decreasing = T)
sort_df[1:bin_width] <- "A"
sort_df[(1+bin_width):((2*bin_width))] <- "B"
sort_df[(1+2*bin_width):((3*bin_width))] <- "C"
sort_df[(1+3*bin_width):(4*bin_width)] <- "D"
sort_df[(1+4*bin_width):(5*bin_width)] <- "F"
sorted_df <- sort_df[1:num_teams]
match_sort <- sort(df_TAVG, decreasing = T)
matched_grades <- cbind(match_sort,sorted_df)
print(matched_grades)
# PUSH MATCHED_GRADES WITH
