CREATE DATABASE hr_analytics;
USE hr_analytics;

select * from hr_raw; 

SELECT DISTINCT Department FROM hr_raw;
SELECT DISTINCT JobRole FROM hr_raw;
SELECT DISTINCT EducationField FROM hr_raw;
SELECT DISTINCT BusinessTravel FROM hr_raw;
SELECT DISTINCT MaritalStatus FROM hr_raw;
SELECT DISTINCT Gender FROM hr_raw;

---------------------------------------------------------------------------------------------------------------------------

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE
);

INSERT INTO departments (department_name)
SELECT DISTINCT Department
FROM hr_raw;

select * from departments;

---------------------------------------------------------------------------------------------------------------------------

CREATE TABLE job_roles (
    job_role_id INT AUTO_INCREMENT PRIMARY KEY,
    job_role_name VARCHAR(100) UNIQUE
);

INSERT INTO job_roles (job_role_name)
SELECT DISTINCT JobRole
FROM hr_raw;

select * from job_roles;

-------------------------------------------------------------------------------------------------------------------

CREATE TABLE education_fields (
    education_field_id INT AUTO_INCREMENT PRIMARY KEY,
    education_field_name VARCHAR(100) UNIQUE
);

INSERT INTO education_fields (education_field_name)
SELECT DISTINCT EducationField
FROM hr_raw;

select * from education_fields;

----------------------------------------------------------------------------------------------------------------------

ALTER TABLE hr_raw
 rename COLUMN employee_id to EmployeeID;
 
 
ALTER TABLE hr_raw
 rename COLUMN ï»¿Age to Age;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    marital_status VARCHAR(20),
    education INT,
    education_field_id INT,
    FOREIGN KEY (education_field_id) 
        REFERENCES education_fields(education_field_id)
);

INSERT INTO employees 
(employee_id, age, gender, marital_status, education, education_field_id)
SELECT 
    hr.EmployeeID,
    hr.Age,
    hr.Gender,
    hr.MaritalStatus,
    hr.Education,
    ef.education_field_id
FROM hr_raw hr
JOIN education_fields ef
ON hr.EducationField = ef.education_field_name;

select * from employees;

-------------------------------------------------------------------------------------------------------------------------

CREATE TABLE job_details (
    employee_id INT,
    department_id INT,
    job_role_id INT,
    job_level INT,
    business_travel VARCHAR(50),
    overtime VARCHAR(10),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (job_role_id) REFERENCES job_roles(job_role_id)
);

INSERT INTO job_details
SELECT 
    hr.EmployeeID,
    d.department_id,
    jr.job_role_id,
    hr.JobLevel,
    hr.BusinessTravel,
    hr.OverTime
FROM hr_raw hr
JOIN departments d 
    ON hr.Department = d.department_name
JOIN job_roles jr 
    ON hr.JobRole = jr.job_role_name;
    
select * from job_details;

----------------------------------------------------------------------------------------------------------------------

CREATE TABLE salary_details (
    employee_id INT,
    monthly_income DECIMAL(10,2),
    daily_rate DECIMAL(10,2),
    hourly_rate DECIMAL(10,2),
    monthly_rate DECIMAL(10,2),
    percent_salary_hike DECIMAL(5,2),
    stock_option_level INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO salary_details
SELECT EmployeeID, MonthlyIncome, DailyRate, HourlyRate, 
       MonthlyRate, PercentSalaryHike, StockOptionLevel
FROM hr_raw;

select * from salary_details;

----------------------------------------------------------------------------------------------------------------

CREATE TABLE performance_details (
    employee_id INT,
    performance_rating INT,
    job_satisfaction INT,
    environment_satisfaction INT,
    work_life_balance INT,
    relationship_satisfaction INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO performance_details
SELECT EmployeeID, PerformanceRating, JobSatisfaction,
       EnvironmentSatisfaction, WorkLifeBalance,
       RelationshipSatisfaction
FROM hr_raw;

select * from performance_details;

----------------------------------------------------------------------------------------------------------------------

CREATE TABLE experience_details (
    employee_id INT,
    total_working_years INT,
    years_at_company INT,
    years_in_current_role INT,
    years_since_last_promotion INT,
    years_with_curr_manager INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO experience_details
SELECT EmployeeID, TotalWorkingYears, YearsAtCompany,
       YearsInCurrentRole, YearsSinceLastPromotion,
       YearsWithCurrManager
FROM hr_raw;

select * from experience_details;

-----------------------------------------------------------------------------------------------------------------------

CREATE TABLE attrition (
    employee_id INT,
    attrition_status VARCHAR(10),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO attrition
SELECT EmployeeID, Attrition
FROM hr_raw;

select * from attrition;

------------------------------------------------------------------------------------------------------------------------

show tables;


SELECT e.employee_id,
       d.department_name,
       s.monthly_income,
       a.attrition_status
FROM employees e
JOIN job_details jd 
    ON e.employee_id = jd.employee_id
JOIN departments d 
    ON jd.department_id = d.department_id
JOIN salary_details s 
    ON e.employee_id = s.employee_id
JOIN attrition a
    ON e.employee_id = a.employee_id
LIMIT 10;

DROP TABLE hr_raw;

-------------------------------------------------------------------------------------------------------------------

CREATE VIEW hr_master_view AS
SELECT 
    e.employee_id,
    e.age,
    e.gender,
    e.marital_status,
    ef.education_field_name,
    d.department_name,
    jr.job_role_name,
    jd.job_level,
    s.monthly_income,
    p.performance_rating,
    ex.total_working_years,
    a.attrition_status
FROM employees e
JOIN education_fields ef 
    ON e.education_field_id = ef.education_field_id
JOIN job_details jd 
    ON e.employee_id = jd.employee_id
JOIN departments d 
    ON jd.department_id = d.department_id
JOIN job_roles jr 
    ON jd.job_role_id = jr.job_role_id
JOIN salary_details s 
    ON e.employee_id = s.employee_id
JOIN performance_details p 
    ON e.employee_id = p.employee_id
JOIN experience_details ex 
    ON e.employee_id = ex.employee_id
JOIN attrition a 
    ON e.employee_id = a.employee_id;
    
SELECT * FROM hr_master_view LIMIT 10;