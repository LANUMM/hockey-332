##Boom/Bust OD Classifier
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


## load data
# we must connect to the SQL database and pull the table containing all player stats

###NOTE: PREDICTOR VARIABLES MUST BE FLOAT OR CATEGORICAL, MAY NEED TO RECAST
mydb <- dbConnect(MySQL(), user = 'g1117489', password = 'HOCKEY332', dbname = 'g1117489', host = 'mydb.ics.purdue.edu')
on.exit(dbDisconnect(mydb))
selection_od = dbSendQuery(mydb, "select * from Skaters") # remove ""? # select TAVG
df_od = data.frame(fetch(selection_od, n = -1)) #dataframe

##Binary Stuff
#Interseason Team Change
m_team = df_od$tm[str_detect()]

#Games played increase excl. (boom)
gp_boom = df_od$gp

#Games played decrease or equal (bust)
gp_bust = df_od$gp
# Optimal Age Checker
opt_age = (df_od$age == 28)

# Rookie Checker
rookie_age = (df_od$age == 23)

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
#needs adjustment

###END BUST

##Disconnect
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