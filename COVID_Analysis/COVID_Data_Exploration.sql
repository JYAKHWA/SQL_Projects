-- COVID DATA EXPLORATION --

/* This project explores the COVID Data in the world, in terms of number of cases, vaccinations, population, location, continent, deaths, etc.
	It has also a basic comparison of total cases, deaths, death and case percent comparison between Nepal and the United States.
	The project focuses on applying Aggregate Functions,  Group By, Order By, Having, Partition By, Temp_Tables, CTE, VIEW, JOINS, etc.
	*/


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
SELECT continent, MAX (CAST(total_deaths AS int)) AS 'Total_Death_Count'			--CAST to int, as data type is NVARCHAR in table, cannot give acccurate data--
FROM CovidDeaths
WHERE continent IS NOT NULL		---where added as there are 2 locations and continents where the values are mixed in table, and continet given null if location given
GROUP BY continent
ORDER BY Total_Death_Count DESC;	---US has the highest number, followed by Brazil, Mexico, India, etc. by location if selected by location whre continet is not null---

/* With continents, North America had the most (576232) foloowed by South America (403781), Asia (212853), Europe (127775). Africa (54350) & Oceania (910).   */


----GLOBAL DATA EXPLORATION ----

 --lets look at total-cases, death and death percent in the world in respect to date
 SELECT SUM (new_cases) AS 'Total_New_Case', SUM (CAST(new_deaths AS int)) AS 'Total_New_Death',
		SUM (CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS 'Death Percent'
 FROM CovidDeaths
 WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;		--- In the world, total death precent is 2.11%


/*---------------- Joining two tables --------------------------- */

--- see the total population and new vaccinations---
SELECT dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations, 
SUM (CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS 'Vaccinated_People'
FROM CovidDeaths dth
JOIN CovidVaccinations vacc
	ON dth.location = vacc.location
	AND dth.date = vacc.date
WHERE dth.continent IS NOT NULL
ORDER BY 2, 3;

------------------------------USE CTE (need CTE as we cant use a column we created)-------------------------

WITH PopVsVacc (continent, location, date, population, New_Vaccinations, Vaccinated_People)
AS
(
SELECT dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations, 
SUM (CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS 'Vaccinated_People'
FROM CovidDeaths dth
JOIN CovidVaccinations vacc
	ON dth.location = vacc.location
	AND dth.date = vacc.date
WHERE dth.continent IS NOT NULL
)
SELECT * , (Vaccinated_People/ population) * 100 AS 'Vaccinated_Percent'
FROM PopVsVacc;


------------------------------USE TEMP TABLE for the same work---------------------------------------------------------
DROP TABLE IF EXISTS #vaccinated_percent_people;

CREATE TABLE #vaccinated_percent_people
( continet NVARCHAR (255),
	location NVARCHAR (255),
	date DATETIME,
	population NUMERIC,
	New_Vaccinations NUMERIC,
	Vaccinated_People NUMERIC
);

INSERT INTO #vaccinated_percent_people 
	SELECT dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations, 
	SUM (CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS 'Vaccinated_People'
	FROM CovidDeaths dth
		JOIN CovidVaccinations vacc
		ON dth.location = vacc.location
		AND dth.date = vacc.date
	WHERE dth.continent IS NOT NULL

SELECT * , (Vaccinated_People/ population) * 100 AS 'Vaccinated_Percent'
FROM #vaccinated_percent_people;

----------------------CREATE VIEWS (store data)--------------------------------------------------

CREATE VIEW vaccinated_percent_people AS
	SELECT dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations, 
	SUM (CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS 'Vaccinated_People'
	FROM CovidDeaths dth
		JOIN CovidVaccinations vacc
		ON dth.location = vacc.location
		AND dth.date = vacc.date
	WHERE dth.continent IS NOT NULL


SELECT * FROM vaccinated_percent_people;

---The views can be used as tables, for visualization in Power BI or Tableau. Tableau doesnt automatically connect to SQL database.------------




















