# E-Commerce Sales & Customer Analytics

An end-to-end data analysis project on an e-commerce dataset (users, products, orders, order items). The raw data is explored and validated in **Python**, analysed with **MySQL**, and presented in an interactive **Power BI** dashboard.

The central idea of the project is to report **net revenue** (cancelled and returned orders excluded) instead of gross revenue. About 39.6% of the gross revenue in this dataset comes from orders that were cancelled or returned, so using gross revenue would overstate the business.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Key Results](#key-results)
3. [Dataset](#dataset)
4. [Tools & Technologies](#tools--technologies)
5. [Project Workflow](#project-workflow)
6. [Revenue Definition (Net vs Gross)](#revenue-definition-net-vs-gross)
7. [Data Quality Checks](#data-quality-checks)
8. [Python Analysis](#python-analysis)
9. [SQL Analysis](#sql-analysis)
10. [Power BI Dashboard](#power-bi-dashboard)
11. [Key Insights](#key-insights)
12. [Recommendations](#recommendations)
13. [Limitations](#limitations)
14. [Repository Structure](#repository-structure)
15. [How to Run the Project](#how-to-run-the-project)
16. [Author](#author)

---

## Project Overview

**Business problem:** understand how the business is performing, which products and customers matter most, and how much revenue is lost to cancelled and returned orders.

**What this project does:**
- Loads and validates four raw tables (users, products, orders, order items).
- Defines a clear business rule for valid sales (`is_valid_sale`).
- Answers about 40 business questions in Python and SQL (revenue trends, top products, brands, categories, cities, customer segments, customer lifetime value, repeat vs one-time buyers, and more).
- Builds a 3-page Power BI dashboard with slicers, using the same net revenue rule.
- Checks that Python, SQL and Power BI all give the same numbers.

---

## Key Results

| Metric | Gross (all orders) | Net (valid sales) |
|---|---|---|
| Orders | 20,000 | 12,014 |
| Revenue | 11,918,668.95 | **7,193,050.80** |
| Average order value | 595.93 | **598.72** |

- Revenue lost to cancelled and returned orders: **4,725,618.15 (39.6%)**
- Registered users: **10,000** | users who placed an order: **8,635** (86.35%) | users with at least one valid order: **6,972**
- Electronics and Automotive together generate about **63%** of net revenue.
- **52%** of customers with a valid order bought only once.

---

## Dataset

Four CSV files (in the `data` folder). The data covers orders from **1 January 2024 to 14 November 2025**.

| File | Rows | Main columns |
|---|---|---|
| `users.csv` | 10,000 | user_id, name, email, gender, city, signup_date |
| `products.csv` | 2,000 | product_id, product_name, category, brand, price, rating |
| `orders.csv` | 20,000 | order_id, user_id, order_date, order_status, total_amount |
| `order_items.csv` | 43,525 | order_item_id, order_id, product_id, user_id, quantity, item_price, item_total |

- 10 product categories and 12 brands.
- 5 order statuses: shipped, returned, completed, cancelled, processing.
- Table relationships: `users` 1-to-many `orders`; `orders` 1-to-many `order_items`; `products` 1-to-many `order_items`.

---

## Tools & Technologies

| Layer | Tools |
|---|---|
| Data cleaning, validation, EDA | Python (Pandas, NumPy, Matplotlib), Jupyter Notebook |
| Database and business queries | MySQL (joins, CTEs, window functions, views) |
| Dashboard | Power BI (Power Query, DAX measures, slicers) |
| Version control | Git and GitHub |

---

## Project Workflow

```
Raw CSV files  -->  Python (load, validate, EDA, net revenue rule)
                         |
                         v
                  MySQL database (tables + is_valid_sale column + 40 business queries)
                         |
                         v
                  Power BI dashboard (connected directly to MySQL)
```

1. **Python:** load the four tables, run validation checks, create the `is_valid_sale` column, answer the business questions, create charts, and export summary files.
2. **MySQL:** create the database and tables, add the `is_valid_sale` column to `orders`, and answer the business questions with SQL.
3. **Power BI:** connect to the MySQL tables, create DAX measures, build the dashboard.
4. **Cross-check:** every headline number (net revenue, valid orders, average order value, top products, brands, customers, cities) was compared across Python, SQL and Power BI.

---

## Revenue Definition (Net vs Gross)

An order counts as a **valid sale** unless its status is `cancelled` or `returned`.

```python
orders["is_valid_sale"] = ~orders["order_status"].isin(["cancelled", "returned"])
```

```sql
UPDATE orders
SET is_valid_sale = CASE WHEN order_status IN ('cancelled', 'returned') THEN 0 ELSE 1 END;
```

- **Gross revenue** = revenue from all 20,000 orders.
- **Net revenue** = revenue from the 12,014 valid orders. All revenue, customer, product, brand, category and city analysis uses net revenue.
- **Assumption:** orders with status `processing` are counted as valid sales, since the sale has not been cancelled or returned.
- Order status analysis (distribution, status by category) intentionally uses all orders, because it studies cancellations and returns themselves.
- The partial month **November 2025** (only 14 days of data) is excluded from month-ranking and growth analysis.

---

## Data Quality Checks

Run in Python before any analysis:

| Check | Result |
|---|---|
| Missing values | none in any table |
| Duplicate rows | none |
| Orders with an unknown user | 0 |
| Order items with an unknown order or product | 0 |
| Order total equals the sum of its items | all 20,000 orders match |
| Item price equals product price | all match |
| Orders dated before the customer's signup date | **9,930 (about 50%)**, a data limitation |
| Orders containing the same product on two lines | 29 |
| Product names that are not unique | yes, so all product analysis groups by `product_id` |

---

## Python Analysis

File: `python/ecommerce_analysis.ipynb`

Sections:
1. Load data, convert dates, create `year`, `month` and `month_name`
2. `is_valid_sale` rule and gross vs net KPI summary
3. Data validation checks
4. Revenue analysis (by year, by month, highest and lowest months, growth)
5. Product, brand, category and city analysis
6. Customer analysis (top customers, average revenue per customer, orders per customer, frequency vs spend)
7. Quantity and rating analysis (quantity vs order value, rating vs revenue)
8. Order status analysis
9. Visualisations (5 charts saved in the `images` folder)
10. Exported summary files (saved in the `python` folder)
11. Key insights and recommendations

Exported files in `python/`:

| File | Content |
|---|---|
| `monthly_revenue.csv` | net revenue by month |
| `revenue_by_category.csv` | net revenue by product category |
| `customer_order_summary.csv` | valid orders, net revenue and average order value per customer |
| `quantity_vs_order_value.csv` | quantity and order value per valid order |
| `order_status_analysis.csv` | order counts and revenue by status (all orders) |

---

## SQL Analysis

File: `sql/ecommerce_analytics_sql.sql`

**Setup:** creates the `ecommerce_analytics` database and the four tables with primary and foreign keys, and adds the `is_valid_sale` column to `orders`.

**Business questions answered (net revenue unless stated):**
- Row counts, gross and net KPIs, average order value, order status counts
- Top 10 customers by spending and by quantity
- Highest revenue products, categories, brands and cities
- Revenue share of every category and every brand
- Products never ordered and customers who never ordered
- Customers with more than 5 valid orders
- Top 10 cities by average order value
- Customer segmentation (High, Medium, Low value)
- Highest revenue months, month-over-month growth and running (cumulative) revenue
- Top customer and top 3 customers in each city
- Rank of every customer by spending
- Best product in each category and top 5 products per category
- Best product in each month
- Customers above the average spend
- Customers whose spending increased compared with their previous order
- Customer lifetime value (CLV)
- One-time vs repeat customers
- A reusable SQL view `Customer_Summary` with orders, gross and net spending

**SQL techniques used:** joins, aggregation, `CASE`, subqueries, CTEs, window functions (`ROW_NUMBER`, `RANK`, `LAG`, running `SUM`), and views.

Customer segments (based on net spending): **High** above 5,000, **Medium** 2,000 to 5,000, **Low** below 2,000.

---

## Power BI Dashboard

File: `powerbi/ecommerce_analytics_power_BI.pbix` (connected to the MySQL database)

| Page | Content |
|---|---|
| **Home (Executive Overview)** | Gross revenue, net revenue, orders placed, valid orders, net average order value, registered users; net revenue by month; order status split; net revenue by category; top 10 products by net revenue; slicers for category, month and year |
| **Customer Insights** | Registered, active and inactive customers; active rate; average orders per customer; net revenue per customer; top 10 customers and cities by net revenue; customer segmentation (count, revenue, average revenue); slicers for year, gender and segment |
| **Product Analysis** | Top 10 products by net quantity; top 10 brands by net revenue; net revenue by category; average catalogue price by category; product performance table |

**Main DAX measures:** Net Revenue, Net Revenue (Items), Valid Orders, Net Quantity Sold, Net Avg Order Value, Active Customers, Inactive Customers, Active Rate %, Avg Orders per Customer, Net Revenue per Customer, and segment measures (customers, revenue, average revenue) that respond to the slicers.

**Design decisions:**
- Product charts use `product_id` with the product name as a label, because many products share a name.
- Charts show the real values (not rounded to thousands) where precision matters.
- A note on the Home page explains that November 2025 is a partial month.

---

## Key Insights

1. **Gross revenue overstates the business.** Gross revenue is 11.92M but net revenue is 7.19M; 39.6% (4.73M) is lost to cancelled and returned orders.
2. **Order outcomes are evenly split.** Shipped 20.6%, returned 20.3%, completed 20.1%, cancelled 19.6%, processing 19.4%. About 4 in 10 orders end up cancelled or returned in every category.
3. **Two categories drive the business.** Electronics (41.3%) and Automotive (21.5%) generate about 63% of net revenue. Groceries (0.7%) and Books (2.2%) contribute very little.
4. **Revenue is stable with a small decline.** The peak month is July 2024 (361,515.21) and the lowest complete month is February 2024 (270,451.48). The 2025 monthly average (Jan to Oct, 312.4K) is about 3.8% below the 2024 average (324.7K).
5. **Most customers buy only once.** Of 6,972 customers with a valid order, 3,609 (52%) bought once and 3,363 repeated. 1,365 registered users never ordered.
6. **A small group brings disproportionate value.** 79 High Value customers (0.9%) bring 6.6% of net revenue; 1,009 Medium Value customers bring 41.8%.
7. **Large orders pull the average up.** Mean order value is 598.72, median is 312.60.
8. **Rating does not drive sales.** The correlation between product rating and revenue is about 0 (-0.002). Quantity and order value are positively related (0.51).
9. **No single product or brand dominates.** The top 10 products make up only 4.6% of net revenue and the 12 brands each hold 6% to 11%.

---

## Recommendations

- Investigate why 4 in 10 orders are cancelled or returned; even a small reduction would add more revenue than new acquisition.
- Protect and grow Electronics and Automotive, and review whether Groceries and Books are worth keeping.
- Offer a second-purchase incentive to the 3,609 one-time customers.
- Run a re-activation campaign for the 1,365 registered users who never ordered.
- Create a loyalty programme for the 79 High Value customers.
- Always report net revenue in dashboards, with gross revenue shown separately.

---

## Limitations

- 9,930 orders (about 50%) are dated before the customer's signup date, so customer tenure analysis was avoided.
- Order statuses are almost evenly distributed, which is unusual for real sales data and suggests the dataset is synthetic. The 39.6% cancellation and return rate should be seen as a feature of this dataset, not an industry benchmark.
- Cities are very fragmented (7,755 cities for 10,000 users, at most 13 users per city), so city rankings rest on very few customers.
- The "average catalogue price" in the dashboard is the listed price, not the price customers actually paid.
- Customer segments are based on lifetime net spending over the whole period.

---

## Repository Structure

```
E-commerce-Data-Analysis/
|-- data/       raw CSV files (users, products, orders, order_items)
|-- images/     5 charts created in Python
|-- powerbi/    Power BI dashboard (.pbix) + 3 dashboard screenshots
|-- python/     Jupyter notebook + 5 exported summary files
|-- sql/        SQL script (tables, net revenue column, business queries)
|-- README.md
```

---

## How to Run the Project

**Python**
1. Install the requirements: `pip install pandas numpy matplotlib jupyter`
2. Open `python/ecommerce_analysis.ipynb`.
3. Change the file paths in the first cells to the location of the CSV files in the `data` folder.
4. Run all cells from top to bottom.

**SQL**
1. Open the script in `sql/` in MySQL Workbench.
2. Create the database and tables, then import the four CSV files into them.
3. Run the `ALTER TABLE` and `UPDATE` statements that create `is_valid_sale`.
4. Run the business queries one by one.

**Power BI**
1. Open `powerbi/ecommerce_analytics_power_BI.pbix` in Power BI Desktop.
2. Point the data source to your own MySQL database (Transform data, then Data source settings) and refresh.

---

## Author

**Rohit Konar**
MCA graduate (Pondicherry University), aspiring Data Analyst / Business Analyst.
GitHub: [Rohit-Konar12](https://github.com/Rohit-Konar12)
LinkedIn: https://www.linkedin.com/in/rohit-konar-506766248/
