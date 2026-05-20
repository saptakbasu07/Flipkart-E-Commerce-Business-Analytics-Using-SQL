select*from orders;

--Who are the High-Value Customers?
with revenue as(	
select customer_id,
round(sum(order_amount)::numeric,1) as total_revenue
from orders
where order_status='Delivered'
group by 1
)
select*FROM(		
select c.customer_id,
c.customer_name,
c.email,
r.total_revenue,
dense_rank() over(order by r.total_revenue desc) as ranking
from customers c 
join revenue  r
using(customer_id)
) t
where ranking<=10;

--What is the Repeat Customer Rate?
select count(*) as repeated_customers from(		
select customer_id
from orders
group by customer_id
having count(order_id)>5
) t;

--What is the Cancellation Rate?
with rated as(
select 
round(count(case when order_status='Cancelled' then 1 end)::numeric,1) as total_cancellation,
count( order_id) as total_order
from orders
)
select 
round(total_cancellation*100.0/total_order:: numeric,1) as cancellation_percentage
from rated;


