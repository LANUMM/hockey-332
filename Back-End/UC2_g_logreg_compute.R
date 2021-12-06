##Boom/Bust G Classifier
## load packages; all may not be required
#install.packages(c("caret", "dplyr", "ggplot2", "RMySQL", "xgboost"))
require(caret, lib.loc"~/www/Hockey/rpkg") # definitely required
require(data.table, lib.loc"~/www/Hockey/rpkg")
require(dplyr, lib.loc"~/www/Hockey/rpkg") # definitely required
require(ggplot2, lib.loc"~/www/Hockey/rpkg")
require(lattice, lib.loc"~/www/Hockey/rpkg")
require(magrittr, lib.loc"~/www/Hockey/rpkg")
require(padr, lib.loc"~/www/Hockey/rpkg")
require(Matrix, lib.loc"~/www/Hockey/rpkg")
require(RcppRoll, lib.loc"~/www/Hockey/rpkg")
require(RMySQL, lib.loc"~/www/Hockey/rpkg") # one of these SQL connections required
require(xgboost, lib.loc"~/www/Hockey/rpkg") # definitely required
require(zoo, lib.loc"~/www/Hockey/rpkg")

###CHANGE THIS SECTION FOR THIS SCRIPT (copied from xgb)
## load data
# we must connect to the SQL database and pull the table containing all player stats
mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_g = dbSendQuery(mydb, "select * from Goalies") # remove ""? # select TAVG
df_g = data.frame(fetch(selection_g, n = -1)) #dataframe
###NOTE: PREDICTOR VARIABLES MUST BE FLOAT OR CATEGORICAL, MAY NEED TO RECAST

##Model must iterate over every player
##Binary Variable Construction
#tm_compare, gp_boom_compare, gp_bust_compare must be iterated over every pair of sequential years
#Interseason Team Change
#need to compare prev year team (2021) to next year team; str_detect not necessary
tm_1 = df_g$tm["how get year 1?"]
tm_2 = df_g$tm["how get year 2?"]
tm_compare

#Games played increase excl. (boom)
#need to compare prev year gp (2021) to next year gp
gp_bb_1 = df_g$gp["how get year 1?"]
gp_bb_2 = df_g$gp["how get year 1?"]
gp_boom_compare
#Games played decrease or equal (bust)
gp_bust_compare

# Optimal Age Checker
opt_age = (df_g$age == 28)

# Rookie Checker
rookie_age = (df_g$age == 23)

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
accur = mean(predictions_bustg == test_g$"target variable")

## ORGANIZE RESULT AND/OR POST PROCESSING
#this section will handle and output a g DF with predicted classification attributed

## LOGIC CONTROL AND SPECIAL CASE CHECKING FOR FINAL CLASSIFICATION
#needs adjustment

###END BUST

##Push to DB and Disconnect
e <- 1
for(i in T_AVG){
  myRequest <- paste("UPDATE Skaters SET mid_pred_fantasy_scr=",i , "WHERE ", "rows=",e)
  dbSendQuery(mydb,myRequest)
  e<- e+1
}

all_cons <- dbListConnections(MySQL())
for (con in all_cons){
  dbDisconnect(con)
}