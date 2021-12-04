## XGBoost Implementation

## load packages; all may not be required

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

selection_g = dbSendQuery(db, "select * from table_name") # remove ""? # select goalies only

df_g = data.frame(fetch(selection_g, n = -1)) #dataframe of goalie stats



## This section must iterate the target variable over all o/d player statistics to report forecasts of each, for each player

## partition dataset

# currently set to 75/25 train/test



# remainder of code to complete all xgb computation for o/d here



## End section



## This section must iterate the target variable over all goalie statistics to report forecasts of each, for each goalie

## partition dataset

# currently set to 75/25 train/test

trainindex_g = data.frame(createDataPartition("df_g$targetvariable", p = 0.75, list = F, times = 1))$Resample1 # should train/test selection be random or linear with time?

train_g = data.frame(df_g[trainindex_g,])

test_g = data.frame(df_g[-trainindex_g,])



## XGBoost training

g_trainer = xgboost::xgb.DMatrix(as.matrix(train_g))

g_pred = xgboost::xgb.DMatrix(as.matrix(test_g))

tv_train_g = train_g$'targetvariable'



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
    
    nrounds = c(100,200),
    
    maxdepth = c(10, 15, 20),
    
    colsample_bytree = seq(.5),
    
    eta = .1,
    
    gamma = 0,
    
    min_child_weight = 1,
    
    subsample = 1
    
  ))

xgb_model <- caret::train(
  
  g_trainer, tv_train_g,
  
  trControl = xgb_trcontrol,
  
  tuneGrid = xgb_grid,
  
  method = "xgbTree",
  
  nthread = 1
  
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

# must put into a big database of data calling that big database pull of indy player df_g_pred

g_pred_p = 5*df_g_pred$shutouts + .6*df_g_pred$saves + 5*df_g_pred$win

###

g_pred2 <- g_pred_p



g_pred2[g_pred2==0] <- NA



g_pred2 <- g_pred2[-c(is.na(g_pred2))]



meanGoal <- mean(g_pred2)



sdGoal <- sd(g_pred2)



ZGoal <- ((g_pred2 - meanGoal) / (sdGoal))

rank_result_g <- rank(Zgoal, na.last = TRUE, ties.method = "First")

## End section