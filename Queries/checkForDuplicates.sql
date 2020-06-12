WITH cte AS (
    SELECT 
		brand_id,
        brand_name, 
        ROW_NUMBER() OVER (
            PARTITION BY brand_name
            ORDER BY brand_name) rownum
    FROM 
        product_brand
) 
SELECT 
  * 
FROM 
    cte 
;