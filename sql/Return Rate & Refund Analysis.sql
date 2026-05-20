--Which categories have highest return rates?
with counted as(			
select p.category ,
count(distinct oi.order_id) as total_return_rates
from order_items oi
join orders o
using(order_id)
join products p 
using(product_id)
where o.order_status in('Returned')
group by 1
)
select category,total_return_rates from( 
select category,total_return_rates,
dense_rank() over( order by total_return_rates desc) as ranking
from counted c
) t
where ranking=1;


--Which products are returned most?
with counted as(			
select p.product_name,
count(distinct oi.order_id) as total_return_rates
from order_items oi
join orders o
using(order_id)
join products p 
using(product_id)
where o.order_status in('Returned')
group by 1
)
select product_name,total_return_rates from( 
select product_name,total_return_rates,
dense_rank() over( order by total_return_rates desc) as ranking
from counted c
) t
where ranking=1;

--Which sellers cause most refunds?
with counted as(			
select p.seller_id,
count(distinct oi.order_id) as total_return_rates
from order_items oi
join orders o
using(order_id)
join products p 
using(product_id)
where o.order_status in('Returned')
group by 1
)
select seller_id,seller_name,primary_category,seller_city,total_return_rates from(
select s.*,
c.total_return_rates,
dense_rank() over(order by c.total_return_rates desc) as ranking
from counted c 
join sellers s
using (seller_id)) t
where ranking=1;

--What are the main return reasons?
select 
count(case when r.return_reason='Size Issue'  then 1 end) as Size_issue_total,
count(case when r.return_reason='Changed Mind'  then 1 end) as Changed_mind_total,
count(case when r.return_reason='Late Delivery'  then 1 end) as Late_Delivery_total,
count(case when r.return_reason='Poor Quality'  then 1 end) as Poor_Quality_total,
count(case when r.return_reason='Damaged Product'  then 1 end) as Damaged_product_total,
count(case when r.return_reason='Wrong Item Delivered'  then 1 end) as Wrong_Item_Delivered_total,
count(*) as total_returns
from returns r;


