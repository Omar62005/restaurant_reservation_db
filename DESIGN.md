# Design Document

By Omar Hesham Fathy Ghonim

Video overview: <https://youtu.be/4nhTJZS0PVg?si=nfHku8X9a-gvOboX>

## Scope
This project was designed and tested using MySQL

This database is designed for restaurants reservation system which help people to book reservation in restaurant , rate the restaurant and also users pay deposits , database scope :
* users, in which user can register to system with their basic information like phone number
* restaurants, including basic information about restaurants
* restaurant tables, including tables in each restaurant and their view wheather it is indoor or outdoor and wheather it is available or booked
* reservations, in which user can add or cancel reservation in specific restaurant with time and date he or she wants
* ratings, which allow user to rate restaurant
* payments, which take deposit from user and also calculate final balance when user go to restaurant and finishes his meal


* Out of scope are elements like waiting list , restaurant menu, number of guests the table holds, user can reserve only one table per reservation

## Functional Requirements

* user can create and view its profile
* users can register to system and once user registered once in system it's information is saved
* users can create a reservation in specific restaurant he wants with specific time and date
* users can select amout of deposit he wants to pay starting from 100 till 250
* once user paid the deposit , it is updated in system automatically and when user go to restaurant and finished his meal the deposit is subtracted
from his / her total order
* user can rate restaurant
* also user can cancel his reservation if he wants to
* this database also helps restaurants admins to track free and booked tables in their restaurant

* Beyond scope of this database is :
* there is no waiting list , so if a restaurant is fully booked user will not be allowed to book
* user cannot post a comment about restaurant , he can only rate
* you cannot know number of guests one table holds

## Representation

### Entity Relationship Diagram
![ER Diagram](https://github.com/Omar62005/ERD/blob/main/Restaurants%20Reservation%20System%20ERD.jpeg?raw=true)

### Entities
The database contain the following entities :

#### Users
The `users` table includes:
* `id` which specifies unique id for each user as an `INT` , This column has `Primary Key` Constraint applied.
* `fname` which specifies user's first name as `VARCHAR(32)` , This column has `NOT NULL` constraint.
* `lname` which specifies user's last name as `VARCHAR(32)` , this column has `NOT NULL` constraint.
* `phone` which specifies the user's phone number as `VARCHAR(11)` , this column has `UNIQUE` constraint because the phone number cannot be duplicated , it has a `CHECK` constraint
in which length of phone number must be 11 digits because this is standard in Egypt and has `NOT NUL`L constraint.

#### restaurants
The `restaurants` table includes :
* `id` which specifies unique id for each restaurant as an `INT` , this column has `Primary Key` constraint applied.
* `name` which speceifies name of restaurant as `VARCHAR(16)` , this column has `NOT NULL` constraint and UNIQUE constraint.
* `location` which specifies location of restaurant as `VARCHAR(32)`, No column constraint applied.
* `phone` which specifies phone number of restaurant as `VARCHAR(5)`, `UNIQUE` constraint is applied and `CHECK` constraint is applied to check that phone number consists of exactly 5 digits and `NOT NULL` constraint is applied.

#### ratings
The `ratings` table includes :
* `rate` which specifies the rate of user as an `INT` , this column has `CHECK` constraint that rate is in range between 1 and 5 and `NOT NULL` constraint.
* `user_id` which specifies the id of user of who submitted the rate as an `INT` , This column has `Foreign Key` constraint applied which references the `id` of user in `users` table which ensures that this rate belongs to this user , ensures referential integrity and `NOT NULL` constraint is also applied to this column.
* `restaurant_id` which specifies the id of restaurant that recieved the rate as an `INT` , this column has `Foreign Key` constraint applied referencing the `id` of restaurant
in `restaurants` table to ensure referential integrity and `NOT NULL` constraint is also applied to this column.
* `Primary` Key of this table is Composite Primary Key that consist of two columns (`user_id`,`restaurant_id`).

#### payments
The `payments` table includes :
* `id` which specifies unique id for each payment as an `INT` , this column has `Primary Key` constraint applied.
* `type` which specifies the type of payment user wants to pay with as an `ENUM('Credit','Cash')`, `NOT NULL` constraint is applied to this column.
* `deposit` which is the deposit the user will choose to pay between 100 and 250 to confirm reservation as `INT`, `CHECK` constraint is applied to check deposit is betweem 100 and 250
and `NOT NULL` constraint is applied.
* `total_amount_order` which is total price of food user ordered plus the deposit user already payed as `DECIMAL(5,2)` , `DEFAULT` constraint is applied and default is 0 .
* `final_balance` which is the money the user will pay after subtracting deposit from total price of order as `DECIMAL(5,2)` , `DEFAULT` constraint is applied and default is 0.
* `user_id` which specifies the user who is specified with this payment as `INT` , this column has `Foreign Key` constraint applied referencing `id` of user in `users` table to
ensure referential integrity and `NOT NULL` constraint is also applied.
* `deleted` this column act as flag if reservation is cancelled that value will be 1 which means payment is deleted and will not be continued as `INT` , This is useful because we want to apply soft deletions instead of hard delete the data, `DEFAULT` constraint is applied and default is 0.
* `paid` which indicates that this payment is settled and user has finished his visit to restaurant as `INT` , `DEFAULT` constraint is applied and default is zero.

#### restaurant_tables
The `restaurant_tables` table includes :
* `id` which specifies unique id for each table as an `INT` , this column has `Primary Key` constraint.
* `restaurant_id` which specifies the id of restaurant that own this table as as `INT`, this column has `Foreign Key` constraint is applied referencing `id` of restaurant in
`restaurants` table to ensure referential integrity, `ON DELETE CASCADE` constraint is applied  and `NOT NULL` constraint is also applied.
* `availability` which specifies wheather table is available or booked as `ENUM('Free','Booked')` , `DEFAULT` constraint is applied and default is 'Free'.
* `view` which specifies wheather user needs table to be indoor or outdoor as `ENUM('Indoor','Outdoor')`, `NOT NULL` constraint is applied to this column,

#### reservations
The `reservations` table include :
* `id` which specifies unique id for each reservation as an `INT` , this column has `Primary Key` constraint.
* `table_id` which specifies the id of table which will be reserved to user when users books a reservation as an `INT`,`Foreign Key`constraint is applied referencing the `id` in `restaurnat_tables` table to ensure referential integrity,`ON DELETE CASCADE` constraint is applied,  `NOT NULL` constraint is applied.
* `user_id` which specifies the id of user who booked the reservation as `INT` , `Foreign Key` constraint is applied referencing the `id` of user is `users` table to ensure referential integrity, `NOT NULL` constraint is also applied.
* `date_time` which specifies the date and time user will choose while booking the reservation as `DATETIME` , `NOT NULL` constraint is applied to this column.
* `guests_num` which specifies the number of people on one reservation as `SMALLINT` , `CHECK` constraint is applied to allow only from 1 to 5 guests in one reservation and `NOT NULL` constraint is applied.
* `restaurant_id` which specifies the id of restaurant in which user has made reservation in it as `INT` ,`Foreign Key` constraint is applied referencing `id` of restaurant in `restaurants` table and `NOT NULL` constraint is applied to this column.
* `pay_id` which specifies the id of payment after user book reservation as `INT` ,`Foreign Key` constraint is applied referencing `id` of pay in `payments` table ,`UNIQUE` constraint is applied to this column and `NOT NULL` constraint is applied.
* `cancelled` which is flag to ba marked when reservation is cancelled to perform soft deletions instead of hard delete as `INT`, `DEFAULT` constraint is applied and default is 0.


### Relationships


### Entity Relationship Diagram
![Database ER Diagram](https://raw.githubusercontent.com/Omar62005/ERD/refs/heads/main/Restaurants%20Reservation%20System%20ERD.jpeg)


* One user may not sumbit any rates and may submit one or more rates.
* One restaurant may receive no rates and may receieve one or more rates.
* One user can may have zero or many payments , but one payment is associated with one and only one user.
* One user can may make zero or many reservations , but one reservation is associated with one and only one user.
* One reservation is associated with one and only one payment.
* One restaurant can receieve zero or many reservations , but one reservation must be associated with one and only one restaurant.
* One restaurant must have one or many restaurant tables , but one restaurant table is associated with one and only one restaurant.
* One reservation is associated with one and only one restaurant table , and one restaurant table is associated with one and only one reservation.

## Optimizations

* Which optimizations (e.g., indexes, views) did you create? Why?
* I created view called `free_tables` in which you see restaurant tables that are free not booked
* I created a view called `booked_tables` in which you see restaurant tables that are booked in the moment
* I created view called `cancelled_reservations` in which you can see reservations that are cancelled by users
* I created an index called `rating_idx` which create index on `rate` column in `ratings` table because some users might search for restaurant where this restaurant has like a rate above 3
* I created an index called `users_idx` on (`fname`,`lname`) columns in `users` table because first name and last name of users are frequently queried and frequently accesed in alot of queries.
* I also created an index called `restaurant_idx` on `name` column in `restaurants` table because you can search for restaurant in queries using it name.

## Limitations

* The current schema allows user to reserve only one table per one reservation which may be not very well because maybe the user want to reserve like two tables in one reservation.
* current schema doesnot specify number of guests one table can hold
* my database doesnot make like a time interval for reservation , so if user doesnot come in that time its reservation will be cancelled , but database doesnot do this.
* my database allows only one rate for same restaurant from same user , so user cannot rate same restaurant twice.