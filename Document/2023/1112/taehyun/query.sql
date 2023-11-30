CREATE DATABASE IF NOT EXISTS test_group_by DEFAULT CHARACTER SET utf8mb4;

USE test_group_by;

CREATE TABLE IF NOT EXISTS Items1 (
    item_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    price INTEGER NOT NULL,

    PRIMARY KEY (item_id, year)    
);

CREATE TABLE IF NOT EXISTS Items2 (
    item_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    price INTEGER NOT NULL,

    PRIMARY KEY (year, item_id)
);

DELIMITER $$
CREATE PROCEDURE CreateItem(IN fixed_item_id INT, IN fixed_item_name VARCHAR(255))
BEGIN
    DECLARE current_year INT DEFAULT 1;
    DECLARE current_price INT DEFAULT 10;

    WHILE current_year <= 1000000 DO
        INSERT INTO Items1 (item_id, year, item_name, price) VALUES (fixed_item_id, current_year, fixed_item_name, current_price);
        SET current_year = current_year + 1;
        SET current_price = current_price + 10;
    END WHILE;
END $$
DELIMITER ;

CALL CreateItem(101, '머그컵');
CALL CreateItem(102, '티스푼');
CALL CreateItem(103, '나이프');

INSERT INTO Items2 (item_id, year, item_name, price)
SELECT item_id, year, item_name, price FROM Items1;


