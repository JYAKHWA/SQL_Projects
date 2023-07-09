
USE Indian_Census_Analysis;

SELECT * FROM Indian_Census_Analysis.dbo.Data1;
SELECT * FROM Indian_Census_Analysis.dbo.Data2;


--Check rows in dataset--
SELECT COUNT(*) FROM Indian_Census_Analysis..Data1;
SELECT COUNT(*) FROM Indian_Census_Analysis..Data2;

--Look into data for Bihar and Jharkhand--
SELECT * FROM Data1 
WHERE State IN ('Bihar', 'Jharkhand');

--Lets look the total Population of India--
SELECT SUM(Population) AS 'Total Population' FROM Data2;

-- Look into Average Growth Percent--
SELECT AVG(Growth)*100  'Average Growth Percent' FROM Data1;

--Look Average Growth by State--
SELECT State, AVG(Growth)*100 AS 'Average Growth per State' FROM Data1
GROUP BY State
ORDER BY  'Average Growth per State' DESC;

--calculate Average sex ratio by state

SELECT State, ROUND(AVG(Sex_Ratio), 0) 'Average Sex Ratio per State' FROM Data1
GROUP BY State
ORDER BY 'Average Sex Ratio per State' DESC;

--identify  top 5 states with average literacy greater than 70--
SELECT TOP 5 State, ROUND(AVG(Literacy), 0) AS 'Average Literacy Rate' FROM Data1
GROUP BY State
HAVING ROUND(AVG(Literacy), 0) >70
ORDER BY 'Average Literacy Rate' DESC;

--top 5 states with the lowest sex  ratio--
SELECT TOP 5 State, ROUND(AVG(Sex_Ratio), 0) AS 'Average Sex Ratio' FROM Data1
GROUP BY State
ORDER BY 'Average Sex Ratio';

 --show top 5 most literacy rate and lowest literacy rate per state in the same table--
 DROP TABLE IF EXISTS #top_states_literacy;
 --top5---
 CREATE TABLE #top_states_literacy
 (State NVARCHAR (100),
 TopStates FLOAT );

INSERT INTO #top_states_literacy 
SELECT TOP 5 State, ROUND(AVG(Literacy), 0) AS 'Average Literacy Rate' FROM Data1
GROUP BY State
HAVING ROUND(AVG(Literacy), 0) >70
ORDER BY 'Average Literacy Rate' DESC;

SELECT * FROM #top_states_literacy;

--bottom 5---
 DROP TABLE IF EXISTS #bottom_states_literacy;

 CREATE TABLE #bottom_states_literacy
 (State NVARCHAR (100),
 BottomStates FLOAT );

INSERT INTO #bottom_states_literacy 
SELECT TOP 5 State, ROUND(AVG(Literacy), 0) AS 'Average Literacy Rate' FROM Data1
GROUP BY State
ORDER BY 'Average Literacy Rate';

SELECT * FROM #bottom_states_literacy;

--UNION to join 2 temp tables--
SELECT * FROM #top_states_literacy
UNION
SELECT * FROM #bottom_states_literacy;

--states with letter A, B or S --
SELECT DISTINCT State FROM Data1
WHERE State LIKE 'A%' OR State LIKE 'B%' OR State LIKE 'S%';


-----FIND THE TOTAL MALES AND FEMALES PER STATE----
--Statistical Calculation for males and females--
/** sex_ratio = females/males          eq.1
	population = males + females		eq.2
	females = population - males			eq.3
	from eq.1 & eq2.
	population - males = sex_ratio * males
	ie. population = sex_ratio * males + males
	ie. population = males (sex_ratio + 1)
	ie. males = population / (sex_ration + 1)		eq.4    ---------------------males

	from eq.3 & eq.4
	females = population - (population / (sex_ratio + 1) )	---------taking common
	ie. females = population (1 - 1 / (sex_ratio + 1) )
				= (population * (sex_ratio)) / (sex_ratio + 1)

**/ ------------------------JOINS----------------------------

SELECT d.State, SUM (d.Males) AS 'Total Males', SUM (d.Females) AS 'Total Females' 
FROM
	(SELECT d3.District, d3.State, ROUND(d3.Population / (d3.Sex_Ratio + 1), 0) AS 'Males', ROUND((d3.Population * d3.Sex_Ratio) / (d3.Sex_Ratio + 1), 0) AS 'Females' 
	FROM
		(SELECT d1.District, d1.State, d1.Sex_Ratio/1000 AS 'Sex_Ratio', d2.Population 
		FROM Data1 d1
		JOIN Data2 d2 ON d1.District = d2.District) d3) d
GROUP BY d.State;

---Total literate and illeterate rate by State by Population---

/* literacy_ratio = literate_people / population
	literate_people = literacy_ratio * population
	illiterate_People = (1-literacy_ratio) * population    */
SELECT t.State, SUM(t.[Literate People] ) AS 'Total_Literate_People', SUM(t.[Illiterate People] ) AS 'Total_Illiterate_People' 
FROM
	(SELECT d.District, d.State, ROUND(Literacy_Ratio * d.Population, 0) as 'Literate People', ROUND((1-d.Literacy_Ratio)* d.Population, 0) AS 'Illiterate People' 
	FROM
		(SELECT d1.District, d1.State, d1.Literacy/100 AS 'Literacy_Ratio', d2.Population 
		FROM Data1 d1
		JOIN Data2 d2 ON d1.District = d2.District) d) t
GROUP BY t.State;

--What the population growth number from previous census?---

/* curr_population = previous_population + (Growth * previous_population)
	curr_population = pre_population * (1 + growth)
	pre_population = curr_population / (1 + growth)------------------pre_population (we didive by 100 since growth percent is in 100)
*/
SELECT P.State, P.Growth_Percent AS 'Growth_Percent', P.Current_Population, ROUND(P.Current_Population/(1 + P.Growth_Percent),0) AS 'Previous_Population', ROUND(P.Current_Population - (P.Current_Population/(1 + P.Growth_Percent)),0) AS 'Total_Growth' 
FROM
	(SELECT d1.District, d1.State, d1.Growth AS 'Growth_Percent', d2.Population AS 'Current_Population' 
	FROM Data1 d1
	JOIN Data2 d2 ON d1.District = d2.District) P;


		SELECT P.State, P.Growth_Percent AS 'Growth_Percent', P.Current_Population, ROUND(P.Current_Population/(1 + P.Growth_Percent),0) AS 'Previous_Population', ROUND(P.Current_Population - (P.Current_Population/(1 + P.Growth_Percent)),0) AS 'Total_Growth' 
		FROM
			(SELECT d1.District, d1.State, d1.Growth AS 'Growth_Percent', d2.Population AS 'Current_Population' 
			FROM Data1 d1
			JOIN Data2 d2 ON d1.District = d2.District) P 













