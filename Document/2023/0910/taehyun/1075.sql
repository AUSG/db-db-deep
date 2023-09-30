-- [ LeetCode ] 1075. Project Employees I

-- JOIN, GROUP BY 및 AVG 집계 함수를 사용한 풀이
SELECT
    Project.project_id,
    ROUND(AVG(Employee.experience_years), 2) AS average_years
FROM Project
JOIN Employee
ON Project.employee_id = Employee.employee_id
GROUP BY Project.project_id;
