use challenge;
create view v_monthly_inventory as
select im.store_id,im.product_id,
date_format(im.movement_datetime, '%Y-%m') as month,sum(im.quantity_delta) as total_inventory
from challenge.inventory_movements as im
group by im.store_id, im.product_id, date_format(im.movement_datetime, '%Y-%m');

create view v_monthly_sales as
select o.store_id,oi.product_id,
date_format(o.order_datetime, '%Y-%m') as month,
sum(oi.quantity) as total_sold
from challenge.orders as o
inner join challenge.order_items as oi on o.order_id = oi.order_id
group by o.store_id, oi.product_id, date_format(o.order_datetime, '%Y-%m');

create view v_monthly_inventory_sales as
select inv.store_id,inv.product_id,inv.month,
coalesce(inv.total_inventory, 0) as total_inventory,
coalesce(s.total_sold, 0) as total_sold
from v_monthly_inventory as inv
left join v_monthly_sales as s
on inv.store_id = s.store_id
and inv.product_id = s.product_id and inv.month = s.month

union all

select s.store_id,s.product_id,s.month,
coalesce(inv.total_inventory, 0) as total_inventory,
coalesce(s.total_sold, 0) as total_sold
from v_monthly_sales as s
left join v_monthly_inventory as inv
on s.store_id = inv.store_id
and s.product_id = inv.product_id
and s.month = inv.month
where inv.store_id is null;

create view v_inventory_vs_demand as
select store_id,product_id,month,total_inventory,total_sold,
case when abs(total_inventory - total_sold) <= 5 then 'Within Demand'
else 'Inventory Issue' end as demand_alignment
from v_monthly_inventory_sales;

select * from v_inventory_vs_demand order by store_id, product_id, month;
