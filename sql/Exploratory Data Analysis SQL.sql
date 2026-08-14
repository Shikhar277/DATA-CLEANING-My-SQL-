-- EXPLORATORY DATA ANALYSIS
SELECT * 
FROM layoffs_staging2;

-- overall view
SELECT max(total_laid_off) as `Maximum`,
min(total_laid_off) as `Minimum `,
avg(total_laid_off) as `Average`,
sum(total_laid_off) as `Total`,
count(distinct company) as ` no. of companies`
FROM layoffs_staging2;

-- Industry wise classification data
SELECT count(distinct industry) as `Total industries`
FROM layoffs_staging2;

SELECT industry,sum(total_laid_off) as Total_Laid_off, (sum(total_laid_off) / ( SELECT sum(total_laid_off) FROM layoffs_staging2 ) * 100) as Percentage_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY Total_Laid_off desc;


-- company wise layoff
SELECT count(distinct company) as `Total companies`
FROM layoffs_staging2;

SELECT company,sum(total_laid_off) as Total_Laid_off, (sum(total_laid_off) / ( SELECT sum(total_laid_off) FROM layoffs_staging2 ) * 100) as Percentage_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY Total_Laid_off desc;

-- country wise layoff

SELECT country,sum(total_laid_off) as Total_Laid_off, (sum(total_laid_off) / ( SELECT sum(total_laid_off) FROM layoffs_staging2 ) * 100) as Percentage_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY Total_Laid_off desc;

-- year wise layoff

SELECT YEAR(`date`),sum(total_laid_off) as Total_Laid_off, (sum(total_laid_off) / ( SELECT sum(total_laid_off) FROM layoffs_staging2 ) * 100) as Percentage_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 desc;


-- stage wise layoff

SELECT stage,sum(total_laid_off) as Total_Laid_off, (sum(total_laid_off) / ( SELECT sum(total_laid_off) FROM layoffs_staging2 ) * 100) as Percentage_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY Total_Laid_off desc;

-- monthly grouping
WITH rolling_total as
(
SELECT substring(`date`,1,7) as `Month` , SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) is not null
Group by `Month`
Order by 1 asc
)
SELECT `Month` , total_off, sum(total_off) OVER(order by `Month`) as rolling_sum
FROM rolling_total;


-- YEARLY LAID OFF OF COMAPNIES
WITH yearly_data as
(
SELECT company , YEAR(`date`) as `Year`, SUM(total_laid_off) as total
FROM layoffs_staging2
GROUP BY company,`Year`
),
 Company_rank as
(
SELECT *,
DENSE_RANK() over(partition by `Year` order by total desc) as `rank`
FROM yearly_data
WHERE total is not null and year is not null 
)
SELECT *
FROM  Company_rank
where `rank` <=5;


-- Layoffs by funding bracket (funds_raised_millions)
SELECT
  CASE
    WHEN funds_raised_millions IS NULL THEN 'Unknown'
    WHEN funds_raised_millions = 0 THEN '0'
    WHEN funds_raised_millions BETWEEN 1 AND 10 THEN '1-10M'
    WHEN funds_raised_millions BETWEEN 11 AND 50 THEN '11-50M'
    WHEN funds_raised_millions BETWEEN 51 AND 200 THEN '51-200M'
    ELSE '>200M'
  END AS funding_bracket,
  SUM(IFNULL(total_laid_off,0)) AS total_laid_off,
  ROUND(
    SUM(IFNULL(total_laid_off,0)) /
    NULLIF((SELECT SUM(IFNULL(total_laid_off,0)) FROM layoffs_staging2),0) * 100
  ,2) AS pct_of_total_laid_off,
  ROUND(
    AVG(CAST(NULLIF(REPLACE(percentage_laid_off, '%', ''), '') AS DECIMAL(5,2)))
  ,2) AS avg_pct_laid_off
FROM layoffs_staging2
GROUP BY funding_bracket
ORDER BY total_laid_off DESC;
