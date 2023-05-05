--10,12
--DATA PREPARATION ---
--Q1--BEGIN 
(select count(*) from Transactions) union all
(select count(*) from Customer) union all
(select count(*) from prod_cat_info )
--Q1--END 

--Q2--BEGIN 
select count(transaction_id)[no_returns] from Transactions where qty < 0
--Q2--END

--Q3--BEGIN --
/* while importing the data , checked if date formate is correct and changed to date */
--Q3--END

--Q4--BEGIN

select min(tran_date)[start],max(tran_date)[end],datediff(D,min(tran_date),max(tran_date))[diff_days],
datediff(M,min(tran_date),max(tran_date))[diff_month],
datediff(YEAR,min(tran_date),max(tran_date))[diff_year]
from Transactions

--Q4--END

--Q5--BEGIN
select prod_cat from prod_cat_info where prod_subcat ='DIY'
--Q5--END



--DATA ANALYSIS---


--Q1--BEGIN 
select top 1 store_type, count(store_type)[channel_used] from transactions group by store_type order by count(store_type) desc

--Q1--END



--Q2--BEGIN 

select customer='Male', count(gender)as No_of_Customer from customer where gender = 'M' union all(
select customer='Female', count(gender)as No_of_Customer from customer where gender = 'F')

select distinct(gender),count(gender) over (partition by (gender) order by gender)    from Customer 

--Q2--END


--Q3--BEGIN 

select top 1 city_code , count(customer_Id)[no_of_customer] from Customer  group by city_code order by [no_of_customer] desc

--Q3--END


 --Q4--BEGIN 

 select count(prod_subcat)as book_subcategory from prod_cat_info where prod_cat ='Books'

 
 --Q4--END


 --Q5--BEGIN 
 select max(qty)[max_quantity] from Transactions 
 --Q5--END


 --Q6--BEGIN 

 select  sum(t.total_amt-t.Tax)as[revenue] from Transactions[t] inner join prod_cat_info[p]
 on t.prod_cat_code = p.prod_cat_code  and t.prod_subcat_code = p.prod_sub_cat_code
 
  where p.prod_cat_code in(3,5) and t.qty >0 



  --Q6--END

 --Q7--BEGIN (qty >=0 is crt validation)
 

 select count([count])[no_customer] from  (select cust_id,count(cust_id)[count] from Transactions where qty >=0 
 group by cust_id having count(cust_id) > 10 ) s
  
 --Q7--END
 
 --Q8--BEGIN 
 select  sum(t.total_amt)as[revenue] from Transactions[t] 
 inner join prod_cat_info[p] on t.prod_cat_code = p.prod_cat_code and 
 p.prod_sub_cat_code =t.prod_subcat_code
  
 where p.prod_cat_code in(3,1) and t.total_amt > 0 and t.Store_type = 'Flagship store'



  --Q8--END

  --Q9--BEGIN 

 
 
  select p.prod_subcat,sum(t.qty*t.rate)[revenue_male] from Transactions[t] 
 inner join prod_cat_info[p]  on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code= p.prod_sub_cat_code
 inner join Customer[c]       on c.customer_Id = t.cust_id
  where c.Gender = 'M' and prod_cat ='electronics'and t.qty >0 and t.rate > 0
  group by prod_subcat order by prod_subcat 


  

   --Q9--END


   --Q10--BEGIN individual sales/total sales * 100

    ----1st answer------- by total amt-------

-- select sum(total_amt)[total_qty] into sales  from Transactions where total_amt > 0
	select * from sales
-- select sum(total_amt)[total_qty] into returns  from Transactions where total_amt < 0
 select * from returns

 ----% of sales---
   select top 5 prod_subcat_code,sum(total_amt)[subcat_sales],(sum(total_amt)/t.total_qty)*100[%tage]
   from Transactions ,sales[t] where total_amt > 0
  group by  prod_subcat_code,t.total_qty  order by sum(total_amt) desc
-----% of returns ----
   select top 5  prod_subcat_code,abs(sum(total_amt))[subcat_sales],(abs(sum(total_amt))/abs(t.total_qty))*100[%tage]
   from Transactions ,returns[t] where total_amt < 0
  group by  prod_subcat_code,t.total_qty  
  order by abs(sum(total_amt)) desc


  Select top 5 prod_subcat_code , (sum(total_amt)*100 /(select sum(total_amt) from Transactions)) [% 0f sales],
((select sum(total_amt) from Transactions where total_amt<0)*100/(select sum(total_amt) from Transactions)) [% of return] from Transactions
group by prod_subcat_code
order by [% 0f sales] desc


  ----2nd answer-----------by quantity------------

  select top 5 prod_subcat_code, (sum(qty)*100)/sum(sum(qty)) over()   [%sales]  from Transactions where qty > 0  group by prod_subcat_code order by [%sales] desc
   
    select top 5   prod_subcat_code, (sum(qty)*100)/sum(sum(qty)) over()   [%sales]  from Transactions where qty < 0  group by prod_subcat_code order by [%sales] desc

     --Q10--END
  

 --Q11--BEGIN
  
  --------------total revenve = qty sold * unit price , net revenue = total revenue - expenses-----------------
 
  select sum([net_revenue]) from (select c.customer_Id,c.DOB ,datediff(Year,c.dob,max(t.tran_date))as age,sum(t.qty*t.rate)[total revenue] ,
  sum(t.qty*t.rate)-sum(t.tax)[net_revenue]
  from  Customer as c inner join Transactions as t on c.customer_Id = t.cust_id
  where t.Qty > 0 and t.rate > 0
  group by c.customer_Id,c.DOB, tran_date
  having datediff(Year,c.dob,max(t.tran_date)) between 25 and 35 and tran_date >= dateadd(D,-30,(select max(tran_date) from Transactions)))
  a

 
 

  --Q11--END
  --Q12--BEGIN

  select top 1 prod_cat_code,sum(total_amt)[qty_return] from Transactions where total_amt < 0 and  tran_date > dateadd(M,-3,(select max(tran_date) from Transactions))
   
  group by prod_cat_code 
  order by [qty_return]

  --Q12--END
  
  --Q13--BEGIN
  select top 1 Store_type,sum(total_amt)[max_sales],sum(qty)[max_quantity] from Transactions group by Store_type 
  order by  sum(total_amt) desc,
  sum(qty) desc
  --Q13--END

  --Q14--BEGIN avg revenue=total revenue/ sum(qty ) , total revenue = units sold * cost /unit(returns should be removed)

  --------overall average ----
    select * from Transactions 
	select * from  prod_cat_info
  select avg(total_amt) from Transactions

  ----------cate wise avg revenue
  select prod_cat_code,
  sum(total_amt) [total revenue],
  (sum(total_amt))/sum(qty) [avg_revenue],
  (select avg(total_amt) from Transactions) [overall_avg]

  from Transactions 
  group by prod_cat_code 
  having (sum(total_amt))/sum(qty) 
  > (select avg(total_amt) from Transactions)

  
  --Q14--END
  
--Q15--BEGIN
 select top 5 prod_cat_code ,sum(qty) from Transactions group by prod_cat_code order by sum(qty) desc
 ----(5,3,6,2,1)

 select prod_cat_code, prod_subcat_code, sum(qty*rate)[Total_Revenue],(sum(qty*rate))/sum(qty)[average_Revenue] from Transactions
 where prod_cat_code in ( 5,3,6,2,1)
 and qty >0 and rate > 0
 group by prod_cat_code,prod_subcat_code  order by prod_cat_code


 --Q15--END

 

 