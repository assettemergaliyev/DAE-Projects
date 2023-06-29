-- Case Study #1 - Danny's Diner

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
	"customer_id" VARCHAR(1),
	"order_date" DATE,
	"product_id" INTEGER
);

INSERT INTO sales
	("customer_id", "order_date", "product_id")
VALUES
	('A', '2021-01-01', '1'),
	('A', '2021-01-01', '2'),
	('A', '2021-01-07', '2'),
	('A', '2021-01-10', '3'),
	('A', '2021-01-11', '3'),
	('A', '2021-01-11', '3'),
	('B', '2021-01-01', '2'),
	('B', '2021-01-02', '2'),
	('B', '2021-01-04', '1'),
	('B', '2021-01-11', '1'),
	('B', '2021-01-16', '3'),
	('B', '2021-02-01', '3'),
	('C', '2021-01-01', '3'),
	('C', '2021-01-01', '3'),
	('C', '2021-01-07', '3');
 

CREATE TABLE menu (
	"product_id" INTEGER,
	"product_name" VARCHAR(5),
	"price" INTEGER
);

INSERT INTO menu
	("product_id", "product_name", "price")
VALUES
	('1', 'sushi', '10'),
	('2', 'curry', '15'),
	('3', 'ramen', '12');
  

CREATE TABLE members (
	"customer_id" VARCHAR(1),
	"join_date" DATE
);

INSERT INTO members
	("customer_id", "join_date")
VALUES
	('A', '2021-01-07'),
	('B', '2021-01-09');


-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_amount_spent
FROM sales s 
INNER JOIN menu m ON s.product_id = m.product_id 
GROUP BY s.customer_id 
ORDER BY total_amount_spent DESC;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(order_date) AS days_visited
FROM sales 
GROUP BY customer_id 
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT s.customer_id, m.product_name AS first_purchase
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date = (
    SELECT MIN(order_date)
    FROM sales
    WHERE customer_id = s.customer_id
);

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(m.product_name) AS quantity
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY quantity DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS most_popular_item
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING COUNT(*) = (
	SELECT MAX(cnt) 
	FROM (
		SELECT customer_id, COUNT(*) AS cnt
		FROM sales
		GROUP BY customer_id, product_id
	) AS counts
	WHERE s.customer_id = counts.customer_id
)
ORDER BY most_popular_item DESC;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT m.customer_id, m.product_name AS first_purchase_after_membership
FROM (
	SELECT s.customer_id, m.product_name, s.order_date,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
	FROM sales s
	INNER JOIN menu m ON s.product_id = m.product_id
	INNER JOIN members mem ON s.customer_id = mem.customer_id
	WHERE s.order_date > mem.join_date
) AS m
WHERE m.rn = 1;

--7. Which item was purchased just before the customer became a member?
SELECT m.customer_id, m.product_name AS last_purchase_before_membership
FROM (
	SELECT s.customer_id, m.product_name, s.order_date,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn
	FROM sales s
	INNER JOIN menu m ON s.product_id = m.product_id
	INNER JOIN members mem ON s.customer_id = mem.customer_id
	WHERE s.order_date < mem.join_date
) AS m
WHERE m.rn = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT m.product_name, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_amount
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date OR mem.join_date IS NULL
GROUP BY m.product_name
ORDER BY total_amount DESC;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(m.price) AS total_amount,
	SUM(CASE 
			WHEN m.product_name = 'sushi' THEN (m.price * 2) * 10
			ELSE m.price * 10
		END
	 ) AS total_points
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_points DESC;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id, 
	SUM(CASE 
			WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + INTERVAL '7 days' THEN (m.price * 2) * 10
			ELSE m.price * 10
		END
	 ) AS total_points
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
INNER JOIN members mem ON s.customer_id = mem.customer_id 
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
 