DECLARE @quantity INT;
SET @quantity = 3;

SELECT 
	p.product_id,
	p.product_name,
	promo.promotion_name,
	@quantity AS quantity,
	promo.min_order_qty,
	pp.base_price,
	dbo.discounted_price(pp.base_price, promo.discount_value, promo.discount_unit, promo.min_order_qty, @quantity) AS current_price,
	promo.valid_from,
	promo.valid_to
FROM 
	product AS p
JOIN product_pricing AS pp ON pp.product_id = p.product_id
RIGHT JOIN product_promotion AS ppro ON ppro.product_id = p.product_id
RIGHT JOIN promotion AS promo ON promo.promotion_id = ppro.promotion_id
WHERE pp.is_active = 1 AND p.is_in_stock = 1 AND is_available = 1 AND (p.product_id = 35 OR p.product_id = 1) AND GETDATE() > promo.valid_from AND GETDATE() < promo.valid_to
ORDER BY promo.promotion_id