--EDA
SELECT * FROM customers;
SELECT * FROM deliveries;
SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT * FROM riders;

--IMPORT DATASETS


-- DATA CLEANING
SELECT COUNT(*) FROM customers
WHERE
name IS NULL
OR
email IS NULL
OR 
phone IS NULL
OR 
city IS NULL
OR
signup_date IS NULL;


SELECT COUNT(*) FROM deliveries
WHERE
order_id IS NULL
OR
rider_id IS NULL
OR 
delivery_distance_km IS NULL
OR 
delivery_time_mins IS NULL
OR
delivery_fee IS NULL
OR 
rider_tip IS NULL
;

SELECT * FROM orders
WHERE
customer_id IS NULL
OR
restaurant_id IS NULL
OR 
order_date IS NULL
OR 
order_amount IS NULL
OR
payment_mode IS NULL
OR 
order_status IS NULL
;

DELETE FROM orders
WHERE
customer_id IS NULL
OR
restaurant_id IS NULL
OR 
order_date IS NULL
OR 
order_amount IS NULL
OR
payment_mode IS NULL
OR 
order_status IS NULL
;

INSERT INTO orders(order_id,customer_id,restaurant_id)
VALUES
(1031,119,210),
(1032,120,204),
(1034,103,206);



-----  ------------------
--Analysis and Report
--- -----------------


--Q.1) write the query to find top 5 most frequently ordered dishes by customer called "Priya Nair" in the last 1 year
--join cx and order
--fliter for last 1 year and --'Priya Nair'
--group by cx id and dishes , count
SELECT * 
FROM
   (SELECT 
	cx.customer_id,
	cx.name,
	rs.cuisine_type,-- dishes
	COUNT(*) as total_orders,-- most frequent order
	DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank -- THIS IS WINDOW FUNC IF SAME TYPE OF ORDER VAULES AND SO WE HAVE TO USE RANK FUNC
	
	FROM orders as o
	JOIN 
	   customers as cx
	ON
	 o.customer_id = cx.customer_id
	 
	 JOIN
	 restaurants as rs
	 ON 
	 o.restaurant_id = rs.restaurant_id
	 
	WHERE 
	
	
	order_date > CURRENT_DATE - INTERVAL'1Year'
	 AND 
	  cx.name = 'Priya Nair'
	
	 GROUP BY 1,2,3
	 ORDER BY 1,4 DESC) AS t1

 WHERE  rank <= 5;--here we are using the subquery as t1 (table for other) beacuse after completeing subqueries we can use where rank inside the subquery so we have to do such thing
 
 -- i have not so much dataset it will show only two of them but this code is for top 5 


--2.popular time slots
--Question:Identify the time slots during which  the most orders are placed . based on 2 hour intervals
-- FOR THIS WE HAVE NO order_time in colunme datasets so we have to  skip it
/*
SELECT
    CASE
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 24:00'
	END AS time_slot
	COUNT(order_id) As order_count
FROM orders
GROUP BY time_slot
ORDER by order_count DESC;
*/

/*Another ways of solving this 

SELECT 
FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 AS start_time,
FLOOR(EXTRACT(HOUR FROM order_time)/2)*2+2 AS End_time,
COUNT(*) as total_orders
FROM orders
GROUP BY 1,2
ORDER By 3 DESC;
*/


--order values anlaysis
--Q3)Find th average order value per customer who has placed more than 750 orders

SELECT
  o.customer_id,
  c.name,
  AVG(order_amount) as avg_order_value,
  COUNT(order_id) AS total_order
FROM orders as o
JOIN 
 customers as c
ON 
 o.customer_id = c.customer_id
GROUP BY 1,2
HAVING  count(order_id) > 1 --- i have no more data so i am using 1 instead of 750 orders 
ORDER BY 4 DESC;
-- having is use for Filters groups  and after the 'group by'


--4) High value customers
-- list the customers  who have spent more than 100 k in total orders
-- return customer_id and customer_name
SELECT
  o.customer_id,
  c.name,
  SUM(order_amount) as total_spent
  
FROM orders as o
 JOIN 
 customers as c
 ON 
 o.customer_id = c.customer_id
 GROUP BY 1,2
 HAVING SUM(order_amount)> 1000; -- i have less data therefore  i am using 1000 instead of 100k
 

--5)order without deliveries
--Q) write the query to find orders that were placed but not deliveries
-- return each restaurant name, city and number  of  not deilvered orders

SELECT 
o.order_id,
rs.restaurant_name,
rs. city,
o.order_status
FROM orders as o
LEFT JOIN restaurants as rs -- HERE we use left join in place of join only because order are not deliverd in orders table but information in restaurants table 
on o.restaurant_id= rs.restaurant_id
WHERE
  order_id  NOT IN ( SELECT order_id FROM orders WHERE order_status ='Delivered')
  -- this last is using like this beacause if we have NULL values and not fill values it also return in down comment we must add order_status of null values and not filled by usinf OR It become lengthly 
-- instead of last line we can write order_status='Cancelled'

--6) restaurant revenue ranking
-- rank  restaurants by their total revenue from the last year, including their name
--total revenue, and rank within city
WITH ranking_tables
AS

 ( SELECT 
	r.city,
	r.restaurant_name,
	SUM(o.order_amount) as total_revenue,
	RANK() OVER( PARTITION BY R.CITY ORDER BY SUM(o.order_amount)DESC) AS RANK
	FROM orders as o 
	LEFT JOIN 
	restaurants as r
	ON 
	o.restaurant_id = r.restaurant_id
	GROUP BY 1, 2
	ORDER BY 1,3 DESC
)
SELECT * 
FROM ranking_tables
WHERE RANK = 1 --- THIS line gives rank 1 according to city 
-- sub-queries:gives rank by city and order_amount


--Q7) Most Popular Dish by city;
-- idenitfy the most popular dish in each city based on the number of orders
WITH ranking_tables
AS
(
SELECT r.city,
      r.cuisine_type,
	  count(*) as number_of_orders,-- here in palce of * we can use order_id it mean same
	  rank() over(partition by r.city order by count(*) desc) as rank
FROM orders as o 
JOIN 
   restaurants as r
   ON
   o.restaurant_id = r.restaurant_id
group by 1,2
order by 3 desc 
)
SELECT * 
FROM ranking_tables
WHERE RANK = 1

--Q8)customer churn
-- find the customers who haven't placed an order in 2026 but did it in 2025
SELECT DISTINCT customer_id
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2025
      AND
	  customer_id NOT IN (
                           SELECT DISTINCT customer_id
							FROM orders
							WHERE EXTRACT(YEAR FROM order_date) = 2026
	                       );
	  
--Q9)cancellation rate comparsion
--calcaute and compare the order cancellation rate for each restaurants between the
--current date and the pervious year

WITH cancel_ratio_25
AS
  (  SELECT 
	 restaurant_id,
	 COUNT(order_id) AS total_order, 
	 COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END ) as Not_deilvered -- may not delivered are null therefire we can write order_status IS  NULL
	FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 2025
	GROUP BY 1
	), 

 cancel_ratio_26
AS
	(  SELECT 
		 restaurant_id,
		 COUNT(order_id) AS total_order, 
		 COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END ) as Not_deilvered -- may not delivered are null therefire we can write order_status IS  NULL
		FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 2026
	GROUP BY 1
),
last_year_date
as
(	SELECT
	restaurant_id,
	total_order,
	Not_deilvered,
	ROUND(
	Not_deilvered :: numeric /total_order :: numeric*100,2)
	AS canellation_ratio
	FROM cancel_ratio_25
),
current_year_date
as
(SELECT
restaurant_id,
total_order,
Not_deilvered,
ROUND(
Not_deilvered :: numeric /total_order :: numeric*100,2)
AS canellation_ratio
FROM cancel_ratio_26
)
SELECT
	current_year_date.restaurant_id as rest_id,
	current_year_date.canellation_ratio as cur_ratio,
	last_year_date.canellation_ratio AS lst_ration
FROM
	current_year_date
JOIN
	last_year_date
ON 
	current_year_date.restaurant_id = last_year_date.restaurant_id

 
--Q10) rider average delivery time
--determine  each rider's average delivery time ()
SELECT
o.order_id,
d.rider_id,
AVG(d.delivery_time_mins) AS avg_rider_delivery_time
 FROM orders as o

JOIN 
    deliveries as d
ON
	o.order_id = d.order_id
WHERE 
    order_status = 'Delivered'
GROUP BY 1,2
--this is according to my table but if order time and delivery time are given (delivery time - order time)
--if time is given in hour: min: sec then
--delivery time - order time this will not give us perfect answer so we have to use epoch
-- SELECT EXRTACT(EPOCH FROM (delivery time - order time + CASE WHEN delivery time < order time THEN INTERVAL '1 day' ELSE INTERVAL 'o day' END))/60 AS time_difference_insec
-- epoch give use in sec so we have to convert into min therefore we divded by 60

--Q11) monthly restaurant growth ratio
-- calculate each  restaurants growth ratio based on the total number of delivered order since its joining
--Growth_ratio=((current-pervious)/perivous)*100
WITH growth_ratio
AS
(
SELECT
restaurant_id,
TO_CHAR(order_date,'mm-yy') as month,
COUNT(order_id) as crt_month_orders,
LAG(COUNT(order_id),1) OVER(PARTITION BY restaurant_id ORDER BY TO_CHAR(order_date,'mm-yy') ) AS prev_month_order
FROM orders   
WHERE 
order_status ='Delivered'
GROUP BY 1,2
ORDER BY 1,2
)

SELECT
		restaurant_id,
		month,
		crt_month_orders,
		 prev_month_order,
		 ROUND(((crt_month_orders:: numeric -  prev_month_order::numeric)/ prev_month_order:: numeric)*100,1) AS growth_ratio
FROM growth_ratio
 
--Q12) customer segmentation
----customer segmentation- segment customer  into 'Gold' or 'silver' group based on thier total spending
--compared  to average order value (aov). if customer's total spending exceeds the aov,
--label them as 'Gold'; otherwise them as 'silver'.write the sql query to each segment's
--total number of orders and total revnuew
WITH customer_segment_table
AS
(
SELECT 
		customer_id,
		COUNT(order_id) as total_orders,
		SUM(order_amount) as total_spent,
		CASE
		    WHEN
			SUM(order_amount)>(SELECT  AVG(order_amount)  FROM orders) THEN 'Gold'
			ELSE 'Silver'
		END	as cx_category
FROM orders
GROUP BY 1)
SELECT
    cx_category,
	SUM(total_orders) AS total_order,
	SUM(total_spent) AS total_spent
FROM customer_segment_table
GROUP by 1

---Q13)rider monthly earning
--calculate each rider's  total monthly earning, assuming  they earn 8% of the order amount
SELECT
   d.rider_id,
   TO_CHAR(order_date,'mm-yy') as month,
   SUM(order_amount) AS revenue,
   SUM(order_amount)* 0.8 as rider_earning
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
GROUP BY 1,2
ORDER BY 1,2 DESC

--Q14)rider  rating analysis
-- find the number of 5-star, 4-star, and 3- star rating each rider  has.
--rider receive the rating by the delivery time
--if  orders are delivered less than 20 minutes of order recived time the rider get 5-star rating,
--if they delivers 20 and 30 min they get 4-star rating
-- if they delivers after 30 min they get 3-star rating

WITH T1
as
(
SELECT 
o.order_id,
d.rider_id,
delivery_time_mins  as delivery_took_time
FROM orders as o
JOIN  deliveries as d
ON o.order_id = d.order_id
WHERE order_status = 'Delivered'
), 
T2 AS
(SELECT
rider_id,
delivery_took_time,
CASE
    WHEN delivery_took_time < 20 THEN '5'
	WHEN delivery_took_time BETWEEN 20 AND 30 THEN '4'
	ELSE '3'
END AS stars
FROM T1)

SELECT 
	rider_id,
	stars,
	COUNT(stars::INT) as total_stars
FROM T2
GROUP BY 1,2
ORDER BY 1,2 DESC


--this is according to my table but if order time and delivery time are given (delivery time - order time)
--if time is given in hour: min: sec then
--delivery time - order time this will not give us perfect answer so we have to use epoch
-- SELECT EXRTACT(EPOCH FROM (delivery time - order time + CASE WHEN delivery time < order time THEN INTERVAL '1 day' ELSE INTERVAL 'o day' END))/60 AS time_difference_insec
-- epoch give use in sec so we have to convert into min therefore we divded by 60 
--  we have to this process in delivery_time_mins


--Q15) order frequency by day
-- anlayze orders frequency per day of the week and identify the peak day for each restaurants
WITH freq_day_table
AS
(
SELECT 
   r.restaurant_name,
   TO_CHAR(order_date,'Day') as  day,
   COUNT(order_id) as total_orders,
   RANK() OVER( PARTITION BY r.restaurant_name ORDER BY  COUNT(order_id) DESC ) AS RANK
  FROM orders as o
 JOIN restaurants as r
 ON 
 o.restaurant_id = r. restaurant_id
 GROUP BY 1,2
 )
 SELECT * 
 FROM freq_day_table
 WHERE rank =1


--Q16) customer life value (CLV)
-- calculate the total revenue generated by  each customer all over their orders
SELECT 
    o.customer_id,
	c.name,
	COUNT(o.order_id) as number_of_order,
	SUM(o.order_amount) as CLV
FROM orders as o
JOIN customers as c
ON 
   o.customer_id = c.customer_id
 GROUP BY 1,2
   

--Q17) monthly sales trends:
--identify sales trends by comparing  each month's to the perivous month
SELECT 
   EXTRACT(YEAR FROM order_date) as year,
   EXTRACT(MONTH FROM order_date) as month,
   SUM(order_amount) as total_sale,
   LAG(SUM(order_amount),1) OVER(ORDER BY EXTRACT(YEAR FROM order_date),EXTRACT(MONTH FROM order_date)) AS perv_month_sale
FROM orders
GROUP BY 1,2

--Q18)Rider efficiency
--evalute rider eifficiency by determining times and identifying those  with the lowest and highest averages
WITH new_table
AS
(
  SELECT 
  d.rider_id AS riders_id,
  d.delivery_time_mins as deliveries_time
  FROM orders as o
  JOIN deliveries as d
  ON 
     o.order_id = d.order_id
  WHERE order_status = 'Delivered'
),
rider_time
AS
(
SELECT
      riders_id,
	AVG(deliveries_time) AS AVG_deliveries_time
FROM new_table	
GROUP BY 1
)
SELECT 
      MIN(AVG_deliveries_time),
	  MAX(AVG_deliveries_time)
FROM rider_time

--Q19)order item  popularity
--track the popularity of specific order items over time and  identify seasonal demand spikes
SELECT 
    order_items,
	seasons,
	COUNT(order_id) as total_orders
FROM
(
SELECT *,
      EXTRACT( MONTH FROM o.order_date) as month,
	  CASE
	      WHEN EXTRACT( MONTH FROM o.order_date) BETWEEN 4 AND 6 THEN 'spring'
		  WHEN EXTRACT( MONTH FROM o.order_date) > 6 AND EXTRACT( MONTH FROM order_date)< 9 THEN 'summer'
		  ELSE 'winter' 
	  END as seasons,
	  cuisine_type as order_items 
FROM orders as o
JOIN restaurants as r
ON o.restaurant_id = r.restaurant_id) AS T1
GROUP BY 1,2
order by 1,3 desc

--Q20)rank each city  based on  the total revenue  for last year 
SELECT
     r.city,
	 SUM(order_amount) as total_revenue,
	 RANK() OVER(ORDER BY  SUM(order_amount) DESC )AS city_rank
FROM orders as o
JOIN restaurants as r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1
	 