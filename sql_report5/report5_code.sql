/* 1) Return Impact : Find Return rate in each product category along with total and average refund value*/

with sold as (select p.category,sum(oi.quantity) as qty_sold
from challenge.orders o inner join challenge.order_items oi on o.order_id = oi.order_id 
inner join challenge.products p on oi.product_id = p.product_id
where o.status <> 'cancelled'
group by p.category),
returned as (select p.category,sum(r.quantity_returned) as qty_returned,sum(r.refund_amount) 
as total_refund,avg(r.refund_amount) as avg_refund_per_return
from challenge.returns r inner join challenge.order_items oi on r.order_item_id = oi.order_item_id
inner join challenge.orders o on oi.order_id = o.order_id
inner join challenge.products p on oi.product_id = p.product_id
where o.status <> 'cancelled'
group by p.category)
select s.category as product_category_names,coalesce(s.qty_sold, 0) as qty_sold,coalesce(r.qty_returned, 0) as qty_returned,
case when s.qty_sold >0
then round(coalesce(r.qty_returned,0) * 100.0 / s.qty_sold, 2)
else null
end as return_rate_in_percentage,round(coalesce(r.total_refund,0), 2) as total_refund_value,
round(coalesce(r.avg_refund_per_return,0), 2) as avg_refund_per_return,
case when coalesce(r.qty_returned,0) > 0
then round(coalesce(r.total_refund,0) / r.qty_returned, 2)
else null
end as avg_refund_per_returned_unit
from sold s left join returned r on s.category = r.category
order by return_rate_in_percentage desc;

/*2) In each store which products are more in demand based on Qty sold.
(Find the Contribution to qty sold of each product in a particular store)*/

select sr.store_id,sr.store_name, pd.product_id,pd.product_name,
sum(oi.quantity) as product_quantity_sold,round(sum(oi.quantity) * 100.0/ nullif(sum(sum(oi.quantity)) over (partition by sr.store_id), 0), 2) as percentage_contribution_to_store_qty
from challenge.orders as o
join challenge.stores as sr on o.store_id = sr.store_id
join challenge.order_items as oi on o.order_id = oi.order_id
join challenge.products as pd on oi.product_id = pd.product_id
where o.status <> 'cancelled'
group by sr.store_id, sr.store_name, pd.product_id, pd.product_name
order by sr.store_id, percentage_contribution_to_store_qty desc;

/*3) In each store which products are getting returned more? Solve in same way as question 2*/
select a.store_id,a.store_name,pdt.product_id,pdt.product_name,
sum(re.quantity_returned) as product_qty_returned,
round(sum(re.quantity_returned) * 100.0/ nullif(sum(sum(re.quantity_returned)) over (partition by a.store_id), 0), 2) 
as percntg_contribution_to_store_returns
from challenge.returns as re
inner join challenge.order_items as oi on re.order_item_id = oi.order_item_id
inner join challenge.orders as o on oi.order_id = o.order_id
inner join challenge.stores as a on o.store_id = a.store_id
join challenge.products as pdt on oi.product_id = pdt.product_id
where o.status <> 'cancelled'
group by a.store_id, a.store_name, pdt.product_id, pdt.product_name
order by a.store_id, percntg_contribution_to_store_returns desc;

/* Q4) Products in a store with high demand as well as high return*/
/* yes there has been a product that demonstrate both high demand as well as a high return rate.
the product is named as Acme Sports Item 209 which has been sold at Eco Market store.
this product is sold with volume of 49 units and among them 9 were returned which is very significant rate (18.37%)
among the top selling products.(Although we have another interesting point with order volume 44 units 
and return volume 10 units, the product name is 'Pulse Home Item 211' from store 'Value Store' but we are not considering that as it may have high return 
but comapred to Acme sports item 209 it hasn't that high volume of demand and almost both have the same high return)*/
