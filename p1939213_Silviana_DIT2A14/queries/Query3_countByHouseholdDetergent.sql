SELECT 
	pc3.category_name AS category_name,
	pc2.category_name AS sub_category_name,
	COUNT(*) AS 'count'
FROM product
JOIN product_category AS pc1 ON pc1.category_id = product.category_id
LEFT OUTER JOIN product_category AS pc2 ON pc1.parent_id = pc2.category_id
LEFT OUTER JOIN product_category AS pc3 ON pc2.parent_id = pc3.category_id
WHERE pc2.category_name = 'Detergents'
GROUP BY pc3.category_name, pc2.category_name
;