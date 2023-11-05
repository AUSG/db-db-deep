# Write your MySQL query statement below
```sql
SELECT E.employee_id, E.name, F.reports_count, F.average_age
FROM Employees as E,
(SELECT reports_to as employee_id, count(employee_id) as reports_count, ROUND(avg(age),0) as average_age
FROM Employees
GROUP BY reports_to) as F
WHERE E.employee_id = F.employee_id
ORDER BY E.employee_id
```

### 풀이 방법
- Subquery
- reports_to로 그룹화함으로써, 지목을 받은 사람들(managers)의 정보를 담아냈다.

- 그 다음, Employees 테이블 내의 직원들 중 매니저 id와 동일한 직원들을 골라 알맞게 적어주었다.