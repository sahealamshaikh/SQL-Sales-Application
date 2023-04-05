--------------------------CREATING TABLE CATEGORY-----------------------------

CREATE TABLE category (
ID int primary key ,
Name varchar2(100) not null
);

CREATE SEQUENCE seq_cat;

INSERT INTO category(id,name)
values(seq_cat.nextval,'Grocery');
INSERT INTO category(id,name)
values(seq_cat.nextval,'Mobiles');
INSERT INTO category(id,name)
values(seq_cat.nextval,'Fashion');

alter table category
rename column ID to Category_id; 

select * from category;

--------------CREATING TABLE PRODUCT-------------------------------------

CREATE TABLE product(
    product_id int NOT NULL primary key ,
    product_name varchar2(100),
    Price INT not null,
    Category_id int,
    FOREIGN KEY(Category_id) REFERENCES category(Category_id) 
);

create SEQUENCE seq_pro;

insert into product(product_id,product_name,price,category_id)
values(seq_pro.nextval,'Parle G',80,1);
insert into product(product_id,product_name,price,category_id)
values(seq_pro.nextval,'Oreo',100,1);
insert into product(product_id,product_name,price,category_id)
values(seq_pro.nextval,'Corn flakes',90,1);
insert into product(product_id,product_name,price,category_id)
values(seq_pro.nextval,'Chocos',100,1);
insert into product(product_id,product_name,price,category_id)
values(seq_pro.nextval,'Sugar',100,1);

select * from product;


-------------------Creating state table------------------------------

create table state(
state_id int primary key,
state_name varchar2(50) not null
);

create sequence seq_state;

insert into state(state_id,state_name)
values(seq_state.nextval,'Maharastra');
insert into state(state_id,state_name)
values(seq_state.nextval,'Rajasthan');
insert into state(state_id,state_name)
values(seq_state.nextval,'Gujrat');
insert into state(state_id,state_name)
values(seq_state.nextval,'Madhya pradesh');


select * from state;

---------------------------crete table customer------------------------

create table customer(
cust_id int primary key,
cust_name varchar2(50),
email varchar2(50) unique,
DOB date,
state_id int,
foreign key (state_id) references state(state_id)
);

alter table customer
modify email varchar(100) not null;

alter table customer
drop column email;

alter table customer
add email varchar(50);

create sequence seq_cust;

update customer
set email =  'sahealamshaikh@gmail.com'
where cust_id = 1;

insert into customer(cust_id,cust_name,email,DOB,state_id)
values(seq_cust.nextval,'Sahealam shaikh','sahealamshaikh@gmail.com','01-jan-22',1);
insert into customer(cust_id,cust_name,DOB,state_id,email)
values(seq_cust.nextval,'Sachin verma','19-jan-22',1,'sachinver@gmail.com');
insert into customer(cust_id,cust_name,DOB,state_id,email)
values(seq_cust.nextval,'Rahul verma','29-jan-22',1,'rahulverma@gmail.com');
insert into customer(cust_id,cust_name,DOB,state_id,email)
values(seq_cust.nextval,'Anis shaikh','21-jan-22',1,'anishaikh@gmail.com');

select * from customer;

--------------------creating transaction table-------------------

create table transaction(
trans_id int primary key,
trans_time date ,
cust_id int,
product_id int,
quantity int,
foreign key (cust_id) references customer(cust_id),
foreign key (product_id) references product(product_id)
);

create sequence seq_trans;

insert into transaction(trans_id,trans_time,cust_id,product_id,quantity)
values(seq_trans.nextcal,systimestamp,2,4,3);
insert into transaction(trans_id,trans_time,cust_id,product_id,quantity)
values(seq_trans.nextcal,systimestamp,5,23,5);

select * from transaction;

--------------------------------------------------------------------------------

-----------------   Three table join -------------------------------------------
    
            -----    # top 3 selling categories     ----

---creating joins

select * 
from transaction t , product p , category c
where t.product_id = p.product_id 
and p.category_id = c.category_id;

------finding category wise total sales

select c.category_id , sum(t.quantity*p.price) sales
from transaction t , product p , category c
where t.product_id = p.product_id 
and p.category_id = c.category_id
group  by c.category_id
order by sales desc ;

----- finding TOP 3 selling categories using rownum

select rownum , cat_id , sales 
from (select c.category_id cat_id, sum(t.quantity*p.price) sales
        from transaction t , product p , category c
        where t.product_id = p.product_id 
        and p.category_id = c.category_id
        group  by c.category_id
        order by sales desc 
    );


select rnum , sales , cat_id 
from (select rownum rnum ,cat_id ,sales 
        from (select c.category_id cat_id, sum(t.quantity*p.price) sales
                from transaction t , product p , category c
                where t.product_id = p.product_id 
                and p.category_id = c.category_id
                group  by c.category_id
                order by sales desc ))
where rnum <= 3 ;

-------finding TOP 3 using FETCH only

select c.category_id,sum(t.quantity*p.price) totalsales
from category c,product p,transaction t
where c.category_id = p.category_id
and t.product_id = p.product_id
group by c.category_id
order by totalsales desc
fetch first 3 rows only;


----------------------    # top 3 selling PRODUCTS     -------------------------

------creating joins
select p.product_id,t.quantity,p.price
from transaction t,product p,category c
where t.product_id = p.product_id 
and p.category_id = c.category_id;

------finding product group wise total sales
select p.product_id , sum(p.price*t.quantity) totalsales
from transaction t,product p,category c
where t.product_id = p.product_id 
and p.category_id = c.category_id
group by p.product_id
order by totalsales desc;

-----finding TOP 3 product using rownum
select rownum rnum ,product_id ,totalsales
from (select p.product_id product_id, sum(p.price*t.quantity) totalsales
        from transaction t,product p,category c
        where t.product_id = p.product_id 
        and p.category_id = c.category_id
        group by p.product_id
        order by totalsales desc);
        
select * 
from (select rownum rnum ,product_id ,totalsales
        from (select p.product_id product_id, sum(p.price*t.quantity) totalsales
                from transaction t,product p,category c
                where t.product_id = p.product_id 
                and p.category_id = c.category_id
                group by p.product_id
                order by totalsales desc)
        )
where rnum <= 3;

---------------------    # PRODCUT WISE TOTAL SALES     ------------------------

-----creating joins
SELECT * 
FROM transaction t,category c,product p
WHERE t.product_id = p.product_id
AND p.category_id = c.category_id;

-----finding productname wise totalsales
SELECT p.product_name,sum(t.quantity*p.price) Sales
FROM transaction t,category c,product p
WHERE t.product_id = p.product_id
AND p.category_id = c.category_id
GROUP BY p.product_name
ORDER BY sales DESC
fetch first 3 rows only;

------------------- CUSTOMER PURCHASE DETAILS ----------------------------------

------customer purchase detail with cust_id

SELECT c.cust_id,price,quantity
FROM transaction t,product p,customer c
where t.product_id = p.product_id
AND t.cust_id = c.cust_id
ORDER BY c.cust_id;

------customer purchase detail with cust_name

SELECT c.cust_name,sum(p.price*t.quantity) totalsales
FROM transaction t,product p,customer c
where t.product_id = p.product_id
AND t.cust_id = c.cust_id
group by c.cust_name
ORDER BY totalsales desc;

-------------- TOP 3 SELLING CITIES -------------------------------------------

SELECT s.state_name,SUM(t.quantity*p.price) TOTALSALES,count(c.cust_id)
FROM product p,transaction t,customer c,state s
WHERE t.product_id = p.product_id
AND  t.cust_id = c.cust_id
AND c.state_id = s.state_id
GROUP BY s.state_name
ORDER BY totalsales desc
FETCH FIRST 3 ROWS ONLY;

------------------------ DAILY SALES -------------------------------------------

SELECT to_char(t.trans_TIME,'DD-MON-YYYY') DATES ,SUM(t.quantity*p.price) TOTALSALE
FROM transaction t,product p
where t.product_id = p.product_id
GROUP BY to_char(t.trans_TIME,'DD-MON-YYYY')
ORDER BY DATES;


------------------------ WEEKLY SALES -------------------------------------------

SELECT to_char(t.trans_TIME,'w') DATES ,SUM(t.quantity*p.price) TOTALSALE
FROM transaction t,product p
where t.product_id = p.product_id
GROUP BY to_char(t.trans_TIME,'w')
ORDER BY DATES;

------------------------ MONTHLY SALES -------------------------------------------

SELECT to_char(t.trans_TIME,'MM') DATES ,SUM(t.quantity*p.price) TOTALSALE
FROM transaction t,product p
where t.product_id = p.product_id
GROUP BY to_char(t.trans_TIME,'MM')
ORDER BY DATES;

------------------------ State wise Product wise Total Sales -------------------------------------------

SELECT p.product_id,t.quantity,s.state_name,p.product_name,p.price
FROM transaction t , customer c , state s , product p
WHERE t.product_id = p.product_id
AND t.cust_id = c.cust_id 
AND c.state_id = s.state_id;

SELECT s.state_name,a.name,sum(p.price*t.quantity) TotalSales
FROM transaction t , customer c , state s , product p,category a
WHERE t.product_id = p.product_id
AND t.cust_id = c.cust_id 
AND c.state_id = s.state_id
AND p.category_id = a.category_id
GROUP BY s.state_name,a.name
order by s.state_name;
