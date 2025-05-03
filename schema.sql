-- create users table
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT,
    `fname` VARCHAR(32) NOT NULL,
    `lname` VARCHAR(32) NOT NULL,
    `phone` VARCHAR(11) UNIQUE CHECK(LENGTH(`phone`) = 11) NOT NULL,
    PRIMARY KEY(`id`)
);


-- create restaurants table 
CREATE TABLE `restaurants` (
    `id` INT AUTO_INCREMENT, 
    `name` VARCHAR(16) NOT NULL UNIQUE,
    `location` VARCHAR(32),
    `phone` VARCHAR(5) UNIQUE CHECK(LENGTH(`phone`)=5),
    PRIMARY KEY(`id`)
);

-- create ratings table
CREATE TABLE `ratings` (
    `rate` INT NOT NULL CHECK (`rate`<=5),
    `user_id` INT NOT NULL,
    `restaurant_id` INT NOT NULL,
    PRIMARY KEY (`user_id`,`restaurant_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants`(`id`) 
);

-- create payments table
CREATE TABLE `payments` (   
    `id` INT AUTO_INCREMENT,
    `type` ENUM('Credit', 'Cash') NOT NULL,
    `deposit` INT CHECK(deposit BETWEEN 100 AND 250) NOT NULL,
    `total_amount_order` DECIMAL(5,2) DEFAULT 0,
    `final_balance` DECIMAL(5,2) DEFAULT 0,
    `user_id` INT NOT NULL,
    `deleted` INT DEFAULT 0,
    `paid` SMALLINT DEFAULT 0,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
);

-- create restaurant_tables table
CREATE TABLE `restaurant_tables` (
    `id` INT AUTO_INCREMENT,
    `restaurant_id` INT NOT NULL,
    `availability` ENUM('Free','Booked') DEFAULT 'Free',
    `view` ENUM('Indoor', 'Outdoor') NOT NULL ,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants`(`id`) ON DELETE CASCADE
);

-- create reservations table
CREATE TABLE `reservations` (
    `id` INT AUTO_INCREMENT,
    `table_id` INT NOT NULL ,
    `user_id` INT NOT NULL,
    `date_time` DATETIME NOT NULL  ,
    `guests_num` SMALLINT NOT NULL CHECK(`guests_num` BETWEEN 1 AND 5),
    `restaurant_id` INT NOT NULL,
    `pay_id` INT UNIQUE NOT NULL,
    `cancelled` INT DEFAULT 0,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`pay_id`) REFERENCES `payments`(`id`) ,
    FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants`(`id` ),
    FOREIGN KEY (`table_id`) REFERENCES `restaurant_tables`(`id`) ON DELETE CASCADE
);



-- Stored Procedure to add users
DELIMITER $$
CREATE PROCEDURE `add_users` (IN p_fname TEXT, p_lname TEXT, p_phone TEXT)
BEGIN 
    IF CHAR_LENGTH(p_phone) = 11 THEN 
    INSERT INTO `users` (`fname`,`lname`,`phone`)
    VALUES (p_fname,p_lname,p_phone);
    END IF;
END $$
DELIMITER ;


-- stored procedure to add rating
DELIMITER $$
CREATE PROCEDURE `add_rating`(
    IN p_rate INT,
    IN p_fname TEXT,
    IN p_lname TEXT,
    IN p_restaurant_name TEXT
)
BEGIN
    DECLARE id_user INT;
    DECLARE id_restaurant INT;

    SELECT `id` INTO id_user
    FROM `users`
    WHERE `fname` = p_fname AND `lname` = p_lname
    LIMIT 1;

    SELECT `id` INTO id_restaurant
    FROM `restaurants`
    WHERE `name` = p_restaurant_name
    LIMIT 1;
    IF id_user IS NOT NULL AND id_restaurant IS NOT NULL THEN
        INSERT INTO `ratings` (`rate`, `user_id`, `restaurant_id`)
        VALUES (p_rate, id_user, id_restaurant);
    END IF;
END $$
DELIMITER ;

-- view to show all free tables
CREATE VIEW `free_tables` AS
SELECT * FROM `restaurant_tables`
WHERE `availability` = 'Free';

-- view to show booked tables
CREATE VIEW `booked_tables` AS
SELECT * FROM `restaurant_tables`
WHERE `availability` = 'Booked';


-- view to show reservations that are cancelled
CREATE VIEW `cancelled_reservations` AS
    SELECT * FROM `reservations`
    WHERE `cancelled` = 1; 


-- indexes to improve performance
CREATE INDEX `ratings_idx` 
ON `ratings`(`rate`);

CREATE INDEX `users_idx`
ON `users`(`fname`,`lname`);

CREATE INDEX `restaurants_idx`
ON `restaurants`(`name`);


-- procedure to allow user to make a reservation
DELIMITER $$
CREATE PROCEDURE `add_reservation` (IN p_fname VARCHAR(12), IN p_lname VARCHAR(16), IN p_phone VARCHAR(11), IN p_datetime datetime,
IN p_guests_num INT,IN p_restaurant_name VARCHAR(10), IN p_type ENUM('Cash','Credit'), IN p_deposit INT )
BEGIN
	declare id_user int;
    declare id_table int;
    SELECT id into id_user from users where phone = p_phone LIMIT 1;
    SELECT id into id_table from restaurant_tables where availability = 'Free' LIMIT 1;
    IF id_user IS NOT NULL THEN
		start transaction;
        UPDATE restaurant_tables 
        SET `availability` = 'Booked'
        WHERE id = id_table;
        
        INSERT INTO payments (type, deposit,user_id)
        VALUES (p_type, p_deposit, id_user);
        
        INSERT INTO reservations (table_id,user_id,date_time,guests_num,restaurant_id,pay_id)
        VALUES (id_table, id_user, p_datetime, p_guests_num, 
        (SELECT id from restaurants where name = p_restaurant_name), 
        (select id from payments order by id desc limit 1));
        commit;
    ELSE 
        CALL add_users(p_fname,p_lname,p_phone);
        start transaction;
        UPDATE restaurant_tables
        SET `availability` = 'Booked'
        WHERE id = id_table;
        
        INSERT INTO payments (type, deposit,user_id)
        VALUES (p_type, p_deposit, (select id from users ORDER BY id DESC LIMIT 1));
        
        INSERT INTO reservations (table_id,user_id,date_time,guests_num,restaurant_id,pay_id)
        VALUES (id_table, 
        (select id from users ORDER BY id DESC LIMIT 1), p_datetime, p_guests_num, 
        (SELECT id from restaurants where name = p_restaurant_name), 
        (select id from payments order by id desc limit 1));
        commit;
        
	END IF;
END $$
DELIMITER ;
        
-- trigger to calculate final balance
DELIMITER $$
CREATE TRIGGER final_pay 
BEFORE UPDATE ON payments
FOR EACH ROW 
BEGIN
    -- if the payment is not deleted and not paid, calculate the final balance and set the payment as paid
    IF NEW.deleted != 1 AND NEW.payed != 1 THEN
        SET NEW.final_balance = ABS(NEW.total_amount_order - NEW.deposit);
        SET NEW.payed = 1;
    END IF;
END $$
DELIMITER ;


-- procedure to cancel reservation
DELIMITER $$
create procedure `cancel_reservation` (In p_fname VARCHAR(10), IN p_phone varchar(11), IN p_resname VARCHAR(8), IN p_datetime DATETIME)
BEGIN
	declare id_user INT;
    declare res_id INT;
    SELECT id INTO id_user from users where phone = p_phone;
    select id INTO res_id from restaurants where name = p_resname;
	start transaction ;
	UPDATE `restaurant_tables`
    set availability = 'Free' 
    WHERE id = (
		select table_id from reservations 
        where user_id = id_user AND date_time = p_datetime AND cancelled != 1 AND restaurant_id = res_id LIMIT 1
        );
        
    UPDATE `reservations`
    SET cancelled = 1 
    WHERE user_id = id_user
    AND date_time = p_datetime;
    
    UPDATE payments 
    SET deleted= 1, deposit = 0
    where id = (
		select pay_id from reservations where user_id = id_user AND date_time = p_datetime AND restaurant_id = res_id LIMIT 1
    );
    COMMIT;
END $$



