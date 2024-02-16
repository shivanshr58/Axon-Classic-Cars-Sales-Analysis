-- Axon Data Analysis-SQL

-- 1. Order numbers and total sales from 2003 until 2005 which order status is finished
SELECT YEAR(orderdate) Year,SUM(priceeach * quantityordered) Sales, COUNT(ordernumber) Num_orders
FROM orders
JOIN orderdetails using(ordernumber)
GROUP BY YEAR(orderdate);

-- 2. Total sales for each sub-category of product on 2004 and 2005 and growth rate

WITH cte AS(SELECT productcode,productName, YEAR(orderdate) year,SUM(priceeach * quantityordered) Total_Sales
FROM  orders
JOIN orderdetails using(ordernumber)
JOIN products using(productcode)
GROUP BY productcode,productName,YEAR(orderdate)),
cte2 AS(SELECT productcode,productname, SUM(CASE WHEN year = '2003' THEN Total_Sales ELSE 0 END) sales_2003,
SUM(CASE WHEN year = '2004' THEN Total_Sales ELSE 0 END) sales_2004
FROM cte
GROUP BY productcode,productname)
SELECT *,ROUND(((sales_2004-sales_2003)/sales_2003) * 100,2) Growth_pct
FROM cte2;

-- 3. The number of customers and number of shipped orders for each year

SELECT  YEAR(orderdate) Year,COUNT(DISTINCT(customerNumber)) Num_Customers,Count(ordernumber) Num_Orders_Shipped
FROM orders
WHERE status = 'shipped'
GROUP BY 1;

-- 4. The number of new customers for each year

SELECT Year_Acquired Year, COUNT(*) Num_NewCustomers
FROM (SELECT customernumber,MIN(YEAR(orderdate)) Year_Acquired
FROM orders
GROUP BY 1) new_customers
GROUP BY Year_Acquired
UNION 
SELECT 2005,0 ;

-- 5. Repeat customers
SELECT customernumber,CONCAT(contactFirstName,' ',contactLastName) Name,COUNT(ordernumber) num_orders
FROM orders
JOIN customers using(customernumber)
WHERE status = 'shipped'
GROUP BY 1,2
HAVING 3>1
ORDER BY 3 DESC;
