
# Customer Behaviour Analysis System

An end-to-end data analytics project that analyzes e-commerce sales, customer purchasing behaviour, product performance, customer experience, and customer value using Python, MySQL, SQL, and Power BI.

## Project Overview

RetailPulse India is a fictional e-commerce business used to demonstrate how data analytics can support business decisions.

This project transforms raw transactional data into actionable insights through data quality validation, data cleaning, SQL analysis, RFM customer segmentation, and interactive Power BI dashboards.

**Dataset note:** The project uses a synthetic Indian e-commerce dataset. The results demonstrate an analytical workflow and should not be interpreted as actual company performance.

## Business Objectives

- Analyze revenue, orders, and sales trends.
- Identify repeat customers and purchasing patterns.
- Evaluate product, category, and brand performance.
- Understand returns, customer reviews, and delivery performance.
- Segment customers using Recency, Frequency, and Monetary (RFM) analysis.
- Identify customer groups that could benefit from retention campaigns.
- Present business findings through interactive dashboards.

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Data profiling, cleaning, validation, and feature engineering |
| Pandas and NumPy | Data manipulation and analytical transformations |
| MySQL | Relational database storage and querying |
| SQL | Business analysis, aggregations, joins, and RFM segmentation |
| Power BI | Interactive dashboards and visual reporting |
| DAX | KPI calculations and analytical measures |
| Power Query | Data preparation and transformation |
| Git and GitHub | Version control and project documentation |

## Dataset

The dataset contains nine main analytical tables:

| Table | Description |
|---|---|
| customers | Customer profiles, demographics, and loyalty information |
| orders | Order transactions, dates, amounts, and statuses |
| order_items | Product-level order quantities, revenue, costs, and profit |
| products | Product, category, brand, price, and inventory information |
| payments | Payment methods, statuses, and refunds |
| shipments | Dispatch, delivery, and shipment status information |
| returns | Returned products, reasons, and refund amounts |
| customer_reviews | Ratings, review sentiment, and verified purchases |
| marketing_campaigns | Campaign activity, conversions, cost, and revenue |

The raw and processed CSV files are excluded from Git using `.gitignore`. Use the original dataset source and its applicable terms when reproducing the project.

## Data Preparation and Quality Validation

The Python data pipeline includes:

- Missing-value and duplicate checks.
- Primary-key and foreign-key validation.
- Date parsing and chronological validation.
- Categorical text standardization.
- Validation of order amount, item revenue, and profit calculations.
- Analytical feature creation for order dates, discounts, and delivery delays.
- Export of cleaned datasets for downstream analysis.

### Validation Results

- No duplicate primary keys were detected in the tested raw tables.
- No invalid foreign-key references were detected.
- Order amount, item revenue, and profit calculations passed the tested business-rule checks.
- No invalid chronological records were detected in the tested date validations.
- Missing values were preserved when they represented legitimate business conditions.

Negative-profit records were identified as a business finding rather than automatically treated as data errors.

## SQL Analysis

SQL analysis covers:

1. Overall business KPIs.
2. Monthly revenue and sales trends.
3. Customer purchasing behaviour.
4. Product, category, and brand performance.
5. Regional and demographic analysis.
6. Returns, reviews, and customer experience.
7. Marketing campaign performance.
8. Shipment and delivery performance.
9. Payment analysis.
10. RFM customer segmentation.

The analysis uses joins, aggregations, common table expressions, conditional logic, date functions, and window functions where appropriate.

## Power BI Dashboard

The report contains five pages.

### 1. Executive Overview
- Total revenue
- Total orders and delivered orders
- Total customers
- Average order value
- Repeat customer rate
- Total profit
- Monthly revenue trend
- Revenue by product category

### 2. Customer Behaviour
- Customers by loyalty tier
- Customer distribution by state
- Customer status breakdown
- Repeat versus one-time customers

### 3. Product & Sales Analysis
- Revenue by product category
- Top brands by profit
- Profit by category
- Top products by revenue
- Profit margin by category
- Monthly revenue trends

### 4. Customer Experience
- Returns by reason
- Total returns and return rate
- Average customer rating
- Customer review sentiment
- Shipment delivery status
- Average delivery days
- Delayed shipment rate

### 5. Customer Segmentation
- Customers by RFM segment
- Revenue by RFM segment
- Average orders per customer by segment
- Average days since the last purchase by segment

## RFM Customer Segmentation

RFM analysis evaluates customers using three measures:

- **Recency:** How recently a customer purchased.
- **Frequency:** How many delivered orders the customer placed.
- **Monetary:** The total value of delivered orders.

Customers are assigned scores and classified into six analytical segments:

- Champions
- Loyal Customers
- Potential Loyalists
- New Customers
- At Risk
- Lost Customers

The segmentation results can help prioritize customer retention, loyalty initiatives, and re-engagement campaigns.

The RFM table contains 21,849 customers with delivered-order activity in the current analysis. Customers without qualifying delivered orders are not included in this RFM population.

## Key Findings

The current Power BI report displays the following results for the synthetic dataset:

- Total revenue: approximately ₹2,084.31 million.
- Total orders: approximately 100,000.
- Delivered orders: approximately 81,000.
- Total customers in the customer table: 25,000.
- Average order value: approximately ₹25,830.
- Repeat customer rate: approximately 78.25%.
- Total profit: approximately ₹158.63 million.

Additional analysis highlights differences in category performance, customer purchasing frequency, return reasons, delivery outcomes, and RFM segment value.

These figures reflect the current report's measure definitions and filters. They are illustrative dataset results, not real-world business claims.

## Business Recommendations

- Develop retention campaigns for valuable customers whose recent purchase activity has declined.
- Reward Champions and Loyal Customers with relevant loyalty benefits.
- Test targeted re-engagement campaigns for Lost Customers.
- Investigate product categories and brands with weak or negative profit.
- Analyze common return reasons to identify product quality, sizing, and expectation gaps.
- Monitor delayed shipments and delivery performance.
- Evaluate marketing campaigns using conversions, cost, revenue, and ROI.
- Track repeat purchasing and customer value over time.

Recommendations should be validated through further analysis and campaign testing before implementation.

## Project Structure

```text
Customer_Behaviour_Analysis/
├── data/
│   ├── raw/
│   └── processed/
├── excel/
├── images/
├── notebooks/
├── powerbi/
├── python/
│   ├── data_quality_check.py
│   ├── duplicate_check.py
│   ├── foreign_key_check.py
│   ├── categorical_check.py
│   ├── numeric_validation.py
│   ├── date_validation.py
│   ├── data_cleaning.py
│   ├── processed_validation.py
│   └── load_to_mysql.py
├── reports/
│   └── data_dictionary.md
├── sql/
│   ├── 02_create_tables.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_business_analysis.sql
│   ├── 05_customer_segmentation.sql
│   └── 06_create_rfm_segment_table.sql
├── .gitignore
├── README.md
└── requirements.txt
```

File names in the project may evolve as the implementation is refined.

## How to Run the Project

### Prerequisites

- Python 3.11 or a compatible version
- MySQL Server
- Power BI Desktop
- Git

### 1. Clone the repository

```bash
git clone https://github.com/sivateja580/customer_behaviour_analysis_system.git
cd customer_behaviour_analysis_system
```

### 2. Install Python dependencies

```bash
python -m venv .venv
```

Activate the environment on Windows:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install the project dependencies:

```bash
pip install -r requirements.txt
```

### 3. Add the dataset

Place the required source CSV files in `data/raw/`, following the dataset's licensing and usage terms.

### 4. Clean and validate the data

Run the Python validation and cleaning scripts from the project root as required by the pipeline.

```bash
python python/data_quality_check.py
python python/data_cleaning.py
python python/processed_validation.py
```

### 5. Set up MySQL

Create the database and execute the SQL scripts in the appropriate order. Review database credentials and local paths before running the Python loader.

### 6. Load and analyze the data

Run the MySQL loader, execute the SQL analysis scripts, and review the resulting business metrics and RFM segments.

### 7. Open the Power BI report

Open the `.pbix` file in the `powerbi/` folder. Configure the database connection for your environment and refresh the data when required.

## Future Enhancements

- Add automated data-quality reporting.
- Build customer churn prediction models.
- Compare customer segments over time.
- Analyze cohort retention and repeat-purchase behaviour.
- Automate refresh and reporting workflows.
- Explore cloud-based data storage and deployment.

## Author

Siva Teja Kumar Reddy Boreddy

Data Analytics | Python | SQL | Power BI

GitHub: [sivateja580](https://github.com/sivateja580)

---

*This project was developed for learning, portfolio demonstration, and business analytics practice, practical Exposure on Project.*
