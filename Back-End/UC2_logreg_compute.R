##Boom/Bust OD Classifier
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

## load data
# we must connect to the SQL database and pull the table containing all player stats
db = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host') # remove '' when fields filled?
selection_od = dbSendQuery(db, "select * from table_name") # remove ""? # select offense and defense players only
df_od = data.frame(fetch(selection_od, n = -1)) # dataframe of offense and defense player stats
###NOTE: PREDICTOR VARIABLES MUST BE FLOAT OR CATEGORICAL, MAY NEED TO RECAST

## TRAIN/TEST PARTITIONING
trainindex_od = data.frame(createDataPartition("df_od$targetvariable", p = 0.75, list = F, times = 1))$Resample1 # should train/test selection be random or linear with time?
train_od = data.frame(df_od[trainindex_od,])
test_od = data.frame(df_od[-trainindex_od,])

###BEGIN BOOM CLASSIFIER
## BOOM LOGISTIC REGRESSION TRAINING
model_boomod <- glm("target variable" ~., data = train_od, family = binomial)
## BOOM LOGISTIC REGRESSION IMPLEMENT
probs_boomod <- model_boomod %>% predict(test_od, type = "response")
predictions_boomod <- ifelse(probs_boomod > 0.5, "boom", "no") #can change these to 1/0 later
# Assess Model Accuracy
mean(predictions_boomod == test_od$"target variable")

## ORGANIZE RESULT AND/OR POST PROCESSING
#this section will handle and output an od DF with predicted classification attributed

## LOGIC CONTROL AND SPECIAL CASE CHECKING FOR FINAL CLASSIFICATION

###END BOOM

###BEGIN BUST CLASSIFIER
## BUST LOGISTIC REGRESSION TRAINING
model_bustod <- glm("target variable" ~., data = train_od, family = binomial)
## BUST LOGISTIC REGRESSION IMPLEMENT
probs_bustod <- model_bustod %>% predict(test_od, type = "response")
predictions_bustod <- ifelse(probs_bustod > 0.5, "bust", "no") #can change these to 1/0 later; flip order for bust?
# Assess Model Accuracy
mean(predictions_bustod == test_od$"target variable")

## ORGANIZE RESULT AND/OR POST PROCESSING
#this section will handle and output an od DF with predicted classification attributed

## LOGIC CONTROL AND SPECIAL CASE CHECKING FOR FINAL CLASSIFICATION

###END BUST
