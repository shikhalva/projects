-- DATA CLEANING

-- Step 1: Inspecting the Data

SELECT *
FROM layoffs;

-- This retrieves all records from the layoffs table, to get an initial understanding of the dataset.

-- 1) Remove Duplicates
-- 2) Standardise the data
-- 3) Null or blank values
-- 4) Remove any columns if necessary

-- Step 2: Creating a Staging Table  Purpose: To work on a duplicate version of the data without modifying the original.

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Copying all data from layoffs to layoffs_staging, to have a backup of the original data.

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Step 3: Identifying Duplicates  Used ROW_NUMBER() to assign a unique row number to duplicate records based on key columns

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- This Common Table Expression (CTE) assigns a row number to each record where values match across multiple columns helping in identifying exact duplicate records for removal.
	
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Step 4: Creating a New Staging Table for Cleaning

 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- This new table (layoffs_staging2) has the same structure as layoffs_staging, but with an additional row_num column for duplicate tracking, Ensuring a structured approach to cleaning

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 0;

-- Step 5: Removing Duplicates, Cleans the dataset by keeping only the first occurrence of each duplicate.

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM layoffs_staging2;

-- STANDARDISING THE DATA

-- Trimming Extra Spaces,  ensuring consistency in text fields

 SELECT company, TRIM(company)
 FROM layoffs_staging2;
 
 UPDATE layoffs_staging2
 SET company = TRIM(company);

-- Fixing Industry Names

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Standardizing industry names like "Crypto Tech" to "Crypto" to prevent duplicate categories.

SELECT *
FROM layoffs_staging2
WHERE industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


 SELECT DISTINCT industry
 FROM layoffs_staging2;
 
 SELECT DISTINCT location
 FROM layoffs_staging2
 ORDER BY 1;

-- Fixing Country Names

 SELECT country
 FROM layoffs_staging2
 ORDER BY 1;
 
 SELECT *
 FROM layoffs_staging
 WHERE country LIKE 'United States%'
 ORDER BY 1;
 
 SELECT DISTINCT country , TRIM(country)
 FROM layoffs_staging2
 ORDER BY 1;

-- Removing unnecessary trailing periods from country names.
 
 SELECT DISTINCT country , TRIM( TRAILING '.' FROM country)
 FROM layoffs_staging2
 ORDER BY 1;

 UPDATE layoffs_staging2
 SET country = TRIM(TRAILING '.' FROM country)
 WHERE country LIKE 'United States%';
 
 SELECT *
FROM layoffs_staging2;

--Step 7: Converting Date Format  , Converting string dates to proper date format.

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); 	

SELECT `date`
FROM layoffs_staging2;

-- Ensures that date is stored in DATE format.

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 8: Handling Missing Values

-- Identifies missing industry values.

 SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'; 

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


SELECT t1.industry , t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Fills missing industry values by matching companies with known values.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';


SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Removes rows where both layoff columns are missing.

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

--Step 13: Final Cleanup

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Removes the row_num column since duplicates have already been eliminated.














 
 
 
