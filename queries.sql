-- inserting initial data into users table
INSERT INTO `users` (`id`, `fname`, `lname`, `phone`) 
VALUES 
(1, 'Ahmed', 'Hassan', '01012345678'),
(2, 'Sara', 'Ali', '01198765432'),
(3, 'Mohamed', 'Ibrahim', '01234567890'),
(4, 'Nour', 'Mostafa', '01567890123'),
(5, 'Omar', 'Farouk', '01056784321'),
(6, 'Laila', 'Saad', '01122334455');

-- calling the procedure to insert user
CALL add_users('Mona','ahmed','01029011777');

-- inserting initial data into restaurants table
INSERT INTO `restaurants` (`id`, `name`, `location`, `phone`) 
VALUES 
(1, 'Primos', 'Cairo', '19085'),
(2, 'Labash', 'Giza', '15005'),
(3, 'SeaView', 'Alexandria', '16085'),
(4, 'KFC', 'Cairo', '12012'),
(5, 'Zooba', 'New Cairo', '19800');


-- inserting initial data into ratings table
INSERT INTO `ratings` (`rate`, `user_id`, `restaurant_id`) 
VALUES 
(4, 3, 1),
(5, 6, 2),
(2, 1, 5),
(3, 5, 3),
(1, 6, 4),
(5, 2, 1),
(2, 4, 2),
(3, 1, 3),
(4, 6, 5),
(5, 3, 4),
(1, 1, 1),
(4, 2, 5),
(2, 5, 2),
(3, 4, 3),
(5, 6, 1);

-- calling the procedure to insert rating 
CALL add_rating(4, 'Ahmed', 'Hassan', 'Primos'); 

-- inserting initial data into restaurant_tables table
INSERT INTO `restaurant_tables` (`id`, `restaurant_id`, `availability`,  `view`) 
VALUES 
(1, 3, 'Free', 'Outdoor'),
(2, 1, 'Free',  'Indoor'),
(3, 4, 'Free','Outdoor'),
(4, 2, 'Free', 'Indoor'),
(5, 5, 'Free', 'Outdoor'),
(6, 1, 'Free', 'Indoor'),
(7, 2, 'Free', 'Outdoor'),
(8, 3, 'Free',  'Indoor'),
(9, 5, 'Free', 'Outdoor'),
(10, 4, 'Free', 'Indoor'),
(11, 1, 'Free', 'Outdoor'),
(12, 2, 'Free', 'Outdoor'),
(13, 3, 'Free', 'Outdoor'),
(14, 4, 'Free', 'Indoor'),
(15, 5, 'Free', 'Outdoor');


-- add reservation for user who are not registered in the system
CALL add_reservation('Karim', 'Shams', '01047054020', '2025-05-03 02:20:00', 4, 'Labash', 'Cash', 200);

-- add reservation for user who are registered in the system
CALL add_reservation('Sara', 'Ali', '01198765432', '2025-05-010 07:00:00', 3, 'Labash', 'Credit', 100);

-- cancel reservation for user who are registered in the system
CALL cancel_reservation('Sara', '01198765432', 'Labash', '2025-05-010 07:00:00');


/*Query to find user details and their reservations details like
date and time and name of restaurants they reserved in*/

SELECT `fname`, `lname` ,`date_time`, `guests_num` , `name` FROM `users`
JOIN `reservations` ON `users`.`id` = `reservations`.`user_id`
JOIN `restaurants` ON `restaurants`.`id` = `reservations`.`restaurant_id`
ORDER BY `date_time` ;


-- Query to show restaurants that has average rating greater than 2.5 

SELECT `name` AS 'Restaurant' , ROUND(AVG(`rate`),2) AS 'Average Rate' FROM `ratings`
JOIN `restaurants` ON `restaurants`.`id` = `ratings`.`restaurant_id`
GROUP BY `name` 
HAVING `Average Rate` > 2.5
ORDER BY `Average Rate` DESC , `Restaurant`;


/*Query to Show the top 5 users who have spent the most money (total payments), 
along with their names and total amount.*/

SELECT `fname` , `lname`, SUM(`final_balance`) AS 'Total Amount'
FROM `payments` 
JOIN `users` ON `users`.`id` = `payments`.`user_id`
GROUP BY `users`.`id` 
ORDER BY `Total Amount` DESC
LIMIT 5; 


/* Query to Display the restaurant(s) with the highest number of reservations, 
including the restaurant name and count.*/

SELECT `name`, COUNT(`reservations`.`id`) AS 'Reservations Count'
FROM `reservations` 
JOIN `restaurants` ON `reservations`.`restaurant_id` = `restaurants`.`id`
GROUP BY `name`
ORDER BY `Reservations Count` DESC;

-- Query to Show users who never made a reservation, even though they exist in the system. 

SELECT `fname` , `lname` FROM `users`
WHERE `id` NOT IN (
	SELECT `user_id` FROM `reservations` 
);

-- Query to List restaurants that have received at least one rating less than 3.

SELECT `name` 
FROM `restaurants` 
WHERE `id` IN (
	SELECT DISTINCT `restaurant_id` 
	FROM `ratings`
	WHERE `rate` < 3
);


-- updating payments to see how trigger works
UPDATE `payments`
SET `total_amount_order` = 800
WHERE `user_id` = (
    SELECT `id` FROM `users`
    WHERE `phone` = '01047054020'
);

