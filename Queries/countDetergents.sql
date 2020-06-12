WITH cats AS (
	SELECT 
		81 AS id
	UNION ALL
	SELECT c.category_id
	FROM product_category AS c
		JOIN cats ON c.parent_id = cats.id
)
SELECT count(*) AS 'Count of Household/Detergent'
FROM product
	JOIN cats ON cats.id = product.category_id;