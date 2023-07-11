-- COVID DATA EXPLORATION --

USE COVID_Analysis;

SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

-------------------- Select data to use------------
SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

--- Death chances in Nepal vs US (likelihhod of death) ---
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 'Death Percent' 
FROM CovidDeaths
WHERE location = 'Nepal'
ORDER BY 1, 2;				------ Total Death Percent is 1%---

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 'Death Percent' 
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;				------ Total Death Percent is 1.78%---


--- Total Cases VS Population (Cases by Population)----
--- % of people with COVID---
SELECT location, date, population, total_cases, (total_cases / population) * 100 'Case_Percent_by_Population' 
FROM CovidDeaths
WHERE location = 'Nepal'
ORDER BY 1, 2;            --- Nepal has about 1% population with COVID by April, 2021 (3279)--

SELECT location, date, population, total_cases, (total_cases / population) * 100 'Case_Percent_by_Population' 
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;           ---US has about 10% population with COVID by April, 2021 (576232 death)--


/* Identified  total cases by population in Nepal is 1% and US is 10%. However, death percent is close. Nepal has 1% from the cases while US has 1.78%.
Clearly, the huge population in the US increased the total cases by population, while death in Nepal seems devastating although having too less population.  */


--- Lets find the country with the infection compared to population in the world. ----
SELECT location, population, MAX (total_cases) AS 'Highest_COVID_Count', MAX ((total_cases / population)) * 100 AS 'Max_Case_Percent'
FROM CovidDeaths
GROUP BY location, population
ORDER BY Max_Case_Percent DESC;		---Andorra has the highest case percent, 17.13% followed by 15% in Montenegro and Czechia---

---Lets see the countries with the highest death per population by continent---
SELECT continent, MAX (CAST(total_deaths AS int)) AS 'Highest_Death_Count'			--CAST to int, as data type is NVARCHAR in table, cannot give acccurate data--
FROM CovidDeaths
WHERE continent IS NOT NULL					---where added as there are 2 locations and continents where the values are mixed in table, and continet given null if location given
GROUP BY continent
ORDER BY Highest_Death_Count DESC;			---US has the highest number, followed by Brazil, Mexico, India, etc. by location if selected by location whre continet is not null---

/* With continents, North America had the most (576232) foloowed by South America (403781), Asia (212853), Europe (127775). Africa (54350) & Oceania (910).   */






























