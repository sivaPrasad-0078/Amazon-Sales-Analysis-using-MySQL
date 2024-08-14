create database amazondb;

use amazondb;
-- Load the data from the dataset--
select * from amazon;

-- Change the column names --
ALTER TABLE amazon 
RENAME COLUMN `Invoice ID` TO `Invoice_ID`;

ALTER TABLE amazon 
RENAME COLUMN `Customer type` TO `Customer_type`;

ALTER TABLE amazon 
RENAME COLUMN `Product line` TO `Product_line`;

ALTER TABLE amazon 
RENAME COLUMN `Unit price` TO `Unit_price`;

ALTER TABLE amazon 
RENAME COLUMN `Tax 5%` TO `Tax`;

ALTER TABLE amazon 
RENAME COLUMN `Total` TO `Total_Price`;

ALTER TABLE amazon 
RENAME COLUMN `gross margin percentage` TO `gross_margin_percentage`;

ALTER TABLE amazon 
RENAME COLUMN `gross income` TO `gross_income`;

ALTER TABLE amazon 
RENAME COLUMN `Payment` TO `Payment_method`;

-- after change the column names --
select*from amazon;

-- check the null in each column --
select * from amazon where 
Invoice_ID is null
or Branch is null
or City is null
or Customer_type is null
or Gender is null
or Product_line is null
or Unit_price is null
or Quantity is null
or Tax is null
or Total is null
or `Date` is null
or `Time` is null
or `Payment` is null
or `Cogs` is null
or `gross_margin_percentage` is null 
or `gross_income` is null
or `Rating` is null;

-- Feature engineering --
-- Add the new 3 columns to the dataset --
-- The column names are timeofday,dayname,monthname --

-- select DAYNAME(Date) from amazon; --
-- Add the time_of_day column and update the values --
alter table amazon add column time_of_day varchar(20);

SET SQL_SAFE_UPDATES = 0;
update amazon 
SET time_of_day = case
	 WHEN TIME(Time) between '06:00:00' and '11:59:59' then 'Morning'
	 WHEN TIME(Time) between '12:00:00' and '17:59:59' then 'Afternoon'
	 WHEN TIME(Time) between '18:00:00' and '23:59:59' then 'Evening'
	 ELSE 'Night'
end;
SET SQL_SAFE_UPDATES = 1;

-- Add the day_name column and Update the values --

alter table amazon add column day_name varchar(20);

SET SQL_SAFE_UPDATES = 0;
update amazon 
set day_name=DAYNAME(Date);
SET SQL_SAFE_UPDATES = 1;

-- Add the month_name column and the Update the values--

alter table amazon add column month_name varchar(20);

SET SQL_SAFE_UPDATES = 0;
update amazon
set month_name = monthname(Date);
SET SQL_SAFE_UPDATES = 1;

select * from amazon;

-- checking the distinct product_lines --
select distinct(Product_line) as Product_line from amazon;
select count(distinct(Product_line)) as count_distinct_Product_line from amazon;

-- check the distinct branches --
select distinct(Branch) from amazon;

-- check the distinct cities in datset --
select distinct(City) from amazon;
select distinct Branch,City from amazon;

-- check the unique payment methods --
select distinct(Payment_method) from amazon; 
select count(distinct(Payment_method)) as count_Payment_method from amazon;


-- PRODUCT ANALYSIS --

-- By Total Revenue --
select Product_line, sum(Total_Price) as Total_Price from amazon 
group by Product_line order by Total_Price desc limit 1;

select Product_line, sum(Total_Price) as Total_Price from amazon 
group by Product_line order by Total_Price limit 1;

-- by total Quantity --
select Product_line, sum(Quantity) as Quantity from amazon 
group by Product_line order by Quantity desc;

-- by rating --
select Product_line, avg(Rating) as Rating from amazon 
group by Product_line order by Rating desc;


-- SALES ANALYSIS --

-- Sales analysis by Branch and city --
select Branch,City,sum(Total_Price) as Total_Price from amazon 
group by Branch,City order by Total_Price desc;

select Branch,City,sum(Quantity) as Quantity from amazon 
group by Branch,City order by Quantity desc;

-- month vise sales --
select month_name,sum(Total_Price) as Total_Price from amazon
group by month_name order by Total_Price desc; 

select day_name, avg(Rating) as Rating from amazon
group by day_name order by Rating desc; 

select time_of_day,count(*) as num_sales from amazon 
group by time_of_day order by num_sales desc; 

-- CUSTOMER ANALYSIS --
select Customer_type,sum(Total_Price) as Total_Price from amazon 
group by Customer_type order by Total_Price desc;

select Gender,sum(Total_Price) as Total_Price from amazon 
group by Gender order by Total_Price desc;

select Customer_type,count(*) as count_cust_Type from amazon
group by Customer_type order by count_cust_type desc;

select Customer_type,avg(Rating) as Rating from amazon 
group by Customer_type order by Rating desc;

select Gender,Product_line,count(*) as num_sales from amazon where Gender = 'Female'
group by Gender,Product_line order by num_sales desc limit 1;

select Gender,Product_line,count(*) as num_sales from amazon where Gender = 'Male'
group by Gender,Product_line order by num_sales desc limit 1;


-- Question and Answers --

-- 1.What is the count of distinct cities in the dataset? --

select count(distinct(City)) from amazon;

-- 2.For each branch, what is the corresponding city? --

select distinct Branch,City from amazon;

-- 3.What is the count of distinct product lines in the dataset? --
select count(distinct(Product_line)) as count_Product_line from amazon;

-- 4.Which payment method occurs most frequently? --
select Payment_method,count(*) as Payment_method_count from amazon
group by Payment_method order by Payment_method_count desc limit 1;

-- 5.Which product line has the highest sales? --
select Product_line, sum(Total_Price) as Total_Price from amazon 
group by Product_line order by Total_Price desc limit 1;

-- 6.How much revenue is generated each month? --
select month_name, sum(Total_Price) as Total_Price from amazon 
group by month_name order by Total_Price desc;

-- 7.In which month did the cost of goods sold reach its peak? --
select month_name, sum(cogs) as cogs from amazon 
group by month_name order by cogs desc limit 1;

-- 9.In which city was the highest revenue recorded? --
select City,sum(Total_Price) as Total_Price from amazon 
group by City order by Total_Price desc limit 1;

-- 10.Which product line incurred the highest Value Added Tax? --
select Product_line,sum(Tax) as Tax from amazon 
group by Product_line order by Tax desc ;

-- 12.Identify the branch that exceeded the average number of products sold. --
select Branch,avg(Quantity) as total_products_sold from amazon
group by Branch having total_products_sold > (select avg(Quantity) from amazon)


-- 13.Which product line is most frequently associated with each gender? --
select Gender,Product_line,COUNT(*) AS frequency from amazon
group by Gender,Product_line;
    
WITH ranked_product_lines AS (
    SELECT Gender,Product_line,COUNT(*) AS frequency,
        row_number() over(partition by Gender order by COUNT(*) desc) AS ranks from amazon
    group by Gender,Product_line)
    select Gender,Product_line,frequency from ranked_product_lines where ranks = 1;
    
-- 14.Calculate the average rating for each product line. --
select Product_line,avg(Rating) as avg_Ratings from amazon
group by Product_line order by avg_Ratings desc;

-- 15.Count the sales occurrences for each time of day on every weekday. --
select time_of_day,day_name, count(*) as sales_count  from amazon 
group by time_of_day,day_name order by FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');

-- 16.Identify the customer type contributing the highest revenue. --
select Customer_type,sum(Total_Price) as Total_Price from amazon 
group by Customer_type order by Total_Price desc;

-- 17.Determine the city with the highest VAT percentage. --
select City,sum(Tax) as Tax from amazon 
group by City order by Tax desc limit 1;

-- 18.Identify the customer type with the highest VAT payments. --
select Customer_type,sum(Tax) as Tax from amazon 
group by Customer_type order by Tax desc limit 1;

-- 19.What is the count of distinct customer types in the dataset? --
select count(distinct(Customer_type)) from amazon;

-- 20.What is the count of distinct payment methods in the dataset? --
select count(distinct(Payment_method)) as count_payment_method from amazon;

-- 21.Which customer type occurs most frequently? --
select Customer_type,count(*) as frequency from amazon 
group by Customer_type order by frequency desc limit 1;

-- 22.Identify the customer type with the highest purchase frequency.--
select Customer_type,count(*) as pur_frequency from amazon 
group by Customer_type order by pur_frequency desc limit 1;

-- 23.Determine the predominant gender among customers. --
select Gender,count(*) as frequency from amazon 
group by Gender order by frequency desc limit 1;

-- 24.Examine the distribution of genders within each branch.--
select Branch,Gender, count(*) as nums from amazon 
group by Branch,Gender order by Branch,Gender;

-- 25.Identify the time of day when customers provide the most ratings.-- 
select time_of_day,avg(Rating) as avg_Rating from amazon 
group by time_of_day order by avg_Rating desc limit 1;

-- 26.Determine the time of day with the highest customer ratings for each branch.--

select Branch,time_of_day,avg(Rating) as avg_rating from amazon 
group by Branch,time_of_day order by Branch,avg_rating desc;

-- 27.Identify the day of the week with the highest average ratings.--

select day_name,avg(Rating) as avg_rating from amazon 
group by day_name order by avg_rating desc limit 1;

-- 28.Determine the day of the week with the highest average ratings for each branch.--
select Branch,day_name,avg(Rating) as avg_rating from amazon 
group by Branch,day_name order by Branch,avg_rating desc ;


with ranked_line as (
	select Branch,day_name,avg(Rating) as avg_rating,
		row_number() over(partition by Branch order by avg(Rating) desc) as ranks from amazon 
	group by Branch,day_name)
select Branch,day_name,avg_rating from ranked_line where ranks=1;






select * from amazon;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


