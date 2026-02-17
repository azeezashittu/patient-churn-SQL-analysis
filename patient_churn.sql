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

/* The hospital is losing patients, which reduces revenue and long-term patient value*/
/* Who is leaving, why are they leaving, and which patient groups should we focus on to reduce churn and protect revenue*/
-- count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100 (Churn Rate Percentage)

-- Question 1: What is the overall churn rate?
select round(count(case when churn = 'Left' then 1 end) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patient_activity_table;

-- Question 2: Which insurance type has the highest churn rate?
select p.insurance_type, round(count(case when churn = 'Left' then 1 end) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by p.insurance_type
order by 2 desc;

-- Question 3: Do patients with chronic diseases churn more than those without?
select p.chronic_disease, count(churn) as churned
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by p.chronic_disease
order by 2 desc;

-- Question 4: What is the average satisfaction score of churned vs retained patients?
select churn, round(avg(satisfaction_score),2) as avg_score
from patient_activity_table
group by churn
order by 2 desc;

-- Question 5: Do patients with more missed appointments churn more?
select case 
when missed_appointments between 0 and 4 then 'Few Missed Appointments'
when missed_appointments between 5 and 9 then 'Many Missed Appointments'
end as appointments_missed, count(churn) as churned
from patient_activity_table
where churn = 'Left'
group by appointments_missed
order by 2 desc;

select case 
when missed_appointments between 0 and 4 then 'Few Missed Appointments'
when missed_appointments between 5 and 9 then 'Many Missed Appointments'
end as appointments_missed,
round(count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patient_activity_table
group by appointments_missed
order by 2 desc;

-- Question 6: Are patients with fewer visits more likely to churn?
select 
case 
when visits_last_year between 0 and 9 then 'Fewer vists'
when visits_last_year between 10 and 19 then 'Frequent visits'
end as visits,
round(count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100,2) as churn_rate_prc
from patient_activity_table
group by visits
order by 2 desc;

-- Question 7: What is the average tenure of churned patients?
select round(avg(tenure_months),2) as avg_tenure
from patient_activity_table
where churn = 'Left';

-- Question 8: How much revenue was lost from patients who have churned?
select sum(total_bill_amount) as revenue
from patient_activity_table
where churn = 'Left';

-- Question 8 (Part 2): vs. revenue from patients who haven't churned
select sum(total_bill_amount) as revenue
from patient_activity_table
where churn = 'Stayed';

-- Question 9 (Part 1): Which demographic group brings the most revenue? (Age)
select min(age), max(age)
from patients_table;

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


-- Question 9 (Part 2): Which demographic group brings the most revenue? (Gender)
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

-- Question 9 (Part 3): Which demographic group brings the most revenue? (Insurance)
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

-- Question 10: Do high-revenue patients churn less?
select 
case when total_bill_amount <= 25199.40 then 'Low Revenue'
else 'High Revenue'
end as revenue_tier,
count(case when churn = 'Left' then 1 END) * 1.0 / count(*) * 100 as churn_rate_prc
from patient_activity_table
group by revenue_tier
order by 2 desc;

-- Question 11: Which insurance group visits the hopsital most frequently?
select insurance_type, sum(visits_last_year) as visits
from patients_table p JOIN patient_activity_table a
on p.patient_id = a.patient_id
group by insurance_type
order by 2 desc;

-- Question 12 (Part 1): What demographic group has the MOST missed appointments? (Age)
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

-- Question 12 (Part 2): What demographic group has the MOST missed appointments? (Gender)
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

-- Question 12 (Part 3): What demographic group has the MOST missed appointments? (Insurance)
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

-- Question 13: Is satisfaction higher for patients who visit more often?
select 
case 
when visits_last_year between 0 and 9 then 'Fewer vists'
when visits_last_year between 10 and 19 then 'Frequent visits'
end as visits,
round(avg(satisfaction_score),2) as avg_satisfaction
from patient_activity_table
group by visits
order by 2 desc;