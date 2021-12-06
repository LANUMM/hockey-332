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

#REQUIRE ITERATION OVER  ALL PRLAYERS AND ALL STATS
## load data
# we must connect to the SQL database and pull the table containing all player stats
mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_g = data.frame(fetch(selection_g, n = -1)) #dataframe


## This section must iterate the target variable over all goalie statistics to report forecasts of each, for each goalie
## partition dataset
# currently set to 75/25 train/test
trainindex_g = data.frame(createDataPartition(df_g$sv, p = 0.75, list = F, times = 1))$Resample1 # should train/test selection be random or linear with time?
train_g = data.frame(df_g[ ,c(7:11)][trainindex_g,])
test_g = data.frame(df_g[ ,c(7:11)][-trainindex_g,])

## XGBoost training
g_trainer = as.matrix(train_g)
g_pred = as.matrix(test_g)
tv_train_g = train_g$sv

## XGBoost Implementation
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
  g_trainer,
  tv_train_g,
  method = "xgbTree",
  trControl = xgb_trcontrol,
  tuneGrid = xgb_grid[1:7, ],
  scale_pos_weight = 0.32
)

fitted <- xgb_model %>%
  stats::predict(g_trainer) %>%
  stats::ts(start=2008, end = 2021, frequency = 13) #84, 87, 89 confirm

xgb_forecast <- xgb_pred %>%
  stats::ts(start=2008, end = 2021, frequency = 13)

ts <- tv_train_g %>%
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

g_pred_p = 5*df_stats_g$so + .6*df_stats_g$sv + 5*df_stats_g$w
g_pred2 <- g_pred_p
g_pred2[g_pred2==0] <- NA
g_pred2 <- g_pred2[-c(is.na(g_pred2))]

meanGoal <- mean(g_pred2)
sdGoal <- sd(g_pred2)
ZGoal <- ((g_pred2 - meanGoal) / (sdGoal))

rank_result_g <- rank(Zgoal, na.last = TRUE, ties.method = "first")

error <- mean(as.numeric(pred > 0.5) != test$"target variable")

##Push to DB and Disconnect
all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}

#test <- chisq.test(train$Age, output_vector)
#print(test)

## End section

