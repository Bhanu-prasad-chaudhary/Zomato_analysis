-- Zomato Data Analysis
DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
customer_id INT PRIMARY KEY,
name VARCHAR(20),
email VARCHAR(20),
phone VARCHAR(15),
city VARCHAR(15),
signup_date DATE
);
SELECT * FROM customers;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
order_id INT PRIMARY KEY,
customer_id INT,--fk
restaurant_id INT,--fk
order_date DATE,
order_amount FLOAT,
payment_mode VARCHAR(15),
order_status VARCHAR(15)
);
SELECT * FROM orders;
--adding foreign key
ALTER TABLE orders
ADD CONSTRAINT fl_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE orders
ADD CONSTRAINT fl_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES restaurants(restaurant_id);

DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants(
restaurant_id INT PRIMARY KEY,
restaurant_name VARCHAR(25),
cuisine_type VARCHAR(20),
city VARCHAR(15),
average_cost_for_two FLOAT,
rating FLOAT
);
SELECT * FROM restaurants;

DROP TABLE IF EXISTS riders;
CREATE TABLE riders(
rider_id  INT PRIMARY KEY,
rider_name  VARCHAR(20),
phone  VARCHAR(20),
vehicle_type  VARCHAR(20),
rating FLOAT,
age INT
);
SELECT * FROM riders;

DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries(
delivery_id	INT PRIMARY KEY, 
order_id  INT,----fk
rider_id INT,---fk
delivery_distance_km FLOAT,
delivery_time_mins FLOAT,
delivery_fee FLOAT,
rider_tip INT
 -- CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) -- this is another ways of creating foreign key with constriants
);
SELECT * FROM deliveries;
--adding foreign key 
ALTER TABLE deliveries
ADD CONSTRAINT fl_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT fl_rider
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);

--End of schemas



