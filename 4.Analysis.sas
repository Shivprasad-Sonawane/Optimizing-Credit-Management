/* Creating a dataset which combines the 3 tables with customer column*/
data project1.dataset;
merge project1.customers project1.spends project1.repayments;
by Customer;
run;

/* Monthly spend for each customer */
proc contents data=project1.spends; /* To check the datatype of dates*/
run;

proc sql;
create table monthly_spend as 
select Customer, put(Spend_Month, monname.) as Month, Sum(Spend) as Total_Spend 
from project1.spends 
group by 1, 2
order by 1, 3 desc;
quit;
proc report;
column Customer Month Total_spend;
title 'Monthly Spend for each Customer';
run;

proc rank data=monthly_spend out=result ties=dense descending;
by Customer;
var Total_Spend;
ranks transRank;
run;
proc print data=result n;
run;

proc sql;
create table rnk_table as 
select Month, count(*) as Customers
from result
where transRank=1
group by 1
order by 2 desc;
quit;
proc report;
column Month Customers;
title 'Max spend by months by customers';
run;



/* Monthly repayment for each customer */
proc sql;
create table monthly_repaid as 
select Customer, put(Repaid_Month, monname.) as Month, Sum(Repaid) as Total_Repaid
from project1.repayments 
group by 1, 2
order by 1, 3 desc;
quit;
proc report;
column Customer Month Total_Repaid;
title 'Monthly Repayment for each Customer';
run;

proc rank data=monthly_repaid out=result ties=dense descending;
by Customer;
var Total_Repaid;
ranks rnk;
run;

proc sql;
create table rnk_table as 
select Month, count(*) as Customers
from result
where rnk=1
group by 1
order by 2 desc;
quit;
proc report;
column Month Customers;
title 'Max Repaid by months by customers';
run;



/* Monthly profit for the bank  */
proc sql;
create table monthly_profit as 
select put(Spend_Month, monname.) as Month, sum(Spend - Repaid) as Profit
from project1.dataset
group by 1
order by 2 desc;
quit; 
proc report;
column Month Profit;
title 'Monthly Profit by bank';
run;



/* Category in which the customers are spending more money */
proc summary data=project1.spends;
var Spend;
class Category;
output out=summary_dataset SUM=total_spending;
run;
proc sort data=summary_dataset;
by descending total_spending;
run;
proc report;
column Category total_spending;
title "Customer Spending by Category Report";
run;

proc sgplot data=summary_dataset;
vbar Category / response=total_spending datalabel; *categoryorder=respdesc;
title "Bar Chart of Total Spending by Category";
run;



/* City in which bank is making the maximum profit */
proc sql;
create table profitable_city as 
select City, SUM(Spend) as Total_Spending, SUM(Repaid) as Total_Repaid,
SUM(Spend - Repaid) as Net_Profit
from project1.Customers as c join project1.Spends as s 
on c.Customer=s.Customer join project1.repayments r 
on c.Customer = r.Customer
group by 1
order by 4 desc;
proc report data=profitable_city;
column City Net_Profit;
title 'Profit by City';
proc sgplot;
vbar City / response=Net_Profit;
title 'Net Profit/Loss by City';
yaxis label='Net Profit/Loss (in millions)';
run;



/* Which customer is spending more than limit */
proc sql;
create table spending_limit as
select distinct c.Customer 
from project1.customers c join project1.spends s 
on c.Customer=s.Customer
where Spend > Limit;
quit;
proc print data=spending_limit;
run;



/* Which age group is spending more money */
proc summary data=project1.dataset;
var Spend;
class Age;
output out=Age_data SUM=total_spending;
proc sort data=Age_data;
by descending total_spending;
proc print;
run;

proc sql;
create table age_group_spend as 
select Age, sum(Spend) as Total_Spend 
from project1.dataset
group by 1 
order by 2 desc;
quit;
proc report data=age_group_spend;
column Age Total_Spend;
define Age / display 'Age Group';
title "Total Spend by Age Group";
proc sgplot;
scatter x=Age y=Total_Spend;
title "Total Spend Distribution by Age Group";
run;



/* People in which segment are spending more money */
proc summary data=project1.dataset;
var Spend;
class Segment;
output out=Segment_Spend SUM=total_spending;
proc sort data=Segment_Spend;
by descending total_spending;
proc print data=Segment_Spend;
run;

proc sql;
create table Segment_Spend as 
select Segment, sum(Spend) as Total_Spend 
from project1.dataset
group by 1 
order by 2 desc;
quit;
proc report;
column Segment Total_Spend;
define Segment / display 'Segment';
title "Total Spend by Segment";
proc sgplot data=Segment_Spend;
vbar Segment / response=Total_Spend;
title "Total Spend Distribution by Segment";
run;



/* Which is the profitable segment */
data merged_data;
set project1.dataset;
Spend_Repaid_Diff = Spend - Repaid;
proc summary data=merged_data;
class Segment;
var Spend_Repaid_Diff;
output out=Profit_summary SUM(Spend_Repaid_Diff)=Profit;
proc print data=Profit_summary;
run;

proc sql;
create table segment_profit as
select Segment, sum(Spend) as Total_Spend, sum(Repaid) as Total_Repaid,
sum(Spend) - sum(Repaid) as Net_Profit
from project1.dataset
group by 1
order by 4 desc;
quit;
proc report;
column Segment Net_Profit;
proc sgplot;
hbar Segment / response=Net_Profit categoryorder=respdesc barwidth=0.5;
title 'Profitability by Segment';
xaxis label='Profit';
run;



/* Who are the highest paying 10 customers? */
proc summary data=project1.spends;
var Spend;
class Customer;
output out=Top_10_Customers SUM=Total_Spending;
proc sort;
by descending Total_Spending;
proc print data=Top_10_Customers(obs=11);
run;

proc sql;
create table Top_10_Customers as 
select Customer as Customers, sum(Spend) as Total_Spend
from project1.spends
group by 1 
order by 2 desc;
quit;
proc print data=Top_10_Customers(obs=10);
run;






proc sgplot data=project1.spends;
histogram Spend;
title "Histogram of Spends";
proc sgplot data=project1.repayments;
histogram repaid;
title "Histogram of Repaid";
run;

proc sgplot data=project1.dataset;
scatter x=Spend  y=Repaid;
run;

proc sgplot data=project1.spends;
vbox Spend / category=Category;
run;

proc sgplot data=project1.dataset;
vbox Spend / category=Segment;
run;

proc sgplot data=project1.dataset;
vbox Spend / category=Credit_Card_Product;
run;

proc sgplot data=project1.dataset;
vbox repaid / category=Segment;
run;

proc sgplot data=project1.dataset;
vbox repaid / category=Credit_Card_Product;
run;