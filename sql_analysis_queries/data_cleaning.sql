use house_project;

-- checking null's 
SELECT *
FROM house_data
WHERE 
House_ID IS NULL OR
City IS NULL OR
Property_Type IS NULL OR
Bedrooms IS NULL OR
Bathrooms IS NULL OR
Area_sqft IS NULL OR
Age_of_Property_Years IS NULL OR
Distance_from_City_Center_km IS NULL OR
Parking IS NULL OR
Furnishing IS NULL OR
Price_Lakhs IS NULL;

-- Check duplicates based on House_ID
SELECT House_ID, COUNT(*)
FROM house_data
GROUP BY House_ID
HAVING COUNT(*) > 1;


-- Trim Spaces from Text Columns
UPDATE house_data
SET 
City = TRIM(City),
Property_Type = TRIM(Property_Type),
Furnishing = TRIM(Furnishing);


-- Remove Rows with Invalid Numeric Values
DELETE FROM house_prices
WHERE 
Bedrooms <= 0 OR
Bathrooms <= 0 OR
Area_sqft <= 0 OR
Price_Lakhs <= 0 OR
Distance_from_City_Center_km < 0 OR
Age_of_Property_Years < 0;


-- Remove Rows with Invalid Numeric Values
-- Remove negative or zero values

DELETE FROM house_data
WHERE 
Bedrooms <= 0 OR
Bathrooms <= 0 OR
Area_sqft <= 0 OR
Price_Lakhs <= 0 OR
Distance_from_City_Center_km < 0 OR
Age_of_Property_Years < 0;






