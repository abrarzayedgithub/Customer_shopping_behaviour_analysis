select * from imported_customer_data
---
select gender,sum(Purchase_Amount) as revenue from imported_customer_data group by gender
---
select Customer_Id, Purchase_Amount from imported_customer_data 
where Discount_Applied= 'Yes' and  
Purchase_Amount  >= (select AVG(Purchase_Amount) from imported_customer_data)
---
select top 5
Item_Purchased,Round(AVG(cast(Review_Rating as numeric)),2) as average_product_rating from imported_customer_data
group by Item_Purchased
order by average_product_rating desc

---Compare the average purchase amounts between standard and express shipping
select Shipping_Type, Round(Avg(Purchase_Amount),2) as amount from imported_customer_data
where Shipping_Type in ('Standard','Express')
group by Shipping_TYpe

---do subscribed customer spend more? compare average spend and total revenue between subscriber and non-subscriber

select Subscription_Status, count(Customer_Id) total_customer, round(avg(Purchase_Amount),2) as avg_spend,round(sum(Purchase_Amount),2)
as total_revenue from imported_customer_data
group by Subscription_Status
order by total_revenue,avg_spend desc;

--- which 5 products have the highest percentage of purchases with discount applied
select top 5
Item_purchased, round(cast(sum(case when Discount_Applied = 'Yes' then 1 else 0 end) as float)/count(*) * 100,2) 
as discount_rate
from imported_customer_data
group by Item_purchased
order by discount_rate desc

--- segment customer into new ,returning and loyal based on their total number of previous purchases and show the 
--- count of each segment
with customer_type as(
select Customer_ID,Frequency_of_purchases,
case
when Frequency_of_purchases  = 'Weekly' THEN 'loyal'
when Frequency_of_purchases  = 'Fortnightly' THEN 'returning'
when Frequency_of_purchases  = 'Monthly' Then 'returning' 
else 'new'
END as customer_segment
from imported_customer_data
)
select customer_segment, count(*) as number_of_customers
from customer_type
group by customer_segment

--- what are the top 3 most purchased product within each category
with item_counts as(
select Category,Item_Purchased,
count(*) purchase_count,
rank() over(
partition by category
order by count(*) desc
) as rnk
from imported_customer_data
group by Category,Item_Purchased
)
select Category,Item_Purchased,purchase_count from item_counts
where rnk <= 3
order by category,rnk





