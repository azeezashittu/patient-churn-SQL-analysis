# Patient Churn Data Analysis Using SQL

## Project Overview

This project analyzes patient churn for a healthcare provider using SQL to identify common key factors that play a role in patients deciding to churn. The goal is to uncover insights that help this organization find high risk (patients that are most likely to churn) and high value (patients that bring in a lot of revenue) patients, while also improving/discovering some strategies to benefit these patients and protect long term revenue. This project demonstrates core SQL skills like: JOINs, aggregations (group by, count(*), sum(), avg(), etc.), and filtering. 

## Objectives

- Calculate the overall churn rate
- Identify our high risk churn patient groups
- Analyze revenue between various demographics (age, gender, insurance)
- Understanding patient satisfaction patterns

## Database Structure

This project uses two tables:

- patients_table: demographic information (patient_id, age, gender, chronic_disease, insurance_type)
- patient_activity_table: activity information (patient_id, tenure_months, visits, satisfaction_score, total_bill_amount, misseed_appointmemnts, and if the patients have churned)

Both tables are joined using patient_id

## Schema

``` sql
CREATE TABLE patients_table (
patient_id INT PRIMARY KEY,
age INT,
gender VARCHAR(10),
chronic_disease VARCHAR(5),
insurance_type VARCHAR(50)
);

CREATE TABLE patient_activity_table (
patient_id INT,
tenure_months INT,
visits_last_year INT,
satisfaction_score DECIMAL(3,1),
total_bill_amount DECIMAL (10,2),
missed_appointments INT,
churn VARCHAR(10),
FOREIGN KEY (patient_id) REFERENCES patients_table(patient_id)
);
```

## Business Questions and Solutions

### 1. What is the overall churn rate?

``` sql
select round(count(case when churn = 'Left' then 1 end) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patient_activity_table;
```

### 2. Which insurance type has the highest churn rate?

``` sql
select p.insurance_type, round(count(case when churn = 'Left' then 1 end) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by p.insurance_type
order by 2 desc;
```

### 3. Do patients with chronic diseases churn more than those without?

``` sql
select p.chronic_disease, count(churn) as churned
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by p.chronic_disease
order by 2 desc;
```

### 4. What is the average satisfaction score of churned vs retained patients?

``` sql
select churn, round(avg(satisfaction_score),2) as avg_score
from patient_activity_table
group by churn
order by 2 desc;
```

### 5. Do patients with more missed appointments churn more?

``` sql
select case 
when missed_appointments between 0 and 4 then 'Few Missed Appointments'
when missed_appointments between 5 and 9 then 'Many Missed Appointments'
end as appointments_missed,
round(count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patient_activity_table
group by appointments_missed
order by 2 desc;
```

### 6. Are patients with fewer visits more likely to churn?

``` sql
select 
case 
when visits_last_year between 0 and 9 then 'Fewer vists'
when visits_last_year between 10 and 19 then 'Frequent visits'
end as visits,
round(count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patient_activity_table
group by visits
order by 2 desc;
```

### 7. What is the average tenure of churned patients?

``` sql
select round(avg(tenure_months),2) as avg_tenure
from patient_activity_table
where churn = 'Left';
```

### 8. (Part 1) How much revenue was lost from patients who have churned?

``` sql
select sum(total_bill_amount) as revenue
from patient_activity_table
where churn = 'Left';
```

### 8. (Part 2) vs. revenue from patients who haven't churned

``` sql
select sum(total_bill_amount) as revenue
from patient_activity_table
where churn = 'Stayed';
```

### 9. (Part 1) Which demographic group brings the most revenue? (Age)

``` sql
select 
case 
when age between 18 and 32 then 'Young Adults'
when age between 33 and 47 then 'Adults'
when age between 48 and 62 then 'Older'
when age >= 63 then 'Seniors'
end as age_distribution,
sum(total_bill_amount) as revenue
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by age_distribution
order by 2 desc;

select 
case 
when age between 18 and 32 then 'Young Adults'
when age between 33 and 47 then 'Adults'
when age between 48 and 62 then 'Older'
when age >= 63 then 'Seniors'
end as age_distribution,
avg(total_bill_amount) as revenue
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by age_distribution
order by 2 desc;
```

### 9. (Part 2) Which demographic group brings the most revenue? (Gender)

``` sql
select gender, sum(total_bill_amount) as revenue
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by gender
order by 2 desc;

select gender, avg(total_bill_amount) as revenue
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by gender
order by 2 desc;
```

### 9. (Part 3) Which demographic group brings the most revenue? (Insurance)

``` sql
select insurance_type, sum(total_bill_amount) as revenue
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by insurance_type
order by 2 desc;

select insurance_type, avg(total_bill_amount) as revenue
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by insurance_type
order by 2 desc;
```

### 10. Do high-revenue patients churn less?

``` sql
select 
case when total_bill_amount <= 25199.40 then 'Low Revenue'
else 'High Revenue'
end as revenue_tier,
count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100 as churn_rate_prc
from patient_activity_table
group by revenue_tier
order by 2 desc;
```

### 11. Which insurance group visits the hospital most frequently?

``` sql
select insurance_type, sum(visits_last_year) as visits
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by insurance_type
order by 2 desc;
```

### 12. (Part 1) What demographic group has the MOST missed appointments? (Age)

``` sql
select
case 
when age between 18 and 32 then 'Young Adults'
when age between 33 and 47 then 'Adults'
when age between 48 and 62 then 'Older'
when age >= 63 then 'Seniors'
end as age_distribution,
sum(missed_appointments) as total_appointments_missed
from patients_table p JOIN patient_activity_table a 
on p.patient_id = a.patient_id
group by age_distribution
order by 2 desc;

select
case 
when age between 18 and 32 then 'Young Adults'
when age between 33 and 47 then 'Adults'
when age between 48 and 62 then 'Older'
when age >= 63 then 'Seniors'
end as age_distribution,
round(avg(missed_appointments),2) as avg_appointments_missed
from patients_table p JOIN patient_activity_table a 
on p.patient_id = a.patient_id
group by age_distribution
order by 2 desc;
```

### 12. (Part 2) What demographic group has the MOST missed appointments? (Gender)
``` sql
select gender, sum(missed_appointments) as appointments_missed
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by gender
order by 2 desc;

select gender, round(avg(missed_appointments),2) as appointments_missed
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by gender
order by 2 desc;
```

### 12. (Part 3) What demographic group has the MOST missed appointments? (Insurance)

``` sql
select insurance_type, sum(missed_appointments) as appointments_missed
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by insurance_type
order by 2 desc;

select insurance_type, round(avg(missed_appointments),2) as appointments_missed
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by insurance_type
order by 2 desc;
```
### 13. Is satisfaction higher for patients who visit more often?

``` sql
select 
case 
when visits_last_year between 0 and 9 then 'Fewer vists'
when visits_last_year between 10 and 19 then 'Frequent visits'
end as visits,
round(avg(satisfaction_score),2) as avg_satisfaction
from patient_activity_table
group by visits
order by 2 desc;
```

## Findings/Conclusions/Solutions

This analysis identified important factors related to patient churn, including lower satisfaction scores, missed appointments, fewer visits, and many differences across insurance groups and other demographic categories. Based on my findings, here are a couple of recommendations:

- Target Patients with Low Engagement: For patients with multiple missed appointments and fewer visits, the hospital should implement engagement strategies such as appointment reminders, following up with our patients, and notifications about any discount packages or check-ups (if they haven't visited in a while) to improve these missed visits.
- Improving Patient Satisfaction: My queries show that unchurned patients have an average satisfaction score (3.09/5), and churned patients have a below average satisfaction score (2.92/5). The hospital should continue to monitor this score regularly and find ways to improve its satisfaction score, because soon these patients who haven't churned could churn if these ratings drop even a little.

By using data-driven insights, the organization can reduce churn, improve patient experience, and protect long-term revenue.

## Author

Azeez Ashittu
LinkedIn: https://www.linkedin.com/in/azeezashittu
GitHub: https://github.com/azeezashittu
