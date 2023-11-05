## SQL 문제

### The Number of Employees Which Report to Each Employee

#### 풀이

```sql
Input: 
Employees table:
+-------------+---------+------------+-----+
| employee_id | name    | reports_to | age |
+-------------+---------+------------+-----+
| 9           | Hercy   | null       | 43  |
| 6           | Alice   | 9          | 41  |
| 4           | Bob     | 9          | 36  |
| 2           | Winston | null       | 37  |
+-------------+---------+------------+-----+

Output: 
+-------------+-------+---------------+-------------+
| employee_id | name  | reports_count | average_age |
+-------------+-------+---------------+-------------+
| 9           | Hercy | 2             | 39          |
+-------------+-------+---------------+-------------+
```

`Employees` 테이블에 대해서 셀프 조인을 해야한다

```sql
FROM Employees AS e1
JOIN Employees AS e2
ON e1.employee_id = e2.reports_to

| employee_id | name  | reporter | reporter_age |
| ----------- | ----- | -------- | ------------ |
| 9           | Hercy | 6        | 41           |
| 9           | Hercy | 4        | 36           |
```

이렇게 되면 reports_to가 null인 경우는 누락된다

이후, manager employee_id 별로 reporter가 몇 명인지, reporter_age의 평균을 구해야한다

이를 위해 manager employee_id 기준으로 Group by를 사용한다

```sql
SELECT 
	e1.employee_id AS employee_id, 
	e1.name AS name, 
	COUNT(e2.employee_id) AS reports_count, 
	ROUND(AVG(e2.age)) AS average_age
FROM Employees AS e1
JOIN Employees AS e2
ON e1.employee_id = e2.reports_to
GROUP BY e1.employee_id
ORDER BY e1.employee_id ASC
;
```

- Time complexity: O(n)
    - `n` 테이블의 행 수
    - 이는 쿼리가 각 행을 한 번씩 처리하여 각 매니저에 직접 보고하는 직원 수를 찾기 때문

정답은 맞지만 참 안 좋은 쿼리 같아서 윈도우 함수를 사용해보려했지만, 잘 안풀렸다…

정답 케이스를 찾아보니 다른 풀이들도 셀프 조인을 사용한 것을 확인해볼 수 있었다


### 1934. Confirmation Rate

```sql
Input: 
Signups table:
+---------+---------------------+
| user_id | time_stamp          |
+---------+---------------------+
| 3       | 2020-03-21 10:16:13 |
| 7       | 2020-01-04 13:57:59 |
| 2       | 2020-07-29 23:09:44 |
| 6       | 2020-12-09 10:39:37 |
+---------+---------------------+
Confirmations table:
+---------+---------------------+-----------+
| user_id | time_stamp          | action    |
+---------+---------------------+-----------+
| 3       | 2021-01-06 03:30:46 | timeout   |
| 3       | 2021-07-14 14:00:00 | timeout   |
| 7       | 2021-06-12 11:57:29 | confirmed |
| 7       | 2021-06-13 12:58:28 | confirmed |
| 7       | 2021-06-14 13:59:27 | confirmed |
| 2       | 2021-01-22 00:00:00 | confirmed |
| 2       | 2021-02-28 23:59:59 | timeout   |
+---------+---------------------+-----------+
Output: 
+---------+-------------------+
| user_id | confirmation_rate |
+---------+-------------------+
| 6       | 0.00              |
| 3       | 0.00              |
| 7       | 1.00              |
| 2       | 0.50              |
+---------+-------------------+
```

위 문제는 사용자의 Confirmation rate를 구하는 문제입니다.

이 때, Confirmation rate는 `'confirmed'` 메시지의 수를 요청된 확인 메시지의 총 수로 나눈 값입니다. 

아무런 Confirmation 메시지를 요청하지 않은 사용자의 확인 비율은 `0`입니다. 

Message의 종류는 2가지입니다.

```sql
confirmed, timeout
```

만약 사용자가 6개의 메세지를 보냈고 그 중, confirmed가 3개일 경우, Confirmation rate는 0.50입니다.

확인 비율을 **소수점 둘째 자리**까지 반올림하세요.

#### 풀이 아이디어

- 조인을 이용한 CTE 서브쿼리를 이용해서 단계를 나눠 진행
- 회원가입한 유저들 기준으로 confirmation 테이블을 조인
    
    ```sql
    SELECT S.user_id, C.action
    FROM 
    Signups S
    LEFT JOIN Confirmations C
    ON S.user_id = C.user_id
    
    | user_id | action    |
    | ------- | --------- |
    | 3       | timeout   |
    | 3       | timeout   |
    | 7       | confirmed |
    | 7       | confirmed |
    | 7       | confirmed |
    | 2       | timeout   |
    | 2       | confirmed |
    | 6       | null      |
    ```
    
- 지표를 산정해야하는 대상을 기준으로 2개의 테이블을 생성
    - 전체 유저들의 행 개수 = A
        
        ```sql
         SELECT user_id, COUNT(*) AS a_cnt
         FROM Dataset
         GROUP BY user_id
        
        | user_id | a_cnt |
        | ------- | ----- |
        | 3       | 2     |
        | 7       | 3     |
        | 2       | 2     |
        | 6       | 1     |
        ```
        
    - confirmed 된 유저들의 행 개수 = B
        
        ```sql
          SELECT user_id, COUNT(*) AS b_cnt
          FROM Dataset
          WHERE action = 'confirmed'
          GROUP BY user_id
        
        | user_id | b_cnt |
        | ------- | ----- |
        | 7       | 3     |
        | 2       | 1     |
        ```
        
- 위 테이블들에서 나온 값들을 이용해서 b_cnt/a_cnt 를 수행하여 확인 비율을 구해준다
    - 이 때, 6번 유저와 같은 경우는 null이 나오기 때문에 IFNULL을 통해 0으로 처리해준다
    - ROUND를 통해 확인 비율을 **소수점 둘째 자리**까지 반올림
        
        ```sql
        SELECT A.user_id, IFNULL(ROUND((b_cnt/a_cnt),2), 0) AS confirmation_rate
        FROM A
        LEFT JOIN B
        ON A.user_id = B.user_id
        ```
        

전체 쿼리는 아래와 같다.

```sql
WITH Dataset AS (
SELECT S.user_id, C.action
FROM 
Signups S
LEFT JOIN Confirmations C
ON S.user_id = C.user_id
),
A AS (
    SELECT user_id, COUNT(*) AS a_cnt
  FROM Dataset
  GROUP BY user_id
),
B AS
(
  SELECT user_id, COUNT(*) AS b_cnt
  FROM Dataset
  WHERE action = 'confirmed'
  GROUP BY user_id
)

SELECT A.user_id, IFNULL(ROUND((b_cnt/a_cnt),2), 0) AS confirmation_rate
FROM A
LEFT JOIN B
ON A.user_id = B.user_id
;
```

#### 쿼리 개선

```sql
WITH AggregatedConfirmations AS (
    SELECT 
        S.user_id,
        SUM(CASE WHEN C.action = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_count,
        COUNT(C.action) AS total_count
    FROM Signups S
    LEFT JOIN Confirmations C ON S.user_id = C.user_id
    GROUP BY S.user_id
)

SELECT 
    user_id, 
    IFNULL(ROUND(confirmed_count / total_count, 2), 0) AS confirmation_rate
FROM AggregatedConfirmations
ORDER BY user_id;
```

- CTE를 여러 번 거치는 것이 아닌 단일 CTE 안의 조인 과정에서 확인된 메시지 수와 전체 메시지 수를 집계
    
    ```sql
    WITH Dataset AS (
        SELECT 
            S.user_id,
            SUM(CASE WHEN C.action = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_count,
            COUNT(C.action) AS total_count
        FROM Signups S
        LEFT JOIN Confirmations C ON S.user_id = C.user_id
        GROUP BY S.user_id
    )
    
    | user_id | confirmed_count | total_count |
    | ------- | --------------- | ----------- |
    | 3       | 0               | 2           |
    | 7       | 3               | 3           |
    | 2       | 1               | 2           |
    | 6       | 0               | 0           |
    ```
    
- 그 후, 과정은 위의 풀이와 동일합니다.
    
    ```sql
    SELECT 
        user_id, 
        IFNULL(ROUND(confirmed_count / total_count, 2), 0) AS confirmation_rate
    FROM Dataset
    ORDER BY user_id;
    ```
    

- 여기서 `IFNULL`을 써도, **`COALESCE`**를 써도 상관 없다
- IFNULL은 MySQL에만 제공되는 함수인 반면, COALESCE 함수는 표준 SQL 함수
    1. **`IFNULL`**은 두 개의 인수만 취함. 첫 번째 인수가 null인 경우 두 번째 인수를 반환.
    2. **`COALESCE`**는 두 개 이상의 인수를 취할 수 있다. 제공된 인수 중에서 첫 번째 non-null 값을 반환
    3. **동작 방식**:
        - **`IFNULL`**과 **`COALESCE`**는 기본적으로 같은 동작을 수행하지만,
            - **`COALESCE`**는 인수 중 첫 번째 `non-null` 값을 반환하는 절차적 **`CASE`** 문.
        - 따라서 **`COALESCE`**는 본질적으로 다양한 인수 중에서 첫 번째 non-null 값을 찾는 데 사용.
    4. **사용 예제**:
        - **`IFNULL(column_name, 'default_value')`**
            - **`column_name`**이 null이면 'default_value'를 반환합니다.
        - **`COALESCE(column_name1, column_name2,.., 'default_value')`**
            - 칼럼2가 NULL이 아니면 칼럼2를 반환하고 칼럼1과 칼럼2 모두 NULL이면 칼럼3을 반환.
            - 모든 제공된 컬럼이 null이면 'default_value'를 반환.