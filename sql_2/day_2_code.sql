/*Q1: Total Sales in each category*/
select prd.category, round(sum(ot.line_amount),2) as total_amnt_of_sales
from challenge.order_items as ot
inner join challenge.products as prd on ot.product_id = prd.product_id
inner join challenge.orders as o on ot.order_id = o.order_id
where o.status <> 'cancelled'
group by prd.category;

/*Q2: Top 5 products in each category based on the quantity sold. Also, showcase the brand they belong to*/
select category as product_category, product_name, brand, total_qty
from (select prd.category, prd.product_name, prd.brand, sum(ot.quantity) as total_qty, row_number() over (partition by prd.category order by sum(ot.quantity) desc) as ranking
from challenge.order_items as ot
inner join challenge.products as prd on ot.product_id = prd.product_id
inner join challenge.orders as o on ot.order_id = o.order_id
where o.status <> 'cancelled'
group by prd.category, prd.product_name, prd.brand
) as rnn
where ranking <= 5
order by category, total_qty desc;

/*Q3: Monthly units sold in 2025 in each category.*/
select prd.category,monthname(o.order_datetime) as month, month(o.order_datetime) as month_number,sum(ot.quantity) as total_qty_sold
from challenge.order_items as ot
inner join challenge.orders as o on ot.order_id = o.order_id
inner join challenge.products as prd on ot.product_id = prd.product_id
where year(o.order_datetime) = 2025 and o.status <> 'cancelled'
group by prd.category, month, month_number
order by prd.category, month_number;

#INSIGHTS
/*
from the category-wise sales I can say with sales of over INR 15M, fashion is by far the best-performing category; 
home, beauty, and electronics make up a strong cluster of sales as they surround around 13M.
Home, sports and some of the beauty product categories dominate quantity sold, with Pulse Home Item 184 and Acme Sports Item 209 leading. Pulse and Zenon dominate ...
but interestingly books category has lower quantity volume.
 Fashion is the top-performing category in 2025, contributing the highest total units sold, the unit volume 
experiencing a seasonal dip in February(except electronics and sports) before peaking in March and April.*/
