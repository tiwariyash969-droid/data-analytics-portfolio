CREATE TABLE CUSTOMERS(
customer_id varchar(50) primary key,
customer_unique_id varchar(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

select * from customers;
limit 10;

select count(*) from customers;

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

select * from orders;

SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

select * from customers 
limit 10;

select count(distinct(customer_id)) from customers;

select customer_city, count(*) from customers 
group by customer_city
order by count(*) desc
limit 10;


select customer_state, count(*) from customers
group by customer_state 
order by count(*) desc;


select customer_city, count(*) from customers 
group by customer_city 
having count(*)>500
order by count(*) desc;

select customer_state , count(*) from customers 
group by customer_state
having count(*)>100
order by count(*) asc
limit 5;

select customer_state , count(*) from customers
where customer_state = 'SP'
group by customer_state;

select customer_state , count(*) from customers
WHere customer_state ='RJ' OR  customer_state ='SP'
group by customer_state;

select customer_city, count(*) from customers
where customer_state = 'SP'
group by customer_city
order by count(*) desc
limit 5;



select * from customers;

select customer_city , count(*) from customers
where customer_state= 'SP'
group by customer_city
Having Count(*)>1000
order by count(*) desc;

select customer_state ,count(*) from customers
group by customer_State
having count(*) >5000
order by count(*) desc;

select count(*) from customers
where customer_city is null
or customer_state is null;

select customer_unique_id , count(*) from customers
group by customer_unique_id 
having count(*)>1;

select * from orders;
select * from customers;


select customer_id , count(*) from orders
group by customer_id
order by count(*) desc
limit 10;

select o.customer_id ,c.customer_city, c.customer_state, count(*) from orders o
join customers c on o.customer_id = c.customer_id
group by o.customer_id, c.customer_city, c.customer_state
order by count(*) desc
limit 10;

select order_status, count(*) from orders
group by order_status
order by count(*) desc;

select order_status , count(*) from orders
where order_status= 'delivered'
group by order_status;

select count(case when order_status='delivered' then 1 END)* 100.0/ count(*)
from orders;


select order_id, order_status, (case when order_status = 'delivered' then 'Successful'
else 'Not Successful' END) from orders;

select order_id, order_status,(case when order_status = 'delivered' then 'completed'
When order_status = 'canceled' then 'cancelled'
when order_status = 'Shipped' then 'in transit'
else 'pending' End)from orders;

select order_id, order_status,(case when order_status = 'delivered' then 1
When order_status = 'canceled' then 0
when order_status = 'Shipped' then 2
else 3 End)from orders;

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);


select * from customers;
select * from order_items;
select * from orders;

select sum(price) as total_price from order_items;

select sum(freight_value+price) as total_price from order_items;

select product_id , sum(price) as total_revenue ,count(*) from order_items
group by product_id
order by total_revenue desc
limit 10;

select product_id , count(*) as total_order from order_items
group by product_id
order by total_order desc
limit 10;


select o.order_status , sum(price) as total_revenue from orders o
join order_items ot on o.order_id = ot.order_id
group by order_status
order by total_revenue desc;


select c.customer_id , sum(ot.price) as total_spent from customers c
join orders o on c.customer_id = o.customer_id
join order_items ot on o.order_id = ot.order_id
group by c.customer_id 
order by total_spent desc
limit 10;

select c.customer_id , count(o.order_id) as highest_order from customers c
join orders o on c.customer_id = o.customer_id
join order_items ot on o.order_id = ot.order_id
group by c.customer_id 
order by highest_order desc
limit 10;

select c.customer_id, sum(ot.price) as most_spent from customers c
join orders o on c.customer_id = o.customer_id
join order_items ot on o.order_id = ot.order_id
group by c.customer_id 
order by most_spent desc
limit 10;

select avg(order_total) as average_order_value
from(select order_id, sum(price) as total_order
group by order_id)as order_totals;


select order_status , count(*) from orders
group by order_status
order by count(*) desc;

with customer_orders as
	(select c.customer_id , count(o.order_id) as total_orders,
	case when count(order_id) = 1 then 'one time'
	when count(order_id) > 1 then 'repeat orders'
	end as customer_type
	from orders o 
	join customers c on c.customer_id = o.customer_id
	group by c.customer_id
	HAVING COUNT(o.order_id) > 1)
	select customer_type ,count(customer_type) from customer_orders
	group by customer_type;


with customers_orders as (
select c.customer_unique_id , count(o.order_id),
case when count(o.order_id) = 1 then 'one time'
when count(o.order_id)> 1 then 'repeat customer'
end as customer_type
from customers c 
join orders o on c.customer_id = o.customer_id
group by c.customer_unique_id
)
select customer_type , count(*) from customers_orders
group  by customer_type
order by count(*) desc;


WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

customer_summary AS (
    SELECT
        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type,
        COUNT(*) AS total_customers
    FROM customer_orders
    GROUP BY
        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END
)

SELECT
    customer_type,
    total_customers,
    ROUND(
        100.0 * total_customers /
        SUM(total_customers) OVER (), 2
    ) AS customer_percentage
FROM customer_summary;


CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(12,2)
);

select * from order_payments
select * from orders



with average_customer as (select count(distinct order_id) as no_of_order , sum(payment_value) as total_revenue from order_payments)
select no_of_order, total_revenue,
ROUND(total_revenue::numeric / no_of_order,2) as average_cost
from average_customer;

select payment_type , sum(payment_value) as total_pay, count(distinct order_id) from order_payments
group by payment_type
order by total_pay desc;

select  sum(op.payment_value), date_trunc('month', o.order_purchase_timestamp) as order_month from orders o
join order_payments op on op.order_id = o.order_id
group by order_month
order by sum(op.payment_value) desc;

with order_delivery_percentage as (
select order_id , order_delivered_customer_date , order_estimated_delivery_date ,
case 
	when  order_delivered_customer_date > order_estimated_delivery_date then
	'late'
	else
	'on time'
	end as delivery_status from orders
	where order_status = 'delivered'
	AND order_delivered_customer_date IS NOT NULL
	AND order_estimated_delivery_date IS NOT NULL)
	select count(*) as total_orders ,round(count(case when delivery_status = 'late' then 1 end)*100.00/count(*),2) as late_percent , count(case
	when delivery_status = 'on time' then 1 end) as ontime_order,
	count(case when delivery_status = 'late' then 1 end) as late_order from order_delivery_percentage;

	






CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

select * from customers
select * from orders
select * from order_payments

select p.product_category_name , sum(o.price) as total_revenue
from products p 
join order_items o on o.product_id = p.product_id
group by p.product_category_name
order by total_revenue desc;

select COUNT(DISTINCT o.order_id) AS total_orders, c.customer_state , sum(op.payment_value) as revenue from customers c
join orders o on c.customer_id = o.customer_id 
join order_payments op on o.order_id = op.order_id
group by customer_state
order by revenue desc;










































