/* c. Wherever they spend amount is more than limit, replace it with half of the limit for each customer. */
/* d. Wherever the repayment amount is more than limit, replace it with the limit. */

/* To merge the dataset on the bases of some key we need to sort the dataset on that key */
proc sort data=project1.customers;
by Customer;
run;

proc sort data=project1.spends;
by Costomer; /* Later we gonna change this column name*/
run;

/* updating spend amount */
data project1.spends;
merge project1.customers(in=c) 
	  project1.spends(in=s rename=(Costomer=Customer Month=Spend_Month Type=Category Amount=Spend));
by Customer;
	if c and s then do;
		if Spend > Limit then Spend = Limit / 2;
		output;
	end;
	drop Sl_No: Age City Credit_Card_Product Limit Company Segment;
run;

proc print data=project1.spends;
run;

/* Similar with repayment table */
proc sort data=project1.repayments;
by Costomer;
run;

data project1.repayments;
set project1.repayments;
if cmiss(of _all_) = 4 then delete; *Removing blank rows;
run;

data project1.repayments;
merge project1.customers(in=c) 
	  project1.repayments(in=r rename=(Costomer=Customer Month=Repaid_Month Amount=Repaid));
by Customer;
	if c and r then do;
		if Repaid > Limit then Repaid = Limit;
		output; 
	end; 
	drop Sl_No: Age City Credit_Card_Product Limit Company Segment;
run;

proc print data=project1.repayments;
run;

data project1.customers;
set project1.customers;
drop Sl_No:;
run;

proc print data=project1.customers;
run;