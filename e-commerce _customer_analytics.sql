

select * from customers;
select * from order_items;
select * from orders;
select * from payments;
select * from products;

select * from customers limit 5;
select * from order_items limit 5;
select * from orders limit 5;
select * from payments limit 5;
select * from products limit 5;

---count of rows by tables
select 'customers' as table_name ,count(*) as no_of_rows from customers 
union all 
select 'order',count(*) from orders 
union all
select 'order_items',count(*) from order_items
union all
select 'payments',count(*) from payments
union all
select 'products',count(*) from products;


----in product table categorys+count
select category,count(*)  from products group by category;

------check duplicates in customer custer_id
select customer_id,count(*) as count from customers group by customer_id having count(*) >1;

---------------------------------------------------------------------------------------------------------------
select * from customers;----customer tables gives
select distinct customer_name from customers;---customer names --300 names
select customer_name,count(customer_name) as no_of_rows from customers group by customer_name ; --each customers has repetaed times
select customer_name,count(customer_name) as no_of_rows ,sum(count(customer_name)) over() as total_c from customers group by customer_name ;---sum repeatd customers to march customer recods correct or not
-----------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------
--can we check all duplicates ids at once in all tables
select 'customers' as table_name,customer_id::text as id,count(*) as duplicates_count from customers group by customer_id having count(*) >1;

select 'customers' as table_name,customer_id::text as id from customers group by customer_id having count(*) >1;


select 'customers' as table_name,customer_id::text as id,count(*) as duplicates_count from customers group by customer_id having count(*) >1
 union all
 select 'products',product_id::text,count(*) from products group by product_id  having count(*)>1
 union all  
 select 'order',order_id::text,count(*) from orders group by order_id  having count(*)>1
 union all
 select 'order_items',order_item_id::text,count(*) from order_items  group by order_item_id  having count(*)>1
 union all 
 select 'payments',payment_id::text,count(*) from payments group by payment_id  having count(*)>1;
----------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------
---one method ...to check all what u what same 
select * from customers where
customer_id  null or
customer_name isis null or
email is null or
city is null or
state is null or
signup_date is null;
------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
select * from customers union all 
select * from orders union all 
select * from order_items union all 
select * from products union all 
select * from payments; --not work becuse union all use for combine all but it chechs same noof colums both tables 
------------------------------------------------------------------------------------------------------------------------------------------


 
-----------------------------------------------------------------------------------------------------------------------------------------------
----1,total customers
select count(*) as total_customers from customers;

-----2.TOTAL orders
select count(order_id) from orders;----------total orders 50000

------productname+noof orders by each product
select p.product_name,count(*) as total_orders from orders o 
join order_items oi 
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id group by p.product_name;

--product name + orders+after join total orders
select p.product_name,
count(*) as total_orders ,
sum(count(o.order_id) )over() as total_orders
from orders o 
join order_items oi 
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id group by p.product_name;

select p.product_name,
count(*) as total_orders ,
sum(count(o.order_id) )over() as total_orders
from orders o 
join order_items oi 
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id group by p.product_name;

------3.products
select count(*) as total_prdts from products;

select category,product_name from products group by category,product_name order by category;

----4.total revenue
select  round(sum(quantity* unit_price)) as tota_revune from order_items;

select sum(oi.quantity* oi.unit_price) as tota_revune
from order_items oi;

select  round(sum(oi.quantity* oi.unit_price)) as tota_revune
from order_items oi;

select round(sum(oi.quantity* oi.unit_price)::numeric,2) as tota_revune
from order_items oi;


---5.what is the avg ammount of money generated by one order
select count(order_id) from orders;

select order_id,  round(sum(quantity* unit_price)) as tota_revune from order_items group by order_id order by order_id;----

select order_id,order_item_id,product_id,quantity,unit_price,---------
round(sum(quantity* unit_price)) as tota_revune from order_items
group by order_id,order_item_id,product_id,quantity,unit_price 
order by order_id ;

select *,-----------MAIN QUERY FOR PROBLEM
round(sum(quantity* unit_price) over(partition by order_id)::numeric,2)  as total_rev ,
round(avg(quantity* unit_price) over(partition by order_id)::numeric,2)  as avg_rev 
from order_items;


------6... how many orders are delivered,shipped,cancelled and retured
select order_status from orders group by order_status;

select order_status, count(order_status) as total_os from orders group by order_status;

----7..top 10 cuartomers by revenue
select c,o,oi,p,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_rev
from customers c 
join orders o
  on c.customer_id=o.customer_id
join order_items oi
  on oi.order_id=o.order_id
join products p
  on p.product_id=oi.product_id
group by c,o,oi,p
order by total_rev desc 
limit 10;



-------8..top 10 products by total_rev
select p.product_id,p.product_name,p.category,round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_rev
from products p
join order_items oi
on p.product_id=oi.product_id 
group by  p.product_id,p.product_name,p.category
order by total_rev desc limit 10;


------9..find the total noof orders for each order status and show the status with the noof orders
select order_status,count(order_status) as total_orders from orders group by order_status;
select order_status,count(*) as total_orders from orders group by order_status;


---10..find the total revune generated by each order status
select o.order_status,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_rev
from orders o
join order_items oi
on o.order_id=oi.order_id 
group by o.order_status 
order by total_rev desc;


--11..find the avg orders value for each order status item row
select o.order_status,
count(*) as noof_items,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_rev,
round(avg(oi.quantity*oi.unit_price)::numeric,2) as avg_order_values
from orders o
join order_items oi
on o.order_id=oi.order_id 
group by o.order_status
order by total_rev desc;


----12 average order value......for each order status,find the avg rev generated by one complete order
select o.order_status,
count(distinct o.order_id) as noof_orders,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_rev,
round(sum(oi.quantity*oi.unit_price)::numeric / count(distinct o.order_id),2) as avg_order_values
from orders o
join order_items oi
on o.order_id=oi.order_id 
group by o.order_status
order by total_rev desc;




---13..how many orders does each customer have..?
select count(order_id) from orders;---it gives 50000

--------customer_id,name and their repstive ordres
select c.customer_id,c.customer_name,count(o.order_id) as total_orders 
from orders o
join customers c
on c.customer_id=o.customer_id 
group by c.customer_id,c.customer_name 
order by c.customer_id;

------customer_id,name, their repstive ordres and sum of customers orders ....it matches to  total orders 
select customer_id,customer_name,total_orders,sum(total_orders) over() as sum_of_customers_orders from (
select c.customer_id,c.customer_name,count(o.order_id) as total_orders 
from orders o
join customers c
on c.customer_id=o.customer_id 
group by c.customer_id,c.customer_name 
order by c.customer_id) as x;


-----14..top 10 customers based on no.of orders
select c.customer_id,c.customer_name,count(o.order_id) as total_orders 
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name
order by total_orders desc 
limit 10;


select c.customer_name,o.order_id,p.product_name,oi.quantity
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on o.order_id=oi.order_id 
join products p
on p.product_id=oi.product_id 
where c.customer_id ='7596'
order by o.order_id;


select c.customer_id,c.customer_name,x.total_orders ,o.order_id,p.product_name,oi.quantity
from customers c 
join (
select customer_id,count(order_id) as total_orders 
from orders 
group by customer_id
order by total_orders desc
limit 10
)as x
on c.customer_id=x.customer_id
join orders o
on c.customer_id=o.customer_id
join order_items oi
on o.order_id=oi.order_id
join products p
on p.product_id=oi.product_id
order by x.total_orders desc,c.customer_id,o.order_id;



----15...top 10 products based on total quantity
select p.product_id,p.product_name,p.category,sum(oi.quantity) as total_quantity_sold
from products p
join order_items oi
on p.product_id=oi.product_id
group by p.product_id,p.product_name,p.category
order by total_quantity_sold  desc
limit 10;


----16...top 10 products based on total revenue
select p.product_id,p.product_name,p.category,round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_revenue
from products p
join order_items oi
on p.product_id=oi.product_id
group by p.product_id,p.product_name,p.category
order by total_revenue  desc
limit 10;


----17...find the total revenue generated by each product category
select p.category,round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_revenue
from products p
join order_items oi
on p.product_id=oi.product_id
group by p.category
order by total_revenue  desc;


------18..find the no of customers in each city
select c.city,count(c.customer_id) as total_customers
from customers c
group by city 
order by total_customers desc;


----19..find the total revenue generated by each city
select c.city,round(sum(oi.quantity*oi.unit_price)::numeric,2)  as total_revenue
from customers c
join  orders o
on c.customer_id=o.customer_id 
join order_items oi
on oi.order_id=o.order_id
group by c.city 
order by total_revenue desc;


-----20..find the avg revenue per customer for each city
select c.city,round(sum(oi.quantity*oi.unit_price)::numeric/count(distinct c.customer_id),2) as avg_revenue 
from customers c
join  orders o
on c.customer_id=o.customer_id 
join order_items oi
on oi.order_id=o.order_id
group by c.city 
order by avg_revenue desc;


-----21...find the top 5 cities based on total noof orders
select c.city,count(o.order_id) as noof_orders 
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.city
order by noof_orders desc 
limit 5;


-----22....montly revenue analysis
select TO_CHAR(o.order_date::date,'MONTH')as month,
ROUND(sum(oi.quantity*oi.unit_price)::numeric,2) as revenue
from orders o
join order_items oi
on o.order_id=oi.order_id 
group by TO_CHAR(o.order_date::date,'MONTH') 
order by min(o.order_date::date);

---------23....montly revenue analysis and use lag and lead for find difference
with monthly_revenue as (
select 
TO_CHAR(o.order_date::date,'Month')as month,
min(o.order_date::date) as month_date,
ROUND(sum(oi.quantity*oi.unit_price)::numeric,2) as revenue
from orders o
join order_items oi
on o.order_id=oi.order_id 
group by TO_CHAR(o.order_date::date,'Month') 
)
select month,revenue,
lag(revenue) over (order by month_date) as previuos_month_revenue,
revenue-lag(revenue) over (order by month_date) as revenue_diffence,
round((revenue-lag(revenue) over (order by month_date))/lag(revenue) over (order by month_date) *100,2) as percentage_change,
lead(revenue) over (order by month_date) as next_month_revune
from monthly_revenue
order by month_date;




---24...how much total revenue did each category generated
select p.category,
ROUND(sum(oi.quantity*oi.unit_price)::numeric,2) as revenue
from products p
join order_items oi
on p.product_id=oi.product_id 
group by p.category
order by revenue desc;

----25....top 10 cutosmers based on the highest noof orders
select c.customer_id,c.customer_name,count(o.order_id) as TOTAL_ORDERS
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name 
order by total_orders desc
limit 10;


------26...find the customer who have placed more than one order
select c.customer_id,c.customer_name,count(o.order_id) as total_orders
from customers c
join orders o
on c.customer_id=o.customer_id 
group by c.customer_id,c.customer_name 
having count(o.order_id)>1
order by total_orders desc;


-------27.segments customer into groups based on their total speinding give low,mediium,high
select c.customer_id,c.customer_name,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_spending,
case 
	when sum(oi.quantity*oi.unit_price) <1000000 then 'low'
    when sum(oi.quantity*oi.unit_price) <1200000 then 'medium'
    else'high'
end as spending_segment
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
group by c.customer_id,c.customer_name
order by total_spending desc;


----29..Calculate RFM values RFM = Recency + Frequency + Monetary and ther score or rfm and give high,medium,low baesd on rfm score

select count(customer_id) from customers;


select customer_id,customer_name,last_purchases_date,current_date,recency_days,frequency,monetary,recency_score,frequency_score,monetary_score,rfm_score,
case 
	when rfm_score >=12 then 'high'
	when rfm_score >=8 then'medium'
	else'low'
end as customer_segmants
from (
select customer_id,customer_name,last_purchases_date,recency_days,frequency,monetary,recency_score,frequency_score,monetary_score,
recency_score+frequency_score+monetary_score as rfm_score
from(
select customer_id,customer_name,last_purchases_date,recency_days,frequency,monetary,
ntile(5) over(order by recency_days desc) as recency_score,
ntile(5) over(order by frequency ) as frequency_score,
ntile(5) over(order by monetary ) as monetary_score 
from(
select c.customer_id,c.customer_name,
max(o.order_date)::date as last_purchases_date,
current_date as current_date,
current_date - max(o.order_date)::date  as recency_days,
count(o.order_id) as frequency,
round(sum(oi.quantity*oi.unit_price) ::numeric,2) as monetary
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
group by c.customer_id,c.customer_name
) as x
) as b
) as sam
order by rfm_score desc;




------30.RANK products based on their total_revenue and identify the hihest_revenue produts
select product_id,product_name,category,total_revenue,
dense_rank() over (order by total_revenue desc) as ranks
from(
select p.product_id,p.product_name,p.category,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_revenue
from products p
join order_items oi
on p.product_id=oi.product_id 
group by p.product_id,p.product_name,p.category ) as x
order by total_revenue desc;



----31.analysis cancelled orders and find the cancellation rate
select order_status from orders group by order_status;

select order_status,
count(order_id) as total_orders, 
sum(case
	when order_status='cancelled' then 1 else 0
    end) as cancelled_orders,
round(sum (case
	      when order_status ='cancelled' then 1 else 0 
     end) *100/count(order_id),2) as cancellation_ratio
from orders
     group by order_status;



select order_status,
count(order_id) as total_orders, 
sum(case
	when order_status='Cancelled' then 1 else 0
    end) as cancelled_orders,
    sum(case
	when order_status='Shipped' then 1 else 0
    end) as shipped_orders,
    sum(case
	when order_status='Deliverd' then 1 else 0
    end) as deliversd_orders,
    sum(case
	when order_status='Returned' then 1 else 0
    end) as returned_orders,
round(sum (case when order_status ='Cancelled' then 1 else 0 end) /count(order_id)over(),2)*100 as cancellation_ratio,
round(sum (case when order_status ='Delivers' then 1 else 0 end) /count(order_id) over(),2)*100 as Deliverded_ratio,
round(sum (case when order_status ='Returned' then 1 else 0 end) /count(order_id)over(),2)*100 as Returned_ratio,
round(sum (case when order_status ='Shipped' then 1 else 0 end) /count(order_id)over(),2) *100 as Shipped_ratio
from orders
     group by order_status;


------32.analysis orders and revenue by payment method
select p.payment_method,
 count(o.order_id) as total_orders,
round( sum(oi.quantity*oi.unit_price)::numeric,2) as total_revenue,
round( (sum(oi.quantity*oi.unit_price) *100.0 / sum(sum(oi.quantity*oi.unit_price)) over() )::numeric,2) as revenue_percentage
 from payments p
 join orders o
 on p.order_id=o.order_id
 join order_items oi
 on oi.order_id=o.order_id
 group by p.payment_method
 order by total_revenue desc;
 

-----33..analysis total customers,total orders,and total revene by city
select count(distinct customer_id) from customers;----it gives total table customers
select count(distinct order_id) from orders;---------it ggives total table orders
select round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_revenue_by_city------it gies total table revenue
from customers c
join orders o 
on c.customer_id=o.customer_id 
join order_items oi
on oi.order_id=o.order_id ;

with city_data as (------------------this is above quetion ans
select c.city,
count(distinct c.customer_id) as total_customers_by_city,
count(distinct o.order_id) as total_orders_by_city,
round(sum(oi.quantity*oi.unit_price)::numeric,2) as total_revenue_by_city
from customers c
join orders o 
on c.customer_id=o.customer_id 
join order_items oi
on oi.order_id=o.order_id 
group by c.city 
)
select city,
total_customers_by_city,sum(total_customers_by_city) over() as total_customers,
round(total_customers_by_city * 100.0/ sum(total_customers_by_city) over() ,2)as total_customers_percantage,
total_orders_by_city,sum(total_orders_by_city) over() as total_orders,
round(total_orders_by_city * 100.0/ sum(total_orders_by_city) over() ,2)as total_orders_percantage,
total_revenue_by_city,sum(total_revenue_by_city) over() as total_revenue,
round(total_revenue_by_city * 100.0/ sum(total_revenue_by_city) over() ,2)as total_revennue_percantage
from city_data
order by total_revenue_by_city desc;




----34...cusomers who haven't purchased recently

select c.customer_id,c.customer_name,
max(o.order_date)::date as letest_purchased_date,
current_date,
current_date-max(o.order_date)::date as between_days
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name 
order by between_days desc;

--................if same min dates and max date means a customer order same date that is only one date only
select c.customer_id,c.customer_name,
max(o.order_date)::date as letest_purchased_date,
min(o.order_date)::date as earliest_purchased_date,
current_date,
current_date-max(o.order_date)::date as between_days,
current_date-min(o.order_date)::date as between_days2
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name 
having count(distinct o.order_id) =1
order by between_days desc

-------
select c.customer_id,c.customer_name,
max(o.order_date)::date as letest_purchased_date,
current_date,
current_date-max(o.order_date)::date as between_days
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name 
having current_date-max(o.order_date)::date > 90
order by between_days desc;



-----35..checks your table strucutre
select column_name,data_type from information_schema.columns
where table_name ='orders';

---multiple table at a time checks
select 
table_name,
column_name,
data_type
from information_schema.columns
where table_name in (
'customers',
'orders',
'order_items',
'products',
'payments')
order by table_name,column_name;



---- how many repeated_customers
create view repeated_customers as 
select count(*) as repeated_customer from(
SELECT customer_id,
count(*) AS count 
FROM customers
GROUP BY customer_id
HAVING count(*) >1
ORDER BY count desc) as a;

select * from repeated_customers;



---creating view of rfm
create view customer_RFM as
select customer_id,customer_name,last_purchases_date,current_date,recency_days,frequency,monetary,recency_score,frequency_score,monetary_score,rfm_score,
case 
	when rfm_score >=12 then 'high'
	when rfm_score >=8 then'medium'
	else'low'
end as customer_segmants
from (
select customer_id,customer_name,last_purchases_date,recency_days,frequency,monetary,recency_score,frequency_score,monetary_score,
recency_score+frequency_score+monetary_score as rfm_score
from(
select customer_id,customer_name,last_purchases_date,recency_days,frequency,monetary,
ntile(5) over(order by recency_days desc) as recency_score,
ntile(5) over(order by frequency ) as frequency_score,
ntile(5) over(order by monetary ) as monetary_score 
from(
select c.customer_id,c.customer_name,
max(o.order_date)::date as last_purchases_date,
current_date as current_date,
current_date - max(o.order_date)::date  as recency_days,
count(o.order_id) as frequency,
round(sum(oi.quantity*oi.unit_price) ::numeric,2) as monetary
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
group by c.customer_id,c.customer_name
) as x
) as b
) as sam
order by rfm_score desc;

select * from customer_RFM;



----avg rev per customer
select round(sum(oi.quantity*oi.unit_price)::numeric / count(distinct c.customer_id),2) as avg_rev_per_customers
from customers c
join orders o
on c.customer_id=o.customer_id 
join order_items oi
on o.order_id=oi.order_id ;

create view avg_revenue_per_customer as 
select round(sum(oi.quantity*oi.unit_price)::numeric / count(distinct c.customer_id),2) as avg_rev_per_customers
from customers c
join orders o
on c.customer_id=o.customer_id 
join order_items oi
on o.order_id=oi.order_id ;

select * from avg_revenue_per_customer;























































