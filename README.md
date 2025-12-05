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

 ## 2. TIME SERIES DATA PRE-PROCESSING
 We have a total of 1000 rows of orders with 21 features, I am specifying all the high level details about the data which we extracted during data cleaning and wrangling. Each row in the table specifies a order with the product category bought, quantity of item purchased, unit price of the product and has details about purchase time, delivery details, customer and seller information.
 - order_id : Specifies the unique order. We have 95832 unique orders. Of 110K rows an order_id can reappear in the- dataframe but it will have another product category and number of items bought in that category.
- customer_id: Specifies the customer id for the order. We have a customer ids associated with each order. There are a total of 95832 unique customer ids.
- order_purchase_timestamp : The time stamp for the order. It includes date and time.
- order_estimated_delivery_date : Estimated delivery date at the time of purchase.
- product_id : This specify the actual product in a product category. We have 32072 unique products within 74 overall product categories.
- seller_id : We have 2965 unique sellers.
- freight_value : The freight charges based on product weight and dimension. This value is for one item. If there are three items the total freight will be equal to three times the freight_value.
- product_name_lenght : Number of characters extracted from the product name.
- product_description_lenght : Number of characters extracted from the product description.
- product_photos_qty : Number of product published photos.
- product_weight_g : Product weight measured in grams.
- product_length_cm : Product length measured in centimeters.
- product_height_cm : Product height measured in centimeters.
- product_width_cm : Product width measured in centimeters.
- seller_city : It is the city where seller is located.
- seller_state : It is the state where seller is located.
- customer_unique_id : There are 92755 unique customers which make up 96.79 % of the total customers in database. Only 3.21% of the customers have made repeat purchase. It may be because the data we have is the initial data when Olist had just started its business and therefore we have all the new customers in the database.
- customer_city : It is the city where customer is located.
- customer_state : It is the state where customer is located.
- qty : Number of items bought in a product category.
- price : Unit price for each product.
Target Variable : total_amount : We have calculated this value after multiplying qty and price. This is the actual sales amount important for the business. We will be predicting sales amount to help business prepare for the the future.
- ```Target Variable``` : total_amount : We have calculated this value after multiplying qty and price. This is the actual sales amount important for the business. We will be predicting sales amount to help business prepare for the the future.

### Processing Data for Time Series
- ```order_purchase_timestamp``` has incorrect format column. Let's start converting this column to date-time format and  try to extract some features from dates for analysis.
- let's extract year, date, month , weekday and day information from the dates.

```
#converting date columns which are in object format to datetime format
df['purchase_year']=pd.to_datetime(df['order_purchase_timestamp']).dt.year
df['purchase_month']=pd.to_datetime(df['order_purchase_timestamp']).dt.month
df['purchase_MMYYYY']=pd.to_datetime(df['order_purchase_timestamp']).dt.strftime('%m-%Y')
df['purchase_week']=pd.to_datetime(df['order_purchase_timestamp']).dt.isocalendar().week
df['purchase_dayofweek']=pd.to_datetime(df['order_purchase_timestamp']).dt.weekday
df['purchase_dayofmonth']=pd.to_datetime(df['order_purchase_timestamp']).dt.day
```

Aggregate the total_amount by dates so that we can get a time series, meaning a dataframe with the total_amount column arranged in order as per dates. Let's set the dates as index.

### Exploratory Data Analysis
#### 1. Heatmap:
heat map to see which numerical features are highly correlated with the total_amount. This is just a high level overview to see which features can impact sales and also the correlation among the features.
<Figure size 1800x1200 with 2 Axes><img width="1491" height="1140" alt="image" src="https://github.com/user-attachments/assets/7b64c5e7-6874-4917-8e6d-faf24d4646ae" />

#### Observations:
- Price shows the strongest positive correlation with total sales amount.
- Freight value has a moderate positive relationship with total amount, indicating higher shipping cost for higher-value items.
- Product dimensions (length, height, width) are moderately correlated with freight value.
- Quantity shows only a weak correlation with total amount, suggesting most orders contain single units.
- Date-related features (year, month, week, day) have very weak correlations, indicating no strong linear time-based influence.

#### 2. Histogram:
- histogram to see the distribution of total_amount.
  <img width="700" height="500" alt="image" src="https://github.com/user-attachments/assets/1d1f015d-37a9-42a1-9488-fe0a897784a7" />
  
  **Observation:**
- The daily revenue distribution is highly right-skewed, with most days generating low to moderate sales and only a few days showing very high revenue spikes. 
- This indicates high variability and the presence of outlier sales days.

#### 3. Decomposing time series
- We will be decomposing the time series using additive decomposition so that we can observe the underlying trend, seasonality and residuals.
- Additive Decomposition : Trend + Seasonality + Residual

```
# decompose the time series
decomposition = tsa.seasonal_decompose(daily_data, model='additive')
# saving copy to new datafrme
daily_df=daily_data.copy()
# add the decomposition data
daily_df['Trend'] = decomposition.trend
daily_df['Seasonal'] = decomposition.seasonal
daily_df['Residual'] = decomposition.resid
```

```
#plotting the actual and decomposed componenets of time series
cols = ["total_amount","Trend", "Seasonal", "Residual"]

fig = make_subplots(rows=4, cols=1, subplot_titles=cols)

for i, col in enumerate(cols):
    fig.add_trace(
        go.Scatter(x=daily_df.index, y=daily_df[col]),
        row=i+1,
        col=1
    )

fig.update_layout(height=1200, width=1200, showlegend=False)
# fig.show()
fig.show("svg")
```

<img width="1200" height="1200" alt="image" src="https://github.com/user-attachments/assets/ad8aec70-f6bb-451a-a334-d7602b7884a6" />

#### Observation:
- Trend component shows a steady upward movement, indicating consistent growth in daily revenue over time.

- Seasonal component is strong and repetitive, suggesting clear recurring daily or weekly patterns in sales.

- Residual component captures irregular spikes, reflecting unexpected high-revenue days or one-off events.

- The original series aligns well with the trend + seasonality, confirming that the data has structured patterns.

- High residual variability in 2018 suggests increasing unpredictability alongside business growth.

#### Preparing for Modeling
1. Train and test split
2. Defining functions for plotting predictions and forecast
3. Defining functions for evaluation
MAPE (Mean Absolute Percentage Error): It is a simple average of absolute percentage errors. It is calculated by

<img width="291" height="92" alt="image" src="https://github.com/user-attachments/assets/b432228c-63bd-451e-aea9-d3ab1ce4c5bf" />

RMSE (Root Mean Sqaured Error) : It is the square root of the average of the squared difference between the original and predicted values in the data set:

<img width="312" height="125" alt="image" src="https://github.com/user-attachments/assets/b0d46809-ba6c-414a-853e-817c5ff8734d" />

## 3. TIME SERIES ANALYSIS USING MODELLING
 We will start with SARIMA model to account for the seasonality in our model. SARIMA is Seasonal Autoregressive Integrated Moving Average, which explicitly supports univariate time series data with a seasonal component. Before jumping on to modelling, we need to get a basic understanding of what orders for Auto gregressive and Moving average to choose. We will plot the ACF and PACF plots to find it out.

ACF : Auto correlation function, describes correlation between original and lagged series. PACF : Partial correlation function is same as ACF but it removes all intermediary effects of shorter lags, leaving only the direct effect visible.

### 3.1 Plotting ACF and PACF plot

```
def plot_acf_pacf(df, acf_lags: int, pacf_lags: int) -> None:
    """
    This function plots the Autocorrelation and Partial Autocorrelation lags.
    ---
    Args:
        df (pd.DataFrame): Dataframe contains the order count and dates.
        acf_lags (int): Number of ACF lags
        pacf_lags (int): Number of PACF lags
    Returns: None
    """
    
    # Figure
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16,9), facecolor='w')
    
    # ACF & PACF
    plot_acf(df, ax=ax1, lags=acf_lags)
    plot_pacf(df, ax=ax2, lags=pacf_lags, method='ywm')

    # Labels
    ax1.set_title(f"Autocorrelation {df.name}", fontsize=15, pad=10)
    ax1.set_ylabel("Sales amount", fontsize=12)
    ax1.set_xlabel("Lags (Days)", fontsize=12)

    ax2.set_title(f"Partial Autocorrelation {df.name}", fontsize=15, pad=10)
    ax2.set_ylabel("Sales amount", fontsize=12)
    ax2.set_xlabel("Lags (Days)", fontsize=12)
    
    # Legend & Grid
    ax1.grid(linestyle=":", color='grey')
    ax2.grid(linestyle=":", color='grey')

    plt.show()
    # plotting the ACF and PACF plot for original series
    plot_acf_pacf(daily_df['total_amount'], acf_lags=56, pacf_lags= 56)
```
<Figure size 1600x900 with 2 Axes><img width="1332" height="789" alt="image" src="https://github.com/user-attachments/assets/7b040c3b-0057-40d1-8825-bfd8aa558973" />
  
#### Observation:
The ACF of the original series shows strong autocorrelation with a slow decay, confirming that the data is non-stationary. The PACF spike at lag 1 further indicates short-term dependence, reinforcing the need for differencing before modeling.

```
#double differencing the column total_amount
daily_df['double_difference'] = daily_df['day_difference'].diff(7)
#plotting the ACF and PACF plot for double differenced series
plot_acf_pacf(daily_df['double_difference'].dropna(), acf_lags=56, pacf_lags= 56)
```

<Figure size 1600x900 with 2 Axes><img width="1332" height="789" alt="image" src="https://github.com/user-attachments/assets/4def0cd2-dce6-4c2b-84ac-e09b4a5b27a6" />

#### Observation
The ACF and PACF plots of the double-differenced series show no strong autocorrelation, with most spikes falling within confidence limits. This indicates that the series is sufficiently stationary and behaves close to white noise, confirming that no further differencing is required.

### 3.2 Applying SARIMA model
The SARIMA model is specified

<img width="224" height="59" alt="image" src="https://github.com/user-attachments/assets/561d6d41-b69d-4664-8b29-df4a68140431" />

Where:

- Trend Elements are:
  - p: Autoregressive order
  - d: Difference order
  - q: Moving average order
- Seasonal Elements are:
  - P: Seasonal autoregressive order.
  - D: Seasonal difference order. D=1 would calculate a first order seasonal difference
  - Q: Seasonal moving average order. Q=1 would use a first order errors in the model
  - s: Single seasonal period
- Theoretical estimates:
  - s: In our PACF plot there is peak that reappears every 7 days. Thus, we can set seasonal period to s = 7. This also backed by our seasonal component after additive decomposition.
  - p: We observed that there is some tappering in ACF plot and we found the significant lags of 1,2,3 from PACF plot. We can start with p=1 and see how it works.
  - d: We observed that our series has some trend, so we can remove it by differencing, so d = 1.
  - q: Based on our ACF correlations we can set q = 1 since its the most significant lag.
  - P: P = 0 as we are using ACF plot to find seasonl significant lag.
  - D: Since we are dealing with seasonality and we need to differnce the series, D = 1
  - Q: The seasonal moving average will be set to Q = 1 as we found only one significant seasonal lag in ACF plot. 
- Here we go:


  <img width="212" height="44" alt="image" src="https://github.com/user-attachments/assets/c92592c2-501d-4407-aa8f-a8e83c38db29" />


  #### Baseline Sarima Model

```
#Set Hyper-parameters
p, d, q = 1, 1, 1
P, D, Q = 0, 1, 1
s = 7

#Fit SARIMA
sarima_model = SARIMAX(train_df['total_amount'], order=(p, d, q), seasonal_order=(P, D, Q, s))
sarima_model_fit = sarima_model.fit(disp=0)
print(sarima_model_fit.summary())
```

<Figure size 1600x700 with 4 Axes><img width="1311" height="627" alt="image" src="https://github.com/user-attachments/assets/79aeabb8-2a4d-46d3-89be-6099c8a776f4" />

#### Observations
- Residuals fluctuate around zero with no clear pattern, indicating that the model has captured most of the signal.
- The histogram shows a roughly centered distribution, though slightly skewed, suggesting mild deviation from perfect normality.
- The Q–Q plot shows reasonable alignment with the theoretical line, with only a few outliers in the upper tail.
- The residual correlogram shows no significant autocorrelation, confirming that the residuals behave like white noise.

### 3.3 Plotting predictions and evaluating SARIMA model
**Prediction using SARIMA**

```
# defining prediction period
pred_start_date = test_df.index[0]
pred_end_date = test_df.index[-1]

sarima_predictions = sarima_model_fit.predict(start=pred_start_date, end=pred_end_date)
sarima_residuals = test_df['total_amount'] - sarima_predictions
```
**Evaluation of SARIMA**

```
import numpy as np
from sklearn.metrics import mean_squared_error


# RMSE
def rmse_metrics(y_true, y_pred):
    return np.sqrt(mean_squared_error(y_true, y_pred))



# SAFE MAPE (NOT percent)
# Example: 0.12 instead of 12%
def mape_safe(y_true, y_pred):
    y_true_safe = y_true.replace(0, 1e-6)  # avoid division by zero
    return np.mean(np.abs((y_true_safe - y_pred) / y_true_safe))


# SMAPE (NOT percent)
# Example: 0.15 instead of 15%
def smape(y_true, y_pred):
    numerator = np.abs(y_pred - y_true)
    denominator = (np.abs(y_true) + np.abs(y_pred)) / 2
    return np.mean(numerator / denominator)


# EVALUATION
sarima_rmse = rmse_metrics(test_df['total_amount'], sarima_predictions)
sarima_mape = mape_safe(test_df['total_amount'], sarima_predictions)
sarima_smape = smape(test_df['total_amount'], sarima_predictions)

print(f"RMSE: {sarima_rmse:.4f}")
print(f"MAPE (decimal): {sarima_mape:.4f}")
print(f"SMAPE (decimal): {sarima_smape:.4f}")
```

<img width="222" height="50" alt="image" src="https://github.com/user-attachments/assets/c8b08c1f-e0bf-46d0-84fd-bb7da9631c89" />


**Sarima Forecast**
- We will try to forecast the sales for next 180 days. We have the 121 days known from our test data and we will try to see what our model forcasts for next 60 days.

```
#Forecast Window
days = 180

sarima_forecast = sarima_model_fit.forecast(days)
sarima_forecast_series = pd.Series(sarima_forecast, index=sarima_forecast.index)

#Since negative orders are not possible we can trim them.
sarima_forecast_series[sarima_forecast_series < 0] = 0
```


**Plotting Forecast using baseline SARIMA**

```
plot_forecast(train_df['total_amount'], test_df['total_amount'], sarima_forecast_series)
```

<img width="700" height="500" alt="image" src="https://github.com/user-attachments/assets/7a5460f7-323d-435e-aba3-184f625091b5" />

#### Observations:
- Test data shows large revenue spikes, but the model does not replicate these extreme variations.
- Forecasted values remain smooth and stable, indicating the model predicts the average daily pattern rather than sudden fluctuations.
- The forecast closely follows the central tendency of the series, suggesting SARIMA is effective for baseline revenue forecasting.
- However, the model underestimates irregular high-sales days, as they are not part of the learned seasonal or trend structure.

## 4. Modelling (Facebook Prophet)
FB Prophet is a forecasting package in Python that was developed by Facebook’s data science research team. The goal of the package is to give business users a powerful and easy-to-use tool to help forecast business results without needing to be an expert in time series analysis. We will apply this model and see how it performs.

#### 4.1 Preparing data for FB Prophet

Faecbook prophet needs data in a certain format to be able to process it. The input to Prophet is always a dataframe with two columns: ds and y. The ds (datestamp) column should be of a format expected by Pandas, ideally YYYY-MM-DD for a date or YYYY-MM-DD HH:MM:SS for a timestamp. The y column must be numeric, and represents the measurement here in our case it is total_amount.

```
# preparing the dataframe for fbProphet
prophet_df = daily_data[['total_amount']].reset_index()

prophet_df.rename(columns={
    "order_purchase_timestamp": "ds",
    "total_amount": "y"
}, inplace=True)

#using our original train_df and test_df we will convert them into prophet train andt test set.
prophet_train = train_df["total_amount"].reset_index()
prophet_train.rename(columns={"order_purchase_timestamp": "ds", "total_amount": "y"}, inplace=True)
prophet_test = test_df["total_amount"].reset_index()
prophet_test.rename(columns={"order_purchase_timestamp": "ds", "total_amount": "y"}, inplace=True)
```

#### 4.2 Applying a Baseline FB Prophet
Since we observed that our data has positive trend and seasonality, we will set growth ='linear' and let the model find out appropriate seasonality by making yearly_seaonality, daily_seasonality and weekly_seasonality = True.

```
#instantiate the model
fb_baseline = Prophet(growth='linear', 
                yearly_seasonality=True, 
                daily_seasonality=True, 
                weekly_seasonality=True)
fb_baseline.fit(prophet_train)
```

**Predictions using baseline Prophet**

```
#make predictions dataframe 
future_base = fb_baseline.make_future_dataframe(periods=len(test_df), freq="D")
#make a forecast
forecast_base = fb_baseline.predict(future_base)
forecast_base[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].tail()
```

<img width="391" height="172" alt="image" src="https://github.com/user-attachments/assets/a5120e40-50ee-4292-b5e8-c734ee435af8" />

### 4.3 Plotting and Evaluating Baseline model

```
# Safe MAPE
fb_baseline_mape = mape_safe(
    prophet_test['y'],
    forecast_base[-len(prophet_test):].reset_index()['yhat']
)

# RMSE
fb_baseline_rmse = rmse_metrics(
    prophet_test['y'],
    forecast_base[-len(prophet_test):].reset_index()['yhat']
)

print(f'RMSE: {fb_baseline_rmse}')
print(f'MAPE (decimal): {fb_baseline_mape}')
```

<img width="278" height="72" alt="image" src="https://github.com/user-attachments/assets/929fd185-3c6b-4a06-a79e-e8e254f70615" />

**Plotting the forecast using Baseline FB Prophet**

```
from prophet.plot import plot_plotly

fig = plot_plotly(fb_baseline, forecast_base) 
fig.update_layout(
    title="Daily Sales amount",
    xaxis_title="Date",
    yaxis_title="Revenue amount"
    )
# fig.show()
fig.show("svg")
```

<img width="900" height="600" alt="image" src="https://github.com/user-attachments/assets/821c4276-0de7-45b5-a93f-42f3e022e3b9" />

## Observation:
- Although Prophet did not achieve strong MAPE or RMSE scores, the forecast plot shows that the model successfully captures the overall trend, seasonal patterns, and the general direction of daily revenue. However, it struggles to reproduce the sharp spikes and extreme peaks present in the actual data. Further improvements can be made by tuning hyperparameters and including holiday effects to better model unusually high-revenue days.

### 4.4 Tuning FB Prophet using Grid Search

```

# 1. ALIGN FORECAST WITH TEST SET
merged = prophet_test.merge(
    forecast_base_holi[['ds', 'yhat']],
    on='ds',
    how='left'
)
# 2. DEFINE RMSE + SMAPE METRICS
def rmse_metrics(y_true, y_pred):
    return np.sqrt(np.mean((y_true - y_pred) ** 2))

def smape(y_true, y_pred):
    return 100 * np.mean(
        2 * np.abs(y_pred - y_true) / (np.abs(y_true) + np.abs(y_pred))
    )
# Define MAPE but avoid INF
def mape_safe(y_true, y_pred):
    y_true = np.where(y_true == 0, 1e-5, y_true)  # avoid division by zero
    return np.mean(np.abs((y_true - y_pred) / y_true)) * 100
# 3. CALCULATE METRICS
fb_baseline_holi_rmse = rmse_metrics(merged['y'], merged['yhat'])
fb_baseline_holi_smape = smape(merged['y'], merged['yhat'])
fb_baseline_holi_mape = mape_safe(merged['y'], merged['yhat'])  
# 4. PRINT RESULTS
print("Prophet with Holidays — Evaluation Metrics")
print("-------------------------------------------")
print(f"RMSE : {fb_baseline_holi_rmse}")
print(f"SMAPE: {fb_baseline_holi_smape}")
print(f"MAPE (safe): {fb_baseline_holi_mape}")
```
<img width="347" height="119" alt="image" src="https://github.com/user-attachments/assets/df3abdf3-31f0-402a-a04d-491c1469e684" />

## 5. Challenges with Hourly Resampled Data
To increase the number of data points, I attempted to resample the dataset at an hourly frequency. However, this introduced many zero values during hours with no orders, making the series sparse and irregular. Applying SARIMA on this hourly data produced negative predictions and a declining trend. After further research and guidance, I found that such data requires additional transformations or alternative modeling techniques. Therefore, I chose to proceed using the daily data instead.

### 8.Conclusion
Here is the summary of all the models we tested:
### Summary:

| Model                      | RMSE     | MAPE  |
|----------------------------|----------|-------|
| SARIMA(1,1,1)(0,1,1)(7)    | 462.0464 |87025914.42
| Baseline Prophet           | 456.169  |77407789.89
|Baseline Prophet with holiday|455.088  |756639567.89

We choose the Prophet model with holiday effects as the best-performing model because it achieves the lowest error (lowest MAPE and RMSE) among all models.





