-- Restaurant Owner
-- 5 Table
-- 1x Fact, 4 Dimensions
-- search how to add foreign key
-- write SQL 3-5 queries analyze data
-- 1x subqurry/ with

-- sqlite command
.mode markdown
.head on

-- Create & Insert Into Values dim_customer
CREATE TABLE dim_customer (
  customer_id INT UNIQUE NOT NULL PRIMARY KEY,
  firstname VARCHAR(255) NOT NULL,
  lastname VARCHAR(255) NOT NULL,
  age INT,
  phone_number TEXT
);

INSERT INTO dim_customer VALUES
  (1, 'Neo', 'Houseseller', 25, '0957894025'),
  (2, 'Wanchaloem', 'Wasser', 24, '0890544451'),
  (3, 'Inanis', 'Ninomae', 45, '0895062185'),
  (4, 'Oga', 'Aragami', 31, '0846184945'),
  (5, 'Polka', 'Omaru', 18, '0626546788');


-- Create & Insert Into Values dim_food
CREATE TABLE dim_food (
  food_id INT UNIQUE NOT NULL PRIMARY KEY,
  type_id INT NOT NULL,
  food_name TEXT NOT NULL,
  price REAL,
  FOREIGN KEY (type_id) REFERENCES dim_type(type_id)
);

INSERT INTO dim_food VALUES 
  (1, 1, 'French Fries', 69),
  (2, 1, 'Garlic Bread', 79),
  (3, 2, 'Pork Steak', 129),
  (4, 2, 'Chicken Steak', 119),
  (5, 3, 'Water', 20),
  (6, 3, 'Coke', 20);


-- Create & Insert Into Values dim_types for dim_foods
CREATE TABLE dim_type (
  type_id INT UNIQUE NOT NULL PRIMARY KEY,
  type_name TEXT
);

INSERT INTO dim_type VALUES 
  (1, 'Appetizer'),
  (2, 'Main Dish'),
  (3, 'Beverage');


-- Create & Insert Into Values dim_staff
CREATE TABLE dim_staff (
  staff_id INT UNIQUE NOT NULL PRIMARY KEY,
  staff_name VARCHAR(255)
);

INSERT INTO dim_staff VALUES 
  (1, 'Tete'),
  (2, 'Sompong');


-- Create & Insert Into Values dim_location
CREATE TABLE dim_location (
  location_id INT UNIQUE NOT NULL PRIMARY KEY,
  location_name VARCHAR(3)
);

INSERT INTO dim_location VALUES 
  (1, 'UDT'),
  (2, 'BKK');


-- Create & Insert Into Values fact_order
CREATE TABLE fact_order (
  order_id INT UNIQUE NOT NULL PRIMARY KEY,
  order_date TEXT,
  customer_id INT,
  food_id INT,
  amount INT,
  staff_id INT,
  location_id INT,
  FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  FOREIGN KEY (food_id) REFERENCES dim_food(food_id),
  FOREIGN KEY (staff_id) REFERENCES dim_staff(staff_id),
  FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);

INSERT INTO fact_order VALUES
  (1, '2022-08-22', 1, 2, 1, 1, 1),
  (2, '2022-08-22', 1, 3, 1, 1, 1),
  (3, '2022-08-22', 1, 6, 1, 1, 1),
  (4, '2022-08-23', 2, 1, 1, 1, 1),
  (5, '2022-08-23', 2, 4, 1, 1, 1),
  (6, '2022-08-23', 2, 5, 1, 1, 1),
  (7, '2022-08-23', 3, 1, 1, 2, 2),
  (8, '2022-08-23', 3, 4, 1, 2, 2),
  (9, '2022-08-23', 3, 5, 1, 2, 2),
  (10, '2022-08-24', 4, 2, 1, 2, 2),
  (11, '2022-08-24', 4, 3, 1, 2, 2),
  (12, '2022-08-24', 4, 6, 1, 2, 2),
  (13, '2022-08-25', 3, 1, 1, 2, 2),
  (14, '2022-08-25', 3, 4, 1, 2, 2),
  (15, '2022-08-25', 3, 5, 1, 2, 2),
  (16, '2022-08-25', 5, 2, 1, 2, 2),
  (17, '2022-08-25', 5, 3, 1, 2, 2),
  (18, '2022-08-26', 1, 6, 1, 1, 1),
  (19, '2022-08-26', 1, 4, 1, 1, 1),
  (20, '2022-08-27', 2, 5, 1, 1, 1),
  (21, '2022-08-27', 1, 2, 1, 1, 1);

-- Create subqurry/ WITH

WITH sub AS (
SELECT 
  f_o.order_id,
  f_o.order_date,
  d_cus.lastname || ' ' || firstname AS customer_name,
  d_stf.staff_name,
  d_fd.food_id,
  d_fd.food_name,
  f_o.amount,
  d_fd.price
FROM fact_order AS f_o
JOIN dim_staff AS d_stf ON f_o.staff_id = d_stf.staff_id
JOIN dim_food AS d_fd ON f_o.food_id = d_fd.food_id
JOIN dim_customer AS d_cus ON f_o.customer_id = d_cus.customer_id
)

-- Qurry for Sompong's sale
  
SELECT 
  COUNT(*) AS transection,
  SUM(price) AS total_sale,
  ROUND(AVG(price)) AS avg_sale
FROM sub
WHERE staff_name = 'Sompong';

-- Qurry for best seller item

WITH sub AS (
SELECT 
  f_o.order_id,
  f_o.order_date,
  d_cus.lastname || ' ' || firstname AS customer_name,
  d_stf.staff_name,
  d_fd.food_id,
  d_fd.food_name,
  f_o.amount,
  d_fd.price
FROM fact_order AS f_o
JOIN dim_staff AS d_stf ON f_o.staff_id = d_stf.staff_id
JOIN dim_food AS d_fd ON f_o.food_id = d_fd.food_id
JOIN dim_customer AS d_cus ON f_o.customer_id = d_cus.customer_id
)

SELECT 
  food_id,
  food_name,
  COUNT(food_name) AS n_order
FROM sub
GROUP BY food_id
ORDER BY n_order DESC
LIMIT 3;

-- Qurry for most spending customer

WITH sub AS (
SELECT 
  f_o.order_id,
  f_o.order_date,
  d_cus.lastname || ' ' || firstname AS customer_name,
  d_stf.staff_name,
  d_fd.food_id,
  d_fd.food_name,
  f_o.amount,
  d_fd.price
FROM fact_order AS f_o
JOIN dim_staff AS d_stf ON f_o.staff_id = d_stf.staff_id
JOIN dim_food AS d_fd ON f_o.food_id = d_fd.food_id
JOIN dim_customer AS d_cus ON f_o.customer_id = d_cus.customer_id
)

SELECT 
  customer_name,
  sum(price) AS total_spending,
  avg(price) AS avg_spending
FROM sub
ORDER BY sum(price);

-- AVG sale per day

SELECT 
  COUNT(f_o.order_id) AS transection,
  f_o.order_date,
  COUNT(f_o.order_date) AS n_order,
  SUM(d_fd.price) AS sale_per_day
FROM fact_order AS f_o 
JOIN dim_food AS d_fd ON f_o.food_id = d_fd.food_id
GROUP BY f_o.order_date;

-- Create email for staff

SELECT 
  staff_name,
  LOWER(staff_name) || "@fakesteakeshop.com" AS Staff_email
FROM dim_staff;