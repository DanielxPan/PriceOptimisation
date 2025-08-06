# 🛒 Price Optimisation Project

## 📌 Objective
This project aims to identify the **optimal price point for each product** to maximise overall profitability in a retail context. By leveraging historical sales data and evaluating multiple machine learning methods, the project uncovers price strategies that can lead to **a 5–15% increase in profit**.

## 🛠️ Tools & Technologies
- **PostgreSQL** – for querying and preprocessing raw transactional data
- **Python** – for data processing, modeling, and evaluation
- **Matplotlib** – for visualisation of pricing curves and model results

## ⚙️ Methodology
1. **Data Preparation**: Cleaned and aggregated transactional sales data by product and price point.
2. **Data Preprocessing**: Calculated the average price and quantity sold per day, and estimated **price elasticity** for each product.
3. **Modeling**: Compared the performance of four approaches to predict profit:
   - **Baseline**: Used historical data to calculate the maximum observed profit
   - **Linear Regression**
   - **Polynomial Regression**
   - **Decision Tree Regression**
4. **Evaluation**: Visualised predicted vs. actual profit curves to assess model fit and selected the best-performing model based on generalisation ability.
5. **Output**: Identified the **optimal price point** for each product across all models and calculated the corresponding potential profit gain.
6. **Visualization**: Plotted the optimal price and profit projections **across store types**, allowing for model comparison in a unified view.

## 📊 Results
This pricing optimisation strategy revealed significant potential for **profit uplift**, segmented by store category:

- 🏬 **Country Stores**: up to **44%** increase in profit  
- 🌆 **Metro Stores (Region A)**: up to **38%** increase  
- 🌇 **Metro Stores (Region B)**: up to **25%** increase  

These insights provide targeted pricing recommendations based on store location and customer behaviour, enabling more effective retail pricing strategies.

## 📁 Repository Structure
```
data/           - Sample or dummy data files  
notebooks/      - Jupyter notebooks for model development  
scripts/        - Python scripts for data cleaning and analysis  
reports/        - Visualisations and summary PDFs  
dashboards/     - Dashboard screenshots or visuals  
```

## 📷 Sample Output
<!-- Add screenshots to this folder and reference them here -->
![Profit Curve Example](dashboards/dashboard_screenshot.png)

## 📄 Notes
> 🔐 All data used in this project is anonymised or synthetic. No real customer or business information is disclosed.

## 🙋‍♂️ Author
Po-Yang(Daniel) Pan  
[LinkedIn](https://linkedin.com/in/daniel-pan-16a972a1) | [Email](mailto:daniel.pan.py@gmail.com)