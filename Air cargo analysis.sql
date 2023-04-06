create database aircargo;
use aircargo;
create table customer(
customer_id INT NOT NULL,
first_name VARCHAR(20) NOT NULL,
last_name varchar(20) not null,
dob varchar(20) not null,
gender char(1) not null,
primary key(customer_id));


create table pof(
customer_id int not null,
aircraft_id varchar(20) not null,
route_id varchar(20) not null,
depart char(5) not null,
arrival char(4) not null,
seat_no char(5) not null,
class_id varchar(20) not null,
travel_date varchar(20) not null,
flight_no varchar(20) not null,
primary key(customer_id));

create table routes(
route_id int not null,
flight_no varchar(20) not null,
origin_airport char(20) not null,
destination_airport char(20) not null,
aircraft_id varchar(20) not null,
dist_miles int not null,
primary key(route_id));


create table ticket_details(
customer_id int not null,
p_date VARCHAR(20) not null,
aircraft_id varchar(20) not null,
class_id varchar(20) not null,
no_of_tickets int not null,
a_code char(3) not null,
price_per_ticket int not null,
brand varchar(20) not null,
primary key(customer_id));

select*from customer where customer_id in (select distinct customer_id from pof where route_id between 1 and 25) order by customer_id;
select count(distinct customer_id) as num_passengers,sum(no_of_tickets * price_per_ticket) as total_revenue from ticket_details
 where class_id='BUSINESS';

select concat (first_name," ", last_name) as full_name from customer;

select first_name,last_name from customer where customer_id in (select distinct b.customer_id from customer a, ticket_details b);

select first_name,last_name from customer where customer_id in (select distinct customer_id from ticket_details where brand='EMIRATES');

select class_id,count(distinct customer_id) as num_passengers from pof group by class_id having class_id='economy plus';
select * from customer a
inner join (select distinct customer_id from pof where class_id ='economy plus') b
on a.customer_id = b.customer_id;

select if ((select sum(no_of_tickets*price_per_ticket) as total_revenue from ticket_details) > 10000, 'crossed 10k','not crossed 10k') as 
revenue_check;

create user if not exists 'muzamil'@'127.0.0.1' identified by 'password123';
grant all privileges on aircargo to muzamil@127.0.0.1;

select class_id,max(price_per_ticket) from ticket_details group by class_id;
select distinct class_id,max(price_per_ticket) over (partition by class_id) as max_price from ticket_details order by max_price;

explain select* from pof where route_id=4;
create index idx_rid on pof (route_id);
explain select*from pof where route_id=4;

select customer_id,aircraft_id,sum(price_per_ticket * no_of_tickets) as total_price from ticket_details group by customer_id,aircraft_id;

create view business_class_customers as
select a.*,b.brand from customer a
inner join (select distinct customer_id,brand from ticket_details where class_id='BUSINESS' order by customer_id) b
on a.customer_id=b.customer_id;

select * from customer where customer_id in (select distinct customer_id from pof where route_id in (1,5));


delimiter //
create procedure check_route( in rid varchar(300))
begin
declare TableNotFound condition for 1146;
declare exit handler for TableNotFound
select 'please check if table customer/route id are created - one/both are missing' Message;
set @query= concat('select *from customer where customer id in ( select distinct customer_id from pof where route_id in (',rid,'));');
prepare sql_query from @query;
execute sql_query;
end//
delimiter ;
call check_route('1,5');


delimiter //
create procedure check_dist()
begin
     select* from routes where dist_miles > 2000;
end //
delimiter ;
call check_dist();


select flight_no,dist_miles,case
when dist_miles between 0 and 2000 then "SDT"
when dist_miles between 2001 and 6500 then "IDT"
else "LDT"
end distance_category from routes;


delimiter //
create function group_dist(dist int)
returns varchar(20)
deterministic
begin
declare dist_cat char(3);
iF dist between 0 and 2000 then
set dist_cat = 'SDT';
elseif dist between 2001 and 6500 then
set dist_cat= 'IDT';
elseif dist > 6500 then
set dist_cat ='LDT';
end if;
return (dist_cat);
end //


create procedure group_dist_proc()
begin
select flight_no,dist_miles,group_dist(dist_miles) as distance_category from routes;
end //
delimiter ;
call group_dist_proc();



select p_date,customer_id,class_id,case
when class_id in ('business','economy plus') then "yes"
else "no"
end as complimentary_service from ticket_details;


delimiter //
create function check_comp_serv(cls varchar(20))
returns char(4)
deterministic
begin
declare comp_ser char(4);
if cls in ('business','economy plus') then
set comp_ser = "yes";
else
set comp_ser = "no";
end if;
return (comp_ser);
end //


create procedure check_comp_serv_proc()
begin
select p_date,customer_id,class_id,check_comp_serv(class_id) as complimentary_service from ticket_details;
end //
delimiter ;
call check_comp_serv_proc();

select * from customer where last_name='Scott' limit  1;

delimiter //
create procedure cust_lname_scott()
begin
declare c_id int;
declare f_name varchar(20);
declare l_name varchar(20);
declare dob varchar(20);
declare gen char(1);

declare cust_rec cursor
for
select*from customer where last_name='Scott';


create table if not exists cursor_table(
c_id int,
f_name varchar(20),
l_name varchar(20),
dob varchar(20) ,
gen char(1)
);

open cust_rec  ;
fetch cust_rec into c_id,f_name,l_name,dob,gen ;
insert into cursor_table(c_id,f_name,l_name,dob,gen)values(c_id,f_name,l_name,dob,gen) ;
close cust_rec;


select * from cursor_table;

end //

delimiter ;

call cust_lname_scott () ;