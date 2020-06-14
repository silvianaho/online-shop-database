--UPDATE promotion
--SET discount_value = 100
--WHERE promotion_id = 5;

/*
INSERT INTO 
	dbo.product(product_name, product_desc, measurements, is_available, is_in_stock, brand_id, category_id)
VALUES
	('meow', 'meow meow meow', '1KG', 1, 0, 1, 1);
GO
INSERT INTO 
	dbo.product_pricing(product_id, base_price, date_start, is_active)
VALUES
	(340, 9999.99, '01/01/20 00:00:00', 1);
*/

SELECT p.*, pp.base_price FROM product as p, product_pricing as pp WHERE p.product_id = 340 AND pp.product_id = p.product_id;
UPDATE product_pricing
SET base_price = 10
WHERE product_id = 340;
SELECT p.*, pp.base_price FROM product as p, product_pricing as pp WHERE p.product_id = 340 AND pp.product_id = p.product_id;


