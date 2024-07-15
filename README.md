# SQL-Project-Bank-CRM
SELECT * FROM bank_churn;
SELECT * FROM customerinfo;
SELECT * FROM activecustomer;
SELECT * FROM creditcard;
SELECT * FROM exitcustomer;
SELECT * FROM gender;
SELECT * FROM geography;

-- 1.	What is the distribution of account balances across different regions?
SELECT geo.GeographyLocation, ROUND(SUM(bc.Balance),2) AS balances
FROM bank_churn bc
JOIN customerinfo ci USING (CustomerID)
JOIN geography geo USING (GeographyID)
GROUP BY geo.GeographyLocation ;

-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
SELECT *
FROM customerinfo
WHERE month(BankDOJ) IN (10,11,12)
ORDER BY EstimatedSalary DESC
LIMIT 5;

-- 3.	Calculate the average number of products used by customers who have a credit card. 
SELECT b.CustomerId, ROUND(AVG(NumOfProducts),0) As avg_products
FROM bank_churn b
LEFT JOIN  customerinfo c ON b.CustomerID = c.CustomerID
WHERE HasCrCard = 1
GROUP BY b.CustomerId;


-- 4.	Determine the churn rate by gender for the most recent year in the dataset.
SELECT g.GenderCategory,MAX(YEAR(BankDOJ)) AS recent_year, count(CustomerId) as no_of_customers
FROM customerinfo c
JOIN bank_churn b USING (CustomerID)
JOIN gender g USING (genderID)
GROUP BY g.GenderCategory;

-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT (CASE WHEN Exited = 1 THEN 'Exited' ELSE 'Remain'END ) AS exited_remain,
	    AVG(CreditScore) AS avg_creditscore
FROM bank_churn 
GROUP BY exited_remain;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
WITH active_avg_est_salary AS
	(SELECT g.GenderCategory AS gender, ROUND(AVG(c.EstimatedSalary),2) AS active_avg_est_salary 
	FROM customerinfo c
	JOIN bank_churn b USING (CustomerID)
	JOIN gender g USING (genderID)
	WHERE IsActiveMember = 1
	GROUP BY g.GenderCategory),
	inactive_avg_est_salary AS
    (SELECT g.GenderCategory AS gender, ROUND(AVG(c.EstimatedSalary),2) AS inactive_avg_est_salary 
	FROM customerinfo c
	JOIN bank_churn b USING (CustomerID)
	JOIN gender g USING (genderID)
	WHERE IsActiveMember = 0
	GROUP BY g.GenderCategory)
SELECT *
FROM active_avg_est_salary a
JOIN inactive_avg_est_salary i USING(gender);

-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
SELECT CASE WHEN CreditScore < 600 THEN 'Poor(Less Than 600)' 
            WHEN CreditScore >= 600 AND CreditScore < 700 THEN 'Fair(Between 600 And 700)' 
            WHEN CreditScore >= 700 AND  CreditScore < 800 THEN 'Good(Between 700 And 800)'
            ELSE 'Excellent(More than 800)'
            END AS segments, Count(Exited) As cnt_exited
FROM bank_churn
WHERE Exited = 1
GROUP BY segments
ORDER By cnt_exited DESC;

-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT g.GeographyLocation, Count(c.CustomerId) AS active_customers
FROM customerinfo c
JOIN geography g USING(GeographyID)
JOIN bank_churn b USING(CustomerID)
WHERE IsActiveMember = 1 AND Tenure >5
GROUP BY g.GeographyLocation;

-- 9.	What is the impact of having a credit card on customer churn, based on the available data?

-- 10.	For customers who have exited, what is the most common number of products they have used?
SELECT NumOfProducts,count(CustomerId) AS no_of_customers
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY no_of_customers DESC;

-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly).
-- Prepare the data through SQL and then visualize it.
SELECT YEAR(BankDOJ) AS join_year, 
	   MONTHNAME(BankDOJ) AS join_month, 
       COUNT(CustomerID) AS Customers
FROM customerinfo
GROUP BY join_year,join_month
ORDER BY join_year DESC,join_month;

-- 12.	Analyze the relationship between the number of products and the account balance for customers who have exited.
SELECT NumOfProducts,
       Round(AVG(Balance),2) AS avg_balance 
FROM bank_churn 
WHERE Exited =1 
GROUP BY NumOfProducts 
Order BY NumOfProducts ASC;


-- 13.	Identify any potential outliers in terms of balance among customers who have remained with the bank.

-- 14.	How many different tables are given in the dataset, out of these tables 
-- which table only consists of categorical variables?

-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value. (SQL)
-- Gender wise average income
-- geographical
-- rank gender avg values
WITH avg_income AS
    (SELECT gg.GeographyLocation,g.GenderCategory,ROUND(AVG(c.EstimatedSalary),2) AS average_income
	FROM customerinfo c
	JOIN gender g USING (GenderID)
	JOIN geography gg USING (GeographyID)
	GROUP BY  gg.GeographyLocation,g.GenderCategory
	order by  gg.GeographyLocation,g.GenderCategory)
SELECT *,RANK() OVER(PARTITION BY GenderCategory ORDER BY average_income DESC) AS rn
FROM avg_income;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
-- avg tenure 
-- age bracket (18-30,30-50,50+)
SELECT CASE WHEN c.age BETWEEN 18 and 30 THEN '18-30'
			WHEN c.age BETWEEN 30 AND 50 THEN '30-50'
            ELSE '50+' 
            END AS age_brackets,
            AVG(bc.Tenure) AS avg_tenure
FROM customerinfo c
JOIN bank_churn bc USING (CustomerID)
WHERE bc.Exited = 1
GROUP BY age_brackets
ORDER BY age_brackets;

-- 17.	Is there any direct correlation between salary and the balance of the customers? 
-- And is it different for people who have exited or not?

-- 18.	Is there any correlation between the salary and the Credit score of customers?

-- 19.	Identify any potential outliers in terms of spend among customers who have remained with the bank.

-- 20.	How many different tables are given in the dataset, 
-- out of these tables which table only consists of categorical variables?

-- 21.	Using SQL, write a query to find out the gender-wise average income of male and females in each geography id. 
-- Also, rank the gender according to the average value. (SQL)
-- avg income male female each geography id
WITH avg_income_location_gender AS
	(SELECT ci.GeographyID,
			g.GenderCategory,
			ROUND(AVG(ci.EstimatedSalary),2) As avg_income 
	FROM customerinfo ci
	JOIN gender g USING(GenderID)
	GROUP BY ci.GeographyID,
			g.GenderCategory
	ORDER BY ci.GeographyID,
			 g.GenderCategory DESC)
	SELECT *, RANK() OVER(partition by GenderCategory ORDER BY avg_income DESC) AS gender_rank
    FROM avg_income_location_gender;


-- 22.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
With exit_cust_tenure As
	(Select c.CustomerId,
		   c.Surname, 
		   datediff(curdate(),c.BankDOJ) AS tenure_years,
		   CASE WHEN c.Age> 50 THEN "50+"
				WHEN c.Age BETWEEN 30 AND 50 THEN "30-50"
				ELSE "18-30" END AS age_brackets
	FROM customerinfo c
	JOIN bank_churn ch On c.CustomerId = ch.CustomerId
	-- JOIN exitcustomer e ON e.ExitID = ch.Exited
	WHERE ch.Exited = 1)
    SELECT age_brackets, Round(AVG(tenure_years),2) as avg_tenure
    FROM exit_cust_tenure
    GROUP BY age_brackets;
    

-- 23.	Is there any direct correlation between the salary and the balance of the customers? 
-- And is it different for people who have exited or not?
-- 24.	Is there any correlation between th e salary and Credit score of customers?
-- 25.	Write the query to get the customer ids, their last name and whether they are active or not for 
-- the customers whose surname ends with “on”.
SELECT DISTINCT b.CustomerID,c.Surname As last_name, a.ActiveCategory
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
JOIN activecustomer a ON b.IsActiveMember = a.ActiveID
WHERE c.Surname LIKE "%on" 
