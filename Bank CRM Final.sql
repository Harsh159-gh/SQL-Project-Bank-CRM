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
WHERE MONTH(BankDOJ) IN (10, 11, 12)
ORDER BY EstimatedSalary DESC
LIMIT 5 ;

-- 3.	Calculate the average number of products used by customers who have a credit card. 
SELECT 
    ROUND(AVG(NumOfProducts), 0) AS avg_products
FROM 
    bank_churn b
LEFT JOIN  
    customerinfo c 
ON 
    b.CustomerID = c.CustomerID
WHERE 
    HasCrCard = 1;



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
	GROUP BY g.GenderCategory), inactive_avg_est_salary AS
    (SELECT g.GenderCategory AS gender, ROUND(AVG(c.EstimatedSalary),2) AS inactive_avg_est_salary 
	FROM customerinfo c
	JOIN bank_churn b USING (CustomerID)
	JOIN gender g USING (genderID)
	WHERE IsActiveMember = 0
	GROUP BY g.GenderCategory)
SELECT a.gender, a.active_avg_est_salary, i.inactive_avg_est_salary
FROM active_avg_est_salary a
JOIN inactive_avg_est_salary i ON a.gender = i.gender;

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


-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly).Prepare the data through SQL and then visualize it.
SELECT YEAR(BankDOJ) AS join_year, 
	   MONTHNAME(BankDOJ) AS join_month, 
       COUNT(CustomerID) AS Customers
FROM customerinfo
GROUP BY join_year,join_month
ORDER BY join_year DESC, join_month;


-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the 
-- gender according to the average value. (SQL)
WITH avg_income AS
    (SELECT gg.GeographyID,g.GenderCategory,ROUND(AVG(c.EstimatedSalary),2) AS average_income
	FROM customerinfo c
	JOIN gender g USING (GenderID)
	JOIN geography gg USING (GeographyID)
	GROUP BY  gg.GeographyID,g.GenderCategory
	order by  gg.GeographyID,g.GenderCategory)
SELECT *,RANK() OVER(PARTITION BY GenderCategory ORDER BY average_income DESC) AS rn
FROM avg_income;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
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


-- 19.	Rank each bucket of credit score as per the number of customers who have churned the bank.
select case
when CreditScore >= 800 then 'Excellent'
when CreditScore < 800 and CreditScore >= 740 then 'Very Good'
when CreditScore < 740 and CreditScore >= 670 then 'Good'
when CreditScore < 670 and CreditScore >= 580 then 'Fair'
else 'Poor'
end as CreditScoreSegment,
count(CustomerID) as TotalCustomers,
row_number() over( order by count(CustomerID) desc) as 'RowNumber'
from bank_churn
	where exited = 1
group by 1;


-- 20(1). According to the age buckets find the number of customers who have a credit card.

select case
when Age between 18 and 30 then 'Young Adults'
when Age between 30 and 50 then 'Adults'
else 'Old'
end as AgeBucket,
count(c.CustomerID) as CustomerCount
from bank_churn b inner join customerinfo c on b.CustomerId = c.CustomerId
	where HasCrCard = 1
group by AgeBucket;

-- 20(2). Also retrieve those buckets that have lesser than average number of credit cards per bucket.
SELECT CASE
           WHEN Age BETWEEN 18 AND 30 THEN 'Young Adults'
           WHEN Age BETWEEN 30 AND 50 THEN 'Adults'
           ELSE 'Old'
       END AS AgeBucket,
       SUM(HasCrCard) AS TotalCards
FROM customerinfo c 
INNER JOIN bank_churn b ON c.CustomerId = b.CustomerId
GROUP BY AgeBucket
HAVING SUM(HasCrCard) < (SELECT SUM(HasCrCard)/3 FROM bank_churn);

-- 21.  Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

select GeographyID, count(c.CustomerID) as CustomerCount,
row_number() over( order by count(CustomerID) desc) as 'CustomerRANK',
round(avg(Balance), 2) as AverageBalance,
row_number() over( order by avg(Balance) desc) as 'BalanceRANK'
from customerinfo c inner join bank_churn b on c.CustomerId = b.CustomerId
	where Exited = 1
group by 1;

-- 22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the
-- primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

select concat(CustomerID,'_', Surname) as CustomerID_Surname from customerinfo;

-- 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

SELECT *,
    (SELECT ExitCategory FROM exitcustomer ec WHERE ec.ExitID = Bank_Churn.Exited) AS ExitCategory
FROM Bank_Churn;


-- 25.	Write the query to get the customer ids, their last name and whether they are active or not for the customers whose surname
-- ends with “on”.
select c.CustomerId,
Surname,
IsActiveMember
from customerinfo c
inner join bank_churn b
on c.CustomerId = b.CustomerId
	where Surname like '%on';

-- 26. Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns. 
-- One more point to consider is that the data in the Exited Column is absolutely correct and accurate.
SELECT *
FROM bank_churn
WHERE IsActiveMember = 1 AND Exited = 1;



-- SUBJECTIVE QUESTIONS
    
-- 9. Utilize SQL queries to segment customers based on demographics and account details.

select Tenure,
NumOfProducts,
case
when CreditScore >= 800 then 'Excellent'
when CreditScore < 800 and CreditScore >= 740 then 'Very Good'
when CreditScore < 740 and CreditScore >= 670 then 'Good'
when CreditScore < 670 and CreditScore >= 580 then 'Fair'
else 'Poor'
end as CreditScoreSegment,
count(customerID) as CustomerCount,
round(avg(Balance), 2) as AverageBalance
from bank_churn
group by 1, 2, 3
order by 1;


select * from bank_churn