DROP TABLE IF EXISTS product_promotion;
DROP TABLE IF EXISTS promotion;

CREATE TABLE promotion(
	promotion_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	promotion_name VARCHAR(255) NOT NULL,
	discount_value DECIMAL(10,2) NOT NULL,
	discount_unit VARCHAR(10) NOT NULL,
	date_created DATETIME NOT NULL DEFAULT GETDATE(),
	valid_from DATETIME NOT NULL,
	valid_to DATETIME NOT NULL,
	min_order_qty INT NULL,
);

CREATE TABLE product_promotion(
	product_id INT FOREIGN KEY REFERENCES product(product_id),
	promotion_id INT FOREIGN KEY REFERENCES promotion(promotion_id),
	PRIMARY KEY(product_id, promotion_id)
);