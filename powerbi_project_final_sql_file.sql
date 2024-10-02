use powerbi;
select * from customer_purchase
set SQL_SAFE_UPDATES = 0

# CHANGE DATA TYPE OF PURCHASEDATE COLUMN ##

-- 2. Add new date column
ALTER TABLE customer_purchase
ADD COLUMN PurchaseDateNew DATE;

-- 3. Update new date column with converted values
UPDATE customer_purchase
SET PurchaseDateNew = STR_TO_DATE(PurchaseDate, '%d/%m/%Y');

-- 4. Verify the new column has the correct data
SELECT PurchaseDate, PurchaseDateNew 
FROM customer_purchase
limit 10;

-- 5. Drop the old column and rename the new column
ALTER TABLE customer_purchase
DROP COLUMN PurchaseDate;

ALTER TABLE customer_purchase
CHANGE COLUMN PurchaseDateNew PurchaseDate DATE;

select customerid from customer_purchase;
select * from customer_purchase


## NORMALIZATION OF TABLE 
#CREATE CUSTOMERS TABLE USING CUSTOMER_PURCHASE TABLE #

create  table customers1 as with cte as (
select customername,country,PurchaseDate from customer_purchase )
select row_number() over(order by PurchaseDate )+4000 as customerID,customername,country from cte;

# create customers table #
create table purchase as with cte1 as 
(select row_number() over(order by PurchaseDate asc)+5000 as PurchaseID,PurchaseQuantity,PurchasePrice,PurchaseDate,
cs.customerid,p.ProductID,TransactionID
from customer_purchase c join products p on c.productname = p.productname
join customers1 cs on c.customername = cs.customername and c.Country = cs.Country)
select PurchaseID,PurchaseQuantity,PurchasePrice,PurchaseDate,customerid,productid,TransactionID from cte1;

# create products table #
create table products as (with cte as (select distinct productname,productcategory,dense_rank() over(partition by productcategory
order by productname)+200 as pd from customer_purchase)
select row_number() over(order by productname)+200 as productid,productname,productcategory from cte);

# check null values for all tables #

# check null value for transactionID #
select * from customer_purchase
where transactionid is null;

# Check null value for customerID #
select * from customer_purchase
where customerid is null;

# check null values for productcategory #
select * from customer_purchase
where productcategory is null;

# check null for productname #
select * from customer_purchase
where productname is null;

# check null purchaseQuantity #
select * from customer_purchase
where purchaseQuantity is null;

# check null for PurchaseDate #
select * from customer_purchase
where PurchaseDate is null;

# check null for country #
select * from customer_purchase
where Country is null;


# BUILD RELATIONSHIP BETWEEN TABLES #
alter table customers1
add primary key (customerID);

alter table products 
add primary key (productID)

alter table purchase
add constraint fk foreign key (customerID)
references customers1(customerID)

alter table purchase
add constraint fk1 foreign key (productId)
references products(productID)





