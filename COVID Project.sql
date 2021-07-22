SELECT * FROM Covid..COVIDdata ORDER BY 3,1
SELECT * FROM Covid..vaccinationdata 
SELECT * FROM Covid..populationbycountry


-- Total Cases vs Total Deaths and Death Percentage (w.r.t. total infected) of each country
SELECT Country, SUM(New_Cases) AS total_cases, SUM(New_deaths) AS total_deaths, ((SUM(New_deaths)*100.0)/SUM(New_cases)) AS Death_percentage
FROM Covid..COVIDdata  
GROUP BY Country
HAVING SUM(New_cases)<>0
ORDER BY 2 DESC


-- Top 10 worstly affected Countries with Maximum number of Cases
SELECT TOP(10) Country, SUM(New_cases) AS total_cases
FROM Covid..COVIDdata
GROUP BY Country
ORDER BY total_cases DESC


-- 10 countries with most number of deaths
SELECT TOP(10) Country, SUM(New_deaths) AS total_deaths
FROM Covid..COVIDdata
GROUP BY Country
ORDER BY total_deaths DESC


-- 10 countries with worst death percentage (w.r.t. to total infected in the country)
SELECT TOP(10) Country, ((SUM(New_deaths)*100.0)/SUM(New_cases)) AS Death_percentage
FROM Covid..COVIDdata
GROUP BY Country
HAVING SUM(New_cases)<>0
ORDER BY Death_percentage DESC


-- Percentage Population Infected or Died due to covid in each country
SELECT ttt.Country, Population, (ttt.total_cases*100.0)/Population AS PercentagePopulationInfected, 
(ttt.total_deaths*100.0)/Population AS PercentagePopulationDied 
FROM
(SELECT Country, SUM(New_cases) AS total_cases, SUM(New_deaths) AS total_deaths FROM Covid..COVIDdata GROUP BY Country) ttt INNER JOIN
Covid..populationbycountry
ON ttt.Country=populationbycountry.COUNTRY
ORDER BY 2 DESC


-- Creating temp table Top 10 countries having largest number of cases recorded in a single day
DROP TABLE IF EXISTS #temptable
CREATE TABLE #temptable (Country varchar(250), max_cases_peak float)
INSERT INTO #temptable
SELECT TOP(10) Country, MAX(New_cases) AS max_cases_peak
FROM Covid..COVIDdata
GROUP BY Country
ORDER BY max_cases_peak DESC


-- Top 10 countries having largest number of cases recorder in a single day (Temp Table)
SELECT * FROM #temptable


-- Top 10 countries having largest number of cases recorder in a single day with the date on which it was reported (USING #temptable)
SELECT #temptable.Country, #temptable.max_cases_peak, Date_reported
FROM Covid..COVIDdata INNER JOIN #temptable 
ON Covid..COVIDdata.Country=#temptable.Country AND COVIDdata.New_cases=#temptable.max_cases_peak
ORDER BY 2 DESC


-- Percentage Population Vaccinated, Partially and Fully, and Vaccines Administered per 100 population
SELECT vaccinationdata.Country, Population, ttt.total_cases AS TotalCases, PERSONS_VACCINATED_1PLUS_DOSE_PER100 AS [PercentageVaccinated1+dose],
PERSONS_FULLY_VACCINATED_PER100 AS PercentageFullyVaccinated, TOTAL_VACCINATIONS_PER100 AS VaccinationGivenPer100
FROM
(SELECT Country, SUM(New_cases) AS total_cases FROM Covid..COVIDdata GROUP BY Country) ttt
INNER JOIN
Covid..vaccinationdata
ON ttt.Country=vaccinationdata.COUNTRY
INNER JOIN Covid..populationbycountry
ON ttt.Country=populationbycountry.Country
ORDER BY 3 DESC


-- What vaccines are available in each country (Splitting comma separated values in column)
SELECT COUNTRY, cs.VALUE AS vaccine
FROM Covid..vaccinationdata
cross apply STRING_SPLIT (VACCINES_USED, ',') cs


-- To get which countries use a particular vaccine (Using Common Table Expression (CTE))
WITH vaccinetable AS
(
SELECT COUNTRY, cs.Value AS vaccine
FROM Covid..vaccinationdata
cross apply STRING_SPLIT (VACCINES_USED, ',') cs
)
SELECT * FROM vaccinetable 
WHERE vaccine like '%Sputnik%'

