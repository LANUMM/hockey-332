## XGBoost Implementation
## load packages; all may not be required
#install.packages(c("caret", "dplyr", "ggplot2", "RMySQL", "xgboost"))
#require(caret, lib.loc"~/www/Hockey/rpkg") # definitely required
#require(data.table, lib.loc"~/www/Hockey/rpkg")
#require(dplyr, lib.loc"~/www/Hockey/rpkg") # definitely required
#require(forecast, lib.loc"~/www/Hockey/rpkg")
#require(ggplot2, lib.loc"~/www/Hockey/rpkg")
#require(lattice, lib.loc"~/www/Hockey/rpkg")
#require(magrittr, lib.loc"~/www/Hockey/rpkg")
#require(padr, lib.loc"~/www/Hockey/rpkg")
#require(Matrix, lib.loc"~/www/Hockey/rpkg")
#require(RcppRoll, lib.loc"~/www/Hockey/rpkg")
#require(RMySQL, lib.loc"~/www/Hockey/rpkg") # one of these SQL connections required
#require(xgboost, lib.loc"~/www/Hockey/rpkg") # definitely required
#require(zoo, lib.loc"~/www/Hockey/rpkg")
require(caret) # definitely required *********************
require(data.table)
require(dplyr) # definitely required *********************
require(forecast)
require(ggplot2)
require(lattice)
require(magrittr)
require(padr)
require(Matrix)
require(RcppRoll)
require(RMySQL) # one of these SQL connections required
require(xgboost) # definitely required #Problem*********************
require(zoo)

## load data
# we must connect to the SQL database and pull the table containing all player stats
mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
myReq <- paste("SELECT * FROM Skaters")
selection_od = dbSendQuery(mydb, myReq) # remove ""? # select TAVG
df_od = data.frame(fetch(selection_od, n = -1)) #dataframe
df_od$sog <- as.numeric(df_od$sog)
df_od$blk <- as.numeric(df_od$blk)
df_od$hit <- as.numeric(df_od$hit)
#statlist = c(8:20)
max_year = max(df_od$year)

statlist = c("g", "a", "pts", "pim", "ppg", "shg", "ppa", "sha", "sog", "blk", "hit", "ppp", "shp")
#myReq <- paste("SELECT * FROM Skaters WHERE Skaters.year=",max_year)
#myReq <- paste("SELECT * FROM Skaters S, (SELECT player_ids FROM Skaters S,(SELECT player_id, COUNT(year) AS Count FROM Skaters GROUP BY player_id) Y WHERE S.player_id=Y.player_id AND Y.count > 1) G WHERE S.player_id=G.player_id")
#myRep <- paste("SELECT player_id FROM Skaters GROUP BY player_id HAVING COUNT(player_id) > 1")
#Skaters.
myRequest <- paste("SELECT S.* FROM Skaters S, (SELECT player_id, COUNT(player_id) AS count FROM Skaters GROUP BY player_id) G WHERE S.player_id=G.player_id AND G.count>1")
myData = dbSendQuery(mydb,myRequest)
skater_ids_df = data.frame(fetch(myData, n = -1)) #dataframe
#playerData
#playerData[playerData$player_id==2012, ]

#myData = dbSendQuery(mydb,myReq)
#skater_ids_df = data.frame(fetch(myData, n = -1)) #dataframe
skater_ids = skater_ids_df$player_id
#Skater_ids are Skaters who played in 2021 and multiple years

skater_ids2 <- skater_ids_df[skater_ids_df$year == 2021, ]
#skater_ids2_1 <- skater_ids_df[skater_ids_df$year == 2020, ]

#skater_ids[skater_ids$player_id==1397, ]
#skater_ids3 = skater_ids[skater_ids$player_id == skater_ids2$player_id]
#which(skater_ids$year == 2008)

df_total = c()
df_final = c()

for (ind in skater_ids2$player_id) {
  #myReq <- paste("SELECT * FROM Skaters HAVING (COUNT(Skaters.player_id) > 1) AND Skaters.player_id=",ind)
  #myReq <- paste("SELECT * FROM Skaters HAVING (COUNT(Skaters.player_id) > 1) AND Skaters.player_id=",ind)
  #myData = dbSendQuery(mydb,myReq)
  #skater_info = data.frame(fetch(myData, n = -1)) #dataframe
  myReq <- paste("SELECT * FROM Skaters WHERE Skaters.player_id=",ind)
  myData = dbSendQuery(mydb,myReq)
  skater_info = data.frame(fetch(myData, n = -1)) #dataframe
  if (nrow(skater_info) == 1) {
    next
  }else {
    for (indx in statlist) {
      ## This section must iterate the target variable over all o/d player statistics to report forecasts of each, for each player
      ## partition dataset
      # currently set to 75/25 train/test
      skater_info2 = skater_info[rep(seq_len(nrow(skater_info)), each = 20), ]
      trainindex_od = data.frame(createDataPartition(skater_info2$indx, p = 0.75, list = F, times = 1))$Resample1 # should train/test selection be random or linear with time?
      train_od = data.frame(skater_info2$indx[trainindex_od, ])
      test_od = data.frame(skater_info2$indx[-trainindex_od,])
      #[ ,c(8:20)]
      
      if (ind == 2497){
        print('Dumbass')
      }
      ## XGBoost training
      od_trainer = as.matrix(train_od)
      od_pred = as.matrix(test_od)
      tv_train_od = train_od[indx]
      
      xgb_trcontrol <- caret::trainControl(
        method = "cv",
        number = 5,
        allowParallel = TRUE,
        verboseIter = FALSE,
        returnData = FALSE
      )
      
      xgb_grid <- base::expand.grid(
        list(
          nrounds = 1000,
          eta = c(0.001, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.3),
          max_depth = c(2, 4, 6, 8),
          gamma = c(1, 2, 3), 
          subsample = c(0.5, 0.75, 1),
          min_child_weight = c(1, 2, 3), 
          colsample_bytree = 1
        ))
      
      xgb_model <- train(
        od_trainer,
        tv_train_od,
        method = "xgbTree",
        trControl = xgb_trcontrol,
        tuneGrid = xgb_grid[1:7, ],
        scale_pos_weight = 0.32
      )
      
      xgb_pred <- xgb_model %>% stats::predict(od_pred)
      
      fitted <- xgb_model %>%
        stats::predict(od_trainer) %>%
        stats::ts(start=2008, end = max_year, frequency = (max_year - 2008)) #84, 87, 89 confirm
      
      xgb_forecast <- xgb_pred %>%
        stats::ts(start=2008, end = max_year, frequency = (max_year - 2008))
      
      ts <- tv_train_od %>%
        stats::ts(start=2008, end = max_year, frequency = (max_year - 2008))
      
      forecast_list  <- list(
        model = xgb_model$modelInfo,
        method = xgb_model$method,
        mean = xgb_forecast,
        x = ts,
        fitted = fitted,
        residuals = as.numeric(ts) - as.numeric(fitted)
        )
      class(forecast_list) <- "forecast"
      forecast::autoplot(forecast_list)
      
      df_final = append(df_final, xgb_pred)
      }
   }
  df_final = as.matrix(df_final)
  df_final = t(df_final)
  future_vals = c(ind, df_final)
  df_total = data.frame(append(df_total, future_vals))
}

#use df_final as final loop database
#see goalie comment here for info
df_total_pred_pts <- 6*df_total[2] + 4*df_total[3] + 2*df_total[13] + (.9)*df_total[10] + 1*df_total[11]
od_pred2 <- df_total_pred_pts
od_pred3 <- od_pred2
od_pred2[od_pred2==0] <- NA
od_pred2 <- as.numeric(na.omit(od_pred2))

meanSkate <- mean(od_pred2)
sdSkate <- sd(od_pred2)
ZSkate <- ((od_pred2 - meanSkate) / (sdSkate))

rank_result_od <- rank(ZSkate, na.last = TRUE, ties.method = "first")

#error <- mean(as.numeric(pred > 0.5) != test$"target variable")
#chisq_test <- chisq.test(df_od$sv, od_pred3)
#print(chisq_test)

e <- 1
for(i in df_total_pred_pts){
  myRequest <- paste("UPDATE Skaters SET pred_fantasy_score=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e <- e+1
}

e <- 1
for(i in rank_result_od){
  myRequest <- paste("UPDATE Skaters SET pre_rank=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e <- e+1
}

e <- 1
for(i in ZSkate){
  myRequest <- paste("UPDATE Skaters SET Zscore=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e <- e+1
}

#must be inside loop
for (indx in statlist){
  e <- 1
  for(i in df_total[indx+1]){
    myRequest <- paste("UPDATE Skaters SET indx*=",i , "WHERE ", "rows=",e)
    dbSendQuery(mydb,myRequest)
    e<- e+1
  }
}
##Push to DB and Disconnect
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}