SELECT 
	p.*,
	pp.base_price
FROM 
	product AS p
JOIN product_pricing AS pp ON pp.product_id = p.product_id
ORDER BY pp.base_price ASC;