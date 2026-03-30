/*Question 1:Active Products as a percentage of total products*/
use challenge; #<- this is the name of my database with these tables
select (sum(case when active = 'TRUE' then 1 else 0 end) / count(*)) * 100 as activeproduct_percntg
from challenge.products;

/* Question2: Classify Stores into Old and New (before 2023 – Old, In or After 2023 New) and then count the stores in each classification.*/

select case 
when year(opened_at) >= 2023 then 'new'
else 'old'
end as store_categories, count(*) as total_stores
from stores
group by store_categories;

/*Question3: Top 5 cities by number of customers along with Old and New classification of stores*/
select cs.city,case 
when year(ss.opened_at) >= 2023 then 'new'
else 'old'
end as store_categories, count(cs.customer_id) as no_of_customers
from challenge.customers cs
inner join challenge.stores ss
on cs.city = ss.city
group by store_categories, cs.city
order by no_of_customers desc
limit 5;

/*Question4: Average order line value (`AVG(line_amount)`)*/
select avg(line_amount) as AvgofOrderLineValue
from order_items;
