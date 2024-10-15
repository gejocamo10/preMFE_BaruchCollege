#6.1: INNER JOIN --------------------------------------------------------------------------
#1)	What is an inner join in your own words?
#It is a way of linking tables that only return rows whether there are perfect match in keys. 

#2)	Using an inner join, select all of the columns from RISK_DATA_HIST but include the TICKER as well. Total columns returned should be ONLY and in this order: COB_DATE, POSITION_ID, TICKER, VAR
SELECT
	RDH.COB_DATE,
    RDH.POSITION_ID,
    SI.TICKER,
    RDH.VAR
FROM DBO.RISK_DATA_HIST RDH
INNER JOIN
	DBO.SECURITY_INFO SI
	ON RDH.CUSIP = SI.CUSIP
   	AND RDH.COB_DATE BETWEEN SI.START_DATE AND SI.END_DATE;

#3)	Using multiple inner joins, please return the following columns, only for the first three days of available data: COB_DATE, POSITION_ID, TICKER, QUANTITY, VAR, SECTOR, COUNTRY
SELECT
	TDH.COB_DATE,
    TDH.POSITION_ID,
    SI.TICKER,
    TDH.QUANTITY,
    RDH.VAR,
    SI.SECTOR,
    SI.COUNTRY
FROM DBO.TRADE_DATA_HIST TDH
INNER JOIN
	DBO.RISK_DATA_HIST RDH
	#I used POSITION_ID because it includes COB_DATE and CUSIP
	ON TDH.POSITION_ID = RDH.POSITION_ID
INNER JOIN
	DBO.SECURITY_INFO SI
    ON SI.CUSIP = RDH.CUSIP
	AND TDH.COB_DATE BETWEEN SI.START_DATE AND SI.END_DATE
WHERE
	TDH.COB_DATE BETWEEN 20180102 AND 20180104;
    
#6.2: LEFT/RIGHT JOIN --------------------------------------------------------------------------
#1)	Describe a left join in your own words.
#It is a way of linking tables such that everything in my main table should be return besides only those from the secundary table that match with the main.

#2)	Describe a right join.
#It is a way of linking tables such that everything in my secundary table should be return besides only those from the main table that match with the secundary.

#3)	Write a logical left join using our dataset.
SELECT
	TDH.COB_DATE,
    TDH.POSITION_ID,
    TDH.CUSIP,
    TDH.EMPLOYEE_ID,
    RDH.VAR,
    RDH.DURATION,
    RDH.CONVEXITY
FROM
	DBO.TRADE_DATA_HIST TDH
LEFT JOIN
	DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID;
    
#4)	Write a logical right join using our dataset.
SELECT
	TDH.COB_DATE,
    TDH.CUSIP,
    TDH.POSITION_ID,
    SPH.CLOSE_PRICE_USD,
    SPH.RATE,
    TDH.QUANTITY,
    TDH.QUANTITY * SPH.CLOSE_PRICE_USD AS MARKET_VALUE
FROM
	DBO.SECURITY_PRICE_HIST SPH
RIGHT JOIN
	DBO.TRADE_DATA_HIST TDH
    ON TDH.CUSIP = SPH.CUSIP
    AND TDH.COB_DATE = SPH.COB_DATE;


#6.3: FULL OUTER JOIN --------------------------------------------------------------------------
#1)	What is a full join?
#It is a way of linking tables such that all data from both appear. No match is needed. ALl rows are connected in a new table.

#2)	Why would you ever use a full join instead of an inner join?
#If it is required to observe all info from different tables in a single one, then I will use full join. But this is not frequently asked, so
#inner join may be used more often. 

#3)	Fully join TRADE_DATA_HIST and RISK_DATA_HIST. 
SELECT 
	TDH.*,
    RDH.*
FROM DBO.TRADE_DATA_HIST AS TDH
FULL OUTER JOIN DBO.RISK_DATA_HIST AS RDH
ON TDH.POSITION_ID = RDH.POSITION_ID;
    
#4)	Following question #3 above, do either of those tables contain positions not in the other?
#No. Both tables contain the same positions

#5)	Now join your TEST_DATA table on RISK_DATA_HIST (join only position_ids). What did you learn from this join that’s different than the results of #3?
SELECT 
	TD.*,
    RDH.*
FROM DBO.TEST_DATA AS TD
FULL OUTER JOIN DBO.RISK_DATA_HIST AS RDH
ON TD.POSITION_ID = RDH.POSITION_ID;
    
#Some positions in risk_data_hist  are not part of test_data such that there are empty entries in the full joined table that belong to those data. 
#However, entries that are part of the same row but belong to position_id of test_data are not empty since these data already exist in risk_data_hist.


#6.4: SELF JOIN --------------------------------------------------------------------------
#1)	What is a self join?
#It is a way of linking a table to itself.

#2)	List 3 examples (not from the lectures) of where you might use a self join?
#1. If we are interested in finding historical returns of tickers. This is becase we compare prices to its lag
#2. If we are interested in finding moving or simple averages of returns. We connect the table to itself many times as needed to find these rolling means.
#3. If we want to compute rolling or simple standard deviations of returns as well.

#3)	Which security on which date has the largest single day VaR increase in Jan 2018?
SELECT
#We show the info for RDH1
	RDH1.COB_DATE COB_DATE_1,
    RDH1.CUSIP CUSIP_1,
    RDH1.VAR VAR_1,
#We show the info for RDH2
	RDH2.COB_DATE COB_DATE_2,
    RDH2.CUSIP CUSIP_2,
    RDH2.VAR VAR_2,
    #Add ticker to identify the security
    SI.TICKER,
#We show the percent change in VaR
    ROUND(((RDH2.VAR/RDH1.VAR)-1)*100,2) CHANGE_PERCENT
FROM
	DBO.RISK_DATA_HIST RDH1
LEFT JOIN DBO.RISK_DATA_HIST RDH2
	ON RDH1.CUSIP = RDH2.CUSIP
    AND RDH1.COB_DATE = DATE_SUB(RDH2.COB_DATE, INTERVAL 1 DAY)
#To observe the ticker left join with SECURITY_INFO
LEFT JOIN DBO.SECURITY_INFO SI
	ON RDH1.CUSIP = SI.CUSIP
    AND RDH1.COB_DATE BETWEEN SI.START_DATE AND SI.END_DATE
#Only in Jan 2018
WHERE
	RDH1.COB_DATE LIKE ('201801%')
GROUP BY
	RDH1.CUSIP,
    RDH1.COB_DATE
ORDER BY
	CHANGE_PERCENT DESC;
#Security AIG ('C653124476') has the largest single day VAR increase in Jan 2018

#4)	Which trader had the largest DECREASE in trade quantity between Jan 2 2018 and Feb 2 2018?
#I first created a table that cointains SUM(QUANTITY) per trader for both dates (Jan 2 2018 and Feb 2 2018)
CREATE TABLE
	DBO.TEST_DATA_EXERCISE6
AS SELECT
	COB_DATE,
    EMPLOYEE_ID,
	SUM(QUANTITY) SUM_QUANTITY
FROM
	DBO.TRADE_DATA_HIST
WHERE
	COB_DATE IN (20180102, 20180202)
GROUP BY
    EMPLOYEE_ID,
    COB_DATE;
#Then I created CHANGE_PERCENT which provides the percentage change in SUM(QUANTITY) between both dates
# with all the columns associated
SELECT
	TDE1.COB_DATE COB_DATE_1,
    TDE1.EMPLOYEE_ID EMPLOYEE_ID_1,
    TDE1.SUM_QUANTITY SUM_QUANTITY_1,
	TDE2.COB_DATE COB_DATE_2,
    TDE2.EMPLOYEE_ID EMPLOYEE_ID_2,
    TDE2.SUM_QUANTITY SUM_QUANTITY_2,
	ROUND(((TDE2.SUM_QUANTITY/TDE1.SUM_QUANTITY)-1)*100,2) CHANGE_PERCENT
FROM
	DBO.TEST_DATA_EXERCISE6 TDE1
INNER JOIN DBO.TEST_DATA_EXERCISE6 TDE2
	ON TDE1.EMPLOYEE_ID = TDE2.EMPLOYEE_ID
	AND TDE1.COB_DATE = DATE_SUB(TDE2.COB_DATE, INTERVAL 1 MONTH)
ORDER BY
	CHANGE_PERCENT ASC;
#Then I dropped the recently created table to avoid having too much data in the server
DROP TABLE
	DBO.TEST_DATA_EXERCISE6;

#Trader 2 had the largest decrease between Jan 2 2018 and Feb 2 2018


#6.5: UNION --------------------------------------------------------------------------
#1)	What is a Union?
#It stacks rows from one table into another table. It does not include duplicates.

#2)	How is a Union different than a Join?
#Join links tables based on same key values, while union unify different key values from different tables into one table.

#3)	Provide the code to Union all columns from table TRADE_DATA_HIST and table RISK_DATA_HIST.
SELECT 
	*
FROM 
	DBO.TRADE_DATA_HIST
UNION
SELECT
	*
FROM
	DBO.RISK_DATA_HIST;
    
#4)	Does the above Union make sense?
#No. It stacks rows that belong to different variables. For example, it is linking EMPLOYEE_ID column with VAR column.

#5)	Union TEST_DATA_HIST onto TRADE_DATA_HIST. Explain why or why not this union makes sense.
SELECT 
	*
FROM 
	DBO.TRADE_DATA_HIST
UNION
SELECT
	*
FROM
	DBO.TEST_DATA_HIST;
#It makes sense as long as they have the same columns with additional information in rows (TEST_DATA_HIST may contain different values than TRADE_DATA_HIST for a single column).
#Similar values for a single column does not matter since UNION does not include duplicates.

#6)	If you were going to Union two tables, one that has VaR on column 2 and one has Duration on column 2, what would happen to the output? 
#We will have a final column that contain both VaR and Duration in a single column. It does not make sense.

#7)	Do you have any suggestion how to deal with this assuming your manager insists you Union these two tables?
#One way is to create a VaR column and a Duration column and set the value to NULL where there is no data. 
#Another way is to use LEFT JOIN, RIGHT JOIN and UNION in order to create a table that stacks rows to the belonging column. In this sense we are
#replicating FULL OUTER JOIN dynamics but only including those relevant columns from both tables. For example:
 SELECT
	TD.*,
    RDH.VAR
FROM
	DBO.TEST_DATA TD
LEFT JOIN DBO.RISK_DATA_HIST RDH
	ON TD.POSITION_ID = RDH.POSITION_ID
WHERE
	TD.COB_DATE BETWEEN 20180101 AND 20180201
UNION
SELECT
	TD.*,
    RDH.VAR
FROM
	DBO.TEST_DATA TD
RIGHT JOIN DBO.RISK_DATA_HIST RDH
	ON TD.POSITION_ID = RDH.POSITION_ID
WHERE
	RDH.COB_DATE BETWEEN 20180101 AND 20180201
    AND TD.POSITION_ID IS NULL;

#8)	What is a Union All?
#It is a type of union but includes duplicates.

#9)	Provide a live case scenario where you might want to use Union All instead of Union.
#If we want to add a table that contains new info about trades for recent dates, then when we unify both tables we will need to acknowledge
#those duplicates and avoid omitting them. 

#10)	Is there a way to do a Union All but not show certain duplicates? If yes, explain.
#Yes. By using WHERE clause we can formulate a condition for the second table (the one that is being aggregated) in which all columns cannot take specific values such that
#a duplicated row (or many duplicated rows) are omited. for example:
SELECT
	*
FROM DBO.TRADE_DATA_HIST
UNION ALL
SELECT
	*
FROM DBO.TEST_TRADES
WHERE
#In NOT LIKE clause we can aggregate more restrictions to identify more duplicated rows
	COB_DATE NOT LIKE 20180106
    AND POSITION_ID NOT LIKE '20180106C853829400T5A003'
    AND CUSIP NOT LIKE 'C853829400'
    AND TRADER_ID NOT LIKE 'T5' 
    AND FUND_ID NOT LIKE 'A003'
    AND QUANTITY NOT LIKE '32000';


#6.6: Full Join Workaround
#1)	Explain in English what we are trying to accomplish with this workaround
#We are trying to simulate the results from FULL OUTER JOIN by using LEFT JOIN, RIGHT JOIN and UNION to remove duplicates that matched the both joins. 
#2)	Type out the code that is used in the video.
SELECT 
	TDH.POSITION_ID,
    TDH.EMPLOYEE_ID,
    RDH.POSITION_ID,
    RDH.VAR
FROM
	DBO.TRADE_DATA_HIST TDH
LEFT JOIN DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID
WHERE
	TDH.COB_DATE BETWEEN 20180101 AND 20180201
UNION
SELECT 
	TDH.POSITION_ID,
    TDH.EMPLOYEE_ID,
    RDH.POSITION_ID,
    RDH.VAR
FROM
	DBO.TRADE_DATA_HIST TDH
RIGHT JOIN DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID
WHERE
	RDH.COB_DATE BETWEEN 20180101 AND 20180201
    AND TDH.POSITION_ID IS NULL;
    
#3)	Above, please add a comment ABOVE each line of code explaining what it does and why it is necessary to add.
#We first apply LEFT JOIN to link TRADE_DATA_HIST with RISK_DATA_HIST and keep all the data that come from TRADE_DATA_HIST
SELECT 
	TDH.POSITION_ID,
    TDH.EMPLOYEE_ID,
    RDH.POSITION_ID,
    RDH.VAR
FROM
	DBO.TRADE_DATA_HIST TDH
LEFT JOIN DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID
WHERE
	#Add this to avoid crash
	TDH.COB_DATE BETWEEN 20180101 AND 20180201
#We then unify this result by using UNION with another table created by using RIGHT JOIN.
#UNION is used to remove all duplicates created after using LEFT JOIN and RIGHT JOIN.
#RIGHT JOIN is used to keep all the data that come from RISK_DATA_HIST
UNION
SELECT 
	TDH.POSITION_ID,
    TDH.EMPLOYEE_ID,
    RDH.POSITION_ID,
    RDH.VAR
FROM
	DBO.TRADE_DATA_HIST TDH
RIGHT JOIN DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID
WHERE
	#Here we are using RDH.COB_DATE because we are keeping rows in which TD.POSITION_ID is null
	RDH.COB_DATE BETWEEN 20180101 AND 20180201
    #If the gurus said it then i'll probably do it :)
    AND TDH.POSITION_ID IS NULL;
    
#4)	Write your own FULL JOIN WORKAROUND on TRADE_DATA_HIST and SECURITY_PRICE_HIST.
SELECT
	TDH.COB_DATE,
    TDH.CUSIP,
    TDH.POSITION_ID,
    TDH.EMPLOYEE_ID,
    TDH.QUANTITY,
    SPH.CLOSE_PRICE_USD,
    SPH.RATE
FROM
	DBO.TRADE_DATA_HIST TDH
LEFT JOIN DBO.SECURITY_PRICE_HIST SPH
	ON TDH.CUSIP = SPH.CUSIP
    AND TDH.COB_DATE = SPH.COB_DATE
WHERE
	TDH.COB_DATE BETWEEN 20180101 AND 20180201
UNION
SELECT
	TDH.COB_DATE,
    TDH.CUSIP,
    TDH.POSITION_ID,
    TDH.EMPLOYEE_ID,
    TDH.QUANTITY,
    SPH.CLOSE_PRICE_USD,
    SPH.RATE
FROM
	DBO.TRADE_DATA_HIST TDH
LEFT JOIN DBO.SECURITY_PRICE_HIST SPH
	ON TDH.CUSIP = SPH.CUSIP
    AND TDH.COB_DATE = SPH.COB_DATE
WHERE
	SPH.COB_DATE BETWEEN 20180101 AND 20180201
    AND TDH.POSITION_ID IS NULL;

#5)	What did you learn from the output of this query?
#There are some data from TRADE_DATA_HIST that do not exist in SECURITY_PRICE_HIST (primarily related to BOND). So
#the result would be a fully joined table with some values in blank for those rows that match existing data from TRADE_DATA_HIST to
#unexisting data in SECURITY_PRICE_HIST.


