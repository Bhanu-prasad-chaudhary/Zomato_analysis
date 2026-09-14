# Zomato Data Analysis SQL Project

## Project Overview

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to analyze food delivery data. The project involves creating a relational database containing customers, orders, restaurants, riders, and deliveries, performing data exploration and cleaning, and answering business-related questions using SQL queries.

The project focuses on customer behavior, restaurant performance, order trends, delivery performance, rider analysis, customer segmentation, and revenue analysis. It is ideal for beginners who are building practical SQL and data analytics skills through a business-oriented project.

## Objectives

1. **Set up a food delivery database**: Create and organize tables for customers, orders, restaurants, riders, and deliveries.
2. **Data Cleaning**: Identify records containing missing values and remove incomplete order records where required.
3. **Exploratory Data Analysis (EDA)**: Explore the available datasets and understand the relationships between different entities.
4. **Business Analysis**: Use SQL queries to answer real-world business questions related to customers, restaurants, orders, riders, and revenue.
5. **Performance Analysis**: Analyze restaurant revenue, rider delivery efficiency, customer spending, order frequency, and sales trends.

## Project Structure

### 1. Database Setup

![ERD](https://github.com/Bhanu-prasad-chaudhary/Zomato_analysis/blob/main/ERD.png)

The project contains five main tables:

* **customers** — stores customer information.
* **orders** — stores customer orders and order details.
* **restaurants** — stores restaurant information.
* **riders** — stores rider information.
* **deliveries** — stores delivery and rider performance information.

The `orders` table is connected with the `customers` and `restaurants` tables through foreign keys, while the `deliveries` table is connected with the `orders` and `riders` tables.

```sql
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    name VARCHAR(20),
    email VARCHAR(20),
    phone VARCHAR(15),
    city VARCHAR(15),
    signup_date DATE
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATE,
    order_amount FLOAT,
    payment_mode VARCHAR(15),
    order_status VARCHAR(15)
);

CREATE TABLE restaurants(
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(25),
    cuisine_type VARCHAR(20),
    city VARCHAR(15),
    average_cost_for_two FLOAT,
    rating FLOAT
);

CREATE TABLE riders(
    rider_id INT PRIMARY KEY,
    rider_name VARCHAR(20),
    phone VARCHAR(20),
    vehicle_type VARCHAR(20),
    rating FLOAT,
    age INT
);

CREATE TABLE deliveries(
    delivery_id INT PRIMARY KEY,
    order_id INT,
    rider_id INT,
    delivery_distance_km FLOAT,
    delivery_time_mins FLOAT,
    delivery_fee FLOAT,
    rider_tip INT
);
```

Foreign-key relationships were added between customers, restaurants, orders, deliveries, and riders to maintain relationships between the datasets.

### 2. Data Exploration & Cleaning

The project begins with exploratory queries to view the data from all five tables.

```sql
SELECT * FROM customers;
SELECT * FROM deliveries;
SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT * FROM riders;
```

The project also checks for missing values in the datasets. For example, customer records are checked for missing name, email, phone, city, and signup date values. Delivery records are checked for missing order, rider, distance, delivery time, delivery fee, and rider tip values.

Orders are also checked for missing customer, restaurant, date, amount, payment mode, and order status information. Records containing missing order information are deleted where required.

```sql
SELECT * FROM orders
WHERE
    customer_id IS NULL
    OR restaurant_id IS NULL
    OR order_date IS NULL
    OR order_amount IS NULL
    OR payment_mode IS NULL
    OR order_status IS NULL;
```

## 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

### 1. Top 5 Most Frequently Ordered Dishes by Customer

Find the top 5 most frequently ordered cuisine types by a specific customer, such as **Priya Nair**, during the last one year.

This analysis uses `JOIN`, `COUNT()`, `DENSE_RANK()`, filtering, and a subquery.

```sql
SELECT *
FROM
(
    SELECT
        cx.customer_id,
        cx.name,
        rs.cuisine_type,
        COUNT(*) AS total_orders,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
    FROM orders AS o
    JOIN customers AS cx
        ON o.customer_id = cx.customer_id
    JOIN restaurants AS rs
        ON o.restaurant_id = rs.restaurant_id
    WHERE
        order_date > CURRENT_DATE - INTERVAL '1 year'
        AND cx.name = 'Priya Nair'
    GROUP BY 1,2,3
) AS t1
WHERE rank <= 5;
```

### 2.popular time slots
Question:Identify the time slots during which  the most orders are placed . based on 2 hour intervals
FOR THIS WE HAVE NO order_time in colunme datasets so we have to  skip it
```sql
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
```

Another ways of solving this 
```sql
SELECT 
FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 AS start_time,
FLOOR(EXTRACT(HOUR FROM order_time)/2)*2+2 AS End_time,
COUNT(*) as total_orders
FROM orders
GROUP BY 1,2
ORDER By 3 DESC;
```

### 3. Average Order Value per Customer

Find the average order value for customers who have placed more than a specified number of orders.

```sql
SELECT
    o.customer_id,
    c.name,
    AVG(order_amount) AS avg_order_value,
    COUNT(order_id) AS total_order
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING COUNT(order_id) > 1 -- i have no more data so i am using 1 instead of 750 orders 
ORDER BY 4 DESC;
-- having is use for Filters groups  and after the 'group by'
```

### 4. High-Value Customers

Identify customers who have spent more than a specified amount across their orders.

```sql
SELECT
    o.customer_id,
    c.name,
    SUM(order_amount) AS total_spent
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING SUM(order_amount) > 1000;
```

### 5. Orders Without Deliveries

Find orders that were placed but were not delivered, along with the restaurant name, city, and order status.

```sql
SELECT
    o.order_id,
    rs.restaurant_name,
    rs.city,
    o.order_status
FROM orders AS o
LEFT JOIN restaurants AS rs
    ON o.restaurant_id = rs.restaurant_id
WHERE
    order_id NOT IN
    (
        SELECT order_id
        FROM orders
        WHERE order_status = 'Delivered'
    );
```

### 6. Restaurant Revenue Ranking

Rank restaurants according to their total revenue within each city.

```sql
WITH ranking_tables AS
(
    SELECT
        r.city,
        r.restaurant_name,
        SUM(o.order_amount) AS total_revenue,
        RANK() OVER
        (
            PARTITION BY r.city
            ORDER BY SUM(o.order_amount) DESC
        ) AS rank
    FROM orders AS o
    LEFT JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    GROUP BY 1,2
)
SELECT *
FROM ranking_tables
WHERE rank = 1;
```

### 7. Most Popular Dish by City

Identify the most popular cuisine type in each city based on the number of orders.

```sql
WITH ranking_tables AS
(
    SELECT
        r.city,
        r.cuisine_type,
        COUNT(*) AS number_of_orders,
        RANK() OVER
        (
            PARTITION BY r.city
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM orders AS o
    JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    GROUP BY 1,2
)
SELECT *
FROM ranking_tables
WHERE rank = 1;
```

### 8. Customer Churn

Find customers who placed orders in 2025 but did not place any orders in 2026.

```sql
SELECT DISTINCT customer_id
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2025
AND customer_id NOT IN
(
    SELECT DISTINCT customer_id
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2026
);
```

### 9. Cancellation Rate Comparison

Calculate and compare the cancellation rate for restaurants between 2025 and 2026.
```sql
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
```
The analysis uses multiple CTEs to calculate total orders, cancelled orders, and cancellation percentages for both years.

### 10. Rider Average Delivery Time

Determine the average delivery time for riders based on delivered orders.

```sql
SELECT
    o.order_id,
    d.rider_id,
    AVG(d.delivery_time_mins) AS avg_rider_delivery_time
FROM orders AS o
JOIN deliveries AS d
    ON o.order_id = d.order_id
WHERE order_status = 'Delivered'
GROUP BY 1,2;
```

### 11. Monthly Restaurant Growth Ratio

Calculate the monthly growth ratio of restaurants based on delivered orders.

The growth ratio is calculated using:

**Growth Ratio = ((Current Month Orders - Previous Month Orders) / Previous Month Orders) × 100**
```sql
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
```

The query uses the `LAG()` window function to compare the current month's orders with the previous month's orders.

### 12. Customer Segmentation

Segment customers into **Gold** and **Silver** groups based on their total spending compared with the average order value.

The analysis then calculates the total number of orders and total spending for each customer segment.

```sql
WITH customer_segment_table AS
(
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        SUM(order_amount) AS total_spent,
        CASE
            WHEN SUM(order_amount) >
                 (SELECT AVG(order_amount) FROM orders)
            THEN 'Gold'
            ELSE 'Silver'
        END AS cx_category
    FROM orders
    GROUP BY 1
)
SELECT
    cx_category,
    SUM(total_orders) AS total_order,
    SUM(total_spent) AS total_spent
FROM customer_segment_table
GROUP BY 1;
```

### 13. Rider Monthly Earnings

Calculate each rider's monthly earnings based on a percentage of the order amount.

```sql
SELECT
    d.rider_id,
    TO_CHAR(order_date,'MM-YY') AS month,
    SUM(order_amount) AS revenue,
    SUM(order_amount) * 0.8 AS rider_earning
FROM orders AS o
JOIN deliveries AS d
    ON o.order_id = d.order_id
GROUP BY 1,2
ORDER BY 1,2 DESC;
```

### 14. Rider Rating Analysis

Assign riders a rating based on their delivery time:

* Less than 20 minutes → **5 stars**
* 20–30 minutes → **4 stars**
* More than 30 minutes → **3 stars**

```sql
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
```

The query then counts the number of each rating received by every rider.


#### 15. Order Frequency by Day

Analyze order frequency by day of the week and identify the peak ordering day for each restaurant.

```sql
WITH freq_day_table AS
(
    SELECT
        r.restaurant_name,
        TO_CHAR(order_date,'Day') AS day,
        COUNT(order_id) AS total_orders,
        RANK() OVER
        (
            PARTITION BY r.restaurant_name
            ORDER BY COUNT(order_id) DESC
        ) AS rank
    FROM orders AS o
    JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    GROUP BY 1,2
)
SELECT *
FROM freq_day_table
WHERE rank = 1;
```

### 16. Customer Lifetime Value (CLV)

Calculate the total revenue generated by each customer across all their orders.

```sql
SELECT
    o.customer_id,
    c.name,
    COUNT(o.order_id) AS number_of_order,
    SUM(o.order_amount) AS CLV
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY 1,2;
```

### 17. Monthly Sales Trends

Analyze monthly sales trends by comparing each month's sales with the previous month's sales.

The query uses the `LAG()` window function to retrieve the previous month's total sales.

```sql
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(order_amount) AS total_sale,
    LAG(SUM(order_amount),1) OVER
    (
        ORDER BY
        EXTRACT(YEAR FROM order_date),
        EXTRACT(MONTH FROM order_date)
    ) AS perv_month_sale
FROM orders
GROUP BY 1,2;
```

### 18. Rider Efficiency

Evaluate rider efficiency by calculating the average delivery time and identifying the lowest and highest average delivery times among riders.

```sql
WITH new_table AS
(
    SELECT
        d.rider_id AS riders_id,
        d.delivery_time_mins AS deliveries_time
    FROM orders AS o
    JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE order_status = 'Delivered'
),
rider_time AS
(
    SELECT
        riders_id,
        AVG(deliveries_time) AS avg_deliveries_time
    FROM new_table
    GROUP BY 1
)
SELECT
    MIN(avg_deliveries_time),
    MAX(avg_deliveries_time)
FROM rider_time;
```

### 19. Order Item Popularity

Track the popularity of specific order items over different seasons and identify seasonal demand patterns.
```sql
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
```
The analysis categorizes orders into seasons and counts the number of orders for each cuisine type and season.

### 20. City Revenue Ranking

Rank each city according to its total revenue.

```sql
SELECT
    r.city,
    SUM(order_amount) AS total_revenue,
    RANK() OVER
    (
        ORDER BY SUM(order_amount) DESC
    ) AS city_rank
FROM orders AS o
JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id
GROUP BY 1;
```

## Findings

* **Customer Insights**: Customer behavior can be analyzed through order frequency, total spending, churn, and Customer Lifetime Value.
* **Restaurant Performance**: Restaurant revenue can be compared and ranked within cities.
* **Order Trends**: Monthly sales and daily order frequency can be used to identify ordering patterns.
* **Customer Segmentation**: Customers can be divided into Gold and Silver segments based on their spending.
* **Delivery Performance**: Rider delivery times can be analyzed to evaluate rider efficiency and assign performance-based ratings.
* **Cancellation Analysis**: Restaurant cancellation rates can be compared between different years.
* **City Performance**: Cities can be ranked based on their total revenue.
* **Seasonal Demand**: Cuisine popularity can be analyzed across different seasons.

## Reports

* **Customer Analysis**: Customer spending, churn, segmentation, order frequency, and CLV.
* **Restaurant Analysis**: Restaurant revenue ranking, popular cuisine types, and cancellation rates.
* **Sales Analysis**: Monthly sales trends and city revenue ranking.
* **Rider Analysis**: Delivery time, rider efficiency, monthly earnings, and rating analysis.
* **Order Analysis**: Order frequency, high-value customers, undelivered orders, and seasonal popularity.

## Conclusion

This project provides a practical introduction to SQL-based data analysis using a food delivery dataset. It covers database design, data cleaning, exploratory data analysis, joins, aggregations, CTEs, subqueries, CASE statements, and window functions.

The analysis demonstrates how SQL can be used to answer business questions related to customers, restaurants, orders, riders, deliveries, revenue, and customer behavior.

This project also provides a strong foundation for developing practical data analyst skills by applying SQL to real-world business scenarios.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `Schemas.sql` file to create the database tables and relationships.
3. **Import the Data**: Import the relevant datasets into the corresponding tables.
4. **Run the Analysis Queries**: Execute the queries provided in the `Analytic part.sql` file.
5. **Explore and Modify**: Modify the queries to explore additional customer, restaurant, rider, delivery, and sales insights.

## Author - Bhanu Prasad Chaudhary

This project is part of my portfolio, showcasing my SQL and PostgreSQL skills as I build my career in data analytics.

I am a Computer Engineering graduate with an interest in Data Analytics, Data Science, SQL, and Machine Learning. This project demonstrates my practical experience with PostgreSQL and my ability to use SQL to explore datasets and answer business-related questions.

## Skills Demonstrated

PostgreSQL
SQL
Data Cleaning
Exploratory Data Analysis
Data Aggregation
JOINs
CTEs
Subqueries
Window Functions
RANK()
DENSE_RANK()
LAG()
CASE Statements
GROUP BY
HAVING
Customer Segmentation
Revenue Analysis
Customer Lifetime Value (CLV)
Rider Performance Analysis
Business Analysis

## Connect With Me

GitHub: https://github.com/Bhanu-prasad-chaudhary/Zomato_analysis

LinkedIn: https://www.linkedin.com/in/bhanu-chaudhary-7a84082a4/

Email: [chaudharybhanu20178@gmail.com](mailto:chaudharybhanu20178@gmail.com)

## Credits

This project was created as part of my SQL and data analytics learning journey. It focuses on applying PostgreSQL and SQL techniques to analyze food delivery data and answer practical business questions.

Thank you for visiting my project!
