-- =============================================
-- Author:		Silviana
-- Create date: 12/06/2020
-- Description:	Calculate discounted price
-- =============================================
GO
CREATE FUNCTION dbo.discounted_price
(
	@base_price DECIMAL(10,2), 
	@discount_value DECIMAL(10,2), 
	@discount_unit VARCHAR(10), 
	@min_order_qty INT,
	@quantity INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN

	DECLARE @discounted_price DECIMAL(10,2);
	DECLARE @multiplier INT;
	
	IF (ROUND(@quantity/@min_order_qty, 0) = @quantity/@min_order_qty) SET @multiplier = @quantity/@min_order_qty 
	ELSE SET @multiplier = FLOOR(@quantity/@min_order_qty)

	IF (@discount_unit = '$') SET @discounted_price = @base_price * @quantity - @discount_value * @multiplier
	IF (@discount_unit = '%') SET @discounted_price = @base_price * @quantity - @discount_value * @multiplier/100 * @base_price
	RETURN @discounted_price

END
GO

DECLARE @quantity INT;
SET @quantity = 1;

SELECT 
	p.product_id,
	p.product_name,
	pp.base_price,
	promo.promotion_name,
	promo.valid_from,
	promo.valid_to,
	@quantity AS quantity,
	promo.min_order_qty,
	dbo.discounted_price(pp.base_price, promo.discount_value, promo.discount_unit, promo.min_order_qty, @quantity) AS total_discounted_price
FROM 
	product AS p
JOIN product_pricing AS pp ON pp.product_id = p.product_id
RIGHT JOIN product_promotion AS ppro ON ppro.product_id = p.product_id
RIGHT JOIN promotion AS promo ON promo.promotion_id = ppro.promotion_id
WHERE pp.is_active = 1 AND p.is_in_stock = 1 AND is_available = 1

--UNION

--SELECT * FROM dbo.discounted_price(p.product_id, pp.base_price, promo.discount_value, promo.discount_unit, promo.min_order_quantity, @quantity) AS total_discounted_price;