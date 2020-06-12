WITH category_hierarchy AS (
  SELECT category_id, 
         parent_id,
		 category_name,
         category_id AS root_category, 
         1 AS category_level
  FROM product_category
  WHERE parent_id IS NULL
  UNION ALL

  SELECT c.category_id,
         c.parent_id,
		 c.category_name,
         ch.root_category,
         ch.category_level + 1
  FROM product_category AS c
  JOIN category_hierarchy ch ON c.parent_id = ch.category_id
)


/*
SELECT (SELECT COUNT(c2.category_id) FROM category_hierarchy AS c2 GROUP BY c2.category_id HAVING COUNT() > 1) AS cnt, * 
FROM category_hierarchy as c 
LEFT JOIN product p ON p.category_id = c.category_id
-- GROUP BY 
--	c.category_id, c.parent_id, c.category_name, c.root_category, c.category_level
ORDER BY c.root_category, c.category_level
*/
/*
SELECT 
	COUNT(*) AS catcnt,
	--(SELECT COUNT(*) FROM category_hierarchy AS c2 WHERE c2.category_level >= c.category_level AND c2.root_category = c.root_category) AS cnt,
	c.category_id,
	c.category_name,
	--p.product_id,
	--p.product_name,
	c.category_level
FROM category_hierarchy AS c--, product AS p
WHERE c.category_id = 472
-- JOIN product p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
--ORDER BY c.root_category, c.category_level
;
*/

SELECT 
	c.category_id,
	c.parent_id,
	c.root_category,
	c.category_level
FROM
	category_hierarchy AS C
ORDER BY root_category, category_level


/*
WITH category_hierarchy
AS (
	SELECT C.* 
	FROM dbo.product_category AS C 
	WHERE C.parent_id = NULL
	
	UNION ALL
	
	SELECT subC.* FROM dbo.product_category AS subC
	INNER JOIN category_hierarchy ch
	ON subC.parent_id = ch.category_id
)
SELECT * FROM category_hierarchy
;
*/

/*
WITH Tree_CTE(Tree_ID, Tree_name, Parent_ID, Seq_index, Full_index, Tree_level)
AS
(
    SELECT TreeDataTbl.*, 0  FROM TreeDataTbl WHERE Parent_ID =0
    UNION ALL
    SELECT ChildNode.*, Tree_level+1  FROM TreeDataTbl AS ChildNode
    INNER JOIN Tree_CTE
    ON ChildNode.Parent_ID = Tree_CTE.Tree_ID
)
SELECT * FROM Tree_CTE order by Tree_level
*/