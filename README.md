# E-Commerce Data Analysis

## 📌 Project Overview

This project analyzes an e-commerce dataset to understand sales performance, customer behavior, product performance, and order trends.

The project uses **SQL, Python, and Power BI** to perform data analysis, generate business insights, and create an interactive dashboard.

---

## 🎯 Business Objective

The main objective of this project is to answer key business questions such as:

* Which categories and products generate the most revenue?
* How does revenue change over time?
* What is the typical order value?
* Which customers contribute the most revenue?
* How frequently do customers place orders?
* What is the relationship between order quantity and order value?
* Which order statuses contribute to revenue?
* Which categories have higher cancellation and return activity?
* What actions can the company take based on these findings?

---

## 🗂️ Dataset

The project contains four datasets:

* users.csv — Customer information
* orders.csv — Order-level information
* order_items.csv — Individual products included in each order
* products.csv — Product details such as category, brand, price, and rating

The dataset contains **20,000 orders, 43,525 order items, 2,000 products, and 10,000 users**.

---

## 🛠️ Tools & Technologies

* **SQL / MySQL** — Data querying and business analysis
* **Python** — Data cleaning, exploratory data analysis, statistical analysis, and visualization
* **Pandas** — Data manipulation
* **Matplotlib** — Data visualization
* **Power BI** — Interactive dashboard and business reporting
* **Jupyter Notebook** — Python analysis environment

---

# 🔎 Analysis Process

## 1. SQL Analysis

SQL was used to answer business questions involving:

* Revenue analysis
* Customer spending
* Product performance
* Category performance
* Order status analysis
* Customer order frequency
* Ranking and segmentation
* Aggregations using `SUM`, `COUNT`, `AVG`, `GROUP BY`, `ORDER BY`, and `HAVING`
* Window functions such as `ROW_NUMBER()`

SQL queries are available in:

sql/ecommerce_analysis.sql

---

## 2. Python EDA

Python was used for:

* Data validation
* Data type conversion
* Date/time analysis
* Descriptive statistics
* Revenue analysis
* Customer analysis
* Product and category analysis
* Correlation analysis
* Data visualization

Python analysis is available in:

python/ecommerce_analysis.ipynb

---

## 3. Power BI Dashboard

An interactive Power BI dashboard was created to provide a visual overview of the e-commerce business.

The dashboard focuses on:

* Sales performance
* Profit/revenue-related KPIs
* Customer and product analysis
* Category performance
* Order trends
* Business insights

Power BI file:

powerbi/ecommerce_analysis.pbix

---

# 📊 Key Findings

### Revenue by Category

Electronics generated the highest revenue at approximately **4.96M**, followed by Automotive at approximately **2.50M**.

### Customer Behavior

There were **8,635 unique customers** who placed orders, with an average of approximately **2.32 orders per customer**.

### Average Order Value

The average order value was approximately **595.93**, while the median order value was approximately **308.19**, indicating that some higher-value orders increase the average.

### Order Status

Returned and cancelled orders together represented approximately **39.93% of all orders**, making order cancellation and return behavior an important area for further investigation.

### Quantity vs Order Value

The correlation between total quantity and order value was approximately **0.499**, indicating a moderate positive relationship.

### Rating vs Revenue

The correlation between product rating and revenue was approximately **-0.005**, suggesting almost no linear relationship between rating and revenue in this dataset.

---

# 💡 Business Recommendations

Based on the analysis:

1. **Focus on high-performing categories**

   * Continue strengthening the Electronics category while identifying opportunities in other categories.

2. **Improve customer retention**

   * Use personalized recommendations, cross-selling, upselling, and loyalty rewards to encourage repeat purchases and increase customer value.

3. **Investigate cancellations and returns**

   * Analyze the reasons behind cancelled and returned orders by category and product.
   * Improve product information, quality control, and fulfillment processes where necessary.

4. **Use data-driven product recommendations**

   * Recommend products based on customers' previous purchasing behavior to improve engagement and order value.

---

# 📁 Project Structure

```text
E-Commerce-Data-Analysis/
│
├── data/
│   ├── users.csv
│   ├── orders.csv
│   ├── order_items.csv
│   └── products.csv
│
├── sql/
│   └── ecommerce_analysis.sql
│
├── python/
│   ├── ecommerce_analysis.ipynb
│   ├── images/
│   └── outputs/
│
├── powerbi/
│   └── ecommerce_analysis.pbix
│
├── README.md
└── .gitignore
```

---

# 📈 Python Visualizations

The Python analysis includes visualizations for:

* Revenue by Category
* Monthly Revenue Trend
* Order Status Distribution
* Customer Distribution by Number of Orders
* Quantity vs Order Value

---

# 🚀 Conclusion

This project demonstrates an end-to-end approach to e-commerce analytics by combining **SQL for data querying, Python for exploratory analysis, and Power BI for interactive reporting**.

The analysis converts raw transactional data into actionable business insights related to revenue, customers, products, and order behavior.
