-- CREATE DATABASE house_project;
-- USE house_project;
-- DROP TABLE IF EXISTS house_data;
CREATE TABLE house_data (
    House_ID INT,
    City VARCHAR(100),
    Property_Type VARCHAR(50),
    Bedrooms INT,
    Bathrooms INT,
    Area_sqft INT,
    Age_of_Property_Years INT,
    Distance_from_City_Center_km DECIMAL(5,2),
    Parking INT,
    Furnishing VARCHAR(50),
    Price_Lakhs DECIMAL(10,2)
);
LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/House_Price_Prediction_Dataset_50000.csv'
INTO TABLE house_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM house_data;
SELECT * FROM house_data LIMIT 5;
