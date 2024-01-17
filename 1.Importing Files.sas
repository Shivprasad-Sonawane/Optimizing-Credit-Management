/* Problem Statement: */
/* From the data given in this embedded excel file you need to find out customer spending habits.  */
/* Analysis of Customer Demographics in terms of Age Group, City and Product Segment. */


PROC IMPORT DATAFILE='/home/u63701622/Project_1/Dataset/Dataset.xls'
DBMS= XLS 
OUT= PROJECT1.CUSTOMERS REPLACE;
SHEET='Customer Acqusition';
GETNAMES= YES;
RUN;

PROC PRINT DATA=PROJECT1.CUSTOMERS NOOBS;
RUN;


PROC IMPORT DATAFILE='/home/u63701622/Project_1/Dataset/Dataset.xls'
DBMS= XLS 
OUT= PROJECT1.SPENDS REPLACE;
SHEET= 'Spend';
GETNAMES= YES;
RUN;

PROC PRINT DATA=PROJECT1.SPENDS NOOBS;
RUN;

PROC IMPORT DATAFILE='/home/u63701622/Project_1/Dataset/Dataset.xls'
DBMS= XLS 
OUT= PROJECT1.REPAYMENTS(DROP=E) REPLACE; /* drop e removes the extra column which was empty */
SHEET= 'Repayment';
GETNAMES= YES;
RUN;

PROC PRINT DATA=PROJECT1.REPAYMENTS NOOBS;
RUN;

