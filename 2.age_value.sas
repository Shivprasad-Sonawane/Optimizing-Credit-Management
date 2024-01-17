/* b. Wherever the age value is less than 18, make it mean of age values. */

proc print data=project1.customers;
run;

/* Here I create a mean variable to store mean of age. */
proc means data=Project1.customers noprint;
var Age;
output out= mean_dataset mean=mean_age; 
run;

/* Update the customers table with mean of age who's values are lower than 18 */
data PROJECT1.CUSTOMERS;
  set PROJECT1.CUSTOMERS;
  if _n_ = 1 then set mean_dataset; /* _n_ is automatic var which represent the current observation */
  if Age < 18 then Age = int(mean_age);
  drop _type_ _freq_ mean_age; /* droping the extra column which was created by defalut due to proc mean method */ 
run;

proc print data=PROJECT1.CUSTOMERS;
run;

/* To check wheather the age column is affected or not*/
data check;
set PROJECT1.CUSTOMERS;
if Age < 18 then Less = '< 18';
run;

proc print data=check;
run;
