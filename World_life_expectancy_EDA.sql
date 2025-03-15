#we are going to conduct exploratory data analysis 

#there are 2 parts of EDA.  First part goes with data cleaning where we do counts, group by, to see if there are parts that need to be fixed.

#the second part of the EDA process is where we try and find patterns, insights and trends in the datat and use this info in the future.

#we will start by looking at the life expectancy of each country over the years, we will look at the lowest to the highest  life expectancies.alter

SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`)
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Country DESC;

#some countries like Zimbabwe have really improved their life expectancy over the past 15 years. Zambia included.
#we can also check the Life expectancy increase over the past 15 years and see how it went in each country:

SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC;

#Haiti has the highest life expectancy increase over the past 15 years.
#we can also check the country with the lowest life expectancy increase:



SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years ASC;

#apart from the litle life expectancy increase, age also plays a part in how far the life expectancy will go.


#next we shall look at correlations. i.e How is life expectancy corelating to all the other outliers in the data.

#For instance, how does the average GDP and and average life expectancy work per country?


SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC;


#The higher the gdp the higher th elife expectancy of the country

#we can also check the corelation between BMI and life expectancy


SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC;

#The BMI and life expectancy tend to have a positive corelation  but we need to go deeper into the data and find out why.



