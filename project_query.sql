#Data cleaning project

-- 1.Remove duplicates
-- 2.Standardize data 
-- 3.Null values or blank values
-- 4.Remove any columns



SELECT *
FROM layoffs;

CREATE TABLE layoffs_stg
LIKE layoffs;


INSERT layoffs_stg
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_stg;


-- 1.Remove duplicates
SELECT * 
FROM layoffs_stg;


SELECT * ,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stg;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stg
)
SELECT *
FROM duplicate_cte
ORDER BY row_num > 1;

SELECT *
FROM layoffs_stagging
WHERE company = 'casper';


-- In mysql you can't delete the duplicates in the cte because you cannot update a statement and deleting is an update 


CREATE TABLE `layoffs2` (
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


INSERT INTO layoffs2
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stg;

SELECT *
FROM layoffs2;

DELETE
FROM layoffs2
WHERE row_num > 1;

SELECT *
FROM layoffs2
WHERE row_num > 1;


-- Standardizing data 

SELECT company, TRIM(company)
FROM layoffs2;

UPDATE layoffs2
SET company = TRIM(company);

SELECT DISTINCT industry 
FROM layoffs2
ORDER BY 1;

SELECT *
FROM layoffs2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs2
SET industry = 'Crypto'
WHERE industry LIKE  'Crypto%';

SELECT DISTINCT country
FROM layoffs2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs2
WHERE country LIKE 'United states%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs2
ORDER BY 1;

UPDATE layoffs2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs2;

UPDATE layoffs2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs2;


ALTER TABLE layoffs2
MODIFY COLUMN `date` DATE;


-- Null values or blank values

SELECT *
FROM layoffs2
WHERE company LIKE 'Juul';
;

SELECT *
FROM layoffs2
WHERE company IS NULL;

UPDATE layoffs2 
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs2 t1
JOIN layoffs2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;



UPDATE layoffs2 t1
JOIN layoffs2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;




-- REMOVE COLUMNS 



SELECT *
FROM layoffs2;


ALTER TABLE layoffs2
DROP COLUMN row_num;
