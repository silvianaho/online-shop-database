SELECT 
	brand.brand_name,
	COUNT(*) AS 'count'
FROM product
JOIN product_brand as brand ON brand.brand_id = product.brand_id
WHERE brand.brand_name = 'Breeze' OR brand.brand_name = 'Dynamo'
GROUP BY brand.brand_name WITH CUBE;