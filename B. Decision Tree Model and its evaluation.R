#Part B Develop decision tree models to predict default.


# Excluding Leakage variables
str(clean_mod_data)
leakage<- c("funded_amnt","funded_amnt_inv","issue_d","out_prncp","out_prncp_inv","total_pymnt","total_pymnt_inv","total_rec_prncp","total_rec_int","total_rec_late_fee","recoveries","collection_recovery_fee","last_pymnt_d","last_pymnt_amnt","collections_12_mths_ex_med","acc_now_delinq","tot_coll_amt","ann_return","ann_return_val")
nm<- names(clean_mod_data) %in% leakage
df_nl<-clean_mod_data[!nm]

#More Cleaning

str(df_nl)
df_nl$loan_status[df_nl$loan_status == 'Fully Paid'] <- 'Non-Default'
df_nl$loan_status[df_nl$loan_status == 'Charged Off'] <- 'Default'
unique(df_nl$loan_status)
df_nl$loan_status<-as.factor(df_nl$loan_status)
df_nl$term <- NULL
df_nl$title <- NULL
df_nl$zip_code <- NULL
df_nl$hardship_flag <- NULL
df_nl$disbursement_method <- NULL
str(df_nl)


# (a) Split the data into training and validation sets. What proportions do you consider, why?
#Split the data into train,test,CV 


trn=0.7
nr<-nrow(df_nl)
trnd<-sample(1:nr,trn*nr,replace=FALSE)
train_data<-df_nl[trnd,]
df_nl2<-df_nl[-trnd,]
str(train_data)

str(df_nl2)
cvn=0.5
nr2<-nrow(df_nl2)
cv<-sample(1:nr2,cvn*nr2,replace=FALSE)
cv_data<-df_nl2[cv,]

str(cv_data)

test_data<-df_nl2[-cv,]
str(test_data)


# Train decision tree models (use both rpart, c50)
# [If something looks too good, it may be due to leakage - make sure you address this]
# What parameters do you experiment with, and what performance do you obtain (on training
# and validation sets)? Clearly tabulate your results and briefly describe your findings.
# How do you evaluate performance - which measure do you consider, and why?
#Training the Model

library(rpart)
library('C50')

# Rpart Model

DT1 <- rpart(loan_status ~., data=train_data,
               method="class", parms = list(split = "gini"), control = rpart.control(cp=0, minsplit = 30))

printcp(DT1)
par("mar")
par(mar=c(1,1,1,1))
plotcp(DT1)

#Model 1
DT1_pruned <- prune(DT1, cp=0.0012)
summary(DT1_pruned)

#Model 2
DT2 <- rpart(loan_status ~., data=train_data,
             method="class", parms = list(split = "gini",loss=matrix(c(0,10,30,0))), control = rpart.control(cp=0, minsplit = 30))

printcp(DT2)
par("mar")
par(mar=c(1,1,1,1))
plotcp(DT2)

DT2_pruned <- prune(DT2, cp=0.0019)
summary(DT2_pruned)

par("mar")
par(mar=c(1,1,1,1))
dev.new(width=100, height=1000)
rpart.plot::prp(DT2_pruned, type=2, extra=1)
# Model Evaluation - Model 1

#0n Training Data
predTrn1=predict(DT1_pruned, train_data, type='class')
table(pred = predTrn1, true=train_data$loan_status)
mean(predTrn1 == train_data$loan_status)


#0n validation Data
predcv1=predict(DT1_pruned, cv_data, type='class')
table(pred = predcv1, true=cv_data$loan_status)
mean(predcv1 == cv_data$loan_status)

# Model Evaluation - Model 2

#0n Training Data
predTrn2=predict(DT2_pruned, train_data, type='class')
table(pred = predTrn2, true=train_data$loan_status)
mean(predTrn2 == train_data$loan_status)


#0n validation Data
predcv2=predict(DT2_pruned, cv_data, type='class')
table(pred = predcv2, true=cv_data$loan_status)
mean(predcv2 == cv_data$loan_status)


#Model Evaluation - Lift - Model 1
pred=predict(DT1_pruned, cv_data, type='prob')
head(pred)
trnSc <- cv_data %>% select("loan_status")
head(trnSc)
trnSc$score <- pred[, 2]
head(trnSc)
trnSc <- trnSc[ order(trnSc$score, decreasing=TRUE),]
head(trnSc)
trnSc$cumDefault<-cumsum(trnSc$loan_status == "Non-Default")
dim(trnSc)
dev.new(width=50, height=50)
plot( trnSc$cumDefault, type = "l", xlab='#cases', ylab='#No-default')
abline(0,max(trnSc$cumDefault)/14981, col="blue")

#Model Evaluation - Decile Lift table
trnSc["bucket"] <- ntile( -trnSc[,"score"], 10)
decile1<-trnSc %>% group_by (bucket) %>%
summarize (count=n(),
              noDefaults = sum(loan_status=="Non-Default"),
              defRate = noDefaults/count,
              cumDefRate = cumsum(noDefaults)/cumsum(count),
           lift = cumDefRate/( sum(trnSc$loan_status=="Non-Default")/nrow(trnSc)))
decile1


#Model Evaluation - ROC - Model 1

scoreTst <- predict(DT1_pruned, cv_data, type="prob")[ ,'Non-Default']
rocPredTst <- prediction(scoreTst, cv_data$loan_status, label.ordering = c('Default', 'Non-Default'))
perfROCTst <- performance(rocPredTst, "tpr", "fpr")
plot(perfROCTst)


#Model Evaluation - Lift - Model 2
pred=predict(DT2_pruned, cv_data, type='prob')
head(pred)
trnSc <- cv_data %>% select("loan_status")
head(trnSc)
trnSc$score <- pred[, 2]
head(trnSc)
trnSc <- trnSc[ order(trnSc$score, decreasing=TRUE),]
head(trnSc)
trnSc$cumDefault<-cumsum(trnSc$loan_status == "Non-Default")
dim(trnSc)
dev.new(width=50, height=50)
plot( trnSc$cumDefault, type = "l", xlab='#cases', ylab='#No-default')
abline(0,max(trnSc$cumDefault)/14981, col="blue")

#Model Evaluation - Decile Lift table
trnSc["bucket"] <- ntile( -trnSc[,"score"], 10)
decile2<-trnSc %>% group_by (bucket) %>%
  summarize (count=n(),
             noDefaults = sum(loan_status=="Non-Default"),
             defRate = noDefaults/count,
             cumDefRate = cumsum(noDefaults)/cumsum(count),
             lift = cumDefRate/( sum(trnSc$loan_status=="Non-Default")/nrow(trnSc)))
decile2

#Model Evaluation - ROC - Model 2

scoreTst <- predict(DT2_pruned, cv_data, type="prob")[ ,'Non-Default']
rocPredTst <- prediction(scoreTst, cv_data$loan_status, label.ordering = c('Default', 'Non-Default'))
perfROCTst <- performance(rocPredTst, "tpr", "fpr")
plot(perfROCTst)





















