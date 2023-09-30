SELECT Project.project_id, round(avg(Employee.experience_years), 2) AS average_years from Project LEFT JOIN Employee On Project.employee_id = Employee.employee_id GROUP BY Project.project_id;