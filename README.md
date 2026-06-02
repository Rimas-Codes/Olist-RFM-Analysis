# Olist E-commerce RFM Customer Segmentation

## Project Overview
This project analyzes customer purchasing behavior using RFM (Recency, Frequency, Monetary) analysis for Olist, a Brazilian e-commerce marketplace. The analysis identifies customer segments to drive targeted marketing strategies.

## Tools Used
- **BigQuery** (SQL) - Data processing and RFM calculation
- **Power BI** - Interactive dashboard and visualization

## Business Problem
E-commerce companies need to understand customer value to:
- Retain high-value customers
- Re-engage at-risk customers
- Optimize marketing spend

## Solution
Built an RFM model that:
- Segments 100,000+ customers into 9 segments
- Identifies "Champions" representing top 7% of customers
- Flags "At Risk" customers for retention campaigns

## Key Insights
- **Champions** (7% of customers): Generate 35% of revenue
- **At Risk** (5% of customers): $200K+ revenue at potential loss
- **Lost Customers** (45%): Opportunity for reactivation campaigns

## SQL Logic Implemented
- CTEs for modular query structure
- NTILE(4) for quartile-based scoring
- CASE statements for segment classification
- Views for reusable transformations

## Power BI Dashboard Features
- Interactive segment filters
- Recency vs Monetary scatter plot
- Customer segment distribution
- Top champions table
- KPI cards (total customers, avg recency, total revenue)

## How to Reproduce
1. Download Olist dataset from Kaggle
2. Run SQL scripts in `/sql` folder in order (01-05)
3. Open Power BI file and connect to BigQuery
4. Refresh visuals

## Files in this Repository
- `/sql` - All SQL queries used for RFM calculation
- `/powerbi` - Power BI dashboard file
- `/documentation` - Project screenshots and overview
