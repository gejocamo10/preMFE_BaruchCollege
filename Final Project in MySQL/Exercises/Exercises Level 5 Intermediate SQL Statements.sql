#5.1: DELETE ------------------------------------------------------------------
#1)	Create a new test table with just two columns (doesn’t matter what they are). Load it with a few rows of data. Delete the entire table.
CREATE TABLE dbo.test_table(
	CLIENT_ID VARCHAR(100) NOT NULL DEFAULT 'NEW_CLIENT',
    CLIENT_NAME VARCHAR(20) NOT NULL DEFAULT 'NEW_CLIENT_ID'
);

INSERT INTO 
	DBO.TEST_TABLE(CLIENT_ID, CLIENT_NAME)
VALUES
	("001AB","AB"), 
    ("001CD","CD"), 
    ("001EF","EF");

DELETE FROM 
	DBO.TEST_TABLE;

#2)	Delete the entire contents of your TEST_TRADES table from last homework. Reload the table with the first five days of data. Select all the data, makes sure it’s all there. 
DELETE FROM
	DBO.TEST_TRADES;

INSERT INTO 
DBO.TEST_TRADES(
SELECT
	*
FROM
	DBO.TRADE_DATA_HIST
WHERE
#I just kept all columns between first and fifth oldest day without typing the date from TRADE_DATA_HIST
#by using MIN(COB_DATE) and MIN(COB_DATE)+4 respectively.
	COB_DATE BETWEEN (SELECT MIN(COB_DATE) FROM DBO.TRADE_DATA_HIST) 
    AND (SELECT (MIN(COB_DATE)+4) FROM DBO.TRADE_DATA_HIST) 
);

#Now delete all of the data from the first day of the table. Here the tricky part: DO NOT actually type out the date. Have your code figure out what the first day is.
DELETE FROM
	DBO.TEST_TRADES TT
WHERE
#I deleted all rows related to first day without actually typing the date.
	TT.COB_DATE = (SELECT MIN(COB_DATE) FROM DBO.TRADE_DATA_HIST);
    
#3)	Delete all rows where quantity < 1000.
DELETE FROM 
	DBO.TEST_TRADES
WHERE 
	QUANTITY < 1000;
#4)	What is an orphaned record and how can we avoid it?
#They are foreign keys that do not have connection to their related primary keys from another table since they have been dropped. 


#5.2: UPDATE ------------------------------------------------------------------
#1)	In your TEST_TRADES table, update all of the traders on the last day of trades to be “T5”. As it turns out you know T5 was the only trader in the office on that day so we want to assign all of the trades to her.
UPDATE
	DBO.TEST_TRADES
SET
	TRADER_ID = "T5"
WHERE
#Since all rows related to first day were delete then I used second day from TRADE_DATE_HIST to specify the date without typing its exact value
	COB_DATE = (SELECT MIN(COB_DATE)+1 FROM DBO.TRADE_DATA_HIST);
    
#2)	Update a ticker in SECURITY_INFO. Where END_DATE = 99991231, modify the ticker by changing the END_DATE to today.
UPDATE
	DBO.SECURITY_INFO
SET
	END_DATE = 20221018
WHERE
	TICKER = "COAG" AND
    END_DATE = 99991231;
    
    
#5.3: INSERT
#1)	Continuing from 5.2.2, now insert a new row in SECURITY_INFO with the appropriate START and END date that a new dimension entry should have. Change the country on this row (the reason why we had to end the other entry is because the ticker’s country changed.
INSERT INTO DBO.SECURITY_INFO (START_DATE,END_DATE,CUSIP,INSTRUMENT_TYPE,DELISTED,TICKER,DESCRIPTION,SECTOR,COUNTRY)
VALUES(20221018, '99991231', 'C850326527', 'Equity', 'N', 'COAG', 'Cabot Oil & Gas', 'Energy', 'PE');

#2)	Create a new table called “ACTIVE_SECURITIES” with the same rows as SECURITY_INFO. Load all active rows from SECURITY_INFO into that table.
CREATE TABLE
	dbo.active_securities
AS SELECT
	*
FROM
	DBO.SECURITY_INFO
WHERE
	DELISTED = "N" AND
    END_DATE = 99991231;
	
#Note: It would almost certainly be a better idea to create a view called “ACTIVE_SECURITIES_V” which simply selects from SECURITY_INFO where the row is active, but then this exercise wouldn’t be any fun, right? 

