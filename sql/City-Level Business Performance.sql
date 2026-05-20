--Which cities generate highest revenue?
with revenue as(
select c.city,
round(sum(o.net_order_amount)::numeric ,0) as total_revenue
from orders o
join customers c
using (customer_id)
where order_status='Delivered'
group by 1)
select city,total_revenue from(
select city,total_revenue ,
row_number() over(order by total_revenue desc) as ranking
from revenue ) t
where ranking=1;


--Which cities have highest repeat customers?
with repeated as(    
select c.customer_id,c.city
from orders o 
join customers c 
using (customer_id)
where o.order_status='Delivered'
group by 1,2
	having count(order_id)>1
),
rent as(			
select city,
count(distinct customer_id) as total_repeated_customer
from repeated 
group by 1
)
select city,total_repeated_customer from(
select city,total_repeated_customer,
row_number() over(order by total_repeated_customer desc) as rank
from rent
) t
where rank=1;



--Which cities have highest return rates?
with totl as(
select 
c.city,
count(r.order_id) as total_returned
from orders o 
join "returns" r 
using(order_id)
join customers c 
using(customer_id)
where o.order_status='Returned'
group by 1
)
select city,total_returned from (   
select city,total_returned ,
row_number() over(order by total_returned desc) as ranking
from totl
) t
where t.ranking=1;

--Which cities show strong growth?
with revenue as(
select 
c.city,
date_trunc('month',o.order_date) as month,
round(sum(o.net_order_amount )::numeric,0) as total_revenue,
lag(round(sum(o.net_order_amount)::numeric,0)) over(partition by c.city order by date_trunc('month',o.order_date)) as previous_month
from orders o
join customers c
using(customer_id)
group by 1,2
)
select 
city,
to_char(month,'MM-YYYY') as month,
total_revenue,
previous_month,
round((total_revenue-previous_month)/nullif(previous_month,0)*100,2)as growth_percentage
from revenue;