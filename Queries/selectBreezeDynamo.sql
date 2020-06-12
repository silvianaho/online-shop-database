WITH category_hierarchy AS (
  SELECT category_id, 
         parent_id,
		 category_name,
         category_id AS root_category, 
         1 AS category_level,
		 CAST (category_name AS VARCHAR(MAX)) AS lineage
  FROM product_category
  WHERE parent_id IS NULL

  UNION ALL

  SELECT c.category_id,
         c.parent_id,
		 c.category_name,
         ch.root_category,
         ch.category_level + 1,
		 ch.lineage + ' -> ' + CAST (c.category_name AS VARCHAR(MAX))
  FROM product_category AS c
  JOIN category_hierarchy ch ON c.parent_id = ch.category_id
)
SELECT 
	p.brand_id,
	b.brand_name,
	--p.*
	COUNT(p.brand_id) 'Count'
FROM 
	product AS p,
	product_brand AS b
WHERE
	p.category_id IN (SELECT category_hierarchy.category_id
					  FROM category_hierarchy
                      WHERE category_hierarchy.parent_id = 81
                      )
	AND
	(p.brand_id = 104 OR p.brand_id = 105)
	AND
	(b.brand_id = p.brand_id)
GROUP BY
	p.brand_id, b.brand_name;