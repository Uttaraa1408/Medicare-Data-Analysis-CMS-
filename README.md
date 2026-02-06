# Hospital Ratings & Characteristics

# Medicare Data Analysis (CMS)

### Overview

This project analyzes CMS Hospital Overall Ratings to understand how hospital characteristics, service mix, and Medicare spending patterns influence quality ratings across U.S. hospitals. The analysis uses publicly available Medicare data and applies statistical modeling, machine learning, and interactive visualization to identify key drivers of hospital performance.

### Data Sources

Data was sourced from the CMS Provider Data Catalog (PDC):

Hospital General Information

Medicare Inpatient Hospitals - by Provider & Service (DRG level)

Medicare Spending per Beneficiary (MSPB)

The final integrated dataset includes approximately 5,400 hospitals.

### Key Variables

Hospital Overall Rating (1-5)

Ownership Type (Government vs. Private)

Metro vs. Non-Metro Location

Emergency & Acute Care Services

Medicare Spending per Beneficiary (MSPB Score)

Average Medicare Payments

Major Diagnostic Categories (MDCs)

### Methods

Statistical Analysis (SPSS)

Correlation analysis

Multiple linear regression

Ordinal logistic regression

Machine Learning

Decision Trees

Random Forest classifiers

### Visualization

Power BI dashboards for interactive analysis

### Key Findings

MSPB Score is a strong negative predictor of hospital ratings.

Metro hospitals tend to receive higher ratings than non-metro hospitals.

Government-owned hospitals show slightly lower ratings on average.

Certain MDCs, especially Infectious & Parasitic Diseases (MDC_18) and Circulatory System (MDC_5), are consistently associated with lower ratings.

Random Forest models performed better than Decision Trees, though accuracy was limited by class imbalance.

### Tools Used

SPSS

R

Power BI

Excel & Microsoft Access (data preparation)

### Repository Contents

Power BI (.pbix) – Interactive dashboards

Cleaned CMS Dataset – Hospital-level data used for analysis
