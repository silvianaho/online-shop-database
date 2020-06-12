--CREATE DATABASE OnShop1939213;

USE OnShop1939213
GO

DROP TABLE IF EXISTS product_promotion;
DROP TABLE IF EXISTS product_category_promotion;
DROP TABLE IF EXISTS product_brand_promotion;
DROP TABLE IF EXISTS promotion;
DROP TABLE IF EXISTS product_pricing;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS product_brand;
DROP TABLE IF EXISTS product_category;

CREATE TABLE product_brand(
	brand_id INT IDENTITY(1, 1) PRIMARY KEY,
	brand_name VARCHAR(100) NOT NULL,
);

CREATE TABLE product_category(
	category_id INT IDENTITY(1, 1) PRIMARY KEY,
	category_name VARCHAR(100) NOT NULL,
	parent_id INT NULL FOREIGN KEY REFERENCES product_category(category_id),
);


CREATE TABLE product(
	product_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	product_name VARCHAR(255) NOT NULL,
	product_desc VARCHAR(255) NOT NULL,
	measurements VARCHAR(255),
	is_available BIT NOT NULL DEFAULT 1,
	is_in_stock BIT NOT NULL DEFAULT 1,
	brand_id INT NOT NULL FOREIGN KEY REFERENCES product_brand(brand_id),
	category_id INT NOT NULL FOREIGN KEY REFERENCES product_category(category_id)
);

CREATE TABLE product_pricing(
	price_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	base_price DECIMAL (10, 2) NOT NULL,
	date_start DATETIME NOT NULL,
	date_end DATETIME NULL,
	is_active BIT NOT NULL DEFAULT 1,
	product_id INT NOT NULL FOREIGN KEY REFERENCES product(product_id)
);

CREATE TABLE promotion(
	promotion_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	discount_value DECIMAL(10,2) NOT NULL,
	discount_unit VARCHAR(10) NOT NULL,
	date_created DATETIME NOT NULL DEFAULT GETDATE(),
	valid_from DATETIME NOT NULL,
	valid_to DATETIME NOT NULL,
	min_order_val DECIMAL(10, 2) NULL,
	min_over_qty INT NULL,
	free_item INT FOREIGN KEY REFERENCES product(product_id) NULL
);

CREATE TABLE product_promotion(
	product_id INT FOREIGN KEY REFERENCES product(product_id),
	promotion_id INT FOREIGN KEY REFERENCES promotion(promotion_id),
	PRIMARY KEY(product_id, promotion_id)
);