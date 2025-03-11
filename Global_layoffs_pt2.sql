-- EDA EXPLORATORY DATA ANALYSIS

--1. Retrieving All Data

SELECT *
FROM layoffs_staging2;

-- To identify the largest layoffs in absolute and percentage terms.

SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM layoffs_staging2;

--3. Companies That Laid Off 100% of Their Employees

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

--4. Sorting 100% Layoffs by Funds Raised

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

--5. Total Layoffs per Company

SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

--6. Date Range of Layoffs

SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2;

-- 7. Total Layoffs by Industry

SELECT industry , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2;

--Total Layoffs by Country

SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC; 

--Total Layoffs Per Year

SELECT YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

--10. Total Layoffs by Company Growth Stage

SELECT stage , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC; 

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

--These queries provide insights into:

--The biggest layoffs in terms of numbers and percentages.
--Trends over time (yearly and monthly).
--Industry-wise and country-wise analysis.
--The effect of funding and company stage on layoffs.
--Ranking of companies by layoffs.










