# 💻 Global E-commerce Sales Strategy & Metrics (SQL)

A comprehensive SQL-based project analyzing a sales database structure to identify top-performing products, calculate critical customer metrics (like CLV and AOV), and track regional sales performance.

## 🎯 Project Objective

This repository showcases proficiency in **Data Definition Language (DDL)**, **Data Manipulation Language (DML)**, and **advanced analytical querying** within a relational database environment (specifically demonstrating [Insert Database Type Here, e.g., MySQL]).

The key objectives were:
* **Database Design:** Implement a normalized schema with defined primary and foreign key constraints.
* **Analytical Querying:** Develop complex queries utilizing **JOINs**, **CTEs (Common Table Expressions)**, **Window Functions (e.g., LAG())**, and sophisticated aggregation.
* **Business Insights:** Extract actionable metrics on Customer Lifetime Value (CLV), Average Order Value (AOV), and product return rates.

---

## 📁 Repository Structure and Files

The project is structured sequentially for easy setup and review.

| File Name | Purpose | Key SQL Concepts Demonstrated |
| :--- | :--- | :--- |
| `01_create_tables.sql` | **Schema Definition (DDL):** Contains `CREATE TABLE` and indexing for optimal performance. | Constraints, Primary/Foreign Keys, Indexing. |
| `02_insert_data.sql` | **Sample Data (DML):** `INSERT` statements to populate tables with valid test data. | Data Integrity, `INSERT INTO` syntax. |
| `03_analysis_queries.sql` | **Core Analysis:** All business questions and analytical queries. | JOINs, CTEs, Window Functions, Grouping, Subqueries. |
| `README.md` | This file—project documentation and setup guide. | Markdown formatting. |

---

## 🚀 Getting Started (Setup Instructions)

Follow these steps to deploy and execute the analysis on your local database server:

### Step 1: Create a Database
Open your SQL client and create a new, empty database.

> **Example (for MySQL/PostgreSQL):**
> ```sql
> CREATE DATABASE [your_project_db_name];
> USE [your_project_db_name]; 
> ```

### Step 2: Build the Schema (Tables)
Execute the script in **`01_create_tables.sql`**. This creates the five tables: `Regions`, `Customers`, `Products`, `Orders`, and `OrderDetails`.

### Step 3: Load the Data
Execute the script in **`02_insert_data.sql`**. This populates the tables with the necessary sample data.

### Step 4: Run the Analysis
Execute the queries sequentially in **`03_analysis_queries.sql`** to view the results for all analytical questions.

---

## 📝 Schema Overview

The database uses a normalized design centered around the `Orders` and `OrderDetails` tables, linking to key dimensions: 

[Image of a database Entity-Relationship Diagram (ERD)]


* **Fact Tables:** `Orders`, `OrderDetails`
* **Dimension Tables:** `Customers`, `Products`, `Regions`

## 💡 Key Analytical Insights Demonstrated

The analysis in `03_analysis_queries.sql` successfully extracts complex metrics, demonstrating proficiency in:

* **Customer Lifetime Value (CLV):** Calculated total spend per customer, allowing for accurate customer segmentation (e.g., Platinum, Gold).
* **Time-Series Analysis:** Determined the **Average Time Between Consecutive Orders** per region using the **`LAG()` window function** for high-efficiency time difference calculation.
* **Return Rate Robustness:** Calculated precise **Return Rates by Product and Category**, using **`LEFT JOIN`** and **`COALESCE()`** to handle products with zero returns gracefully.
* **AOV & Revenue Trends:** Calculated Average Order Value (AOV) and total revenue across various temporal and regional breakdowns.

---
