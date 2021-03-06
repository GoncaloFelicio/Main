USE classicmodels;

-- -- SELECT year(o.orderDate) as year, COUNT(o.orderNumber) as orders_count
-- -- FROM orders o
-- -- WHERE o.status = 'Shipped'
-- -- GROUP BY year
-- ;

-- Question 1a
SELECT 
	e.employeeNumber as EmployeeNumber,
    e.lastName,
    e.firstName,
	count(e.employeeNumber ) as NumberSales
FROM 
	employees e 
INNER JOIN customers c
	ON EmployeeNumber = c.salesRepEmployeeNumber
INNER JOIN orders o
	ON c.customerNumber = o.customerNumber
WHERE o.status = 'Shipped'
GROUP BY EmployeeNumber
ORDER BY NumberSales DESC
;


-- Question 1b

SELECT
	c.salesRepEmployeeNumber as EmployeeNumber,
	SUM(od.priceEach*od.quantityOrdered) as totalRevenue_perEmployer
FROM orderdetails od
INNER JOIN orders o
	ON o.orderNumber = od.orderNumber
INNER JOIN customers c
	ON c.customerNumber = o.customerNumber
	WHERE o.status = 'Shipped'
GROUP BY EmployeeNumber
ORDER BY totalRevenue_perEmployer DESC
;


-- Question 1b (Alternative)
SELECT
	SUM(revenuePerCustomer) as revenuePerEmployee,
	c.salesRepEmployeeNumber as EmployeeNumber,
    e.lastName,
    e.firstName
FROM(
	SELECT 
	p.customerNumber,
	SUM(p.amount) as revenuePerCustomer
	FROM payments p
	GROUP BY p.customerNumber
    -- ORDER BY revenuePerCustomer DESC
	) AS revCust
INNER JOIN customers c
	ON c.customerNumber = revCust.customerNumber
INNER JOIN	employees e
	ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY EmployeeNumber
ORDER BY revenuePerEmployee DESC
;


-- Question 2
SELECT
*
FROM(
    SELECT
	*,
	revenuePerOffice/MAX(revenuePerOffice) OVER() as officesCompared
	FROM(
		SELECT
			SUM(revenuePerCustomer) as revenuePerOffice,
			e.officeCode,
			off.country
		FROM(
			SELECT 
			p.customerNumber,
			SUM(p.amount) as revenuePerCustomer
			FROM payments p
			GROUP BY p.customerNumber
			-- ORDER BY revenuePerCustomer DESC
			) AS perCust
		INNER JOIN customers c
			ON c.customerNumber = perCust.customerNumber
		INNER JOIN	employees e
			ON e.employeeNumber = c.salesRepEmployeeNumber
		INNER JOIN offices off
			ON off.officeCode = e.officeCode
		GROUP BY e.officeCode
		-- ORDER BY revenuePerOffice DESC
		) as perOffice
    ) as comp
WHERE comp.officesCompared < 0.5
;


-- Question 3
SELECT 
	QUARTER(o.orderDate) as Quarters,
    count(o.orderNumber) as numberOrders
FROM orders o
WHERE year(o.orderDate) = 2004
GROUP BY Quarters
ORDER BY numberOrders DESC
;


-- Question 4
SELECT
	c.customerNumber
FROM customers c
Left JOIN(
	Select
		DISTINCT o.customerNumber-- ,
	--     o.orderDate,
	--     dates.firstDate,
	--     dates.lastDate
	From orders o
	CROSS JOIN (
				Select 
				Max(orderDate) as lastDate,
				date_sub(max(orderDate), interval 8 month) as firstDate
				FROM orders
				) as dates
	WHERE o.orderDate between dates.firstDate and dates.lastDate
    ) as undesired
		on c.customerNumber = undesired.customerNumber 
		AND undesired.customerNumber is null
;



-- Question 5
-- not sold in 2003
SELECT 
	count(od.orderNumber) as numberOfOrders,
	pd.productName,
    max(ord.orderDate) as lastOrderDate
FROM orderdetails od
INNER JOIN(
		SELECT 
			p.productCode, 
            p.productName
		FROM products p) as pd
	ON od.productCode = pd.productCode
INNER JOIN(
		SELECT
			o.orderNumber,
            o.orderDate
		FROM orders o) as ord
	ON od.orderNumber = ord.orderNumber
WHERE year(ord.orderDate) != '2003'
GROUP BY pd.productName
ORDER BY numberOfOrders DESC
;


-- not sold in 2004
SELECT 
	count(od.orderNumber) as numberOfOrders,
	pd.productName,
    max(ord.orderDate) as lastOrderDate
FROM orderdetails od
INNER JOIN(
		SELECT 
			p.productCode, 
            p.productName
		FROM products p) as pd
	ON od.productCode = pd.productCode
INNER JOIN(
		SELECT
			o.orderNumber,
            o.orderDate
		FROM orders o) as ord
	ON od.orderNumber = ord.orderNumber
WHERE year(ord.orderDate) != '2004'
GROUP BY pd.productName
ORDER BY numberOfOrders DESC
;


-- not sold in 2005



-- not sold in any Year
SELECT 
	od.orderNumber,
    pd.productCode,
	pd.productName
FROM orderdetails od
RIGHT OUTER JOIN(
		SELECT 
			p.productCode, 
            p.productName
		FROM products p) as pd
	ON od.productCode = pd.productCode
WHERE od.orderNumber is Null
;
