use sakila;

#1a: You need a list of all the actors who have Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

#1b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ',last_name) as `Actor Name` from actor;

/*2a You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you 
use to obtain this information?*/
select actor_id, first_name, last_name from actor where first_name = 'Joe';

#2b Find all actors whose last name contain the letters GEN:
select * from actor where last_name like '%GEN%';

/*2c Find all actors whose last names contain the letters LI. This time, 
order the rows by last name and first name, in that order:*/
select * from actor where last_name like '%LI%' order by last_name, first_name;

#2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

/*3a Add a middle_name column to the table actor. Position it between 
first_name and last_name. Hint: you will need to specify the data type.*/
alter table actor
add middle_name varchar(3) after first_name;

/*3b You realize that some of these actors have tremendously long last names. 
Change the data type of the middle_name column to blobs.*/
alter table actor
modify column middle_name blob;

#3c Now delete the middle_name column.
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

#7e. Display the most frequently rented movies in descending order.
select f.title movie, count(*) rent_count
from film f, inventory i, rental r
where f.film_id = i.film_id and i.inventory_id = r.inventory_id
group by movie
order by rent_count desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount)
from store s, payment p, inventory i, rental r
where s.store_id = i.store_id and i.inventory_id = r.inventory_id 
	and r.rental_id = p.rental_id
group by s.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, country.country
from store s, city c, country, address a
where s.address_id = a.address_id and a.city_id = c.city_id
	and c.country_id = country.country_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need 
to use the following tables: category, film_category, inventory, payment, and rental.)*/
select c.name category, sum(p.amount) total 
from category c, payment p, film_category fc, inventory i, rental r
where c.category_id = fc.category_id 
	and	fc.film_id = i.film_id
    and i.inventory_id = r.inventory_id
    and r.rental_id = p.rental_id
group by c.name
order by total desc
limit 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing 
the Top five genres by gross revenue. Use the solution from the problem above to create 
a view. If you haven't solved 7h, you can substitute another query to create a view.*/
create view `Top 5 categories by gross revenue` as
select c.name category, sum(p.amount) total 
from category c, payment p, film_category fc, inventory i, rental r
where c.category_id = fc.category_id 
	and	fc.film_id = i.film_id
    and i.inventory_id = r.inventory_id
    and r.rental_id = p.rental_id
group by c.name
order by total desc
limit 5;

#8b. How would you display the view that you created in 8a?
select * from `Top 5 categories by gross revenue`;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
drop view `Top 5 categories by gross revenue`;





































