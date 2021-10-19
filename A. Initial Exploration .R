#2A
library(tidyverse)
library(lubridate)
library(pROC)
library(readxl)
library("writexl")


#1 What is the proportion of defaults ('charged off' vs 'fully paid' loans) in the data?
#How does default rate vary with loan grade? Does it vary with sub-grade? And is this what you
#would expect, and why?
lcData100K<-read_excel("D:/Fall'21 - UIC/IDS 572 - Data Mining/Assignments/Assignment 1/lcData100K.xlsx")
df<-lcData100K
df%>%count(loan_status)%>%mutate(freq = n / sum(n))

df1<-df%>%count(loan_status,grade)%>%pivot_wider(names_from = loan_status, values_from = n)
colnames(df1)[2:3]<-c('Def','Paid')
df1
df1%>%mutate(tot = Def+Paid)%>%mutate(prop_def=Def*100/tot)

df2<-df%>%count(loan_status,sub_grade)%>%pivot_wider(names_from = loan_status, values_from = n)
colnames(df2)[2:3]<-c('Def','Paid')
df2
df2%>%mutate(tot = Def+Paid)%>%mutate(prop_def=Def*100/tot)

#2 How many loans are there in each grade? And do loan amounts vary by grade?
#Does interest rate for loans vary with grade, subgrade? Look at the average, standard-deviation,
#min and max of interest rate by grade and subgrade. Is this what you expect, and why? 

df%>%group_by(grade) %>% summarise(n=n(),Tot_amt = sum(loan_amnt))%>%arrange(desc(Tot_amt))

df%>%group_by(grade) %>% summarise(n=n(),Tot_amt = sum(loan_amnt),avg_int_rate=mean(int_rate),std_int_rate=sd(int_rate),min_int_rate=min(int_rate),max_int_rate=max(int_rate))%>%arrange(avg_int_rate)
df%>%group_by(sub_grade) %>% summarise(n=n(),Tot_amt = sum(loan_amnt),avg_int_rate=mean(int_rate),std_int_rate=sd(int_rate),min_int_rate=min(int_rate),max_int_rate=max(int_rate))%>%arrange(avg_int_rate)


#3 For loans which are fully paid back, how does the time-to-full-payoff vary? For this, calculate
#the 'actual term' (issue-date to last-payment-date) for all loans. How does this actual-term vary
#by loan grade (a box-plot can help visualize this)

df1<-df%>%mutate(issue_dd=strptime(issue_d,format = "%Y-%m-%d"))%>%filter(loan_status=='Fully Paid')%>%mutate(actual_term=last_pymnt_d-issue_dd)
df1$acty<-as.duration(df1$actual_term)/dyears(1)
boxplot(df1$acty~df1$grade)
boxplot(df1$acty~df1$sub_grade)

#4
#Calculate the annual return. Show how you calculate the percentage annual return.
df$ann_return <- ((df$total_pymnt -df$funded_amnt)/df$funded_amnt)*(12/36)*100
df$ann_return_val <- (df$total_pymnt -df$funded_amnt)*(12/36)
df%>%select(ann_return)%>%head()
df%>%filter(loan_status=="Charged Off")%>%group_by(grade)%>%
    summarise(nLoans=n(), avgInterest= mean(int_rate), stdInterest=sd(int_rate),
              avgLoanAMt=mean(loan_amnt), avgPmnt=mean(total_pymnt),avgRet_val=mean(ann_return_val),avgRet=mean(ann_return), stdRet=sd(ann_return), minRet=min(ann_return), 
              maxRet=max(ann_return))
df%>%filter(loan_status=="Charged Off" & ann_return>0)
df%>%group_by(grade)%>%summarise(nLoans=n(), avgInterest= mean(int_rate), stdInterest=sd(int_rate),
            avgLoanAMt=mean(loan_amnt), avgPmnt=mean(total_pymnt),avgRet_val=mean(ann_return_val),avgRet=mean(ann_return), stdRet=sd(ann_return), minRet=min(ann_return), 
            maxRet=max(ann_return))
df%>%filter(loan_status=="Fully Paid")%>%group_by(sub_grade)%>%
  summarise(nLoans=n(), avgInterest= mean(int_rate), stdInterest=sd(int_rate),
            avgLoanAMt=mean(loan_amnt), avgPmnt=mean(total_pymnt),avgRet=mean(ann_return), stdRet=sd(ann_return), minRet=min(ann_return), 
            maxRet=max(ann_return))

#5
#What are people borrowing money for (purpose)? Examine how many loans, average
#amounts, etc. by purpose? Do loan amounts vary by purpose? Do defaults vary by purpose?
#Does loan-grade assigned by Lending Club vary by purpose?
unique(df$purpose)
dfb<-df%>%group_by(purpose)%>%
  summarise(nLoans=n(), avgInterest= mean(int_rate), stdInterest=sd(int_rate),
            totLoanAMt=sum(loan_amnt),avgLoanAMt=mean(loan_amnt))%>%arrange(desc(nLoans))
barplot(dfb$nLoans,main="Loans by Purpose",
        xlab="Purpose")
dfc<-df%>%group_by(purpose,grade)%>%summarise(ndefault=n())%>%arrange(desc(ndefault))%>%pivot_wider(names_from = grade, values_from = ndefault)


#employement_length
df$ann_return <- ((df$total_pymnt -df$funded_amnt)/df$funded_amnt)*(12/36)*100
df$emp_length <- factor(df$emp_length, levels=c("n/a", "< 1 year","1 year","2 years", "3 years" ,  "4 years",   "5 years",   "6 years",   "7 years" ,  "8 years", "9 years", "10+ years" ))
table(df$loan_status, df$emp_length)
table(df$grade, df$emp_length)
df %>% group_by(emp_length) %>% summarise(nLoans=n(), defaults=sum(loan_status=="Charged Off"), defaultRate=defaults/nLoans, avgIntRate=mean(int_rate))

#annual_income
df%>%group_by(grade)%>%summarise(avg_annincm=mean(annual_inc))
dfi<-df%>%group_by(loan_status)%>%summarise(avg_annincm=mean(annual_inc))
cor(df$annual_inc,df$loan_amnt,method="pearson")
df1<-df%>%mutate(issue_dd=strptime(issue_d,format = "%Y-%m-%d"))%>%filter(loan_status=='Fully Paid')%>%mutate(actual_term=last_pymnt_d-issue_dd)
df1$acty<-as.duration(df1$actual_term)/dyears(1)
cor(df1$annual_inc,df1$acty,method="pearson")

#7Generate some (at least 3) new derived attributes which you think may be useful for
#predicting default., and explain what these are. For these, do an analyses as in the questions
#above (as reasonable based on the derived variables).

#Variable 1 - annualized installment to income ratio
df$ann_inst_incm_ratio <- (df$installment*12)*100/df$annual_inc
df$ann_inst_incm_ratio<-round(df$ann_inst_incm_ratio,2)
view(df$ann_inst_incm_ratio)
df%>%group_by(grade)%>%summarise(avg_inst_incm_ratio=mean(ann_inst_incm_ratio))

#Variable 2 - loan amount to total current balance ratio
dfx<-subset(df,df$tot_cur_bal!=0)
dfx$amt_bal_ratio <- round((dfx$loan_amnt*100/dfx$tot_cur_bal),2)
sum(is.infinite(dfx$amt_bal_ratio))
view(dfx$amt_bal_ratio)
mean(dfx$amt_bal_ratio)
dfx%>%group_by(grade)%>%summarise(avg_amt_bal_ratio=mean(amt_bal_ratio))

#Variable 3 - Delinquency score
df$del_score <- df$acc_now_delinq*df$delinq_2yrs
df%>%group_by(grade)%>%summarise(avg_del_score=mean(del_score))

#Are there missing values? What is the proportion of missing values in different variables?
#Explain how you will handle missing values for different variables. You should consider what he
#variable is about, and what missing values may arise from - for example, a variable
#monthsSinceLastDeliquency may have no value for someone who has not yet had a delinquency;
#what is a sensible value to replace the missing values in this case?
# Are there some variables you will exclude from your model due to missing values?

df<-lcData100K
dim(df)
str(df)
colSums(is.na(df))
df<-df%>%drop_na()
dim(df)
dfc<-df%>%select_if(is.character)
# df <- df %>% na_if(tech_employees, "NA")
dfc[dfc == "NA"|dfc == "n"|dfc == "n/a"] <- NA
dfn<-dfc%>%sapply(function(x){sum(is.na(x))})%>%as.data.frame()
dfn
library(data.table)
setDT(dfn, keep.rownames = TRUE)[]
colnames(dfn)<-c("var","val")
sum(dfn$val)/nrow(dfn)
names(dfn)
str(dfn)
na_var<- dfn[val>2000]
str(na_var)
x<-unique(na_var$var)
x
mycols <- names(df) %in% x
mycols
newdata <- df[!mycols] 
str(newdata)


r<-newdata%>%select(bc_open_to_buy,percent_bc_gt_75,mths_since_recent_bc,bc_util)%>%sapply(as.numeric)%>%as.data.frame()
str(r)
newdata<-cbind(newdata%>%select(-bc_open_to_buy,-percent_bc_gt_75,-mths_since_recent_bc,-bc_util),r)
newdata[[newdata == "NA"|newdata == "n"|newdata == "n/a"]] <- NA
colSums(is.na(newdata))
newdata$bc_open_to_buy[is.na(newdata$bc_open_to_buy)] <- mean(newdata$bc_open_to_buy, na.rm = TRUE)
newdata$percent_bc_gt_75[is.na(newdata$percent_bc_gt_75)] <- mean(newdata$percent_bc_gt_75, na.rm = TRUE)
newdata$mths_since_recent_bc[is.na(newdata$mths_since_recent_bc)] <- mean(newdata$mths_since_recent_bc, na.rm = TRUE)
newdata$bc_util[is.na(newdata$bc_util)] <- mean(newdata$bc_util, na.rm = TRUE)
colSums(is.na(newdata))
str(newdata)
newdata<-newdata%>%drop_na()
str(newdata)


#Q4 Do a univariate analyses to determine which variables (from amongst those you decide to
#consider for the next stage prediction task) will be individually useful for predicting the
#dependent variable (loan_status). 

str(newdata)
df<-newdata

auc(response=df$loan_status, df$loan_amnt)
# auc(response=df$loan_status, as.numeric(df$emp_length))
aucsNum<-sapply(df %>% select_if(is.numeric), auc, response=df$loan_status)
aucsNum<-aucsNum%>%as.data.frame()
setDT(aucsNum, keep.rownames = TRUE)[]
colnames(aucsNum)<-c("var","val")
aucsNum<-aucsNum%>%arrange(desc(val))
aucAll<- sapply(df %>% mutate_if(is.factor, as.numeric) %>% select_if(is.numeric), auc, response=df$loan_status) 
aucAll
m<-aucAll[aucAll>0.5]
# m<-aucAll
str(m)
m<-as.data.frame(m)
library(data.table)
setDT(m, keep.rownames = TRUE)[]

str(newdata)
xd<- newdata%>%select_if(is.POSIXct)
yd<-newdata%>%select_if(is.character)
head(xd)
colz<-names(newdata) %in% m$rn
zd<-newdata[colz]


clean_mod_data<-cbind(xd,yd,zd)
























