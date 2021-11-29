Step 1: Data Download
-------

Download the data from Kaggle. (The data url:
<a href="https://www.kaggle.com/usdot/flight-delays" class="uri">https://www.kaggle.com/usdot/flight-delays</a>)

Step 2: Data Set Up
-------

Change the path in db\_create.sql file in line 49, 70, 87. Also, we have
a sample data in db/sample\_data/ folder.

Step 3: Database Set Up
-------
Read in sql files in db folder and application by this order:
1. db/db_create.sql
2. db/db_insert.sql
3. db/proj2_procedures.sql
4. db/proj2_triggers.sql
5. db/proj2_views.sql

Step 4: Python Environment Set Up
-------

Please install these packages if you haven’t installed before: 
```
pip install sqlalchemy 
pip install streamlit
pip install pandas
pip install pymysql 
pip install scipy 
pip install plotly
pip install matplotlib
```
Step 5: Start Server
-------
Please go to the application/ folder, open up the terminal, and run the following command: 
```
streamlit run flightDelayWeb.py
```
A webpage should pump up automatically. 