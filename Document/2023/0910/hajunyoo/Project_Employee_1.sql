# Write your MySQL query statement below
WITH dataset AS (
    SELECT p.project_id, e.experience_years
    FROM Project p
    JOIN Employee e ON p.employee_id = e.employee_id
)

SELECT project_id, ROUND(AVG(experience_years), 2) AS average_years
FROM dataset
GROUP BY 1