#========================================Ad-Hoq-Request================================

USE `retail_events_db`;
SELECT * FROM fact_events;

#=========================================Q1==========================================
select distinct dp.product_name 
FROM dim_products AS dp
JOIN  fact_events AS fe ON dp.product_code=fe.product_code
WHERE fe.base_price>500 AND fe.promo_type="BOGOF"
order by dp.product_name;
#========================================Q2==========================================
SELECT city,Count(*) as store_count FROM retail_events_db.dim_stores
group by city
order by store_count desc;
#=========================================Q3=========================================
 SELECT 
 dim_campaigns.campaign_name,
 SUM(base_price*`quantity_sold(before_promo)`)/10000000 as `total_revenue(before_promo)`, 
 SUM(
	case
		when promo_type="50% OFF" then base_price*(1-0.50)* `quantity_sold(after_promo)`
		when promo_type="25% OFF" then base_price*(1-0.25)* `quantity_sold(after_promo)`
		when promo_type="33% OFF" then base_price*(1-0.33)* `quantity_sold(after_promo)`
		when promo_type="BOGOF" then base_price*(1-0.5)*2* `quantity_sold(after_promo)`
		when promo_type="500 Cashback" then (base_price-500)* `quantity_sold(after_promo)`
	end )/10000000 AS `total_revenue(after_promotion)` 
 FROM dim_campaigns join fact_events 
 on dim_campaigns.campaign_id = fact_events.campaign_id
 group by dim_campaigns.campaign_name;

#========================================Q4==========================================

select * , rank() over(order by `ISU%` desc) as rank_order 
from (SELECT dp.category,
(sum(case
		when promo_type="BOGOF" then 2* `quantity_sold(after_promo)`
		else `quantity_sold(after_promo)`
	 end)- sum(`quantity_sold(before_promo)`))/sum(`quantity_sold(before_promo)`)*100 as `ISU%`
FROM retail_events_db.dim_products as dp
join fact_events as fe
on dp.product_code=fe.product_code
where fe.campaign_id="camp_diw_01"
group by dp.category) AS report;

select * , rank() over(order by `ISU%` desc) as rank_order 
from (SELECT dp.category,
(SUM(fe.`quantity_sold(after_promo)`)-SUM(fe.`quantity_sold(before_promo)`))/SUM(fe.`quantity_sold(before_promo)`)*100 AS `ISU%`
FROM retail_events_db.dim_products as dp
join fact_events as fe
on dp.product_code=fe.product_code
where fe.campaign_id="camp_diw_01"
group by dp.category) AS report;
 #=================================================Q5================================================

SELECT 
 dp.product_name,dp.category,
 (sum(case
		when promo_type="50% OFF" then base_price*(1-0.50)* `quantity_sold(after_promo)`
		when promo_type="25% OFF" then base_price*(1-0.25)* `quantity_sold(after_promo)`
		when promo_type="33% OFF" then base_price*(1-0.33)* `quantity_sold(after_promo)`
		when promo_type="BOGOF" then base_price*(1-0.5)*2* `quantity_sold(after_promo)`
		when promo_type="500 Cashback" then (base_price-500)* `quantity_sold(after_promo)`
	end)- sum(base_price*`quantity_sold(before_promo)`))/sum(base_price*`quantity_sold(before_promo)`)*100 as `IR%`
from dim_products as dp
join fact_events as fe on dp.product_code=fe.product_code
group by fe.product_code
order by `IR%` desc
limit 5; 