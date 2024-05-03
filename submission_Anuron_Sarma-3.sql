Use vehdb;
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

Select count(Customer_id) as no_of_customers, state 
from customer_t
group by state
order by no_of_customers desc;

-- The highest number of customers are present in California & Texas with 97 and the lowest in Maine, Wyoming and vermont with 1. 
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

With ratingsCTE as (
  select
    avg(case 
      when customer_feedback = 'Very Bad' then 1
      when customer_feedback = 'Bad' then 2
      when customer_feedback = 'Okay' then  3
      when customer_feedback = 'Good' then  4
      when customer_feedback = 'Very Good' then  5
      Else 0
      End) as average_rating, quarter_number
from order_t
group by quarter_number)
select * from ratingsCTE 
order by average_rating desc;

-- The average rating is in a downward trend from the 1st quarter to the 4th quarter. 
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
with feedbackCTE as(
    Select count(customer_feedback) feedback_count, quarter_number, customer_feedback
    from order_t
    group by quarter_number, customer_feedback)
select customer_feedback, quarter_number, feedback_count,
(feedback_count * 100 / SUM(feedback_count) OVER (PARTITION BY quarter_number)) AS feedback_percentage 
from feedbackCTE
order by quarter_number;
    
-- Yes, the customers are getting dissatisfied over time as we can see a declining trend of 'Very Good' feedbacka and a rising trend of 'Very Bad' feedback.
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

Select Count(Customer_id) no_of_customers, vehicle_maker 
from order_t o join product_t p 
on o.product_id = p.product_id
group by vehicle_maker
order by no_of_customers desc limit 5;

-- By order from top - Chevrolet, Ford, Toyota, Pontiac and Dodge are the preferred veicle makers by customers. 
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT
    c.state,
    p.vehicle_model,
    COUNT(c.customer_id) AS customer_count,
    rank() OVER (PARTITION BY c.state ORDER BY COUNT(c.customer_id) DESC) 
FROM customer_t c 
join order_t o
using(customer_id)
join product_t p
using(product_id)
GROUP BY
    c.state,
    p.vehicle_model
order by customer_count desc;

-- The most prefereed vehicle maker in California is Maxima. 
-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

Select count(order_id) no_of_orders, quarter_number
from order_t
group by quarter_number
order by quarter_number asc;

-- The number of orders by quarter is a downtrend 
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
With revenue_changeCTE as(
    Select sum(quantity*vehicle_price) as total_revenue,
    quarter_number,
    lag(sum(quantity*vehicle_price)) over (order by quarter_number) as prev_quarter_revenue,
    case
        When (lag(sum(quantity*vehicle_price)) over (order by quarter_number)) Is Null Then 0
        else (((sum(quantity*vehicle_price)) - (lag(sum(quantity*vehicle_price)) over (order by quarter_number))) / (lag(sum(quantity*vehicle_price)) over (order by quarter_number))) * 100
        End as revenue_change_qoq
    from order_t
    group by quarter_number)
select * from revenue_changeCTE;
   
-- The quarter over quarter revenue change is a downtrend from 1st to 4th quarter with losses in revenue in every quarter change   
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

Select sum(quantity*vehicle_price) as revenue,
    count(order_id) as no_of_orders,
    quarter_number
    from order_t
    group by quarter_number
    order by quarter_number;

-- Both revenue and orders are in a downtrend from 1st to 4th quarter. 
-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

Select avg(discount) average_discount, credit_card_type
from customer_t c join order_t o
on c.customer_id = o.customer_id
group by credit_card_type;

-- The average discount for various credit cards varies from a minimum of 58.4% to a maximum of 64.38%
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

Select avg(datediff(ship_date,order_date)) average_time_taken_days , quarter_number
from order_t 
group by quarter_number
order by quarter_number;

-- The average time taken to ship the placed orders is minimum in 1st quarter i.e 57.16 days and maximum in 4th quarter
-- i.e 174.09 days with an increasing trend from 1st to 4th quarter.
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



