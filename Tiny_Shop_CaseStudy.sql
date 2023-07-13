
-- Case Study Questions

-- 1 Which product has the highest price? Only return a single row.

SELECT 
* 
FROM products 
WHERE price= (SELECT MAX(price) FROM products);


-- 2 Which customer has made the most orders?

WITH max_cnt AS (
SELECT 
  	count(*) as cnt,
  	customer_id 
FROM orders 
GROUP BY customer_id 
ORDER BY cnt DESC)

SELECT 
 	b.customer_id,
        a.first_name,
        a.last_name
FROM customers a JOIN max_cnt b ON a.customer_id = b.customer_id  
WHERE cnt in  (SELECT MAX(cnt) FROM max_cnt)
ORDER BY a.customer_id;


-- 3 What’s the total revenue per product?

WITH CTE AS (
SELECT 
	SUM(quantity) as num,
	product_id 
FROM order_items 
GROUP BY product_id
ORDER BY product_id)

SELECT
	b.price*a.num as total_revenue,
    a.product_id,
    b.product_name
FROM CTE a JOIN products b ON a.product_id=b.product_id

-- 4 Find the day with the highest revenue.

SELECT 
	o.order_date,
    SUM(ot.quantity*p.price) as revnue
FROM orders o 
JOIN order_items ot ON o.order_id=ot.order_id 
JOIN products p ON p.product_id=ot.product_id
GROUP BY o.order_date
ORDER BY revnue desc 
LIMIT 1;

-- 5 Find the first order (by date) for each customer.

SELECT a.*,min(b.order_date) 
FROM customers a 
LEFT JOIN orders b ON a.customer_id=b.customer_id 
GROUP BY a.customer_id
ORDER BY a.customer_id;

-- 6. Find the top 3 customers who have ordered the most distinct products

   select concat(c.first_name,' ',c.last_name) as CustomerName, count(distinct product_id) as TotalDistinctProducts
   from customers c inner join orders o using(customer_id)
   inner join order_items oi using(order_id)
   group by 1
   order by 2 desc
   limit 3;
   

-- 7 Which product has been bought the least in terms of quantity?

with cte as (select sum(quantity) as quan,order_items.product_id,products.product_name from order_items join products on products.product_id=order_items.product_id group by order_items.product_id,products.product_name order by quan asc)
select * from (select dense_rank() over(order by quan) as rnk,product_name from cte) x where rnk=1;

-- 8 What is the median order total?
    with TotalOrders as
    (
    select o.order_id,SUM(oi.quantity*p.price) as TotalRevenue
    from order_items oi inner join products p using(product_id)
    inner join orders o using(order_id)
    group by o.order_id)
    select avg(totalrevenue) as median_order_total
    from ( select totalrevenue, Ntile(2) over (partition by totalrevenue) as quartile
    from totalorders) median_query where quartile =1 or quartile=2;





-- 9 For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

with cte as(
select orders.order_id,sum((oi.quantity*price)) as total_price from orders join order_items oi using(order_id)
join products using (product_id)
group by 1)
select *,case when total_price>300 then 'Expensive' 
when total_price>100 then 'Affordable' 
when total_price<=100 then 'Cheap' end
from cte;

-- 10 Find customers who have ordered the product with the highest price.

 select concat(first_name,' ',last_name) as Name from order_items 
 inner join  orders using(order_id) 
 inner join customers using(customer_id) 
 where product_id in (select product_id from products where price in (select max(price) from products))
