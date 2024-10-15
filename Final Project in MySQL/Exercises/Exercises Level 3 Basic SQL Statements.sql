
-- 3.1: MAP
-- 1)	Describe a map table in your own words.
-- They are tables that map different column variables in a single table and serve as an intermediary to link column values between two or more tables.
-- 2)	Is it ever appropriate to use a map table?
-- It is convenient for linking tables, but it is not appropriate for cases in which it is important to track a record.
-- 3)	You own a store where you sell fishing equipment. You have a database of inventory and orders. What map table might be helpful to you?
-- I would construct a map table in which the column variables are composed by PRODUCT_ID that lists all id for fishing equipment and a PRODUCT_NAME that related the corresponding name of the fishing equipment. These two columns would allow me to link inventory and orders database in order to search for any specific value for a specific product. For example, I would be able to know how many rods are available from the inventory database by knowing the corresponding id of this product extracted from the map table.


-- 3.2: DIMENSION
-- 1)	Describe in your own words what a dimension table is and why it is so critical for finance firms to They are tables that contain attributes and categorize facts that are not frequently changed but allow us to keep track of their historical values by having start_date and end_date columns. Their importance lies in the fact that sometimes it is important to know what happens to the data during a turning date. For example, if a security has changed its name, a dimension table would allow us to track this record. Perfect for long term projects and allow fact tables to scale
-- 2)	Why is it necessary to have START and END date on each row in a dimension table?
-- It is important to historically track a record about the product id in case of any change.
-- 3)	If we put an entry in the dimension table for Google, two week later Google changed their ticker to GOOGL and then a week later a trader executes two trades, how many rows for this company would exist in the dimension table?
-- There will be 2 rows: the first one corresponds to the initial entry in the dimension table, the second one corresponds to the entry that shows a change in ticker. Of course, the column of number of trades will be different for those 2 rows (the last one will have +2 rows, meanwhile the former will be kept unchanged) and the start_date column for the second row will be update. 
-- 4)	What if we had a fund XYZ in the fund dimension table from Jan 2000 until Feb 2000 and then they were no longer our client. In 2015 they joined us once again. What would the dimension entries look like?
-- There would be 2 rows. Both would have different start_date values and different end_dates values. 


-- 3.3: FACT
-- Things that don’t change frequently and should not be in a fact table. Keep fact table with values that change frequently with one identifier that is important. Everything else in a dimension table
-- 1)	Describe a fact table in your own words.
-- They are tables that include metrics and facts of a process that change frequently.
-- 2)	If we had a product level fact table, would it have multiple rows for TSLA, one for each trader?
-- No, it may have multiple rows in case any fact or metric value related to the product changes frequently. For example, if the price of TSLA changes daily (as we expect), then there will be multiple rows for TSLA for each price per day. However if one column identifies which traders buy/sell that product at that day, then there will be multiple rows that has a code that identify traders that operate this product per day.
-- 3)	If we had a trader level fact table would it have tickers in it?
-- No, we will have facts or metrics related to traders. For example, the amount of trades each trader executes per day.
-- 4)	If we have two traders, A and B, and they both traded IBM yesterday for three clients each. If this was a trade level fact tables, how many rows would this information be on?
-- There would be 6 rows: 3 for each trader. The codes that identify the trades will be somehow like this: AIBMClient1,AIBMClient2,AIBMClient3,BIBMClient1,BIBMClient2,BIBMClient3.
-- 5)	Is a fact table captured yearly, monthly, daily, or continuously?
-- It depends on the frequency of the variable (fact or metric) related to the table level. For example, if we have a product level and the variable is price, the fact table may be captured daily. The objective of a fact table is to captured frequently changes and the frequency may vary according to facts and metrics.


-- 3.4: KEYS
-- 1)	Describe a primary key.
-- Primary key is unique identifier for a record in a table that works as a clustered index that sort the table based on its values.
-- 2)	Describe a foreign key.
-- Foreign key is a column in a table that is a primary key in another table which works as a intermediary that connects both tables. Since they are not primary keys, they do not automatically creates 
-- 3)	Why might you have a primary key column in your table?
-- It allows searching on the table easily, since the latter are sorted by primary keys, while working as a connection to foreign key columns in another table. 
-- 4)	Why might you have a foreign key column in your table?
-- It allows to link two tables by referencing the primary key from another table.



-- 3.5: INDEX & CONSTRAINTS
-- 1)	What is a clustered index?
-- It is a sort on a table. It speeds up SELECT queries on a table 
-- 2)	When deciding which columns to index which might be good candidates? Why those columns?
-- Columns related to ids and keys because SQL will be used by programs (instead of humans) and they need to identify records in a table, so names are not adequate. 
-- 3)	Is it faster or slower to read from an indexed table?
-- Faster
-- 4)	Is it faster or slower to write to an indexed table?
-- Faster
-- 5)	Is a primary key an index?
-- Yes
-- 6)	What are column constraints? 
-- They are restrictions that give some information about the columns. 
-- 7)	What does CHECK do?
-- It assesses if an entry fulfills the constraint such that limit the value range that can have a column. For example, if someone enters a response that is different from Yes/No option, then “check constraint” will identify this and throw an error.
-- 8)	What does DEFAULT do?
-- It is used to set a default value for a column. For example, if we set 0 as default when someone enters a non-number response, then it will throw this value instead
