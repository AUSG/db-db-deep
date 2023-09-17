# 디비 디비 딥(DB DB Deep) 스터디 2회차

## [ 데이터베이스 첫걸음 ] 7장 트랜잭션과 동시성 제어 - 복수의 쿼리 통합

### 

## [ 데이터베이스 첫걸음 ] 8장 테이블 설계의 기초 - 테이블의 개념과 정규형

### 

## [ Programmers ] 문제 풀이

### 입양 시각 구하기 (2)

#### 풀이

아래와 같이 공통 테이블 표현식(Common Table Expression, CTE)의 재귀적(Recursive) 사용을 통해 문제를 해결할 수 있다. 이를 통해 0부터 23까지 `UNION ALL` 키워드를 반복하지 않더라도 쉽게 임시 테이블을 생성할 수 있다.

```SQL
WITH RECURSIVE cte (HOUR) AS (
    SELECT 0 AS HOUR
    UNION ALL
    SELECT HOUR + 1 AS HOUR
    FROM cte
    WHERE HOUR < 23
)

SELECT
    cte.HOUR AS HOUR,
    COUNT(ANIMAL_OUTS.ANIMAL_ID) AS COUNT
FROM cte
LEFT JOIN ANIMAL_OUTS
ON cte.HOUR = HOUR(ANIMAL_OUTS.DATETIME)
GROUP BY cte.HOUR
ORDER BY cte.HOUR ASC;
```

### 즐겨찾기가 가장 많은 식당 정보 출력하기

#### 풀이

문제를 풀기 전 문제 조건에 동일한 `FOOD_TYPE` 컬럼 값을 가진 데이터 중에 동일한 `FAVORITES` 값을 가진 데이터가 존재하지 않는다는 조건이 없기 때문에 즐겨찾기의 수가 동일한 식당이 여러 곳일 경우에 대한 예외 처리를 고민해봐야 한다. 그러나 이런 예외 처리에 대한 안내 또한 별도로 없었기에 궁극적으로는 가장 많은 즐겨찾기 수를 보유한 식당은 고유하게 존재한다고 가정하고 문제를 풀게 되었다.

해당 문제는 특정 컬럼을 기준으로 그룹을 만든 뒤에 집계를 내어 문제를 해결하면 될 것으로 판단된다. 그러나 단순히 `GROUP BY` 구와 함께 `MAX` 집계 함수를 사용하여 문제를 풀이하면 문제를 해결할 수 없다.

아래와 같이 쿼리를 실행할 경우 비집계 컬럼인 `REST_ID` 및 `REST_NAME` 필드의 경우 임의의 값을 선정하게 되기 때문에 오류가 발생한다. Programmers의 경우 `sql_mode` 시스템 변수 값이 아무 것도 저장되어 있지 않기 때문에 오류가 발생하지는 않지만 결국 무작위 값을 가져오는 것은 똑같기 때문에 오답 처리가 된다.

```SQL
SELECT
    FOOD_TYPE,
    REST_ID,
    REST_NAME,
    MAX(FAVORITES) AS FAVORITES
FROM REST_INFO
GROUP BY FOOD_TYPE
ORDER BY FOOD_TYPE DESC;
```

따라서 아래와 같이 중첩 서브쿼리(Nested Subquery)면서 동시에 다중열 서브쿼리(Multiple-column Subquery) 서브쿼리를 사용하여 문제를 풀 수 있다.

```SQL
SELECT
    FOOD_TYPE,
    REST_ID,
    REST_NAME,
    FAVORITES
FROM REST_INFO
WHERE (FOOD_TYPE, FAVORITES) IN (
    SELECT
        FOOD_TYPE,
        MAX(FAVORITES) AS MAXIMUM_FAVORITES
    FROM REST_INFO
    GROUP BY FOOD_TYPE
)
ORDER BY FOOD_TYPE DESC;
```

한 가지 주의할 점은 `IN` 연산자의 경우 기본 키(Primary Key, PK)를 대상으로 하더라도 MySQL 버전에 따라 옵티마이저(Optimizer)가 최적화 하지 못할 수 있다는 점이다. 예를 들어, `world` 데이터베이스의 `countrylanguage` 테이블에서 특정 튜플 값을 가지는 데이터만 추출하는 상황을 생각해보자.

먼저 아래와 같이 `IN` 연산자를 `WHERE` 구에 사용하여 조회할 수 있다.

```SQL
SELECT
    CountryCode,
    Language
FROM countrylanguage
WHERE (CountryCode, Language) IN (
    ('ZMB', 'Bemba'),
    ('ZMB', 'Chewa'),
    ('ZMB', 'Lozi'),
    ('ZMB', 'test')
);
```

해당 쿼리의 실행 계획을 MySQL 5.7 버전에서 출력해보면 아래와 같다. 여기서 중요한 점은 `type` 필드인데, `index` 값을 출력했다는 것을 알 수 있다. 이는 다시 말해 인덱스 풀 스캔(Index Full Scan)을 한다는 것을 의미하며, 인덱스 테이블을 스캔할 뿐 통상적인 풀 스캔과 마찬가지로 인덱스 테이블을 전체 한 번 조회해야 하는 것을 의미한다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: countrylanguage
   partitions: NULL
         type: index
possible_keys: PRIMARY,CountryCode
          key: CountryCode
      key_len: 12
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using where; Using index
```

MySQL 8.0 버전 이상부터는 아래와 같은 실행 계획을 출력한다. 5.7 버전과 달리 `range` 값을 출력했다는 것을 알 수 있다. 이는 곧 인덱스 레인지 스캔(Index Range Scan)을 한다는 것을 의미하며, 인덱스를 하나의 값이 아닌 범위로 검색한다는 것을 의미한다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: countrylanguage
   partitions: NULL
         type: range
possible_keys: PRIMARY,CountryCode
          key: CountryCode
      key_len: 132
          ref: NULL
         rows: 4
     filtered: 100.00
        Extra: Using where; Using index
```


반대로 `IN` 연산자가 아닌 비교 연산자를 나열하여 조회할 수 있다.

```SQL
SELECT
    CountryCode,
    Language
FROM countrylanguage
WHERE (
    CountryCode = 'ZMB'
    AND (
        Language = 'Bemba'
        OR
        Language = 'Chewa'
        OR
        Language = 'Lozi'
        OR
        Language = 'test'
    )
);
```

해당 쿼리의 실행 계획을 MySQL 5.7 버전에서 출력해보면 아래와 같다. `type` 필드의 값이 이전 `IN` 연산자를 사용했을 때와 달리 `ref` 값을 출력하고 있다는 것을 알 수 있다. `ref` 값은 동등 비교를 의미하며, 결국 동등한 조건으로만 비교를 하기 때문에 성능이 좋은 레코드 조회 방법 중 하나이다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: countrylanguage
   partitions: NULL
         type: ref
possible_keys: PRIMARY,CountryCode
          key: CountryCode
      key_len: 12
          ref: const
         rows: 4
     filtered: 100.00
        Extra: Using where; Using index
```

MySQL 8.0 버전 이상부터는 아래와 같은 실행 계획을 출력하며 앞서 `IN` 연산자를 사용한 경우와 동일하게 `range` 값을 출력하고 있다는 것을 알 수 있다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: countrylanguage
   partitions: NULL
         type: range
possible_keys: PRIMARY,CountryCode
          key: CountryCode
      key_len: 132
          ref: NULL
         rows: 4
     filtered: 100.00
        Extra: Using where; Using index
```

`IN` 연산자를 사용하는 형태는 크게 두 가지다.

먼저 상수가 사용된 경우다. 상수가 사용된 경우 MySQL 8.0 이전 버전까지는 앞서 살펴봤던 MySQL 5.7 버전의 실행 계획에서 `index` 값이 출력된 것처럼 항상 풀 테이블 스캔(Full Table Scan)을 하였다. 따라서 성능 문제를 해결하기 위해 쿼리를 분할하여 여러 번 실행하고는 했는데, MySQL 8.0 버전부터는 앞서 살펴봤던 실행 계획에서 `range` 값이 출력된 것처럼 인덱스를 최적으로 사용할 수 있게 개선됐다.

다음으로 서브쿼리가 사용된 경우다. MySQL 8.0 이전 버전의 경우 최적화가 상당히 불안했으나 MySQL 8.0 버전부터는 세미 조인의 최적화가 많이 안정화됐다. 여기서 세미 조인이란 한 테이블의 행이 다른 테이블의 행과 일치할 때 첫 번째 테이블의 행만 출력하는 것을 의미한다. 세미 조인을 구현하기 위해 보통 `IN` 연산자 또는 `EXISTS` 연산자를 사용한다.

결론적으로 `IN` 연산자를 사용할 때는 상수가 사용된 경우와 서브쿼리가 사용된 경우를 고려하여 서브쿼리의 경우 최적화에 어려움이 있기 때문에 여러 고민이 필요하다는 점을 인지해야 하고, MySQL 8.0 버전부터 `IN` 연산자에 대한 최적화 작업이 많이 개선되었기 때문에 MySQL 버전 또한 확인할 필요가 있다.

#### 기타

`NOT IN` 연산자의 경우 동등이 아닌 부정형 비교여서 인덱스를 이용해 처리 범위를 줄이는 조건으로는 사용할 수 없기 때문에 실행 계획에서 인덱스 풀 스캔인 `index` 값이 출력 된다. 가끔 인덱스 레인지 스캔인 `range` 값으로 출력되는 경우도 있는데, 이는 InnoDB 테이블에서 기본 키가 클러스터링 키이기 때문일 뿐 실제 `IN` 연산자와 같이 효율적으로 실행된다는 것을 의미하지는 않는다.

예를 들어 앞서 실행한 쿼리의 `IN` 연산자를 `NOT IN` 연산자로 변경하여 MySQL 8.0 버전에서 실행한다고 가정해보자.

```SQL
SELECT
    CountryCode,
    Language
FROM countrylanguage
WHERE (CountryCode, Language) NOT IN (
    ('ZMB', 'Bemba'),
    ('ZMB', 'Chewa'),
    ('ZMB', 'Lozi'),
    ('ZMB', 'test')
);
```

위 쿼리의 실행 계획을 출력해보면 아래와 같다. `type` 필드의 값이 앞서 `range` 값을 출력했던 것과 달리 `index` 값을 출력하고 있다는 것을 확인할 수 있다. 이는 다시 말해 `NOT IN` 연산자는 `IN` 연산자와 달리 부정형 비교 과정에서 인덱스를 이용해 처리 범위를 줄일 수 없기 때문에 인덱스 풀 스캔을 하게 된 것을 의미한다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: countrylanguage
   partitions: NULL
         type: index
possible_keys: PRIMARY,CountryCode
          key: CountryCode
      key_len: 12
          ref: NULL
         rows: 984
     filtered: 96.00
        Extra: Using where; Using index
```
