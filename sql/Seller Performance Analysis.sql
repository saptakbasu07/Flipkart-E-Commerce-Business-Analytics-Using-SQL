--Which sellers generate highest revenue?
with revenue as(		
select order_id,
round(sum(net_order_amount)::numeric,1) as total_revenue_generated
from orders 
where order_status='Delivered'
	group by 1),
	joining as(			
	select p.seller_id ,r.total_revenue_generated
	from order_items oi
	join revenue r 
	using(order_id)
	join products p 
	using(product_id)
	),
	sell as(
	select s.seller_id, 
	j.total_revenue_generated 
	from sellers s 
	join joining j
	using(seller_id))
	select seller_id,total_revenue_generated from(    
	select *,
	dense_rank() over (order by total_revenue_generated desc) as ranking
	from sell
	) t
	where ranking=1;



--Which sellers contribute most orders?
with revenue as(		
select p.seller_id,
count(distinct oi.order_id) as total_order_generated
from order_items oi  
join orders o 
using(order_id)
join products p 
using (product_id)
where o.order_status='Delivered'
	group by 1),
	sell as(
	select s.seller_id, 
	r.total_order_generated 
	from sellers s 
	join revenue r 
	using(seller_id))
	select seller_id,total_order_generated from(    
	select *,
	dense_rank() over (order by total_order_generated desc) as ranking
	from sell
	) t 
	where ranking=1;




--Which sellers have high returns/cancellations?
 with revenue as(		
select p.seller_id,
count(distinct oi.order_id) as total_order_returned_cancelled
from order_items oi  
join orders o 
using(order_id)
join products p 
using (product_id)
where o.order_status in('Returned','Cancelled')
	group by 1)
	select  seller_id,seller_name,seller_city,total_order_returned_cancelled from(
	select r.seller_id,s.seller_name,s.seller_city,r.total_order_returned_cancelled,
	dense_rank() over(order by r.total_order_returned_cancelled desc) as ranking
from revenue r
join sellers s 
using(seller_id)
) t
where t.ranking=1
;


--Which sellers perform best within each category?
--total order count 
with revenue as(		
select p.seller_id,
count(distinct oi.order_id) as total_order
from order_items oi  
join orders o 
using(order_id)
join products p 
using (product_id)
where o.order_status in('Delivered')
	group by 1)
	select  seller_id,seller_name,primary_category,total_order from(
	select r.seller_id,s.seller_name,s.primary_category,r.total_order,
	dense_rank() over(partition by s.primary_category order by r.total_order desc) as ranking
from revenue r
join sellers s 
using(seller_id)
) t
where t.ranking=1

	
--total revenue per category
with revenue as(		
select p.seller_id,
round(sum(distinct oi.order_id)::numeric,1) as total_revenue
from order_items oi  
join orders o 
using(order_id)
join products p 
using (product_id)
where o.order_status in('Delivered')
	group by 1)
	select  seller_id,seller_name,primary_category,total_revenue from(
	select r.seller_id,s.seller_name,s.primary_category,r.total_revenue,
	dense_rank() over(partition by s.primary_category  order by r.total_revenue desc) as ranking
from revenue r
join sellers s 
using(seller_id)
) t
where t.ranking=1;

