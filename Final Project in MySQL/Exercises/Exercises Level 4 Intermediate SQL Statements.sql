## 4.1: TABLE MODIFICATION--------------------------------------------------------------
#1)	Create a table called TEST_TRADES. It should contain the same columns as our TRADE_DATA table.
CREATE TABLE `dbo`.`test_trades`(
	`COB_DATE` INT NOT NULL,
    `POSITION_ID` VARCHAR(100) NOT NULL,
    `CUSIP` VARCHAR(100) NOT NULL,
    `EMPLOYEE_ID` VARCHAR(100) NOT NULL,
    `FUND_ID` VARCHAR(100) NOT NULL,
    `QUANTITY` VARCHAR(100) NOT NULL,
    `NOTIONAL_USD` VARCHAR(100) NOT NULL,
    `SCHEDULE` VARCHAR(100) NOT NULL,
    `MATURITY_DATE` VARCHAR(100) NOT NULL
);

#*for the next four questions please use the TEST_TRADES table*
#2)	Add an index to the column on the columns you feel appropriate.
ALTER TABLE 
	`dbo`.`test_trades` 
ADD INDEX 
	`IDX_01` (`POSITION_ID` ASC) VISIBLE;

#3)	Change the column titled “EMPLOYEE_ID” to “TRADER_ID”.
ALTER TABLE 
	`dbo`.`test_trades`
CHANGE COLUMN 
	`EMPLOYEE_ID` `TRADER_ID` TEXT NULL DEFAULT NULL;

#4)	INSERT 100 rows from TRADE_DATA into this TEST table, sort by date so the latest dates come in first.
#USING WHAT I HAVE BEEN TAUGHT:
INSERT INTO DBO.TEST_TRADES(COB_DATE, 
							POSITION_ID, 
							CUSIP, 
                            TRADER_ID, 
                            FUND_ID, 
                            QUANTITY, 
                            NOTIONAL_USD, 
                            SCHEDULE, 
                            MATURITY_DATE)
SELECT 
	COB_DATE, 
    POSITION_ID, 
    CUSIP, 
    EMPLOYEE_ID, 
    FUND_ID, 
    QUANTITY, 
    NOTIONAL_USD, 
    SCHEDULE, 
    MATURITY_DATE 
FROM 
	DBO.TRADE_DATA_HIST
ORDER BY
	COB_DATE DESC
LIMIT
 100;
 
#ANOTHER EASIEST FORM:
#Use this syntax to insert data into test_trades from trade_data_hist
INSERT INTO 
DBO.TEST_TRADES (
#Insert all columns data from trade_data_hist into test_trades
SELECT
	*
FROM
	DBO.TRADE_DATA_HIST TDH
ORDER BY
#order by date descendent in order to have latest dates come in first
	COB_DATE DESC
LIMIT
#only first 100 rows
 100
 );


#5)	Update all of the rows where TRADER_ID = ‘T1’ to say ‘INTERNAL’ instead.
UPDATE 
	DBO.TEST_TRADES
SET 
	TRADER_ID = 'INTERNAL'
WHERE 
	TRADER_ID = 'T1';
    

## 4.2: VIEWS--------------------------------------------------------------
#1)	What is a view and why might it be useful?
#It is an artificial table to use very specific data. For example, if we would like to identify position_id for an specific year,
#we can use views in order to construct a table filled by these filters. Consequently, unnecessary columns can be removed.

#2)	Create a view that would be useful on our dataset (not the one from the lecture).
#I create a view that shows all information about positions in BONDS made by Internal traders
CREATE VIEW `dbo`.`test_trades_v` AS
	SELECT 
		`dbo`.`test_trades`.`COB_DATE` AS `COB_DATE`,
        `dbo`.`test_trades`.`POSITION_ID`AS `POSITION_ID`,
        `dbo`.`test_trades`.`TRADER_ID` AS `EMPLOYEE_ID`,
        `dbo`.`test_trades`.`NOTIONAL_USD` AS `NOTIONAL_USD`,
        `dbo`.`test_trades`.`SCHEDULE` AS `SCHEDULE`,
        `dbo`.`test_trades`.`MATURITY_DATE` AS `MATURITY_DATE`        
	FROM 
		`dbo`.`test_trades`
	WHERE
		`dbo`.`test_trades`.`POSITION_ID` LIKE "%BOND%" AND
        `dbo`.`test_trades`.`TRADER_ID` = "INTERNAL";
	
#3)	Explain why your view will be helpful and who might be using it at the firm 
# Managers may want to know if internal traders would have executed some trades related to bonds and the date of these transactions


## 4.3: UNDERSTANDING OUR DATA --------------------------------------------------------------
#1)	Which table contains information about our clients?
# fund_info

#2)	Which table contains information about our employees?
# employee_info

#3)	What is the purpose of SECURITY_INFO?
# Track a record of variables related to securities such as type, ticker, description, etc

#4)	What table might you add to enrich our data further?
# I will add a potential client table in to monitor variables related to these.

#4.4: ROW VS COLUMN
#1)	Explain some key advantages of row based vs column based database and vice-versa.
#Advantages of row based over column based:
#	- Records are easier and faster to read and write since they capture all information about one single obsevation
#	- Row-oriented data are best suited for online transaction since each one represent one observation with all features
#	- Row-based database are able to read all the information at the same time about an observation (does not only focus in one relevant data)

#Advantages of column based over column based:
#	- It does not read unnecesasary data if relevant-data-search is required
#	- Best suited for online analytical processing
#	- These are efficient in performing operations applicable to the entire dataset and enables aggregation over many rows and columns
#	- It allows high compression rates due to little distinct or unique values in columns


