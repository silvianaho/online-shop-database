-- =============================================
-- Author	 :	Silviana
-- Class	 :	DIT/FT/2A/14
-- StudentID :	P1939213
-- =============================================

--CREATE DATABASE OnShop1939213;

--USE OnShop1939213
--GO

DROP TABLE IF EXISTS product_promotion;
DROP TABLE IF EXISTS promotion;
DROP TABLE IF EXISTS product_pricing;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS product_brand;
DROP TABLE IF EXISTS product_category;
DROP FUNCTION IF EXISTS discounted_price;

CREATE TABLE product_brand(
	brand_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	brand_name VARCHAR(100) NOT NULL,
);

CREATE TABLE product_category(
	category_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	category_name VARCHAR(100) NOT NULL,
	parent_id INT NULL FOREIGN KEY REFERENCES product_category(category_id)
);


CREATE TABLE product(
	product_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	product_name VARCHAR(255) NOT NULL,
	product_desc VARCHAR(255) NOT NULL,
	measurements VARCHAR(255) NOT NULL,
	is_available BIT NOT NULL DEFAULT 1,
	is_in_stock BIT NOT NULL DEFAULT 1,
	brand_id INT DEFAULT 0 NOT NULL FOREIGN KEY REFERENCES product_brand(brand_id) ON UPDATE CASCADE ON DELETE SET DEFAULT,
	category_id INT DEFAULT 0 NOT NULL FOREIGN KEY REFERENCES product_category(category_id) ON UPDATE CASCADE ON DELETE SET DEFAULT 
);

CREATE TABLE product_pricing(
	price_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	base_price DECIMAL (10, 2) NOT NULL,
	date_start DATETIME NOT NULL,
	date_end DATETIME NULL,
	is_active BIT NOT NULL DEFAULT 1,
	product_id INT DEFAULT 0 NOT NULL FOREIGN KEY REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE SET DEFAULT 
);

CREATE TABLE promotion(
	promotion_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	promotion_name VARCHAR(255) NOT NULL,
	discount_value DECIMAL(10,2) NOT NULL,
	discount_unit VARCHAR(10) NOT NULL,
	date_created DATETIME NOT NULL DEFAULT GETDATE(),
	valid_from DATETIME NOT NULL,
	valid_to DATETIME NOT NULL,
	min_order_qty INT NOT NULL DEFAULT 1,
);

CREATE TABLE product_promotion(
	product_id INT DEFAULT 0 NOT NULL  FOREIGN KEY REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE SET DEFAULT ,
	promotion_id INT DEFAULT 0 NOT NULL  FOREIGN KEY REFERENCES promotion(promotion_id) ON UPDATE CASCADE ON DELETE SET DEFAULT,
	PRIMARY KEY(product_id, promotion_id)
);

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
	@quantity INT = 1
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