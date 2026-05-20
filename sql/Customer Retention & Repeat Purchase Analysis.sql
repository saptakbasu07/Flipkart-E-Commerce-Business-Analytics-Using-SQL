--Customer Retention & Repeat Purchase Analysis
--Business Problem
--
--Acquiring customers is expensive. Flipkart wants to know whether customers return after their first purchase.

--Which month acquired the most loyal customers?
SELECT 
    TO_CHAR("signup_date", 'YYYY-MM') AS signup_month,
    COUNT(*) AS customer_count
FROM "Flipkart"."customers"
GROUP BY signup_month
ORDER BY customer_count DESC
LIMIT 1;

--How many users return in Month-1, Month-2, Month-3?

with firstly as(   
select  
customer_id,
MIN(order_date) as first_order,
max( order_date) as recent_order
from orders
group by 1
),
monthly as(
select  
count(case when date_part('month',age(recent_order,first_order))= 1 then 1 end) as first_month,
count(case when date_part('month',age(recent_order,first_order))= 2 then 1 end) as second_month,
count(case when date_part('month',age(recent_order,first_order))= 3 then 1 end) as third_month
from firstly)
select  
first_month,
second_month,
third_month,
count(*) as total,
first_month-count(*)/count(*)*100.0 as first_precntage,
second_month-count(*)/count(*)*100.0 as second_precntage,
third_month-count(*)/count(*)*100.0 as three_precntage
from monthly 
group by 1,2,3;






