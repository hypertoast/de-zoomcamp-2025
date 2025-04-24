# de-zoomcamp-2025
DataEngineering Zoomcamp 2025

# NYC Taxi Data Analysis Project Plan

## Project Overview

**Project Title:** NYC Taxi Data Analysis Pipeline: Optimizing Fleet Operations and Understanding Passenger Behavior

**Objective:** Build an end-to-end data pipeline that processes NYC taxi trip data to identify high-demand zones, analyze payment patterns, and visualize trip metrics for operational optimization.

## Technology Stack

| Component | Technology | Description |
|-----------|------------|-------------|
| **Cloud Platform** | Google Cloud Platform | Managed services for scalable data processing |
| **IaC** | Terraform | Infrastructure as code for GCP resource provisioning |
| **Data Lake** | Google Cloud Storage | Raw data storage |
| **Data Warehouse** | BigQuery | SQL-based analytics database with partitioning/clustering |
| **Workflow Orchestration** | Airflow (on GKE or GCE) | Orchestrate the entire data pipeline |
| **Transformations** | dbt | Data transformation and modeling |
| **Dashboard** | Looker Studio | Visualization of insights |
| **Languages** | Python, SQL | For scripts and transformations |
| **Containerization** | Docker | Container images for pipeline components |

## Project Phases

### Phase 1: Infrastructure Setup
- Set up GCP project with billing alerts and budget constraints
- Create Terraform scripts for infrastructure provisioning
- Set up Docker environments
- Deploy Airflow on GCP

### Phase 2: Data Ingestion
- Download NYC TLC Trip data (select Yellow Taxi data for a specific period)
- Design Airflow DAG for data ingestion
- Implement data validation and quality checks
- Load raw data into GCS data lake

### Phase 3: Data Warehouse Setup
- Create optimized BigQuery tables
  - Partition by pickup date
  - Cluster by pickup location ID
- Implement data loading from GCS to BigQuery
- Set up scheduled refreshes

### Phase 4: Transformations
- Set up dbt project
- Create dimension tables (locations, time, payment types)
- Create fact tables (trips, fares)
- Implement data quality tests
- Document data models

### Phase 5: Dashboard Development
- Create Looker Studio dashboard with:
  - Categorical visualization: Payment types by zone
  - Temporal visualization: Trip volumes by hour/day/week
- Design user-friendly interface
- Add interactive filters

## 4. Detailed Implementation Plan

### Data Source Details
- NYC TLC Yellow Taxi Trip Data
- Sample size: 3 months of data
- Key fields:
  - Pickup/dropoff timestamps
  - Pickup/dropoff locations
  - Trip distance
  - Fare amount, tips, total amount
  - Payment type
  - Passenger count

### Data Pipeline Workflow
1. **Extract**: Download TLC data monthly files
2. **Load**: Store raw data in GCS
3. **Transform**: Process with dbt in BigQuery
   - Create staging models
   - Create dimensional models
   - Apply business logic
4. **Visualize**: Present in Looker Studio dashboard

### BigQuery Optimization
- Partition tables by pickup date
- Cluster by zone ID
- Create materialized views for common queries
- Use appropriate column types for efficient storage

### Dashboard Visualizations
1. **Categorical Tile**: "Payment Method Distribution by Zone"
   - Bar chart showing payment types across top 10 zones
   - Helps understand customer payment preferences

2. **Temporal Tile**: "Hourly Trip Volume by Day of Week"
   - Time series showing trip patterns
   - Highlights peak hours and demand fluctuations

## 5. Cost Management Strategy

- Use GCP Free Tier resources where possible
- Set billing alerts at 50% and 80% of your budget
- Schedule VM shutdowns during inactive periods
- Use Terraform to easily destroy resources when not needed
- Limit dataset size if necessary (e.g., use 1-3 months of data)

## 6. Next Steps

1. Set up GCP account and project
2. Create initial Terraform configuration
3. Explore and download sample NYC taxi data
4. Begin designing Airflow DAGs
5. Plan dbt models based on business requirements
