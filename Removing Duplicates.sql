#removing duplicates

SELECT *
FROM customer_sweepstake;

#first thing we can see is the column sweepstake_id which is not properly named. We are going to start by naming it properly:

ALTER TABLE customer_sweepstake 
RENAME COLUMN `ï»¿sweepstake_id` TO `sweepstake_id`;

SELECT *
FROM customer_sweepstake;

#Since that is fixed, we will go through the table and identify areas that need cleaning:
#the process will start by removing duplicates
#we can see that from the table customer id 100101 and 100106 are repeated. We need to remove the duplicated data.

SELECT customer_id, COUNT(customer_id)
FROM customer_sweepstake
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

#we can see from the data below that 101 and 106 appear TO BE ENTERED twice while the rest appear only once.

#an alternative method we can use is by using a window function to identify the duplicates. We will use the ROW_NUM window function

SELECT customer_id,
ROW_NUMBER () OVER( PARTITION BY customer_id ORDER BY customer_id) AS row_num
FROM customer_sweepstake;

#the duplication is clearly evident from the ones with a 2 as the row number.
#to identify the specific customer ids we can use a subquery as follows.


SELECT *
FROM(
SELECT customer_id,
ROW_NUMBER () OVER( PARTITION BY customer_id ORDER BY customer_id) AS row_num
FROM customer_sweepstake) AS table_row
WHERE row_num > 1;

#after identifying the duplicates, now we delete them:

DELETE FROM customer_sweepstake
WHERE sweepstake_id IN(
	
		SELECT sweepstake_id
		FROM (
			SELECT sweepstake_id,
			ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS row_num
			FROM customer_sweepstake) AS table_row
			WHERE row_num > 1);
            
#The duplicates have been deleted using the sweepstake_id as the unique identifier
            
SELECT *
FROM customer_sweepstake;
            


