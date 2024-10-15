## 7.1: ADVANCED QUERIES -------------------------------------------------------------------------------------------------------------------
# 1)	Display total market value traded for fund Whale Rock on each day in Jan 2018.
SELECT
	TDH.COB_DATE,
    FI.FUND_NAME,
    SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY) SUM_MARKET_VALUE
FROM
	DBO.TRADE_DATA_HIST TDH
INNER JOIN DBO.SECURITY_PRICE_HIST SPH
 	ON SPH.CUSIP = TDH.CUSIP
    AND SPH.COB_DATE = TDH.COB_DATE
INNER JOIN DBO.FUND_INFO FI
	ON TDH.FUND_ID = FI.FUND_ID
    AND TDH.COB_DATE BETWEEN FI.START_DATE AND FI.END_DATE
WHERE
	FI.FUND_NAME = "Whale Rock"
    AND TDH.COB_DATE BETWEEN 20180101 AND 20180131
GROUP BY
	TDH.COB_DATE,
    FI.FUND_NAME
ORDER BY
	TDH.COB_DATE;

# 2)	Which ticker contained the highest avg daily market value for a single fund over the history of our dataset, and which ticker & fund was it?
SELECT
	TDH.COB_DATE,
    TDH.CUSIP,
    FI.FUND_NAME,
    SI.TICKER,
    AVG(SPH.CLOSE_PRICE_USD * TDH.QUANTITY) AVG_MARKET_VALUE
FROM
	DBO.TRADE_DATA_HIST TDH
INNER JOIN DBO.SECURITY_PRICE_HIST SPH
 	ON SPH.CUSIP = TDH.CUSIP
    AND SPH.COB_DATE = TDH.COB_DATE
INNER JOIN DBO.FUND_INFO FI
	ON TDH.FUND_ID = FI.FUND_ID
    AND TDH.COB_DATE BETWEEN FI.START_DATE AND FI.END_DATE
INNER JOIN DBO.SECURITY_INFO SI
	ON TDH.CUSIP = SI.CUSIP
    AND TDH.COB_DATE BETWEEN SI.START_DATE AND SI.END_DATE
GROUP BY
	TDH.FUND_ID,
    TDH.COB_DATE
ORDER BY
	AVG_MARKET_VALUE DESC;
#The ticker is ADP which has a CUSIP 'C859618923' with an average market value of '65226774.014' for Trump Advisors fund. 

# 3)	Which region has the largest combined VaR for the month of March 2018?
SELECT
# I found this useful function on the internet
#	MONTHNAME(RDH.COB_DATE) MONTH,
#    SI.COUNTRY,
    CRM.REGION,
    SUM(RDH.VAR) SUM_VAR
FROM
	DBO.RISK_DATA_HIST RDH
INNER JOIN DBO.SECURITY_INFO SI
	ON RDH.CUSIP = SI.CUSIP
    AND RDH.COB_DATE BETWEEN SI.START_DATE AND SI.END_DATE
INNER JOIN DBO.COUNTRY_REGION_MAP CRM
	ON CRM.COUNTRY_CODE = SI.COUNTRY
WHERE
	RDH.COB_DATE BETWEEN 20180301 AND 20180331
GROUP BY
	CRM.REGION
ORDER BY
	SUM_VAR DESC;
# Africa has the largest combined VAR for Mar 2018

# 4)	What is the weighted average duration for each client for each year? You may use quantity for your weighting. The query should return:
# YEAR | FUND_NAME | WT_AVG_DURATION
SELECT
	YEAR(TDH.COB_DATE) YEAR,
    FI.FUND_NAME,
    # I computed the weigthed average duration using daily quantity trades as weights for each fund for each year 
    # captured in these 2 variables:
	# SUM(TDH.QUANTITY*RDH.DURATION),
    # SUM(TDH.QUANTITY),
    # I read the instructions and I noticed that I just need to divide both previously defined variables
    # to find the weighted average duration based on daily quantity weights traded for each fund.
    ROUND(SUM(TDH.QUANTITY*RDH.DURATION)/SUM(TDH.QUANTITY),2) WT_AVG_DURATION
FROM
	DBO.TRADE_DATA_HIST TDH
INNER JOIN	DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID
INNER JOIN DBO.FUND_INFO FI
	ON TDH.FUND_ID = FI.FUND_ID
	AND TDH.COB_DATE BETWEEN FI.START_DATE AND FI.END_DATE
GROUP BY
	# I grouped by year and fund to have this result for each year and fund
	YEAR(TDH.COB_DATE),
    FUND_NAME;






## 7.2: SUBQUERY -------------------------------------------------------------------------------------------------------------------
# 1)	What is a subquery?
# It is a query inside another query.

# 2)	What is more efficient a join or a subquery?
# Subqueries are less efficiente because are slower than joins. The reason is that it creates kind of a loop that incorporates
# a query inside another query (loop of WHERE clause).

# 3)	Provide some code below on when you might use a subquery (should work on our data).
SELECT
	POSITION_ID,
	QUANTITY,
    EMPLOYEE_ID
FROM 
	DBO.TRADE_DATA_HIST
WHERE POSITION_ID IN(
	SELECT POSITION_ID
    FROM DBO.RISK_DATA_HIST
    WHERE VAR > 100
);

## 7.2: COMMON TABLE EXPRESSION -------------------------------------------------------------------------------------------------------------------
# 1)	What is a CTE?
# It is a way of building tables in a query wrote before the actual (main) query. 

# 2)	When might you use a CTE?
# I might use it when I want to join variables (or tables) created from different frequencies (monthly or daily)

# 3)	Setup the following query using CTEs:

# A.	Create a temporary table that has three columns: Fund_Name, Date, Quantity
# I tried tu use CTEs but it was so slow that I lost connection to the server every time I run the query :(
# So I decided to use temp tables instead.
CREATE TEMPORARY TABLE T(
SELECT 
	FI.FUND_NAME,
	TDH.COB_DATE DATE, 
    TDH.QUANTITY
FROM
	DBO.TRADE_DATA_HIST TDH
INNER JOIN DBO.FUND_INFO FI
	ON TDH.FUND_ID = FI.FUND_ID
    AND TDH.COB_DATE BETWEEN FI.START_DATE AND FI.END_DATE
);
# B.	Create a second table that has three columns: Fund _Name, Date, VaR99
CREATE TEMPORARY TABLE R (
SELECT 
	FI.FUND_NAME,
	RDH.COB_DATE DATE, 
    RDH.VAR VaR99
FROM
	DBO.TRADE_DATA_HIST TDH
INNER JOIN DBO.RISK_DATA_HIST RDH
	ON TDH.POSITION_ID = RDH.POSITION_ID
INNER JOIN DBO.FUND_INFO FI
	ON TDH.FUND_ID = FI.FUND_ID
    AND TDH.COB_DATE BETWEEN FI.START_DATE AND FI.END_DATE
);
# C.	Join both CTEs to provide a single result of Client, Date, Quantity, and VaR99
SELECT
	T.FUND_NAME,
    T.DATE,
    T.QUANTITY,
    R.VAR99
FROM
	R
INNER JOIN T
	ON T.FUND_NAME = R.FUND_NAME
	AND T.DATE = R.DATE;

## 7.3: DETERMINISTIC FUNCTION -------------------------------------------------------------------------------------------------------------------
# 1)	What is a deterministic function?
# It is a relation that connect an input with an output. 

# 2)	Create a function that accepts a date and a string parameter: “Y, Q, M, D”. 
# Based on the parameter selected, the function should return either the year, quarter (Q1, Q2, Q3, Q4), month, or day of month.
# I copied these lines from the wizard. I noticed they are really helpful when coding to avoid using MySQL workbench!! Awesome!!
USE DBO;
DROP function IF EXISTS DBO.FN_DATE_SIGNALING;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_DATE_SIGNALING`(InDate INTEGER, InString VARCHAR(64)) 
RETURNS VARCHAR(64) CHARSET utf8mb4 DETERMINISTIC
BEGIN
RETURN (
		CASE
			WHEN InString = "Y" THEN YEAR(InDate)
			WHEN InString = "Q" THEN QUARTER(InDate)
			WHEN InString = "M" THEN MONTHNAME(InDate)
			ELSE DAYNAME(InDate)
		END
        );
END$$
DELIMITER ;

SELECT DBO.FN_DATE_SIGNALING(20180101, 'Y') YEAR;
SELECT DBO.FN_DATE_SIGNALING(20180101, 'Q') QUARTER;
SELECT DBO.FN_DATE_SIGNALING(20180101, 'M') MONTH;
SELECT DBO.FN_DATE_SIGNALING(20180101, 'D') DAY;

# 3)	Create a function that accepts a cusip and a date and returns the TOTAL QUANTITY, TOTAL MARKET_VALUE, AVG VAR, and AVG DURATION of that cusip.
USE DBO;
DROP function IF EXISTS DBO.FN_DETAIL_CUSIP;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_DETAIL_CUSIP`(InDate INTEGER, InCusip VARCHAR(64)) 
RETURNS varchar(64) CHARSET utf8mb4 DETERMINISTIC
BEGIN
RETURN (
		SELECT
			#I used CONCAT() to have a single value returned by the function.
			CONCAT(SUM(TDH.QUANTITY),"|",
            SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY),"|",
            AVG(RDH.VAR),"|",
            AVG(RDH.DURATION))
		FROM
			DBO.TRADE_DATA_HIST TDH
		INNER JOIN DBO.RISK_DATA_HIST RDH
			ON TDH.POSITION_ID = RDH.POSITION_ID
        INNER JOIN DBO.SECURITY_PRICE_HIST SPH
			ON TDH.CUSIP = SPH.CUSIP
			AND TDH.COB_DATE = SPH.COB_DATE
        WHERE
			TDH.CUSIP = InCusip
            AND TDH.COB_DATE = InDate
        GROUP BY
			TDH.COB_DATE,
			TDH.CUSIP
		);
END$$
DELIMITER ;

SELECT DBO.FN_DETAIL_CUSIP(20180202,"C113609857") AS "TOTAL_QUANTITY|TOTAL_MARKET_VALUE|AVG_VAR|AVG_DURATION";

#7.4: TEMPORARY TABLE
#1)	What is a temporary table?
# It creates a table on instantly and then you can use it. They are static datasets and are used as an alterantive to CTE

#2)	Create a temporary table with two columns: CUSIP and REGION. 
DROP TEMPORARY TABLE TEMP_REGION;
CREATE TEMPORARY TABLE TEMP_REGION(
	CUSIP VARCHAR(100) NOT NULL,
    REGION VARCHAR(100) NOT NULL
);
SELECT * FROM TEMP_REGION;

#3)	Load the table with all active cusips as of Jan 2 2018 and their respective regions.
INSERT INTO TEMP_REGION(CUSIP,REGION)
SELECT
	SI.CUSIP,
    CRM.REGION
FROM
	DBO.SECURITY_INFO SI
INNER JOIN DBO.COUNTRY_REGION_MAP CRM
	ON SI.COUNTRY = CRM.COUNTRY_CODE
WHERE
	DELISTED = "N" 
    AND START_DATE >= 20180102 
    AND END_DATE = 99991231;

SELECT * FROM TEMP_REGION;

#4)	Join the above temporary table with RISK_DATA_HIST to retrieve the SUM of VaR for each date for each region. 
SELECT
    RDH.COB_DATE,
    TR.REGION,
    SUM(RDH.VAR) SUM_VAR
FROM
	DBO.RISK_DATA_HIST RDH
INNER JOIN DBO.TEMP_REGION TR
	ON RDH.CUSIP = TR.CUSIP
GROUP BY
	RDH.COB_DATE,
    TR.REGION;

#7.5: STORED PROCEDURES
#1)	Please write your own useful stored procedure on our data.
#I used the stored procedure to find the Market_value for each country in a given region
USE DBO;
DROP procedure IF EXISTS DBO.SP_TRADES_BY_REGION_COUNTRY;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE SP_TRADES_BY_REGION_COUNTRY(
InRegion VARCHAR(64), Instart_date INTEGER, Inend_date INTEGER
)
BEGIN
	SELECT
		SI.COUNTRY COUNTRY,
        SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY) MARKET_VALUE
	FROM
		DBO.TRADE_DATA_HIST TDH
	INNER JOIN DBO.SECURITY_INFO SI
		ON TDH.COB_DATE BETWEEN SI.START_DATE AND SI.END_DATE
        AND TDH.CUSIP = SI.CUSIP
	INNER JOIN DBO.SECURITY_PRICE_HIST SPH
		ON SPH.COB_DATE = TDH.COB_DATE
        AND SPH.CUSIP = TDH.CUSIP
	INNER JOIN DBO.COUNTRY_REGION_MAP CRM
		ON SI.COUNTRY = CRM.COUNTRY_CODE
	WHERE 
    # I filtered by Instart_date and Inend_date given as inputs in the Stored Procedure
		TDH.COB_DATE BETWEEN Instart_date and Inend_date
	GROUP BY
		SI.COUNTRY;
END$$
DELIMITER ;
CALL DBO.SP_TRADES_BY_REGION_COUNTRY('ASIA', 20180101, 20180131);

#2)	Write a stored procedure that accepts a start date, end date, and a fund name. The SP should return: Quarter, Market Value, and % Market Value change over previous quarter.
USE DBO;
DROP PROCEDURE IF EXISTS DBO.SP_QCHANGE_MARKET_VALUE;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE SP_QCHANGE_MARKET_VALUE(
Instart_date INTEGER, Inend_date INTEGER, Infund_name VARCHAR(64) 
)
BEGIN
	SELECT
		# I used this CONCAT() in order to know the year for each quarter
		CONCAT(YEAR(TDH.COB_DATE),"|",QUARTER(TDH.COB_DATE)) AS "YEAR|QUARTER",
		# I used SUM all MARKET_VALUE in order to know the total market_value for each quarter (I could have used AVG as well, but it may be a difference context)
		SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY) MARKET_VALUE,
		# I used the LAG() function to calculate the previous quarter value of total MARKET_VALUE 
		# LAG(SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY), 1) OVER (ORDER BY QUARTER(TDH.COB_DATE) AND YEAR(TDH.COB_DATE)) AS LAG_MARKET_VALUE,
		# I used previously defined variables to find the quarterly percent change of total MARKET_VALUE
		ROUND(((SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY))/(LAG(SUM(SPH.CLOSE_PRICE_USD * TDH.QUANTITY), 1) OVER (ORDER BY QUARTER(TDH.COB_DATE) AND YEAR(TDH.COB_DATE)))-1)*100,2) AS PERCENT_CHANGE_MARKET_VALUE
	FROM
		DBO.TRADE_DATA_HIST TDH
	INNER JOIN DBO.SECURITY_PRICE_HIST SPH
		ON TDH.CUSIP = SPH.CUSIP
		AND TDH.COB_DATE = SPH.COB_DATE
	INNER JOIN DBO.FUND_INFO FI
		ON TDH.FUND_ID = FI.FUND_ID
		AND TDH.COB_DATE BETWEEN FI.START_DATE AND FI.END_DATE
	WHERE
		TDH.COB_DATE BETWEEN Instart_date AND Inend_date
		AND FUND_NAME = Infund_name
	GROUP BY
		# I grouped by QUARTER and YEAR to efficiently identify the total MARKET_VALUE for each quarter in different years (only 1 quarter for 2019 is in the dataset)
		QUARTER(TDH.COB_DATE),
		YEAR(TDH.COB_DATE)
	ORDER BY
		# I ordered by COB_DATE to correctly identify the quarterly percent change of total MARKET_VALUE
		TDH.COB_DATE;
END$$
DELIMITER ;

CALL DBO.SP_QCHANGE_MARKET_VALUE(20180101, 20190131, 'Whale Rock');
CALL DBO.SP_QCHANGE_MARKET_VALUE(20180101, 20180631, 'Whale Rock');
  

