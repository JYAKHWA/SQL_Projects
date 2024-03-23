
		/*			This is a complete SQL Data Analysis Case Study
								PURPOSE OF ANALYSIS: 
					1. HR wants a list of Healthy Individuals & Low Absenteeism for Healthy Bonus Program (Total Budget - $1000)
					2. Calculate wage increase or Annual Compensation for Non-Smokers (Insurance Budget - $ 983,221 for all Non-Smokers
					3. Dashboard with KPIs to understand Absenteeism based on wireframe approved.		*/


--Use HR Database--
USE HR_Employee_Compensation_Analysis;


--Create the join table on common columns--
SELECT * FROM Absenteeism Absn
LEFT JOIN Compensation Comp
ON Absn.ID = Comp.ID
LEFT JOIN Reasons Rsn
ON Absn.Reason_for_absence = Rsn.Number;


--List of top healthiest Employees for the Bonus. As HR hasn't specified healthy criteria, 
	--I assume someone who does not smoke or drink and body_mass_index (BMI) between 19 and 25. BMI range from Google. Third criteria age below 50.
	--Final condition - Absent hours is less than total average.
SELECT ID, Age, Hit_target,Body_mass_index, Absenteeism_time_in_hours FROM Absenteeism
WHERE Social_drinker = 0 AND Social_smoker = 0 AND 
	(Body_mass_index BETWEEN 19 AND 25) AND
	Age < 50 AND
	Absenteeism_time_in_hours < (SELECT AVG(Absenteeism_time_in_hours) FROM Absenteeism)
ORDER BY ID;


--Calculation of compensation_rate increase for the Non-Smokers.
SELECT COUNT(*) AS 'Total Non-Smokers' FROM Absenteeism
WHERE Social_smoker = 0;								--returns total 686

-- The increase is now calculated by non-smokers/budget(983221). Total yearly hour = 5Days* 8hrs* 52Weeks = 2080
-- Thus, total amount = 2080*686 = 1426880. Now, increase = 983221/1426880 = 0.68 per hour increase. In a Year it is = 2080*0.68 = 1414.40 per yr


--Optimize for Dashboard and further analysis on Power BI
