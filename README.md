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
## 1. DATA COLLECTION AND DATA CLEANING

- I began by loading all the datasets individually and performed the following tasks:
  - Reviewed the data dictionary to understand the numerical and categorical columns.
  - Corrected inconsistent or improperly formatted data types.
  - Cleaned the data by removing redundant columns, imputing missing values, and eliminating duplicate rows and columns.
 
  ### 1. Customers Dataset 

- This dataset contains customer geolocation-related information along with unique customer identifiers. A total of 99,441 customer IDs are recorded, which act as transaction-based identifiers generated whenever a purchase is made.
- Out of these, 96,096 are unique customers,indicating that approximately 96.6% of customers made a single purchase, while only 3.4% made repeat purchases. This aligns with the fact that Olist was still in its early growth phase during 2016–2018.
- The dataset consists of four columns with object datatype and one numeric column.  
- There are no duplicate rows or columns, and no missing values present.
- The zipcode column was removed, as geolocation data was not used in the analysis and was therefore unnecessary for further processing.

  ### 2. Sellers Dataset 

- The dataset contains 3,095 unique seller IDs, which serve as the primary key for this table.
- It consists of three columns with object datatype and one numeric column.
- There are no duplicate rows or columns, ensuring data integrity.
- The dataset contains no missing values, making it clean and ready for use without additional preprocessing.

  ### 3. Orders Dataset

- The Orders dataset contains detailed information about each order, including the customer ID, order status, purchase timestamp, and both actual and estimated delivery dates.
- It includes 99,441 unique order IDs, which act as the primary key for this table.
- The dataset consists of eight columns stored as object datatype, including five date-related columns that need to be converted into proper datetime format during preprocessing.
  
```

-- Convert order_purchase_timestamp to datetime format (into new column: order_date)
UPDATE olist_orders_dataset
SET order_date = STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
WHERE order_purchase_timestamp IS NOT NULL AND order_purchase_timestamp != '';

  -- Convert order_approved_at to proper datetime format
UPDATE olist_orders_dataset
SET order_approved_at = STR_TO_DATE(order_approved_at, '%Y-%m-%d %H:%i:%s')
WHERE order_approved_at IS NOT NULL AND order_approved_at != '';

-- Convert delivered carrier date
UPDATE olist_orders_dataset
SET order_delivered_carrier_date = STR_TO_DATE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s')
WHERE order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date != '';

-- Convert delivered customer date
UPDATE olist_orders_dataset
SET order_delivered_customer_date = STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')
WHERE order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date != '';

-- Convert estimated delivery date
UPDATE olist_orders_dataset
SET order_estimated_delivery_date = STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')
WHERE order_estimated_delivery_date IS NOT NULL AND order_estimated_delivery_date != '';
```

- For the final merged master dataset, only the following fields were retained:  
  order_id, order_purchase_timestamp, and order_estimated_delivery_date  all of which contain no missing values.
  
### 4. Order Items Dataset 

- The Order Items dataset provides detailed information about each item within an order, including the quantity of items purchased renamed from **order_item_id** to **qty**, the shipping limit date, and the freight value.

```
-- Rename order_item_id column to qty
ALTER TABLE olist_order_items_dataset
CHANGE COLUMN order_item_id qty INT;
```

- The dataset includes four object-type columns and three numeric columns.
- There are no duplicate rows or columns, and the dataset contains no missing values.


### 5. Products Dataset 

- The Products dataset contains detailed attributes for each product, including product category, name length, description length, number of photos, weight, and physical dimensions.
- It includes 32,951 unique product IDs, which serve as the primary key for this table.
- The dataset consists of several numeric columns (weight, height, length, width) and object-type columns (such as product category name).
- Some columns contain missing values, particularly in product dimensions and weights. Since only 2% of the data was missing, these columns were removed instead of imputed to maintain dataset consistency.
- There are no duplicate rows, although certain product attributes may vary due to differences in seller inputs.


### Merging All Tables

- After completing the cleaning steps for each dataset, all tables were merged to create a comprehensive master dataset for analysis. The merging process was performed in SQL by joining tables on their corresponding primary and foreign keys, such as customer_id, order_id, product_id, and seller_id.

- During the merge, only the essential fields were retained—such as order details, product attributes, seller information, freight value, quantity (qty), and cleaned date fields—to keep the dataset optimized for time series forecasting. Redundant or unused columns were removed to maintain efficiency and clarity.

- Additionally, based on insights from the Kaggle documentation, the **total_amount** was calculated using:
**total_amount = qty * price**,  
where *price* represents the unit price of an item and *qty* (renamed from order_item_id) indicates the number of units purchased.
- Creating column ```total_amount```= ```(oi.qty * oi.price) AS total_amount```

- The final merged dataset was validated for consistency, ensuring there were no duplicates, missing values, or conflicting entries. This consolidated master dataset serves as the foundation for all further preprocessing, exploratory analysis, and model development.

  ### Scraping Holiday Data

- To improve the accuracy of sales forecasting, holiday information was collected since holidays can significantly influence purchasing behavior. A simple web scraping approach was used to extract Brazilian national holidays from the specified [website](https://www.officeholidays.com/countries/brazil/).

- By appending the base URL with the years **2017** and **2018**, we retrieved the corresponding pages containing holiday data for those years and incorporated them into the time series modeling process.

```
  # For web scraping (the requests package allows you to send HTTP requests using Python)
import requests
from bs4 import BeautifulSoup

# For performing regex operations
import re

# For adding delays so that we don't spam requests
import time
#define empty dictionary to save content
content={}

#scaping holiday information for pages 2017 and 2018
for i in [2017, 2018]:
    url = 'https://www.officeholidays.com/countries/brazil/'
    url = url+str(i)
    response = requests.get(url)
    soup = BeautifulSoup(response.content)
    content[i]=soup.find_all('time')

#extracting Holiday information from the scarpped data
#empty list
holidays=[]
for key in content:
    dict_size=len(content[key])
    dict_val=content[key]
    for j in range(0,dict_size):
        holidays.append(dict_val[j].attrs['datetime'])

#creating a dataframe for the holiday information
holidays_df=pd.DataFrame(index=[holidays], data=np.ones(len(holidays)), columns=['is_holiday'])
holidays_df.head()
```

- This dataframe has only one column 'is_holiday' which is one meaning it is an holiday. The index are the dates of the holiday.
- These dates are for year 2017 and 2018. The index is not continuous, these are just the holiday dates. We have saved the data like this so that we can use it for time series.

