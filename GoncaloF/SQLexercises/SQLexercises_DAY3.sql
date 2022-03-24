USE classicmodels;

-- Question 1 Number of days between 2 dates with datediff()
SELECT 
	customerNumber,
	min(o.orderDate) as lastOrder,
    max(o.orderDate) as lastOrder,
    TIMESTAMPDIFF(day, min(o.orderDate), max(o.orderDate)) as daysElapsed,
    TIMESTAMPDIFF(month, min(o.orderDate), max(o.orderDate)) as monthsElapsed,
    TIMESTAMPDIFF(year, min(o.orderDate), max(o.orderDate)) as yearsElapsed
FROM orders o
GROUP BY customerNumber
order by daysElapsed DESC
;


-- Question 2
-- Neat way to calculate consecutive days elapsed 
-- (IFNULL(datediff(o.orderDate,(SELECT MAX(oo.orderDate)
-- 								FROM orders oo
--                              WHERE oo.orderDate < o.orderDate
--                              AND oo.customerNumber = o.customerNumber)),0) as daysElapsed
SELECT
	o.customerNumber,
    count(o.orderDate) as numberOfOrders,
	CONVERT (AVG(IFNULL(datediff(o.orderDate,(SELECT MAX(oo.orderDate)
								FROM orders oo
                                WHERE oo.orderDate < o.orderDate
                                AND oo.customerNumber = o.customerNumber)),0)), UNSIGNED) as AVGdaysElapsedInt
																			-- unsigned is for positive and 0 only
FROM orders o
GROUP BY o.customerNumber 
order by numberOfOrders Desc
;				