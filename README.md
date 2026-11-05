# COVID-19 Data Exploration & Visualization

## Project Overview
This project presents an end-to-end data analysis pipeline examining global COVID-19 metrics, including total cases, total deaths, population infection rates, and vaccination trends. 

The primary objectives of this project are:
1. Extract and transform raw global pandemic datasets into structured metrics using PostgreSQL.
2. Formulate analytical queries to identify geographical hotspots, infection timelines, and death rates relative to population size.
3. Export cleaned aggregate tables to construct an interactive, multi-view dashboard in Tableau Public.

---

## Interactive Tableau Dashboard
The full interactive dashboard is published and accessible via Tableau Public:  
[View COVID-19 Interactive Dashboard](https://public.tableau.com/views/Covid-19Dashboard_17932425206210/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## Tech Stack & Datasets
* **Database Management System:** PostgreSQL
* **Data Visualization:** Tableau Public
* **Source Dataset:** Our World in Data (COVID-19 Global Tracking Dataset)

---

## Technical SQL Highlights
The PostgreSQL script (`Covid19 Analytic Query.sql`) incorporates several core database query techniques:
* **Data Aggregation & Filtering:** Summary calculations using `SUM()`, `AVG()`, and conditional filtering to isolate regional vs. continental metrics.
* **Window Functions:** Cumulative tracking of rolling vaccination numbers per country using `SUM() OVER (PARTITION BY ... ORDER BY ...)`.
* **Common Table Expressions (CTEs):** Modular query structuring to calculate percentage metrics on derived columns.
* **Temporary Tables:** Intermediate data storage for downstream aggregation and exported visual datasets.
* **Type Casting & NULL Handling:** Data normalization to ensure correct numeric precision across infection and mortality rates.

---

## Repository Contents
* `Covid_Deaths.csv` : Raw dataset containing historical case and mortality figures.
* `Covid_Vaccinations.csv` : Raw dataset containing historical vaccination metrics.
* `Covid19 Analytic Query.sql` : Comprehensive PostgreSQL script covering exploratory queries and aggregate creation.
* `Table1_GlobalNumbers.csv` to `Table4_InfectionOverTime.csv` : Processed summary datasets exported specifically for Tableau visual mapping.
* `Covid-19_Dashboard.twb` : Tableau Desktop workbook file.

---

## How to Reproduce
1. Clone the repository to your local machine.
2. Import `Covid_Deaths.csv` and `Covid_Vaccinations.csv` into your PostgreSQL instance.
3. Execute `Covid19 Analytic Query.sql` to generate the aggregate tables.
4. Open `Covid-19_Dashboard.twb` in Tableau Desktop to inspect or edit the visualization layouts.
