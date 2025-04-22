#this is an exploratory data analysis personal project focusing on water pollution per region for the last 20 years.


SELECT *
FROM water_pollution_disease
;

#hands-on SQL challenge questions

#Question 1 - Find the country with the highest average contaminant level across all years.

SELECT Country,
       ROUND(AVG(`Contaminant Level (ppm)`), 1) AS avg_contaminant
FROM water_pollution_disease
GROUP BY Country
ORDER BY avg_contaminant DESC
LIMIT 1;

#result - it is found that Bangladesh is the country with the highest average contaminant level across all years.
#Breakdown:
#GROUP BY Country - to average across all years.
#ORDER BY avg_contaminant DESC - to get highest first.
#LIMIT 1 - return only the top country.


#Question 2 - List the top 5 records with the highest cholera cases per 100,000 people, regardless of year.
SELECT Country,
	ROUND(AVG(`Cholera Cases per 100,000 people`),1) AS avg_cholera_cases
FROM water_pollution_disease
GROUP BY Country
ORDER BY avg_cholera_cases DESC
limit 5;
#we have China, India, Ethiopia, USA and Pakistan.
#If you intended to get the top 5 individual records (country + year) instead of the average per country, then the query would look slightly different:
SELECT Country, Year, `Cholera Cases per 100,000 people`
FROM water_pollution_disease
ORDER BY `Cholera Cases per 100,000 people` DESC
LIMIT 5;


#Show how the global average access to clean water has changed year-over-year
SELECT Year, 
       ROUND(AVG(`Access to Clean Water (% of Population)`), 1) AS avg_access
FROM water_pollution_disease
GROUP BY Year
ORDER BY Year DESC;

#result - from the query we can see that the average %access to clean water has been increasing over the years.
#What It Does:
#Calculates the average access to clean water globally for each year.
#Rounds the average to 1 decimal place. 
#Orders results from the most recent year to oldest. 
#This is a great way to visualize trends over time, like whether global clean water access is improving




SELECT Country, Year, 
       ROUND(AVG(`Contaminant Level (ppm)`), 1) AS avg_contaminant,
       ROUND(AVG(`Diarrheal Cases per 100,000 people`), 1) AS avg_diarrhea_cases
FROM water_pollution_disease
GROUP BY Country, Year;



#Show the Most common water source types by region
SELECT Region, `Water Source Type`, COUNT(*) AS count
FROM water_pollution_disease
GROUP BY Region, `Water Source Type`
ORDER BY Region, count DESC;


#Compare lead, bacteria, or nitrate levels to disease prevalence:
SELECT Country, 
	ROUND(AVG(`Lead Concentration (Âµg/L)`), 1) AS avg_lead,
	ROUND(AVG(`Cholera Cases per 100,000 people`), 1) AS avg_cholera
FROM water_pollution_disease
GROUP BY Country
ORDER BY avg_lead DESC;
#RESULT - high lead concentration in water also leads to high disease prevelance.


#Top 10 countries with highest infant mortality linked to water quality:
SELECT Country, 
	ROUND(AVG(`Infant Mortality Rate (per 1,000 live births)`), 1) AS avg_mortality,
	ROUND(AVG(`Access to Clean Water (% of Population)`), 1) AS access_rate
FROM water_pollution_disease
GROUP BY Country
ORDER BY avg_mortality DESC
LIMIT 10;


#Compare sanitation vs waterborne disease rates in each country:
SELECT Country,
       ROUND(AVG(`Sanitation Coverage (% of Population)`), 1) AS sanitation,
       ROUND(AVG(`Diarrheal Cases per 100,000 people`), 1) AS diarrhea
FROM water_pollution_disease
GROUP BY Country
ORDER BY sanitation;


#Urbanization vs pollution levels
SELECT Country,
       AVG(`Urbanization Rate (%)`) AS urban_rate,
       AVG(`Contaminant Level (ppm)`) AS pollution
FROM water_pollution_disease
GROUP BY Country
ORDER BY urban_rate DESC;

#Show how the global average access to clean water has changed year-over-year.
SELECT Year, 
	ROUND(AVG(`Access to Clean Water (% of Population)`), 1) AS avg_access
FROM water_pollution_disease
GROUP BY Year
ORDER BY Year DESC;


#Compare the average diarrheal disease cases across different water source types.
SELECT `Water Source Type`,
	ROUND(AVG(`Diarrheal Cases per 100,000 people`), 1) AS avg_diarrheal_cases
FROM water_pollution_disease
GROUP BY `Water Source Type`
ORDER BY avg_diarrheal_cases DESC
;


#List all regions where the average sanitation coverage is below 60%.
SELECT Region, 
	ROUND(AVG(`Sanitation Coverage (% of Population)`), 1) AS avg_sanitation_coverage
FROM water_pollution_disease
GROUP BY Region
HAVING avg_sanitation_coverage < 60
ORDER BY avg_sanitation_coverage DESC;


#For each country, show the top 3 years with the highest contaminant level.
#Let’s select what we care about first:
SELECT Country, Year, `Contaminant Level (ppm)`
FROM  water_pollution_disease;


#We want to assign a number to each row within each country, based on descending contaminant level

SELECT Country, Year, `Contaminant Level (ppm)`,
       RANK() OVER (
         PARTITION BY Country
         ORDER BY `Contaminant Level (ppm)` DESC
       ) AS ranks
FROM water_pollution_disease;

#Wrap it in a subquery and filter for top 3

SELECT *
FROM(
SELECT Country, Year, `Contaminant Level (ppm)`,
       RANK() OVER (
         PARTITION BY Country
         ORDER BY `Contaminant Level (ppm)` DESC
       ) AS ranks
     FROM water_pollution_disease) AS rank_table
     WHERE ranks <= 3
     ORDER BY Country, ranks;
     
#Which country has shown the greatest improvement in access to clean water from the earliest to the most recent year?

#Step 1: Understand the Goal- The first year’s clean water value for each country, the most recent year’s clean water value for each country, 
#Then: subtract the first from the last → that gives us the improvement.

#Step 2: Get the first value per country
#we will create a subquery and use ROW_NUMBER() to get the earliest year per country:

SELECT Country,
       Year AS first_year,
       `Access to Clean Water (% of Population)` AS first_access
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Year ASC) AS rn
  FROM water_pollution_disease
) AS ranked_first
WHERE rn = 1;

#Step 3: Get the most recent value per country
#Do the same but now ORDER BY Year DESC

SELECT Country,
       Year AS last_year,
       `Access to Clean Water (% of Population)` AS last_access
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Year DESC) AS rn
  FROM water_pollution_disease
) AS ranked_last
WHERE rn = 1;


#We’ll now use a CTE (Common Table Expression) to combine them and calculate the improvement:

WITH first_access AS (
  SELECT Country, 
         Year AS first_year,
         `Access to Clean Water (% of Population)` AS first_access
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Year ASC) AS rn
    FROM water_pollution_disease
  ) AS ranked
  WHERE rn = 1
),
last_access AS (
  SELECT Country, 
         Year AS last_year,
         `Access to Clean Water (% of Population)` AS last_access
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Year DESC) AS rn
    FROM water_pollution_disease
  ) AS ranked
  WHERE rn = 1
)

SELECT f.Country,
       f.first_year,
       l.last_year,
       ROUND(l.last_access - f.first_access, 1) AS improvement
FROM first_access f
JOIN last_access l ON f.Country = l.Country
ORDER BY improvement DESC;


#Which regions had the highest average number of cholera cases in years where access to clean water was below 70%?

SELECT Region,
	ROUND(AVG(`Cholera Cases per 100,000 people`), 1) AS avg_cholera_cases
FROM water_pollution_disease
WHERE `Access to Clean Water (% of Population)` < 70
GROUP BY Region
ORDER BY avg_cholera_cases DESC;

#In which year was the overall contaminant level the highest, and what was the average contaminant level that year?

SELECT Year,
	ROUND(AVG(`Contaminant Level (ppm)`), 2) AS avg_containment_level
FROM water_pollution_disease
GROUP BY Year
ORDER BY avg_containment_level DESC
LIMIT 1;

#Which countries have had an average access to clean water above 90% across all recorded years?

SELECT Country,
       ROUND(AVG(`Access to Clean Water (% of Population)`), 1) AS avg_access
FROM water_pollution_disease
GROUP BY Country
HAVING avg_access > 90
ORDER BY avg_access DESC;

#Regional Improvement Rankings
#Which region showed the greatest improvement in access to clean water between the earliest and latest years available?

WITH first_year AS (
  SELECT Region,
         Year AS first_year,
         `Access to Clean Water (% of Population)` AS first_access,
         ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Year ASC) AS rn
  FROM water_pollution_disease
),
last_year AS (
  SELECT Region,
         Year AS last_year,
         `Access to Clean Water (% of Population)` AS last_access,
         ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Year DESC) AS rn
  FROM water_pollution_disease
),
earliest AS (
  SELECT Region, first_year, first_access
  FROM first_year
  WHERE rn = 1
),
latest AS (
  SELECT Region, last_year, last_access
  FROM last_year
  WHERE rn = 1
)

SELECT e.Region,
       e.first_year,
       l.last_year,
       ROUND(l.last_access - e.first_access, 1) AS improvement
FROM earliest e
JOIN latest l ON e.Region = l.Region
ORDER BY improvement DESC;


