-- formation of cohort table
create view c as
with rr as (select customer_id,order_datetime,
row_number() over (partition by customer_id order by order_datetime) as order_rank
from challenge.orders
),
a as (
select f.customer_id,f.order_datetime as first_order_date,s.order_datetime as second_order_date,
datediff(s.order_datetime, f.order_datetime) as days_between
from rr as f inner join rr s 
on f.customer_id = s.customer_id 
and s.order_rank = f.order_rank + 1
where f.order_rank = 1
),
cohort_class as (select customer_id,first_order_date,second_order_date,
days_between,case
when days_between between 0 and 30 then 'Cohort 1'
when days_between between 31 and 60 then 'Cohort 2'
when days_between between 61 and 90 then 'Cohort 3'
when days_between > 90 then 'Cohort 4'
else 'No Second Order'
end as cohort
from a
)
select * from cohort_class;

-- Q1) Percentage of customers in each Cohort 
select cohort as cohort_number,count( customer_id) as number_of_customers,
concat(round(count( customer_id) * 100.0 / 
(select count(customer_id) from cohort_table), 0),'%') as percentage_of_customers_in_each_cohort
from c
group by cohort
order by cohort;

-- Q2) Average difference in days between the first and second order for each cohort.
select cohort as cohort_number, round(avg(days_between)) as avg_days_between_orders
from c
group by cohort
order by cohort;
