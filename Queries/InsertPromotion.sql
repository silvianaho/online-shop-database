USE OnShop1939213;
GO

INSERT INTO 
	dbo.promotion(promotion_name, discount_value, discount_unit, valid_from, valid_to, min_order_qty)
VALUES
	('$1.05 off', 1.05, '$', '06/01/20 00:00:00', '07/31/20 00:00:00', 1),
	('10% off', 10, '%', '06/01/20 00:00:00', '07/31/20 00:00:00', 1),
	('$2 off', 2, '$', '06/01/20 00:00:00', '07/31/20 00:00:00', 2),
	('15% off', 15, '%', '06/01/20 00:00:00', '07/31/20 00:00:00', 3),
	('Buy one get one free', 50, '%', '06/01/20 00:00:00', '07/31/20 00:00:00', 2);