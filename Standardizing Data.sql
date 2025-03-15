#standardising data is the second step in the data cleaning process after removing duplicates

SELECT *
FROM customer_sweepstake;

#the first thing we can see is the phone numbers are not in order, they all have different formats and styles. That needs to be standardised.
#we will use the REGEXP_REPLACE funtion to remove the -,(),/ signs

SELECT phone
FROM customer_sweepstake;

#use the following syntax
SELECT phone, REGEXP_REPLACE(phone, '[()-/+]', '')
FROM customer_sweepstake;

#update the column using the UPDATE-SET function
UPDATE customer_sweepstake
SET phone = REGEXP_REPLACE(phone, '[()-/+]', '');

#now run the query for confirmation
SELECT phone
FROM customer_sweepstake;

#standardise the phone format using - and the SUBSTRING function
#first we seperate then we join with dashes(-)

SELECT phone, SUBSTRING(phone,1,3),  SUBSTRING(phone,4,3), SUBSTRING(phone,7,4)
FROM customer_sweepstake;

#to join we use the CONCAT function as follows:

SELECT phone, CONCAT(SUBSTRING(phone,1,3),'-', SUBSTRING(phone,4,3),'-', SUBSTRING(phone,7,4))
FROM customer_sweepstake;

#we need to update and work with NOT NULL values,we will exclude the -- by adding a filter

SELECT phone, CONCAT(SUBSTRING(phone,1,3),'-', SUBSTRING(phone,4,3),'-', SUBSTRING(phone,7,4))
FROM customer_sweepstake
WHERE phone <> '';

#update the phone column:

UPDATE customer_sweepstake
SET phone =  CONCAT(SUBSTRING(phone,1,3),'-', SUBSTRING(phone,4,3),'-', SUBSTRING(phone,7,4))
WHERE phone <> '';

#confirm the result
SELECT phone
FROM customer_sweepstake;

#so far so good
#next we will standardise the birth_date column

SELECT birth_date
FROM customer_sweepstake;

#we can see that the birth_date column is stored as text but MySQL doesn't store dates like that
#we will use the STRING TO DATE function to change the format and the CONCAT + SUBSTRING function as well

SELECT birth_date, CONCAT(SUBSTRING(birth_date, 9,2),'/',SUBSTRING(birth_date, 6,2),'/',SUBSTRING(birth_date, 1,4))
FROM customer_sweepstake;

#UPDATE birth_date column with the new format

UPDATE customer_sweepstake
SET birth_date = CONCAT(SUBSTRING(birth_date, 9,2),'/',SUBSTRING(birth_date, 6,2),'/',SUBSTRING(birth_date, 1,4))
WHERE sweepstake_id IN (9,11);

#Confirm

SELECT *
FROM customer_sweepstake;

#now we can update using the STR_TO_DATE function

UPDATE customer_sweepstake
SET birth_date = STR_TO_DATE(birth_date, '%m/%d/%Y');

#NEXT we will look at the Are you over 18 column

SELECT `Are you over 18?`
FROM customer_sweepstake;

#we will use the CASE statement to standardise the column

SELECT `Are you over 18?`,
CASE 
	WHEN `Are you over 18?` = 'Yes' THEN 'Y'
    WHEN `Are you over 18?` = 'No' THEN 'N'
    ELSE `Are you over 18?`
END    
FROM customer_sweepstake;

#update and confirm

UPDATE customer_sweepstake
SET `Are you over 18?` = CASE 
	WHEN `Are you over 18?` = 'Yes' THEN 'Y'
    WHEN `Are you over 18?` = 'No' THEN 'N'
    ELSE `Are you over 18?`
END;


#NEXT WE WILL WORK ON THE ADDRESS COLUMN\

SELECT address
FROM customer_sweepstake;

#we are unable to filter out on the address eg state, city orr street as it is. that is why we will have to break the column into multiple columns:
#using the SUBSTRING_INDEX function- returns a substring from a string before or after a specified delimiter
#in this case the ','

SELECT address, 
SUBSTRING_INDEX(address, ',',1) AS street,
SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',',2),',',-1) AS city, 
SUBSTRING_INDEX(address, ',',-1) AS state
FROM customer_sweepstake;

#we will then add new columns to our table ysing the alter table function
#the column has to include the character type eg string, txt etc hence the VARCHAR standing for a string of text of variable characters limited to 50:

ALTER TABLE customer_sweepstake
ADD COLUMN street VARCHAR(50) AFTER address,
ADD COLUMN city VARCHAR(50) AFTER street,
ADD COLUMN state VARCHAR(50) AFTER city;

#confirm

SELECT *
FROM customer_sweepstake;

#update the table

UPDATE customer_sweepstake
SET street = SUBSTRING_INDEX(address, ',',1);

UPDATE customer_sweepstake
SET city = SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',',2),',',-1);

UPDATE customer_sweepstake
SET state = SUBSTRING_INDEX(address, ',',-1);

#next we will standardise the state column

SELECT state 
FROM customer_sweepstake;

#we shall use the UPPER statement

SELECT state, UPPER(state)
FROM customer_sweepstake;

UPDATE customer_sweepstake
SET state = UPPER(state);

#perform soem trimming on the city and state column

SELECT city, TRIM(city)
FROM customer_sweepstake;

SELECT state, TRIM(state)
FROM customer_sweepstake;

SELECT street, TRIM(street)
FROM customer_sweepstake;

UPDATE customer_sweepstake
SET city = TRIM(city);

UPDATE customer_sweepstake
SET state = TRIM(state);

UPDATE customer_sweepstake
SET street = TRIM(street);

SELECT *
FROM customer_sweepstake;



