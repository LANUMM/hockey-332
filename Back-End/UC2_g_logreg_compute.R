##Boom/Bust G Classifier
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
library(tidyverse) # required for log reg
library(xgboost) # definitely required
library(zoo)

###CHANGE THIS SECTION FOR THIS SCRIPT (copied from xgb)
## load data
# we must connect to the SQL database and pull the table containing all player stats
db = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host') # remove '' when fields filled?
selection_g = dbSendQuery(db, "select * from table_name") # remove ""? # select goalies only
df_g = data.frame(fetch(selection_g, n = -1)) #dataframe of goalie stats
###NOTE: PREDICTOR VARIABLES MUST BE FLOAT OR CATEGORICAL, MAY NEED TO RECAST

## TRAIN/TEST PARTITIONING
trainindex_g = data.frame(createDataPartition("df_g$targetvariable", p = 0.75, list = F, times = 1))$Resample1 # should train/test selection be random or linear with time?
train_g = data.frame(df_g[trainindex_g,])
test_g = data.frame(df_g[-trainindex_g,])

###BEGIN BOOM CLASSIFIER
## BOOM LOGISTIC REGRESSION TRAINING
model_boomg <- glm("target variable" ~., data = train_g, family = binomial)
## BOOM LOGISTIC REGRESSION IMPLEMENT
probs_boomg <- model_boomg %>% predict(test_g, type = "response")
predictions_boomg <- ifelse(probs_boomg > 0.5, "boom", "no") #can change these to 1/0 later
# Assess Model Accuracy
mean(predictions_boomg == test_g$"target variable")

## ORGANIZE RESULT AND/OR POST PROCESSING
#this section will handle and output an od DF with predicted classification attributed

## LOGIC CONTROL AND SPECIAL CASE CHECKING FOR FINAL CLASSIFICATION

###END BOOM

###BEGIN BUST CLASSIFIER
## BUST LOGISTIC REGRESSION TRAINING
model_bustg <- glm("target variable" ~., data = train_g, family = binomial)
## BUST LOGISTIC REGRESSION IMPLEMENT
probs_bustg <- model_bustg %>% predict(test_g, type = "response")
predictions_bustg <- ifelse(probs_bustg > 0.5, "bust", "no") #can change these to 1/0 later; flip order for bust?
# Assess Model Accuracy
mean(predictions_bustg == test_g$"target variable")

## ORGANIZE RESULT AND/OR POST PROCESSING
#this section will handle and output a g DF with predicted classification attributed

## LOGIC CONTROL AND SPECIAL CASE CHECKING FOR FINAL CLASSIFICATION

###END BUST
