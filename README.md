# Project Title: An In-Depth Time Series Approach for Dynamic Sales Forecasting
## PROJECT OVERVIEW
- Sales forecasting plays a pivotal role in enabling businesses to make informed decisions, yet it remains challenging due to factors such as limited historical data, unpredictable external influences including seasonality, market volatility, and consumer behavior shifts, and the overall dynamic nature of sales trends.
- This project focuses on building a robust analytical pipeline to perform comprehensive time series forecasting using real-world sales data. It integrates both SQL-based preprocessing and advanced modeling techniques to develop accurate and interpretable sales predictions.
-The project is structured into two key notebooks:
  - Data_cleaning functions as the initial notebook, where SQL is used to load raw data, apply cleaning procedures, handle null values, correct data types, and consolidate all tables into a unified ```master_dataaa```.
  - sales_forecasting_timeseries serves as the subsequent notebook, where multiple time series forecasting methods are explored. This includes baseline models, classical statistical approaches, and machine learning–based techniques to evaluate and compare forecasting performance.
## DATA DESCRIPTION
- The dataset sourced from Kaggle contains a public collection of Brazilian e-commerce orders from Olist Store.
- It includes nearly 100,000 transactions recorded between 2016 and 2018, spanning multiple online marketplaces across Brazil.
- The project uses multiple raw datasets containing order details, product attributes, customer and seller information, geolocation data, and review scores.
- These tables collectively provide a holistic view of sales behavior across transactions, products, and geography.

### Data schema
The dataset is structured into multiple tables to enhance clarity and organization. Refer to the data schema below for a better understanding of how these datasets are interconnected.
<img width="946" height="625" alt="image" src="https://github.com/user-attachments/assets/0586b625-6338-446a-9ab6-9b9bae5a3fbf" />

## PROJECT PIPELINE

 1. Data Collection and Pre-Processing
 2. Time Series Data Pre-Processing
 3. Time Series Analysis Using SARIMA Model
 4. Time Series Modelling Using Facebook Prophet
 5. Challenges With Hourly Sampled Data
 6. Conclusion
