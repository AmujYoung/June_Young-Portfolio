SELECT *
FROM world_life_expectancy;

#We will start with data cleaning
#process 1 is Removing duplicates
#Use the follwoing query to search for the duplicates. Each country and year should be unique.

SELECT Country, Year, CONCAT( Country, Year),
COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT( Country, Year);

#we will now add a filter to determine which country year combination has a count of great than 1

SELECT Country, Year, CONCAT( Country, Year),
COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT( Country, Year)
HAVING COUNT(CONCAT(Country, Year)) >1;

#therefore the countries with duplicates are Ireland, Senegal and Zimbabwe.

#next we need to identify their row ids so as to locate them and delete them by row id. We will use the PARTITION BY and ROW_NUM functions
SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy;
 
 
 #we cannot select the row id from the above query as it is. So we need to put the above query as a subquery and write another one below
    
SELECT *
	FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy) AS Row_Table
WHERE Row_Num >1
;

#we will delete the 3 row ids from our table. But remember to back uyp your data so tat you don't just alter the original data source.

#to delete we will write the following query

DELETE FROM world_life_expectancy
WHERE Row_ID IN
	(SELECT Row_ID
		FROM(
			SELECT Row_ID, 
			CONCAT(Country, Year),
			ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
		FROM world_life_expectancy) AS Row_Table
		WHERE Row_Num >1);
        
        
#the rows have been deleted. Confirmation below:

SELECT *
	FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy) AS Row_Table
WHERE Row_Num >1
;  

#STEP 2 is standardising data. 
#IN THIS STAGE WE WILL LOOK AT THE MISSING DATA AND SEE HOW TO CORRECT IT.


SELECT *
FROM world_life_expectancy
WHERE Status = '';

#next we will select the countries where the status is developing

SELECT DISTINCT (Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

#next we wil update the status to Developing where the Country is 'Developing'

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
 SET t1.Status = 'Developing'   
 WHERE t1.Status = ''
 AND t2.Status <> ''
 AND t2.Status = 'Developing';
 
 #run a confirmamtion query to see if it worked
 
SELECT *
FROM world_life_expectancy
WHERE Status = ''; 

#we will run the same cquery for the developed case.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
 SET t1.Status = 'Developed'   
 WHERE t1.Status = ''
 AND t2.Status <> ''
 AND t2.Status = 'Developed';
 
 
 #confirm
SELECT *
FROM world_life_expectancy
WHERE Status = ''; 

#all countries are okay now.
 
 
SELECT *
FROM world_life_expectancy;

#CHECK THE #Life Expectancy column

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';

#to populate those columns we will have to the average of the before and after years. We will also need to do a self join to get the averages right.

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) /2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
 JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';   

#WE will now update the table with the calculation as follows:

 
UPDATE world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
		AND t1.Year = t2.Year -1
	JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
		AND t1.Year = t3.Year + 1
   SET t1.`Life expectancy` =  ROUND((t2.`Life expectancy` + t3.`Life expectancy`) /2, 1)
   WHERE t1.`Life expectancy` = '';
   
   #confirm
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''; 

#table is fully cleaned

SELECT *
FROM world_life_expectancy;
   
