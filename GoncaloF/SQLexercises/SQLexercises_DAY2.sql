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
	SUM(totalRevenue_perCustomer) as totalRevenue_perEmployee,
	c.salesRepEmployeeNumber as EmployeeNumber,
    e.lastName,
    e.firstName
FROM(
	SELECT 
        SUM(totalRevenue_perOrder) as totalRevenue_perCustomer,
 		o.customerNumber
	FROM(
		SELECT 
		od.orderNumber, 
		SUM(od.priceEach*od.quantityOrdered) as totalRevenue_perOrder
		FROM orderdetails od
		GROUP BY od.orderNumber
        -- ORDER BY totalRevenue_perOrder DESC
		) as revenue
	INNER JOIN orders o
		ON o.orderNumber = revenue.orderNumber
	WHERE o.status = 'Shipped'
    GROUP BY o.customerNumber
    -- ORDER BY totalRevenue_perCustomer DESC
	) AS cust
INNER JOIN customers c
	ON c.customerNumber = cust.customerNumber
INNER JOIN	employees e
	ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY EmployeeNumber
ORDER BY totalRevenue_perEmployee DESC
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
	ceiling(MONTH(o.orderDate)/4) as triAnnual,
    count(o.orderNumber) as numberOrders
FROM orders o
WHERE year(o.orderDate) = 2004
GROUP BY triAnnual
ORDER BY numberOrders DESC
;


-- Question 4
SELECT *
FROM
 (
    SELECT o.customerNumber
    FROM orders o
                       -- 1st of previous 8 month
    WHERE o.orderDate BETWEEN SUBDATE(SUBDATE('2005-05-31', DAYOFMONTH('2005-05-31')-1), interval 8 month) 
                       -- end of current month
                   AND LAST_DAY('2005-05-31')
    GROUP BY o.customerNumber
           -- any row from previous month
    HAVING MAX(CASE WHEN o.orderDate < SUBDATE('2005-05-31', DAYOFMONTH('2005-05-31')-1)
                    THEN o.orderDate 
               END) IS NOT NULL
           -- no row in current month
       AND MAX(CASE WHEN o.orderDate >= SUBDATE('2005-05-31', DAYOFMONTH('2005-05-31')-1)
                    THEN o.orderDate 
               END) IS NULL           
 ) AS dt
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
SELECT 
	count(od.orderNumber) as numberOfOrders,
	pd.productName,
    max(ord.orderDate) as lastOrderDate
FROM orderdetails od
RIGHT OUTER JOIN(
		SELECT 
			p.productCode, 
            p.productName
		FROM products p) as pd
	ON od.productCode = pd.productCode
LEFT OUTER JOIN(
		SELECT
			o.orderNumber,
            o.orderDate
		FROM orders o) as ord
	ON od.orderNumber = ord.orderNumber
WHERE 
	year(ord.orderDate) != '2005'
    AND pd.productCode = 'S18_3233'
GROUP BY pd.productName
ORDER BY numberOfOrders DESC
;


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
