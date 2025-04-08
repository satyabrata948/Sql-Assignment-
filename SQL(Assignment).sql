#Q1 #SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
use classicmodels;
#A#
select * from employees;
select employeenumber,firstname,lastname from employees where reportsTo = 1102;
#B#
select * from products;
select distinct productline from products where productline like "%cars";

#Q2. CASE STATEMENTS for Segmentation#
select * from customers;
select customernumber, customername, 
CASE
when country in ('USA', 'canada') then "North America"
when country in ('uk','france', 'germany') then "Europe"
else "other"
end  customersegment
from customers;

#Q3. Group By with Aggregation functions and Having clause, Date and Time functions
Select * from orderdetails;
#A#
select productcode, sum(quantityordered) as total_ordered
from orderdetails group by productcode order by total_ordered desc limit 10;
#B#
select * from payments;
select monthname (paymentdate) as payment_month, count(*) as num_payments from payments
group by payment_month having num_payments>20 order by num_payments desc;

#4.CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
# solution 4 #
# A #
create database customer_orders;
use customer_orders;
create table customers(customer_id int primary key auto_increment,first_name varchar (50) not null, Last_name varchar(50)not null,
email varchar(255) unique,phone_number varchar (20));
desc customers;
#B#
create table orders(order_id int primary key auto_increment,customer_id int, foreign key (customer_id) references customers (customer_id),
order_date date, total_amount decimal (10,2), check (total_amount > 0));
desc orders;

#Q5. JOINS
select * from customers;
select * from orders;
select c.country, count(o.ordernumber) as order_count
from customers c
join orders o on o.customernumber = c.customernumber
group by c.country
order by order_count desc limit 5;

#Q6. SELF JOIN# 
use customer_orders;
drop table project;
create table project(employee_id int primary key auto_increment,fullname varchar(50) not null, 
gender varchar(6) check (gender in ('male','female')), managerid int );
desc project;
select * from project;
insert into project  (fullname,gender,managerid) values ('pranaya','male',3),
('priyanka',"female",1), ('preety','female',not null),('anurag','male',1),('sambit','male',1),('rajesh','male',3), ('hina','female',3);

select m.fullname as managername ,e.fullname as employeename
from project e inner join project m
on m.employee_id = e.managerid;

#Q7. DDL Commands: Create, Alter, Rename
create table facility(facility_id int, name varchar(100),state varchar(100),country varchar (100));
alter table facility modify facility_id int auto_increment, add primary key (facility_id);
alter table facility add city varchar(100) not null after name ;
desc facility;

#Q8. Views in SQL
drop view product_category_sales;
create view product_category_sales 
as (select P.productline,
sum(od.quantityordered*od.priceeach) as total_sales, 
count(distinct od.ordernumber) as number_of_orders
from products p join orderdetails od on p.productcode=od.productcode 
group by p.productline);
select * from  product_category_sales;

#Q9. Stored Procedures in SQL with parameters#
DELIMITER //
CREATE PROCEDURE `get_country_payments` (
in year_s int,
in country varchar(30))
BEGIN
select year(P.PaymentDate) as year, 
c.country as country,
concat(format(sum(p.amount)/1000,0),'K') as total_amount from
payments as p left join customers as c on p.customernumber=c.customernumber
where year (p.paymentdate) = year_s and c.country=country
group by year(p.paymentdate),c.country;
   END 
  //
  DELIMITER ;

call get_country_payments(2003, 'france');


#Q10. Window functions - Rank, dense_rank, lead and lag#
select * from customers;
select * from orders;
#A#
with customers_orders_count as (
select c.customername, count(o.ordernumber) as order_count
from customers c
join orders o on o.customernumber = c.customernumber
group by c.customername
order by order_count desc
)
select customername, 
order_count,
Dense_Rank() over(order by order_count desc) as order_frequency_rank
from customers_orders_count
order by order_count desc;

#B#
create table orders_1 as (
select *, lag(totalorders) over (partition by years order by years) as ranking from 
(select year(orderdate) as years,
monthname( orderdate) as months,
count(ordernumber) as totalorders
from orders group by year(orderdate),monthname(orderdate)) as orders_new);

select Years,Months,Totalorders,concat(round((totalorders-ranking)*100/ranking),'%') as percentage_change from orders_1;

#Q11.Subqueries and their applications#
select productline, count(*) as productcount
from products where buyprice > (select Avg(buyprice) from products) 
group by productline order by productcount desc ;

#Q12. ERROR HANDLING in SQL#
drop table emp_eh;
create table EMP_EH(Empid int primary key, Empname varchar(30),EmailAddress varchar (100));
insert into EMP_EH values (1,"Akshay","akshay123@gmail.com"),(2,"Ayansh","ansh456@gmail.com");
select * from EMP_EH;

DELIMITER //
create procedure Emp_EH (empid int,empname varchar (30),emailaddress varchar (100))
BEGIN
Declare continue handler for SQLEXCEPTION
BEGIN
insert into EMP_EH (empid,empname,emailaddress)
values ('Error occured', 'Error occured','Error occured');
end;
insert into emp_eh values (emoid,empname,emailaddress);
select 'entry success' as message;
END
 // 
DELIMITER ;

Select 'Error occurred' as message;


#Q13. TRIGGERS
create table EMP_BIT(NAME varchar (20),Occupation varchar(15),Working_date date, Working_hours varchar(5));
insert into Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  
select * from EMP_BIT;

DELIMITER //
create trigger emp_bit_BEFORE_INSERT
BEFORE INSERT on emp_bit for each row begin
if new.working_hours < 0 then 
set new.working_hours = - new.working_hours;
end if;
END
  // 
  DELIMITER ;

insert into Emp_BIT VALUES
('Ayansh', 'Scientist', '2020-10-04', -12),
('AShok', 'Actor', '2020-10-04', -10),  
('Sathish', 'Engineer', '2020-10-04', -13);  
select * from EMP_BIT