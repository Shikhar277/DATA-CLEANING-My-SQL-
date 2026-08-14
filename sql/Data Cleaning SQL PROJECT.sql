-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data (issues with spellings)
-- 3. Null or blank values
-- 4. Remove any unnecessary column or row

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- 1 .) Remove Duplicates -----------------------------------------------------------------------------------------

WITH cte as
(
   SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
   FROM layoffs_staging
)
SELECT *
FROM CTE
WHERE row_num>1;

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE not row_num>1;

INSERT INTO layoffs_staging2
 SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
   FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num>1;

-- 2,3 and 4 .) Standardising Data(spellings,whitespaces,date format etc.) -----------------------------------------------------------------------------------------
-- Trimming
UPDATE layoffs_staging2
SET company=trim(company);

SELECT *
FROM layoffs_staging2;

SELECT DISTINCT industry
FROM layoffs_staging2 order by 1;

UPDATE layoffs_staging2
SET	 industry = "Crypto"
WHERE industry LIKE "Crypto%";

SELECT DISTINCT country
FROM layoffs_staging2 order by 1;


UPDATE layoffs_staging2
SET	 country = trim(trailing '.' FROM country)
WHERE country LIKE "United States%";

-- for date change
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- null and blank values

UPDATE layoffs_staging2
SET industry=null
WHERE  industry='';


SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company=t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL; 


SELECT *
FROM layoffs_staging2
WHERE total_laid_off is null and percentage_laid_off is null;

ALTER TABLE layoffs_staging2
DROP row_num;

SELECT *
FROM layoffs_staging2
ORDER BY company;