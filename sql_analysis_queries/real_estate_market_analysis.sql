-- ============================================================
-- ADVANCED HOUSE PRICE ANALYSIS USING MYSQL
-- Dataset: 50,000+ Records
-- Author: Nitin Sonawane
-- ============================================================


-- Q1: What is the revenue contribution (%) of each city to the total market?
WITH city_revenue AS (
    SELECT city,
           SUM(price_lakhs) AS total_revenue
    FROM house_data
    GROUP BY city
)
SELECT city,
       total_revenue,
       ROUND(100 * total_revenue / SUM(total_revenue) OVER (), 2) AS revenue_percentage,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM city_revenue;


-- Q2: What is the revenue contribution of each property type?
WITH type_revenue AS (
    SELECT property_type,
           SUM(price_lakhs) AS total_revenue
    FROM house_data
    GROUP BY property_type
)
SELECT property_type,
       total_revenue,
       ROUND(100 * total_revenue / SUM(total_revenue) OVER (), 2) AS revenue_share
FROM type_revenue
ORDER BY revenue_share DESC;


-- Q3: What are the top 3 most expensive houses in each city?
WITH ranked_properties AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY city ORDER BY price_lakhs DESC) AS rnk
    FROM house_data
)
SELECT *
FROM ranked_properties
WHERE rnk <= 3;


-- Q4: What is the premium housing share (>75 Lakhs) in each city?
WITH premium_stats AS (
    SELECT city,
           COUNT(*) AS total,
           SUM(CASE WHEN price_lakhs > 75 THEN 1 ELSE 0 END) AS premium
    FROM house_data
    GROUP BY city
)
SELECT city,
       ROUND(100 * premium / total, 2) AS premium_percentage,
       RANK() OVER (ORDER BY premium DESC) AS premium_rank
FROM premium_stats;


-- Q5: Which bedroom configuration generates the highest revenue and market share?
WITH bedroom_stats AS (
    SELECT bedrooms,
           COUNT(*) AS units,
           SUM(price_lakhs) AS revenue
    FROM house_data
    GROUP BY bedrooms
)
SELECT bedrooms,
       units,
       revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_share
FROM bedroom_stats
ORDER BY revenue DESC;


-- Q6: Which city shows highest price volatility (risk analysis)?
SELECT city,
       ROUND(AVG(price_lakhs),2) AS avg_price,
       ROUND(STDDEV(price_lakhs),2) AS std_dev,
       ROUND(STDDEV(price_lakhs) / AVG(price_lakhs) * 100,2) AS volatility_percentage
FROM house_data
GROUP BY city
ORDER BY volatility_percentage DESC;


-- Q7: Which city offers the best ROI based on average price per sqft?
SELECT city,
       ROUND(AVG(price_lakhs * 100000 / area_sqft),2) AS avg_price_per_sqft,
       ROUND(AVG(distance_from_city_center_km),2) AS avg_distance,
       RANK() OVER (ORDER BY AVG(price_lakhs * 100000 / area_sqft) DESC) AS roi_rank
FROM house_data
GROUP BY city;


-- Q8: Identify top 20 underpriced properties compared to city average
WITH city_avg AS (
    SELECT city,
           AVG(price_lakhs) AS avg_price
    FROM house_data
    GROUP BY city
)
SELECT h.city,
       h.property_type,
       h.price_lakhs,
       ROUND((c.avg_price - h.price_lakhs) / c.avg_price * 100,2) AS discount_percentage
FROM house_data h
JOIN city_avg c ON h.city = c.city
WHERE h.price_lakhs < c.avg_price
ORDER BY discount_percentage DESC
LIMIT 20;


-- Q9: What is the parking price premium (%) by property type?
SELECT property_type,
       ROUND(
           100 * (
               AVG(CASE WHEN parking = 1 THEN price_lakhs END)
               - AVG(CASE WHEN parking = 0 THEN price_lakhs END)
           )
           / AVG(CASE WHEN parking = 0 THEN price_lakhs END),
       2) AS parking_price_premium_percentage
FROM house_data
GROUP BY property_type;


-- Q10: What is the furnishing price premium percentage?
SELECT ROUND(
           100 * (
               AVG(CASE WHEN furnishing = 'Fully Furnished' THEN price_lakhs END)
               - AVG(CASE WHEN furnishing = 'Unfurnished' THEN price_lakhs END)
           )
           / AVG(CASE WHEN furnishing = 'Unfurnished' THEN price_lakhs END),
       2) AS furnishing_premium_percentage
FROM house_data;


-- Q11: How does property age impact pricing across cities?
WITH age_category AS (
    SELECT city,
           CASE 
               WHEN age_of_property_years <= 5 THEN 'New'
               WHEN age_of_property_years <= 15 THEN 'Moderate'
               ELSE 'Old'
           END AS age_group,
           price_lakhs
    FROM house_data
)
SELECT city,
       age_group,
       ROUND(AVG(price_lakhs),2) AS avg_price,
       RANK() OVER (PARTITION BY city ORDER BY AVG(price_lakhs) DESC) AS price_rank
FROM age_category
GROUP BY city, age_group;


-- Q12: What is the dominant property type in each city?
WITH property_counts AS (
    SELECT city,
           property_type,
           COUNT(*) AS total
    FROM house_data
    GROUP BY city, property_type
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY total DESC) AS rnk
    FROM property_counts
) t
WHERE rnk = 1;


-- Q13: What percentage of houses are large (>1500 sqft) in each city?
SELECT city,
       ROUND(
           100 * SUM(CASE WHEN area_sqft > 1500 THEN 1 ELSE 0 END)
           / COUNT(*), 2
       ) AS large_house_percentage
FROM house_data
GROUP BY city
ORDER BY large_house_percentage DESC;


-- Q14: Which city has the highest luxury house density (>1 Crore)?
SELECT city,
       COUNT(*) AS luxury_count,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS luxury_rank
FROM house_data
WHERE price_lakhs > 100
GROUP BY city;


-- Q15: Which cities offer the best opportunity for affordable housing (<40 Lakhs)?
SELECT city,
       COUNT(*) AS affordable_units,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS market_share
FROM house_data
WHERE price_lakhs < 40
GROUP BY city
ORDER BY affordable_units DESC;


-- Q16: Which city has the highest average price per bedroom (value efficiency analysis)?
SELECT city,
       ROUND(AVG(price_lakhs / bedrooms),2) AS avg_price_per_bedroom,
       RANK() OVER (ORDER BY AVG(price_lakhs / bedrooms) DESC) AS efficiency_rank
FROM house_data
WHERE bedrooms > 0
GROUP BY city;


-- Q17: What is the price growth gap between Near (0-5 km) and Far (>15 km) properties?
WITH location_avg AS (
    SELECT CASE
               WHEN distance_from_city_center_km <= 5 THEN 'Near'
               WHEN distance_from_city_center_km > 15 THEN 'Far'
           END AS location_zone,
           AVG(price_lakhs) AS avg_price
    FROM house_data
    WHERE distance_from_city_center_km <= 5
       OR distance_from_city_center_km > 15
    GROUP BY location_zone
)
SELECT *,
       ROUND(
           (MAX(avg_price) OVER () - MIN(avg_price) OVER ())
           / MIN(avg_price) OVER () * 100,
       2) AS price_gap_percentage
FROM location_avg;


-- Q18: Which property type dominates revenue within each city?
WITH city_type_revenue AS (
    SELECT city,
           property_type,
           SUM(price_lakhs) AS total_revenue
    FROM house_data
    GROUP BY city, property_type
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS revenue_rank
    FROM city_type_revenue
) t
WHERE revenue_rank = 1;


-- Q19: Which cities have above-average price per sqft compared to overall market?
WITH city_psf AS (
    SELECT city,
           AVG(price_lakhs * 100000 / area_sqft) AS avg_psf
    FROM house_data
    GROUP BY city
),
overall_avg AS (
    SELECT AVG(price_lakhs * 100000 / area_sqft) AS overall_psf
    FROM house_data
)
SELECT c.city,
       ROUND(c.avg_psf,2) AS city_price_per_sqft,
       ROUND(o.overall_psf,2) AS overall_price_per_sqft,
       ROUND((c.avg_psf - o.overall_psf) / o.overall_psf * 100,2) AS premium_percentage
FROM city_psf c
CROSS JOIN overall_avg o
WHERE c.avg_psf > o.overall_psf
ORDER BY premium_percentage DESC;


-- Q20: Identify cities with balanced market (low volatility + high revenue)
WITH city_stats AS (
    SELECT city,
           SUM(price_lakhs) AS total_revenue,
           STDDEV(price_lakhs) / AVG(price_lakhs) * 100 AS volatility_percentage
    FROM house_data
    GROUP BY city
)
SELECT city,
       ROUND(total_revenue,2) AS total_revenue,
       ROUND(volatility_percentage,2) AS volatility_percentage,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
       RANK() OVER (ORDER BY volatility_percentage ASC) AS stability_rank
FROM city_stats;
