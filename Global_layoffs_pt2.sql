-- EDA EXPLORATORY DATA ANALYSIS

--1. Retrieving All Data

SELECT *
FROM layoffs_staging2;

-- To identify the largest layoffs in absolute and percentage terms.

SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Maximum of 12000 people were laid off in one go as 100% of the comapny was dissolved.

--3. Companies That Laid Off 100% of Their Employees

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- 116 companies dissolved completely and kattera a construction based company laid off the highest of 2434 employees.

--4. Sorting 100% Layoffs by Funds Raised

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Britishvolt a london based transportation company with a funding of 2400 million shut down followed by Quibi LA and delivroo aus.

--5. Total Layoffs per Company

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

--Amazon,Google ,Meta are the top three comapnies to have highest lay offs overall 

--6. Date Range of Layoffs

SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2;

-- These layoffs seem to have started from 11/3/2020 to 6/3/2023

-- 7. Total Layoffs by Industry

SELECT industry , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Consumer and retail industries were hit the most followed by transportation

SELECT *
FROM layoffs_staging2;

--Total Layoffs by Country

SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC; 

--US, India and the Netherlands had the most layoffs

--Total Layoffs Per Year

SELECT YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

--2023 has the highest number of layoffs according to our dataset.

--10. Total Layoffs by Company Growth Stage

SELECT stage , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC; 

-- most layoffs are from post-ipo companies followed by acquired and series c stages.

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

--11. Extracting the Month from the Date

SELECT SUBSTRING(`date`,6,2) AS `MONTH`
FROM layoffs_staging2;

--12. Monthly Layoffs Trend

SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH` 
ORDER BY 1 ASC;

--13. Rolling Total of Layoffs

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH` 
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Layoffs started with a total of 9628 by the end of 2020 we had around 81000, 2021 - 97000 people were let go 
-- 2023 - 247153

--14. Layoffs Per Year Per Company

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company , YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY company ASC;

--15. Top 5 Companies with Most Layoffs Per Year

WITH Company_year (Company , Years , total_laid_off) AS
(
SELECT company , YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
) , Company_Year_Rank AS
(SELECT * ,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;

--Uber ,Booking.com, Groupon, Swiggy, Airbnb - top 5 comapnies to layoff in 2020
--Bytedance, Katerra, Instacart, WhiteHat Jr - 2021
--Meta, Amazon, Cisco, Peloton, Carvana, Philips - 2022
--Google, Microsoft, Ericsson, Amazon, Dell - 2023

--These queries provide insights into:

--The biggest layoffs in terms of numbers and percentages.
--Trends over time (yearly and monthly).
--Industry-wise and country-wise analysis.
--The effect of funding and company stage on layoffs.
--Ranking of companies by layoffs.










