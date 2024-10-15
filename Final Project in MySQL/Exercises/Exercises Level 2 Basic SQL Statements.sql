#2.1: CASE WHEN
#1)	Return all employees first and last name from EMPLOYEE_INFO, 
#	and add a new column that says “FRONT_OFFICE” if the employee is in a revenue generating position and “BACK_OFFICE” if not. 
#	A C-Level is neither front or back office. I’ll leave this up to you how to handle this .
SELECT
	FIRST_NAME,
    LAST_NAME,
	CASE WHEN
		#I assume that all traders have a revenue-generating position
		EI.ROLE = "Trader" THEN "FRONT_OFFICE"
		WHEN EI.POSITION = "CEO" THEN " "
		ELSE "BACK_OFFICE"
		END AS TYPE_
FROM
	DBO.EMPLOYEE_INFO AS EI;

	
#2)	Return DATE, CUSIP, QUANTITY, and a new column that returns SMALL, MEDIUM, and LARGE if QUANTITY is 5,000 <  25,000 <  50,000  
SELECT
	COB_DATE,
    CUSIP,
    QUANTITY,
		CASE WHEN
			QUANTITY < 5000 THEN "SMALL"
			WHEN QUANTITY < 25000 THEN "MEDIUM"
			ELSE "LARGE"
			END AS SIZE
	FROM
		DBO.TRADE_DATA_HIST;
    


#2.2: ALIAS
#1)	Return all of the columns from table SECURITY_INFO but rename the longer column names to shorter ones
SELECT
	START_DATE AS SDATE,
    END_DATE AS EDATE,
    CUSIP,
    INSTRUMENT_TYPE AS ITYPE,
    DELISTED,
    TICKER,
    DESCRIPTION,
    SECTOR,
    COUNTRY
FROM
	DBO.SECURITY_INFO;

#2)	Write a select statement with multiple filters using aliases for both columns and the table you are selecting from
SELECT
	TDH.COB_DATE AS DATE,
    TDH.EMPLOYEE_ID AS ID,
    TDH.QUANTITY AS Q
FROM 
	DBO.TRADE_DATA_HIST AS TDH
WHERE 
	COB_DATE LIKE "2018%" AND 
    EMPLOYEE_ID IN ("T1","T2","T3") AND 
    QUANTITY <= 20000;
    
#2.3: COALESCE
#1)	Write a query to return all DATE, CUSIP, DURATION, but when duration is NULL it should return CONVEXITY instead
SELECT
	COB_DATE,
    CUSIP,
	COALESCE(DURATION, CONVEXITY) AS DURATION
FROM DBO.RISK_DATA_HIST;
#2)	List all of the tickers in security info that are active. If there is no TICKER return CUSIP. If there is no CUSIP, return DESCRIPTION.
SELECT
    COALESCE(TICKER,CUSIP,DESCRIPTION) AS TICKER
FROM
	DBO.SECURITY_INFO;

#2.4: FUNCTIONS
#1)	Return the aggregated quantity of each CUSIP from TRADE_DATA_HIST on each day.
SELECT
	COB_DATE,
    CUSIP,
	SUM(TDH.QUANTITY) SUMQ
FROM
	DBO.TRADE_DATA_HIST TDH
GROUP BY 
	TDH.CUSIP, 
    COB_DATE;
#2)	Return the aggregated quantity of each CUSIP for each EMPLOYEE_ID. (Date does not matter here)
SELECT
	CUSIP,
	EMPLOYEE_ID,
    SUM(QUANTITY) SUMQ
FROM 
	DBO.TRADE_DATA_HIST AS TDH
GROUP BY 
	CUSIP, 
    EMPLOYEE_ID;
#3)	What is the average QUANTITY of CUSIP C146500095 where the trader is T5?
SELECT
	AVG(QUANTITY) AVERAGE
FROM
	DBO.TRADE_DATA_HIST
WHERE
	CUSIP = "C146500095" AND
    EMPLOYEE_ID = "T5";
#4)	What is the average QUANTITY of CUSIP C146500095 where the trader is T5 and the month is January (could be multiple years, should only check that the month is Jan)?
SELECT
	AVG(QUANTITY) AVERAGE
FROM
	DBO.TRADE_DATA_HIST
WHERE
	CUSIP = "C146500095" AND
    EMPLOYEE_ID = "T5" AND
    #Use ("____01%") to select only month jan for any year with the form ____
    COB_DATE LIKE ("____01%");


#2.5: DECIMAL PRECISION
#1)	Return the full dataset from table RISK_DATA_HIST but the last three columns should only have three decimals each using the CAST method.
SELECT
	RDH.COB_DATE,
    RDH.POSITION_ID,
    RDH.CUSIP,
    CAST(RDH.VaR AS DECIMAL(14,3)) VaR,
    CAST(RDH.Duration AS DECIMAL(14,3)) Duration,
	CAST(RDH.Convexity AS DECIMAL(14,3)) Convexity
FROM
	DBO.RISK_DATA_HIST AS RDH;
#2)	Do the same as above using ROUND.
SELECT
	RDH.COB_DATE,
    RDH.POSITION_ID,
    RDH.CUSIP,
    ROUND(RDH.VaR,3) VaR,
    ROUND(RDH.Duration,3) Duration,
	ROUND(RDH.Convexity,3) Convexity
FROM
	DBO.RISK_DATA_HIST AS RDH;