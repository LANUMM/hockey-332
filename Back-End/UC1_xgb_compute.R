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

## This section must iterate the target variable over all o/d player statistics to report forecasts of each, for each player
## partition dataset
# currently set to 75/25 train/test
trainindex_od = data.frame(createDataPartition(df_od$a, p = 0.75, list = F, times = 1))$Resample1 # should train/test selection be random or linear with time?
train_od = data.frame(df_od[ ,c(8:20)][trainindex_od, ])
test_od = data.frame(df_od[ ,c(8:20)][-trainindex_od,])
head(train_od)
## XGBoost training
od_trainer = as.matrix(train_od)
head(od_trainer)
od_pred = as.matrix(test_od)
head(od_pred)
tv_train_od = train_od$a
head(tv_train_od)

#FUNCTIONAL ABOVE TO THIS POINT
#goalie duplication not yet written
# remainder of code to complete all xgb computation for goalies here
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
    # scale_pos_weight = 0.32, # uncommenting this line leads to the error
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
  stats::ts(start=2008, end = 2021, frequency = 13) #84, 87, 89 confirm

xgb_forecast <- xgb_pred %>%
  stats::ts(start=2008, end = 2021, frequency = 13)

ts <- tv_train_od %>%
  stats::ts(start=2008, end = 2021, frequency = 13)

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

#see goalie comment here for info
df_od_pred_pts <- 6*df_od$g + 4*df_od$a + 2*df_od$ppp + (.9)*df_od$sog + 1*df_od$blk
print(df_od_pred_pts)
od_pred2 <- df_od_pred_pts
od_pred3 <- od_pred2
od_pred2[od_pred2==0] <- NA
od_pred2 <- as.numeric(na.omit(od_pred2))
head(od_pred2)

meanSkate <- mean(od_pred2)
print(meanSkate)
sdSkate <- sd(od_pred2)
ZSkate <- ((od_pred2 - meanSkate) / (sdSkate))

rank_result_od <- rank(ZSkate, na.last = TRUE, ties.method = "first")

#error <- mean(as.numeric(pred > 0.5) != test$"target variable")
chisq_test <- chisq.test(df_od$sv, od_pred3)
print(chisq_test)

##Push to DB and Disconnect
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}
#calc fantasy points and yreturn year as 2022

