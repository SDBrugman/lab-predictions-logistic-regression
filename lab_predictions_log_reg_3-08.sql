USE sakila;

-- In order to optimize our inventory, we would like to know which films will be rented next month 
-- and we are asked to create a model to predict it.

-- 1 --
-- Create a query or queries to extract the information you think may be relevant for building the prediction model. 
-- It should include some film features and some rental features.
-- Step 1: Get the account_id, date, year, month and month_number for every rental activity.
drop view if exists rentals_activity; 
create or replace view rentals_activity as
select customer_id, rental_id, inventory_id, convert(rental_date, date) as activity_date,
date_format(convert(rental_date,date), '%M') as activity_month,
date_format(convert(rental_date,date), '%m') as activity_month_number,
date_format(convert(rental_date,date), '%Y') as activity_year
from rental;

select * from rentals_activity;

-- step 2: Check rental per month by distinct customer and store the results in a view.
drop view if exists monthly_rental_activity;
create view monthly_rental_activity as
select activity_year, activity_month, activity_month_number, count(distinct customer_id) as active_customer from rentals_activity
group by activity_month, activity_year
order by activity_year, activity_month_number asc;

select * from monthly_rental_activity;

drop view if exists film_prediction;
create view film_prediction as
Select f.film_id, fc.category_id, f.rental_rate, f.rating, f.release_year, f.length, 
i.store_id, convert(r.rental_date, date) as activity_date,
date_format(convert(r.rental_date,date), '%M') as activity_month,
date_format(convert(r.rental_date,date), '%m') as activity_month_number,
date_format(convert(r.rental_date,date), '%Y') as activity_year
from rental r
	join inventory i on r.inventory_id = i.inventory_id
    join film f on i.film_id = f.film_id
    join film_category fc on f.film_id = fc.film_id
order by f.film_id, activity_month_number;

select * from film_prediction;

select distinct f.film_id, r.rental_id, 
concat(date_format(convert(r.rental_date,date), '%m'), '' , date_format(convert(r.rental_date,date), '%Y')) as last_month,
CASE
	WHEN concat(date_format(convert(r.rental_date,date), '%m'), '' , date_format(convert(r.rental_date,date), '%Y')) = '022006' THEN '1'
    ELSE '0'
END AS 'rented_last_month'
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
order by rented_last_month DESC;
