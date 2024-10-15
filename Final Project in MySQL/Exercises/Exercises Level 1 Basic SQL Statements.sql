#1.1: SELECT
#1)	All position ids and the traders who traded those positions
SELECT
	POSITION_ID,
    EMPLOYEE_ID
FROM 
	DBO.TRADE_DATA_HIST;
#2)	All data from table employee_info
SELECT
	*
FROM
	DBO.EMPLOYEE_INFO;
#3)	Unique list of all dates where there were trades
SELECT DISTINCT
	COB_DATE
FROM
	DBO.TRADE_DATA_HIST;
#4)	Unique list of first and last names of all employees
SELECT DISTINCT
	FIRST_NAME,
    LAST_NAME
FROM
	DBO.EMPLOYEE_INFO;
    
 #####################################################################     
#1.2: FILTERS
#1)	All dates, cusips, quantity from trader T1
SELECT
	COB_DATE,
    CUSIP,
    QUANTITY
	#Included EMPLOYEE_ID to have a clue whether the code was working, but it can be removed
    #EMPLOYEE_ID
FROM
	DBO.TRADE_DATA_HIST
WHERE
	EMPLOYEE_ID = "T1";
#2)	All rows where cusip starts with “C17”
SELECT
	*
FROM
	DBO.TRADE_DATA_HIST
WHERE
	CUSIP LIKE "C17%";
#3)	All trader, cusips, fund_id when the quantity is between 5,000 and 20,000
SELECT
	EMPLOYEE_ID,
    CUSIP,
    FUND_ID
	#Included QUANTITY to have a clue whether the code was working, but it can be removed
    #QUANTITY
FROM
	DBO.TRADE_DATA_HIST
WHERE
	QUANTITY BETWEEN 5000 AND 20000;
#4)	All data where the trader is T1 T2 or T3
SELECT
	*
FROM
	DBO.TRADE_DATA_HIST
WHERE
	EMPLOYEE_ID IN ("T1","T2","T3");
#5)	All unique cusips that were traded in Jan 2018
SELECT DISTINCT
    #Included COB_DATE to have a clue if the code was working, but it can be removed
	#COB_DATE,
	CUSIP
FROM
	DBO.TRADE_DATA_HIST
WHERE
	COB_DATE LIKE "201801%";
	#Another option: COB_DATE BETWEEN 20180101 AND 20180131;

    
 #####################################################################     
#1.3: MULTIPLE FILTERS
#1)	All trades from trader T1 that were traded in Feb 2018
SELECT
	POSITION_ID
FROM
	DBO.TRADE_DATA_HIST
WHERE
	EMPLOYEE_ID = "T1" AND
    COB_DATE LIKE "201802%";
	#Another option: COB_DATE BETWEEN 20180201 AND 20180228;


#2)	Unique list of fund_ids where the notional is > 10,000, employee_id is T3 or T4, and  the year is 2019
SELECT DISTINCT
	FUND_ID
FROM 
	DBO.TRADE_DATA_HIST
WHERE
	NOTIONAL_USD > 10000 AND
    EMPLOYEE_ID IN ("T3","T4") AND
    COB_DATE LIKE "2019%";
    #Another option: COB_DATE BETWEEN 20190101 AND 20191231;
#3)	Position IDs and cusips of all trades in 2019 where fund_id is A007 or A012
SELECT
	POSITION_ID,
    CUSIP
FROM
	DBO.TRADE_DATA_HIST
WHERE
	FUND_ID IN ("A007", "A012");
#4)	Unique list of Tickers (security_info) where the ticker starts with “AA” or the sector is Health Care
SELECT DISTINCT
	TICKER
FROM 
	DBO.SECURITY_INFO
WHERE
	TICKER LIKE "AA%" OR
    SECTOR = 'Health Care';
    

#1.4: ORDER / LIMIT
#1)	Date, fund_id, trader_cusip but organized first by fund_id, and then date
SELECT
	COB_DATE,
    FUND_ID,
    CUSIP
FROM
	DBO.TRADE_DATA_HIST
ORDER BY
	FUND_ID AND
    COB_DATE;

#2)	All rows, all trades sorted from least quantity to most
SELECT
	*
FROM
	DBO.TRADE_DATA_HIST
ORDER BY
	QUANTITY ASC;
#3)	All employee information sorted by highest salary to lowest, but only show the first three rows
SELECT
	*
FROM
	DBO.EMPLOYEE_INFO
ORDER BY
	SALARY DESC
LIMIT 3;
