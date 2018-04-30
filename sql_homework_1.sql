use sakila;

#1a:
select first_name, last_name from actor;

#1b
select concat(first_name, ' ',last_name) as `Actor Name` from actor;

#2a
select actor_id, first_name, last_name from actor where first_name = 'Joe';

#2b
select * from actor where last_name like '%GEN%';

#2c
select * from actor where last_name like '%LI%' order by last_name, first_name;

#2d
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

#3a
alter table actor
add middle_name varchar(3) after first_name;

#3b
alter table actor
modify column middle_name blob;

#3c
alter table actor
drop column middle_name;

#4a List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as count from actor group by last_name order by count desc;

#4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) c FROM actor GROUP BY last_name HAVING c > 1 order by c desc;

/*4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/
update actor
set first_name = 'HARPO' 
where last_name = 'Williams' and first_name = 'Groucho';

/*4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
 Otherwise, change the first name to MUCHO GROUCHO. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
 (Hint: update the record using a unique identifier.)*/
update actor
set first_name = 'GROUCHO' 
where actor_id = 172 and first_name = 'HARPO';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

/*6a. Use JOIN to display the first and last names, as well as the address, 
of each staff member. Use the tables staff and address:*/
select first_name, last_name, address 
from staff s
join address a
on (s.address_id = a.address_id);

/*6b. Use JOIN to display the total amount rung up by each staff member in 
August of 2005. Use tables staff and payment.*/
select first_name, last_name, sum(amount) Total
from staff s
join payment p
on (s.staff_id = p.staff_id)
WHERE payment_date >='2005-08-01 00:00:00'
AND payment_date <'2005-09-01 00:00:00'
group by first_name, last_name;

/*6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join.*/
select title `Movie`, count(actor_id) `Total actors in the movie`
from film f
join film_actor fa
on (f.film_id = fa.film_id)
group by title
order by `Total actors in the movie` desc;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title `Movie`, count(i.film_id) `Copies on hand`
from film f
join inventory i
on (f.film_id = i.film_id)
group by title
order by `Copies on hand` desc;

/*6e. Using the tables payment and customer and the JOIN command, list the total paid 
by each customer. List the customers alphabetically by last name*/
select first_name, last_name, sum(amount) `Total paid`
from customer c
join payment p
on(c.customer_id = p.customer_id)
group by first_name, last_name
order by last_name;

/*7a. Use subqueries to display the titles of movies starting with 
the letters K and Q whose language is English.*/
select title from film
where title regexp '^[K,Q]'
and language_id in
	(
		select language_id
		from language
		where name = 'English'
	);
    
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id in
	(
		select actor_id
		from film_actor
		where film_id in
			(
				select film_id
				from film
				where title = 'Alone Trip'
			)
	)
order by last_name;

/*7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all 
Canadian customers. Use joins to retrieve this information.*/
select email
from customer
where address_id in
	(
		select address_id 
		from address
		where city_id in
			(
				select city_id
				from city
				where country_id in
					(
						select country_id
						from country
						where country = 'Canada'
					)
			)
	)
;

/*7d. Sales have been lagging among young families, and you wish to target 
all family movies for a promotion. Identify all movies categorized as famiy films.*/
select title
from film
where film_id in
	(
		select film_id
		from film_category
		where category_id in
			(
				select category_id
				from category
				where name = 'Family'
			)
	)
;


















































