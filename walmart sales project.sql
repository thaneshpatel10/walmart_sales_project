drop table walmart;
select *
from walmart;

select count(*)
from walmart;
Q.different payment methods and transactions for each method

select distinct(payment_method),count(category) as transactions,sum(quantity) as quantity_sold
from walmart
group by payment_method;

Q.which category received highest average rating in each branch
select branch,category,avg(rating) 
from walmart
group by branch,category
order by avg(rating) desc;

Q.what is the busiest day of the week for each branch based on transaction volume
select *
from
(select branch,
	to_char(to_date(date,'dd-mm-yy'),'day')as day_name,
	count(*) as transaction,
	rank() over (partition by branch order by count(*) desc) as rank
FROM walmart
group by branch,day_name)
where rank =1;

Q.what are the average,minimum and maximum ratings for each category in each city

select avg(rating) as Ar,min(rating)as mr,max(rating) as mx,category,city
from walmart 
group by category,city;

Q. what is the total profit for each category ranked from highest to lowest
select category,sum((total*profit_margin)) as profit
from walmart
group by category
order by profit desc;


Q. what is the most frequently used payment method in each branch
with cte as(
select payment_method,branch,count(*)as trans,
rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by payment_method,branch)
select *
from cte
where rank=1;

Q.how many transactions occurs in each shift across branches

select branch,
case 
	when (extract (hour from(time::time)))<12 then 'Morning'
	when (extract (hour from(time::time)))between 12 and 17 then 'Afternoon'
	else 'Evening'
End day_time,
count(*)
from walmart
group by 1,2
order by 1,3 desc
	

Q.which branches experienced the largest decrease in revenue as compared to last year


-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart
---
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

