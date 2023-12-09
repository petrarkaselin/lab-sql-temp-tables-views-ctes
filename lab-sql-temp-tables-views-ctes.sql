-- LAB | Temporary Tables, Views and CTEs
use sakila;
    -- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
drop view if exists v_rental; 
create view v_rental as
select customer_id, first_name, last_name, email, count(rental_id) as rental_count
from rental
left join customer
using (customer_id)
group by customer_id, first_name, last_name, email;

select * from v_rental;
   
   -- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
drop temporary table total_paid;
create temporary table total_paid
select * from v_rental
left join (select customer_id, sum(amount) as total_paid
from payment
group by customer_id) as sub
using(customer_id);

select * from total_paid;

    -- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
with customer_summary as
(select v.customer_id, v.first_name, v.last_name, v.email, v.rental_count, tp.total_paid
from v_rental as v
left join total_paid as tp
using(customer_id))
select * from customer_summary;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include:
 -- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
with customer_summary as
(select v.customer_id, v.first_name, v.last_name, v.email, v.rental_count, tp.total_paid
from v_rental as v
left join total_paid as tp
using(customer_id))
select *, round(total_paid/rental_count, 2) as average_payment_per_rental
from customer_summary; 