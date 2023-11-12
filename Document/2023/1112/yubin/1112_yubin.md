> 1105 김유빈 디비디비딥 정리

# 3장. SQL의 조건 분기

> 구문에서 식으로

## Union을 사용한 쓸데없이 긴 표현

UNION은 외부적으로 하나의 SQL 구문을 실행하는 것처럼 보이지만, 내부적으로는 여러 개의 SELECT 구문을 실행하는 실행 계획으로 해석된다. -> 따라서 테이블에 접근하는 횟수가 많아지고, I/O 비용이 크게 증가한다.
UNION을 사용해도 좋을지 여부는 신중히 검토해야한다.

```sql
SELECT item_name, year, price_tax_ex AS price
	FROM Items
 WHERE year <= 2001
UNION ALL
SELECT item_name, year, price_tax_ex AS price
	FROM Items
 WHERE year >= 2002;
```

1. 쓸데없이 길다: 거의 같은 쿼리를 두 번이나 실행
2. 성능적으로 문제가 된다.
   UNION을 사용 했을 때의 실행 계획에서 Item 테이블에 2회 접근한다.
   -> TABLE ACCESS FULL(index없이 테이블을 모두 스캔하는 것)도 2번 발생한다. 읽어오는 비용도 테이블의 크기에 따라 선형적으로 증가하게 된다.

UNION은 간단하게 레코드를 합칠 수 있다는 점에서 편리하지만, 물리 자원과 SQL의 성능을 나쁘게 만드므로 정확한 판단 하에 사용해야 한다.
**WHERE 구에서 조건 분기를 하는 사람은 초보자** -> SELECT구 만으로 조건 분기를 하자.

개선된 쿼리

```sql
SELECT item_name, year,
CASE WHEN year <= 2001 THEN price_tax_ex
WHEN year >= 2002 THEN price_tax_in END AS price
FROM Items;
```

UNION을 사용한 쿼리와 같은 결과를 출력하지만 성능적으로 CASE를 쓴 쿼리가 훨씬 좋다.
Items 테이블 접근 횟수 : 1회
TABLE ACCESS FULL : 1회
-> UNION을 사용한 구문보다 성능이 2배 좋아졌으며 sql 구문 자체의 가독성도 크게 증가.

SQL구문의 성능이 좋은지 나쁜지는 반드시 실행 계획 레벨에서 판단해야. - SQL구문에는 어떻게 데이터를 검색할지 나타내는 접근 경로가 쓰여 있지 않기 때문.

UNION의 기본 단위는 SELECT '구문'을 기본 단위로 함. 이는 아직 절차 지향형의 발상을 벗어나지 못한 방법이다. 반면, CASE의 기본 단위는 '식'이다. 이렇게 '구문'에서 '식'으로 사고를 변경하는 것이 SQL을 마스터하는 열쇠 중 하나이다.

## 집계와 조건 분기

### 1. 집계 대상으로 조건 분기

아래 인구 테이블에서 성별 1은 남성, 2는 여성을 의미. 지역에 따른 남 / 녀 인구의 합을 추출하고 싶을때

| 지역 이름 | 성별 | 인구 |
| --------- | ---- | ---- |
| 성남      | 1    | 60   |
| 성남      | 2    | 40   |
| 수원      | 1    | 30   |
| 수원      | 2    | 40   |
| 광명      | 1    | 50   |
| 광명      | 2    | 60   |
| 일산      | 1    | 20   |
| 일산      | 2    | 15   |

### UNION을 사용한 방법

```sql
SELECT prefecture, SUM(pop_men) AS pop_men, SUM(pop_wom) AS pop_wom
  FROM ( SELECT prefecture, pop AS pop_men, null AS pop_wom
      FROM Population
      WHERE sex = '1'
      UNION
    SELECT prefecture, null AS pop_men, pop AS pop_wom
      FROM Population
    WHERE sex = '2'
GROUP BY prefecture;
```

남성의 인구를 지역별로 구하고, 여성의 인구를 지역별로 구한 뒤 UNION을 활용해 합치는 방법은 절차지향적인 방식이다.
또한 테이블에 접근하는 횟수가 늘어나 성능적으로 문제가 됨을 앞에서 학습했다.

CASE식을 집약 함수 내부에 포함시켜 해결할 수 있다.

```sql
SELECT prefecture,
    SUM(CASE WHEN sex='1' THEN pop ELSE 0 END) AS pop_men,
    SUM(CASE WHEN sex='2' THEN pop ELSE 0 END) AS pop_wom
  FROM Population
  GROUP BY prefecture;
```

외관이 간단해질 뿐만 아니라 성능도 캐시를 고려하지 않았을 때 2배로 증가한다.

'WHERE'구와 'HAVING'구에서 조건 분기를 하는 사람은 초보자이다.

### 1. 집약 결과로 조건 분기

직원과 직원이 소속된 팀을 관리하는 테이블
| 직원ID | 팀ID | 직원이름 | 팀 |
|--------|------|----------|------------|
| 201 | 1 | Joe | 상품기획 |
| 201 | 2 | Joe | 개발 |
| 201 | 3 | Joe | 영업 |
| 202 | 2 | Jim | 개발 |
| 203 | 3 | Carl | 영업 |
| 204 | 1 | Bree | 상품기획 |
| 204 | 2 | Bree | 개발 |
| 204 | 3 | Bree | 영업 |
| 204 | 4 | Bree | 관리 |
| 205 | 1 | Kim | 상품기획 |
| 205 | 2 | Kim | 개발 |

위 테이블을 UNION으로 조건 분기한 코드

```
SELECT emp_name, MAX(team) AS team
FROM Employees
GROUP BY emp_name
HAVING count(_)=1
UNION
SELECT emp_name, '2개를 겸무' AS team
FROM Employees
GROUP BY emp_name
HAVING count(_)=2
UNION
SELECT emp_name, '3개 이상을 겸무' AS team
FROM Employees
GROUP BY emp_name
HAVING count(\*)>=3;
```

3번의 TABLE ACCESS FULL이 발생한다. emp_name으로 그룹화한 집합의 개수를 구하므로 HAVING 구를 사용한다.

이를 CASE 식을 사용할 경우, 아래와 같다.

```
SELECT emp*name,
CASE WHEN COUNT(*)=1 THEN MAX(team)
WHEN COUNT(\_)=2 THEN '2개를 겸무'
WHEN COUNT(\*)=3 THEN '3개 이상을 겸무'
END AS team
FROM Employees
GROUP BY emp_name;
```

이렇게 CASE 식을 사용하여 테이블 접근 비용을 3분의 1로 줄일 수 있다. 이는 집약 결과를 CASE식의 입력으로 사용했기 때문이다.
**HAVING 구에서 조건 분기를 하는 사람도 초보자**

## 그래도 UNION이 필요한 경우

### 1. UNION을 사용할 수밖에 없는 경우

여러 개의 서로 다른 테이블에서 검색한 결과를 머지하는 경우

```
SELECT col_1
FROM Table_A
WHERE col_2='A'
UNION
SELECT col_3
FROM Table_B
WHERE col_4='B'
```

### 2. UNION을 사용하는 것이 성능적으로 좋은 경우

이 경우는 인덱스와 관련된 경우이다. 테이블의 크기가 커 TABLE FULL SCAN보다 INDEX RANGE SCAN이 효율적일 경우 인덱스와 UNION 조합이 더 성능이 좋을 수 있다.

OR, IN 사용 시 WHERE 구문에서 해당 필드에 부여된 인덱스를 사용할 수 없다 -> 테이블이 크고 WHERE 조건으로 선택되는 레코드 수가 충분히 작다면 UNION이 더 빠르다.

## 절차 지향형과 선언형

조건 분기는 조건 분기를 위해 만들어진 CASE 식을 사용하는 것이 UNION을 사용하는 것보다 좋다.

- SQL 구문 내부에는 식(expression)을 작성 -> 선언적인 식에 적응 필요.
- 절차 지향형 세계에서 선언형 세계로 도약하는 것이 중요.

4장은 완벽히 정리하지 않아 제외했습니다!

# Leet Code 풀이

### 대여 기록이 존재하는 자동차 리스트 구하기

[](https://school.programmers.co.kr/learn/courses/30/lessons/157341)

```
-- 수정 예정
SELECT DISTINCT CAR_ID FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY
WHERE CAR_ID IN (SELECT CAR_ID FROM CAR_RENTAL_COMPANY_CAR
WHERE CAR_TYPE = "세단") && (START_DATE BETWEEN DATE("2022-10-01") and DATE("2022-10-31"))
ORDER BY CAR_ID DESC
```