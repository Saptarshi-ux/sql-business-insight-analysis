/*Q1) Total orders and average shipping cost of each carrier*/

select sh.carrier,count(od.order_id) as total_numberof_orders,round(avg(sh.shipping_cost), 2) as average_shipping_cost
from challenge.orders as od
inner join challenge.shipments as sh 
on od.order_id = sh.order_id
where od.status not in ('cancelled', 'created')
group by sh.carrier;

/*Q2) For each carrier, calculate the percentage of orders with a shipping lead time greater than the overall average lead time, 
and the percentage of orders with a shipping lead time less than the overall average lead time.*/

with overall_average_lead as (select avg(datediff(delivered_at, shipped_at)) as overall_avg
from challenge.shipments s
inner join challenge.orders o on s.order_id = o.order_id
where o.status not in ('cancelled', 'created') and s.delivered_at is not null)

select s.carrier, round(sum(case when datediff(s.delivered_at, s.shipped_at) > oa.overall_avg then 1 else 0 end) * 100.0 / count(*), 0) as percentage_above_average_leadtime,
round(sum(case when datediff(s.delivered_at, s.shipped_at) < oa.overall_avg then 1 else 0 end) * 100.0 / count(*), 0) as percentage_below_avg_leadtime
from challenge.shipments s
inner join challenge.orders o on s.order_id = o.order_id
cross join overall_average_lead oa
where o.status not in ('cancelled', 'created')and s.delivered_at is not null
group by s.carrier
order by s.carrier;

/*Q3) Cost-to-serve per order = shipping_cost + (unit_cost*quantity) for items in the order; list top 20 costliest orders.*/
select od.order_id,round(sum(prd.unit_cost * oi.quantity) + sh.shipping_cost,2) as cost_to_serve
from challenge.order_items as oi
inner join challenge.products as prd on oi.product_id = prd.product_id
inner join challenge.shipments as sh on oi.order_id = sh.order_id
inner join challenge.orders as od on oi.order_id = od.order_id
where od.status not in ('cancelled', 'created')
group by od.order_id, sh.shipping_cost
order by cost_to_serve desc
limit 20;
