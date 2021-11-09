# Loan-Class-Prediction
This is an analysis project for predicting status of a loan.

In this analysis, we will analyze data from an online lending platform, Lending Club. The goal is to
develop models to predict which loans are at risk of default. Such models can then be used to devise
investment strategies.

## Background
P2P lending platforms - like Lending Club (LC), Prosper, Peerform, Upstart, etc - provide an online
environment for matching borrowers seeking loans and lenders looking to make an investment. With
lower operational costs than traditional lenders (banks), such online lending platforms leverage
technology, data and analytics to bring quicker and more convenient financing for individual and small
business borrowers from investors looking for attractive investment yields. With increasing volumes,
what started as peer-to-peer platforms for connecting individual borrowers and individual investors has
today evolved to include institutional investors, hedge funds, etc. Also called marketplace lending or
alternate lending, such fintech platforms have seen significant growth in recent years. It is estimated
that in 2018, 38% of all personal loans in the US were issued through fintech firms, growing from 5% in
2013 11. Some estimate the global online lending market to grow from ~$42B in 2018 to ~$460B in 2022
22. Lending Club, a pioneer in fintech, is one of the largest online lending platforms, with over $50B in
total loans issued till date.
LC issues personal loans between $1000 and $40,000 for 36 to 60 month durations. Interest rates on these loans
are determined based on a variety of information, including credit rating, credit history, income, etc.
Based on this, LC assigns a grade for each loan, ranging from A for safest loans to G for highest risk;
subgrades are also assigned within each grade. Loans are split into $25 notes, which investors can
purchase. Interested investors can browse different loans the LC website, which shows the assigned loan
grade and other information.


### What is Peer-to-Peer (P2P) / Marketplace / Alternative lending?
In the traditional process of borrowing and lending, banks have always acted as intermediaries and contributed to overall increase in cost of transaction since they make significant profit off the spread. But today technology and innovation are making possible a new generation of financial services that are more affordable and more available. As the process becomes online, it possible for a third party to directly match idle borrower with its lender/investor, all without the involvement of retail banks or credit card companies. The idea is like what Airbnb and Uber are doing to traditional lodging and transportation industries – marketplace lending model cuts several links out of today’s banking chain and translates that savings into low interest loans.



![image](https://user-images.githubusercontent.com/35283246/140968466-1923a140-8a89-4ac0-8c53-f7c855cbf165.png)


Business Model
The key stakeholders in P2P lending are the loan investors/lenders and the borrowers. The P2P platform role is of an intermediary which supports the whole process and all stakeholders. As an intermediary, the platform scores borrower quality through their data-driven models and enables lenders to make good decisions. Owing to low operational costs, they reduce transaction costs for both borrowers and lenders, leading investors to achieve higher returns while borrowers receive lower interest rates.

How P2P platform make money?
The P2P platform charges both origination fees and ongoing loan service fees. By providing additional value to borrowers and lenders, they maximize the number of transactions happening on their platform and further propel the growth of their business.



Advantages of P2P lending for borrower
•	Low interest rates and easy loan repayment with fixed scheme over a set period.
•	Ability to get unsecured personal loan (without putting any collateral), creditworthiness evaluation based on data points aside from FICO scores. 
•	Borrower convenience owing to digitization, transparency, and minimal regulatory constraints.

Advantages of P2P lending for lender/investor
•	Predictable, stable, and higher yields at relatively low, flexible durations due to amortizing structure of alternative loans.
•	Marketplace loans allow for diversification of portfolio by creating a great asset class.

RESOURCES
1)	https://www.morganstanley.com/im/en-us/financial-advisor/insights/investment-insights/an-introduction-to-alternative-lending.html 
2)	https://foundationcapital.com/wp-content/uploads/2020/04/FC_CharlesMoldow_TrillionDollarMarket.pdf 
3)	https://www.prnewswire.com/news-releases/lendingclub-receives-regulatory-approvals-to-acquire-radius-bancorp-301210498.html 


### DATA EXPLORATION

Out of total loans sanctioned, 13.8% of them have defaulted. Default rate varies greatly with the loan grade as expected. The lower the loan grade, more is the default rate. Grade C loans have default rate of 18% as compared to 5% of grade A loans. As the quality of loan applications decrease the higher the chances of being defaulted which is evident in the data.

Higher grade loans such as A, B and C constitutes 81% of total loans sanctioned with B assigned to 33% of total loans, A to 22%, C to 26%. Similarly, the loan amount varies with grade, higher grades having the highest total loan amount and smaller total amount for lower grade loans. Similarly, as expected, the interest rate also varies with the quality of loans, with higher grade having lower rates as compared to lower grades. Grade A loans are offered at an average of 6% interest rate against 27% for G grade loans. The same follows for subgrade within each loan grade. Higher the subgrade, lower the interest rate. Loans with subgrade B1 are offered at an average interest rate of 9% as against 12% for B5. A similar pattern is seen for the spread of interest rate.

The average time in years to fully payoff the loan is 2.6years for grade A. There isn’t a particular pattern observed between the average payoff time vs grade. This is evident due to the fact that the loan term for all sanctioned loans is 3 years.

![image](https://user-images.githubusercontent.com/35283246/140969782-77414365-46ff-4483-b88b-a859e02f343c.png)


The purpose of loan is categorized into 13 different categories as ‘credit card’, ‘small business’, ‘major purchase’, ‘vacation’, ‘home improvement’, ‘wedding’ etc. The first three categories having the highest number of loans as shown below are “Debt Consolidation”, “Credit Card” and “Home Improvement”.

![image](https://user-images.githubusercontent.com/35283246/140969840-a7440113-4808-487c-91c0-12899568a29d.png)


The total number of loans and proportion of fully paid loans is highest for those having 10+ years of employment. The average annual income varies with the loan grade, lower grade loans have lower average income as compared to higher grades. Grade A loans have an average income 90K as against 54K for grade G loans. In addition to above, fully-paid loans have higher average income as compared to charged-off loans. There is little correlation between loan amount and the average annual income. 


![image](https://user-images.githubusercontent.com/35283246/140969915-b99ebb1f-5004-4684-ba50-b104f9ab7a73.png)



### Next : Data Cleaning and Predictions using machine learning






