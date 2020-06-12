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
--SELECT parent_id, count(*) AS 'No of children' FROM category_hierarchy GROUP BY parent_id ORDER BY parent_id
SELECT * FROM category_hierarchy