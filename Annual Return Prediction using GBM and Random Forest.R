library(tidyverse)
library(lubridate)
library(pROC)
library(readxl)
library("writexl")
library(data.table)
library(rpart)
library('C50')
library(corrplot)
library(corrr)
library('glmnet')
library(broom)
library('gbm')
library('ROCR')
library(caret) 
library(randomForest)
library(ranger)

setwd("D:/Fall'21 - UIC/IDS 572 - Data Mining/Assignments/Assignment 1")

lcdata<-read.csv('lcData100K.csv')
df<-lcdata
str(df)

    df$ann_return <- ((df$total_pymnt -df$funded_amnt)/df$funded_amnt)*(12/36)*100
df$emp_length <- factor(df$emp_length, levels=c("n/a", "< 1 year","1 year","2 years", "3 years" ,  "4 years",   "5 years",   "6 years",   "7 years" ,  "8 years", "9 years", "10+ years" ))

# Data Clean
str(df)
colSums(is.na(df))
dfn<-df%>%select_if((colSums(is.na(df))>30000))
col_na<-colnames(dfn)
col_na<-as.vector(col_na)
df<-df%>%select(-(col_na))


# Character Variable Treatment
str(df)
df<-df%>%select(-c(emp_title,emp_length))
str(df)
dfc<-df%>%select_if(is.character)
dfc[dfc == "NA"|dfc == "n"|dfc == "n/a"] <- NA
dfn<-dfc%>%sapply(function(x){sum(is.na(x))})%>%as.data.frame()
df<-df%>%select(-c(pymnt_plan))

#Numeric Variable Treatment
str(df)
colSums(is.na(df))
unique(df$mths_since_recent_inq)
df$bc_open_to_buy[is.na(df$bc_open_to_buy)] <- median(df$bc_open_to_buy, na.rm = TRUE)
df$percent_bc_gt_75[is.na(df$percent_bc_gt_75)] <- median(df$percent_bc_gt_75, na.rm = TRUE)
df$mths_since_recent_bc[is.na(df$mths_since_recent_bc)] <- median(df$mths_since_recent_bc, na.rm = TRUE)
df$bc_util[is.na(df$bc_util)] <- median(df$bc_util, na.rm = TRUE)
df$mo_sin_old_il_acct[is.na(df$mo_sin_old_il_acct)] <- median(df$mo_sin_old_il_acct, na.rm = TRUE)
df$num_tl_120dpd_2m[is.na(df$num_tl_120dpd_2m)] <- median(df$num_tl_120dpd_2m, na.rm = TRUE)
df$mths_since_recent_inq[is.na(df$mths_since_recent_inq)] <- median(df$mths_since_recent_inq, na.rm = TRUE)
df<-df%>%drop_na()
str(df)

#More Cleaning
df<-df%>%select(-c(disbursement_method,hardship_flag,policy_code,zip_code,title,term,earliest_cr_line,last_credit_pull_d))
# leakage<- c("funded_amnt","funded_amnt_inv","issue_d","out_prncp","out_prncp_inv","total_pymnt","total_pymnt_inv","total_rec_prncp","total_rec_int","total_rec_late_fee","recoveries","collection_recovery_fee","last_pymnt_d","last_pymnt_amnt","collections_12_mths_ex_med","acc_now_delinq","tot_coll_amt")
leakage<- c("issue_d","total_pymnt","total_pymnt_inv","funded_amnt","funded_amnt_inv","out_prncp","out_prncp_inv","total_rec_prncp","total_rec_int","total_rec_late_fee","recoveries","collection_recovery_fee","last_pymnt_d","tot_coll_amt")
nm<- names(df) %in% leakage
df<-df[!nm]
str(df)
df%>%sapply(n_distinct)



df$grade<-as.factor(df$grade)
df$sub_grade<-as.factor(df$sub_grade)
df$home_ownership<-as.factor(df$home_ownership)
df$loan_status<-as.factor(df$loan_status)
df$purpose<-as.factor(df$purpose)
df$addr_state<-as.factor(df$addr_state)
df$debt_settlement_flag<-as.factor(df$debt_settlement_flag)
df$initial_list_status<-as.factor(df$initial_list_status)
df$application_type<-as.factor(df$application_type)
df$verification_status<-as.factor(df$verification_status)
str(df)

# Variable Importance - Correlation
df_c<-df%>%select_if(is.numeric)
df_c.cor<-cor(df_c)
df_c.cor%>%view
dev.new(width=50, height=50)
corrplot(df_c.cor)

thres = 0.6
df_c.cor[upper.tri(df_c.cor, diag=TRUE)] <- NA
df_cc <- as.data.frame(as.table(df_c.cor))
df_cc<-na.omit(df_cc)
df_cc%>%view()
mean(abs(df_cc$Freq))
df_cc%>%filter(df_cc$Var1=='ann_return')%>%arrange(desc(Freq))
df_cc_th <- df_cc %>% filter(abs(Freq) < thres )
df_cc_th <- df_cc_th[order(-abs(df_cc_th$Freq)),]
dim(df_cc_th)
df_cc_th_w <- df_cc_th %>% pivot_wider(names_from = Var2, values_from = Freq)
df_cc_th_w<-column_to_rownames(df_cc_th_w, var="Var1")
df_cc_th_w%>%view()
dev.new(width=50, height=50)
corrplot(as.matrix(df_cc_th_w), is.corr=FALSE, na.label=" ", method="circle")


#Split into train cv test

trn=0.8
nr<-nrow(df)
trnd<-sample(1:nr,trn*nr,replace=FALSE)
train_data<-df[trnd,]
df_nl2<-df[-trnd,]
str(train_data)

cv_data<-df[-trnd,]


#Basic Regression Model - Lasso
train_data1<-train_data %>% select(-ann_return)
glmfit<- cv.glmnet(data.matrix(train_data1), train_data$ann_return, family="gaussian")
dev.new(width=50, height=50)
plot(glmfit)
print(glmfit)

l.lasso.1se <- glmfit$lambda.1se
lasso.model <- glmnet(x=data.matrix(train_data1), y=train_data$ann_return,
                      alpha  = 1, 
                      lambda = l.lasso.1se)
lasso.model$beta 

y<-cv_data %>% select(ann_return)
cv_data1<-cv_data %>% select(-ann_return)
y_predicted <- predict(lasso.model, newx = data.matrix(cv_data1))
mean_y<-lapply(y, mean, na.rm = TRUE)
sst <- sum((y - mean_y)^2)
sst
sse <- sum((y_predicted - y)^2)
sse

# R squared
rsq <- 1 - sse / sst
rsq


#Basic Regression Model - Ridge
train_data1<-train_data %>% select(-ann_return,-loan_status)
glmfit<- cv.glmnet(data.matrix(train_data1), train_data$ann_return, family="gaussian",alpha=0)
dev.new(width=50, height=50)
plot(glmfit)
print(glmfit)
coef(glmfit,s="lambda.min")

l.ridge.min <- glmfit$lambda.min
ridge.model <- glmnet(x=data.matrix(train_data1), y=train_data$ann_return,
                      alpha  = 0, 
                      lambda = l.ridge.min)
ridge.model$beta 

y<-cv_data %>% select(ann_return)
cv_data1<-cv_data %>% select(-ann_return)
y_predicted <- predict(ridge.model, newx = data.matrix(cv_data1))
mean_y<-lapply(y, mean, na.rm = TRUE)
sst <- sum((y - mean_y)^2)
sst
sse <- sum((y_predicted - y)^2)
sse

# R squared
rsq <- 1 - sse / sst
rsq

# Final Model - Linear

train_data1<-train_data %>% select(-ann_return)
glmfit<- cv.glmnet(data.matrix(train_data1), train_data$ann_return, family="gaussian")
dev.new(width=50, height=50)
plot(glmfit)
print(glmfit)

l.lasso.1se <- glmfit$lambda.1se
lasso.model <- glmnet(x=data.matrix(train_data1), y=train_data$ann_return,
                      alpha  = 1, family="gaussian", 
                      lambda = l.lasso.1se)
lasso.model$beta 

plot(lasso.model)

y<-cv_data %>% select(ann_return)
cv_data1<-cv_data %>% select(-ann_return)
y_predicted <- predict(lasso.model, newx = data.matrix(cv_data1))
mean_y<-lapply(y, mean, na.rm = TRUE)
sst <- sum((y - mean_y)^2)
sst
sse <- sum((y_predicted - y)^2)
sse

# R squared
rsq <- 1 - sse / sst
rsq

# L1 Regularization
plot(glmfit$glmnet.fit)

# Q-Q Plots for non-zero variables
dev.new(width=50, height=50)
qqnorm(train_data1$int_rate)
qqnorm(train_data1$loan_amnt)

# Gradient Boosted Model

# for reproducibility
set.seed(123)

# train GBM model
gbm.fit <- gbm(
  formula = ann_return ~ .,
  distribution = "gaussian",
  data = train_data%>%select(-loan_status),
  bag.fraction=0.5,
  n.trees = 2000,
  interaction.depth = 4,
  shrinkage = 0.01,
  cv.folds = 5,
  n.cores = NULL, # will use all cores by default
  verbose = FALSE
)  


# print results
print(gbm.fit)
summary(gbm.fit)
min_MSE <- which.min(gbm.fit$cv.error)
bestIter<-gbm.perf(gbm.fit, method='cv')
gbm.perf(gbm.fit)
sqrt(min(gbm.fit$cv.error))

#EVALUATION
y<-cv_data %>% select(ann_return)
scores_gbmM2<- predict(gbm.fit, newdata=cv_data%>%select(-loan_status), n.tree= bestIter, type="response")
mean_y<-lapply(y, mean, na.rm = TRUE)
sst <- sum((y - mean_y)^2)
sst
sse <- sum((scores_gbmM2 - y)^2)
sse
# R squared
rsq <- 1 - sse / sst
rsq

# Random Forest model

rf.m1 <- ranger(ann_return ~., data=train_data%>%select(-loan_status))

#Basic evaluation
sqrt(rf.m1$prediction.error)

#EVALUATION on Test Data
y<-cv_data %>% select(ann_return)
pred.ranger = predict(rf.m1, cv_data%>%select(-loan_status))
mean_y<-lapply(y, mean, na.rm = TRUE)
sst <- sum((y - mean_y)^2)
sst
sse <- sum((pred.ranger[1] - y)^2)
sse
# R squared
rsq <- 1 - sse / sst
rsq
























