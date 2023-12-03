> 1203 김유빈 디비디비딥 정리

# 7장 서브쿼리

## 21강. 서브쿼리가 일으키는 폐해

### 1\. 서브쿼리의 문제점

서브쿼리의 성능적 문제는 실체적인 데이터를 저장하고 있지 않다는 점에서 기인

**연산 비용 추가**  
서브쿼리에 접근할 때마다 SELECT 구문을 실행해서 데이터를 만들어야. → 구문 실행에 발생하는 비용 추가. (복잡할수록 실행 비용 높아짐)

**데이터 I/O 비용 발생**  
연산 결과의 데이터양이 큰 경우 DBMS가 저장소에 있는 파일을 쓸 때도 존재. (ex. Microsoft SQL Server에서 서브쿼리 결과 tempdb에 저장) 이는 TEMP 탈락 현상의 일종. → 저장소 성능에 따라 접근 속도가 떨어진다.

**최적화를 받을 수 없음**  
서브쿼리로 만들어지는 데이터는 구조적으로 테이블과 차이가 없다. but 명시적 제약, 인덱스가 작성되어 있는 테이블과 달리 서브쿼리에는 메타 정보가 존재하지 않는다 → 옵티마이저가 쿼리를 해석하기 위해 필요한 정보를 서브쿼리에서는 얻을 수 없다.  
→ 내부적으로 복잡한 연산 수행 / 결과 크기가 큰 서브쿼리 사용시 성능 리스크를 고려해야.

**"해당 내용이 정말 서브쿼리를 사용하지 않으면 구현할 수 없는 것인가?"**

### 2\. 서브쿼리 의존증

고객의 구입 명세 정보를 저장하는 테이블(Receipts)에 순번(Seq) 필드는 오래전에 구입했을수록 낮은 값을 가진다.

이때 고객별 최소 순번을 구하는 상황을 가정하자. (고객들이 구매했던 가장 오래된 구입 이력을 찾는 것.)

```
user_id | seq | price
--------*-----*------
A       |   1|    500
B       |   5|    100
C       |  10|    600
```

_구하고자 하는 답_

처음 직면하는 문제점은 최소 순번이 고객마다 다르다는 것이다. 만약 구하고자 하는 최소값이 1이라는 비지니스 규칙이 있다면 seq = 1 조건을 통해 답을 도출할 수 있다. 하지만 예제는 이러한 규칙이 없으므로 동적으로 구해야 한다.

- **서브쿼리를 사용한 방법**  
  간단하게 고객들의 최소 순번 값을 저장하는 서브쿼리(R2)를 만들고, 기존의 Receipts 테이블과 결합하는 방법이 있다.이 방법은 간단하지만 두 가지의 단점을 가지고 있다.

```
SELECT R1.cust_id, R1.seq, R1.price
FROM Receipts R1
    INNER JOIN
    (SELECT cust_id, MIN(seq) AS min_seq
    	FROM Receipts
        GROUP BY cust_id) R2
    ON R1.cust_id=R2.cust_id
    AND R1.seq=R2.min_seq;
```

1\. 코드가 복잡해서 읽기 어렵다.  
2\. 성능이 떨어진다.

\- 서브쿼리는 대부분 일시적인 영역(메모리 또는 디스크)에 확보되므로 오버헤드가 생긴다.  
\- 서브쿼리는 인덱스 또는 제약 정보가 없기 때문에 최적화되지 못한다.  
\- 이 쿼리는 결합을 필요로 하기 때문에 비용이 높고 실행 계획 변동 리스크가 발생한다.  
\- Receipts 테이블에 스캔이 두 번 필요하다.

이는 실행 계획에서도 확인할 수 있다. Oracle과 PostgreSQL 모두 R1, R2 각각에 대해 스캔이 이루어지며, 결합(Hash Join)이 이루어진다. Receipts 테이블에 2회의 접근이 필요하다는 것이다.

**\- 상관 서브쿼리는 답이 될 수 없다**

```
SELECT user_id, seq, price
  FROM Receipts R1
WHERE seq = (SELECT MIN(seq)
              FROM Receipts R2
          WHERE R1.user_id = R2.userId);
```

상관 서브쿼리를 사용한 동치변환 방법

상관 서브쿼리를 사용하더라도 Receipts 테이블에 두 번 접근하게 된다.  
Receipts 테이블에 접근 1회와 기본 키의 인덱스 접근 1회가 필요하다. 결국 성능적인 장점이 없다.

**\- 윈도우 함수로 결합을 제거**  
일단 개선해야 하는 부분은 Receipts 테이블에 대한 접근을 1회로 줄이는 것이다. (SQL 튜닝에서 가장 중요하나 것이 I/O를 줄이는 것이다.) 접근을 줄이기 위해 ROW_NUMBER()함수를 아래와 같이 사용한다.

```
SELECT cust_id, seq, price
    FROM (SELECT cust_id, seq, price,
        ROW_NUMBER()
            OVER (PARTITION BY cust_id
                        ORDER BY seq) AS row_seq
           FROM Receipts ) WORK
    WHERE WORK.row_seq = 1;
```

ROW_NUMBER 함수로 각 사용자의 구매 이력에 번호를 붙이고 그 번호를 조건을 걸어 조회 하는 쿼리이다. 이 쿼리를 통해 Receipts 테이블에 한번만 접근하게 된다. (이전 seq 필드의 최솟값이 불확실해 쿼리를 한 번 더 사용해야 했던 문제 해결)

**\- 장기적 관점에서의 리스크 관리**  
최초의 쿼리와 상관 서브쿼리를 사용한 쿼리에 비해 윈도우 함수를 사용한 쿼리가 얼마나 성능이 좋은지는 여러 환경에 의해 단언하기 어렵다.

하지만 저장소의 I/O 양을 감소시키는 것이 SQL 튜닝의 가장 기본 원칙이다. 처음 사용한 쿼리와 비교해보면 결합을 제거했다. 따라서 단순 성능 향상뿐만 아니라 성능의 안정성 확보도 기대 가능하다.

결합을 사용한 쿼리는 두 개의 불안정 요소가 있다.

- 결합 알고리즘의 변동 리스크
- 환경 요인에 의한 지연 리스크(인덱스, 메모리, 매개변수 등)  
  상관 서브쿼리를 사용한 쿼리도 앞의 리스크에 해당된다.

**\- 알고리즘 변동 리스크**  
결합 알고리즘에는 크게 Nested Loops, Sort Merge, Hash 세 가지 종류가 있다. 어떤 것을 선택할지는 테이블의 크기 등을 고려하여 옵티마이저가 자동으로 결정한다. 레코드 수가 적은 테이블은 Nested Loops가 선택되기 쉽고, 큰 테이블의 경우에는 Sort Merge, Hash가 선택되기 쉽다.

따라서 처음에는 레코드가 적어 Nested Loops를 사용하다가 어느 역치를 넘어서면 실행계획에 변동이 생긴다. 이 경우 성능이 좋아지는 경우도 있겠지만, 나빠지는 경우도 많다.(실행 계획의 안정성을 확보하고 싶다면 Hint 구문을 사용하는 것이 좋다.) → 결합을 사용하면 이러한 변동 리스크를 안을 수 밖에 없다.

또한 데이터양이 많아지면서 Sort Merge, Hash에 필요한 메모리가 부족해지면 일시적으로 저장소를 사용한다. 그 시점에는 성능이 대폭 떨어진다. (TEMP 탈락 현상)

**\- 환경 요인에 의한 지연 리스크**  
Netsed Loops의 내부 테이블 결합 키에 인덱스가 존재하면 성능이 크게 개선된다. 또한 Sort Merge, Hash가 선택되어 TEMP 탈락이 발생하는 경우에 작업 메모리를 늘려주면 성능을 개선할 수 있다.

하지만 항상 결합 키에 인덱스가 존재하는 것이 아니고, 메모리 튜닝은 한정된 리소스 내부에서 트레이드 오프를 발생시킨다.  
즉 장기적으로 고려해야할 리스크를 늘리게 된다는 뜻이다.

따라서 옵티마이저가 이해하기 쉽게 쿼리를 단순하게 작성해야 한다.

꼭 기억할 두 가지 사항

- 실행 계획이 단순할수록 성능이 안정적이다.
- 엔지니어는 기능뿐만이 아니라 비기능적인 부분도 보장해야한다

![문서 12_1](https://github.com/yubin21/db-db-deep/assets/80163835/442534cf-7648-454c-a404-ca3e4479ca3c)

### 4\. 서브쿼리 의존증 - 응용편

Receipts 테이블에서 최댓값을 가지는 레코드와 price 필드의 최대, 최소 차이를 구해보자.

```
cust_id | diff
--------+-------
A       |  -200
B       |  -900
C       |   550
D       |     0
```

_구하고자 하는 답_

**- 다시 서브쿼리 의존증**

최솟값의 집합과 최댓값의 집합을 고객 ID를 키로 결합한다.

```
SELECT TMP_MIN.cust_id,
        TMP_MIN.price - TMP_MAX.price AS diff
FROM (SELECT R1.cust_id, R1.seq, R1.price
        FROM Receipts R1
            INNER JOIN
            (SELECT cust_id, MIN(seq) AS min_seq
            FROM Receipts
            GROUP BY cust_id) R2
        ON R1.cust_id=R2.cust_id
        AND R1.seq=R2.min_seq) TMP_MIN
        INNER JOIN
            (SELECT R3.cust_id, R3.seq, R3.price
            FROM Receipts R3
            INNER JOIN
                (SELECT cust_id, MAX(seq) AS min_seq
                FROM Receipts
                GROUP BY cust_id) R4
        ON R3.cust_id=R4.cust_id
        AND R3.seq=R4.min_seq) TMP_MAX
        ON TMP_MIN.cust_id=TMP_MAX.cust_id;
```

TMP_MIN: 최솟값의 집합, TMP_MAX: 최댓값의 집합이댜. 쿼리가 매우 길며 가독성도 좋지 않다. 서브쿼리 계층이 깊어서 서쿼리를 확인하기도 힘들다.이전의 쿼리를 두 번 붙여 넣어 테이블 접근 4회 발생한다.

**- 레코드간 비교에서도 결합은 불필요**

쿼리의 개선 포인트: 테이블 접근과 결합을 얼마나 줄일 수 있는가

```
SELECT cust_id,
        SUM(CASE WHEN min_seq=1 THEN price ELSE 0 END)
        - SUM(CASE WHEN max_seq=1 THEN price ELSE 0 END) AS diff
FROM (SELECT cust_id, price,
        ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY seq) AS min_seq,
        ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BYP seq DESC) AS max_seq
        FROM Receipts) WORK
WHERE WORK.min_seq=1
    OR WORK.max_seq=1
GROUP BY cust_id;
```

최댓값을 뽑고자 내림차순으로 정렬한다. → 내림차순 순번 max_seq가 1인 레코드가 seq의 최댓값을 가지고 있을 것이 보증된다. min_seq과 max_seq에서 가장 윗 번호인 1번 레코드만 가져와 차이를 구한다.

CASE 식으로 최솟값과 최댓값을 다른 필드에 할당한다. 테이블의 스캔 횟수가 1회가 되며 테이블의 크기가 커질수록 스캔 횟수가 적어지는 의미가 커진다.  
윈도우 함수로 정렬이 2회 발생(ORDER BY seq/ORDER BY seq DESC)하는 데에서 비용이 들지만, 결합을 반복하는 것보다 저렴/실행 계획의 안정성도 확보할 수 있다.

### 5. 서브쿼리는 정말 나쁠까?

- 쿼리를 처음 고민할 때 서브쿼리를 사용해 문제를 분할하면 생각하기 쉬워진다. **생각의 보조 도구**
- 집합을 세세한 부분으로 나누는 기술으로 bottom-up 타입의 사고방식과 좋은 상성을 가진다.
- 효율적인 코드가 되지는 않는다.

## 22강 서브쿼리 사용이 더 나은 경우

### 1. 결합과 집약 순서

결합할 때 사람이 직접 연산 순서를 명시해주면 성능 개선 가능

여러 사업소가 한 회사에 속하는 두개의 일대다 부모자식 관계 테이블이 존재한다.

문제: 회사(district)마다 주요 사업소의 총 직원수(sum_emp)를 구하기

1. 결합 후 집약하는 방법

```
SELECT C.co_cd, MAX(C.district),
        SUM(emp_nbr) AS sum_emp
FROM Companies C
    INNER JOIN
        Shops S
    ON C.co_cd=S.co_cd
WHERE main_flg='Y'
GROUP BY C.co_cd;
```

회사 테이블과 사업소 테이블의 결합 수행 후 결과에 GROUP BY를 적용해 집약한다.

2. 집약 후 결합하는 방법

```
SELECT C.co_cd, C.district, sum_emp
FROM Companies C
    INNER JOIN
        (SELECT co_cd, SUM(emp_nbr) AS sum_emp
        FROM Shops
        WHERE main_flg='Y'
        GROUP BY co_cd) CSUM
    ON C.co_cd=CSUM.co_cd;
```

사업소 테이블 집약해 직원수 구한 후 회사 테이블과 결합한다.

**- 겷합 대상 레코드 수**
결합 대상 레코드 수를 판단했을때, 위 두 방법은 성능적으로 큰 차이가 있다.

- 회사 테이블: 레코드 4개
- 사업소 테이블: 레코드 10개

- 회사 테이블: 레코드 4개
- 사업소 테이블(CSUM): 레토드 4개

CSUM 뷰가 회사 코드로 집약되어 4개로 압축되었다. → 첫번째보다 결합 비용을 낮출 수 있다.

이는 데이터가 많을수록 더 큰 차이를 보인다. 회사 테이블의 규모에 비해 사업소 테이블의 규모가 매우 크다면 결합 대상 레코드수를 집약하는 편이 I/O 비용을 줄일 수 있다. (비록 두번째 방법에서 집약 비용이 더 크긴하나, TEMP 탈락이 발생하지 않는 다면 괜찮은 트레이드 오프)

환경 역시 의존적이다. 테이블 레코드 개수뿐만 아니라 HW, MW, 결합 알고리즘 등 요소를 모두 포함 → 실제 개발시 요인을 고려할 것.

선택 지 중 하나로 "사전에 결합 레코드 수를 합축한다" 를 알면 좋다.

# 8장 SQL의 순서

## 23강 레코드에 순번 붙이기

### 1. 기본키가 한 개의 필드일 경우

**- 윈도우 함수를 사용**

```
SELECT student_id,
		ROW_NUMBER() OVER (ORDER BY student_id) AS Seq
		FROM Weights;
```

ROW_NUMBER 함수를 사용한다.

**- 상관 서브쿼리를 사용**

```
SELECT student_id,
	(SELECT COUNT(*)
		FROM Weight W2
		WHERE W2.student_id <= W1.student_id) AS Seq
	FROM Weights W1;
```

재귀 집합을 만들고 요소 수를 COUNT 함수로 센다. 기본키 student_id를 비교 키로 사용 → 재귀 집합의 요소가 한 개씩 증가한다. (순번 생성시 자주 사용하는 트릭)

기능은 동일하지만 첫번째 방법의 성능이 좋다. 스캔 횟수 1회 / 2회

### 2. 기본 키가 여러 개의 필드로 구성되는 경우

기본 키가 두 개인 경우의 테이블
**- 윈도우 함수를 사용**

```
SELECT class, student_id,
        ROW_NUMBER() OVER (ORDER BY class, student_id) AS seq
    FROM Weights2;
```

**- 상관 서브쿼리를 사용**

```
SELECT class, student_id,
        (SELECT COUNT(*)
        FROM Weights2 W2
        WHERE (W2.class, W2.student_id) <= (W1.class, W1.student_id) ) AS seq
    FROM Weights2 W1;
```

**다중 필드** 비교하기(문자, 숫자, 3개 비교, 기본 키 인덱스도 사용 가능)

**- 그룹마다 순번을 붙이는 경우**

테이블을 그룹으로 나누고 그룹마다 내부 레코드에 순번을 붙인다.

**- 윈도우 함수를 사용**

```
   SELECT class, student_id,
        ROW_NUMBER() OVER(PARTITION BY class ORDER BY student_id) AS Seq
    FROM Weight2
```

class 필드에 PARTITION BY 를 적용한다.

**- 상관서브쿼리를 사용**

```
SELECT class, student_id,
        (SELECT COUNT(*)
        FROM Weights2 W2
        WHERE W2.class = W1.class AND W2.student_id <= W1.student_id) AS seq
    FROM Weights2 W1;
```

### 4. 순번과 갱신

검색이 아닌 갱신에서 순번을 매기는 방법 - 테이블에 순번 필드 (seq)를 만들고, 순번을 갱신하는 UPDATE 구문을 만든다.

**-윈도우 함수를 사용**

```
UPDATE Weights3
    SET seq = (SELECT seq
    FROM ( SELECT class, student_id,
            ROW_NUMBER() OVER (PARTITION BY class ORDER BY student_id) AS seq
            FROM Weights3) SeqTbl
    WHERE Weights3.class = SeqTbl.class
        AND Weights3.student_id = SeqTbl.student_id);
```

SeqTbl라는 서브쿼리로 테이블을 만들어 class 그룹마다 순번 매긴 값을 seq 컬럼에 업데이트한다.

**- 상관 서브쿼리를 사용**

```
UPDATE Weights3
SET seq = (SELECT COUNT(*)
        FROM Weights3 W2
        WHERE W2.class = Weights3.class AND W2.student_id <= Weights3.student_id);
```

## 24강. 레코드에 순번 붙이기 응용

순번의 성질 **연속성**, **유일성**을 이용하여 다양한 테크닉을 사용할 수 있다.

### 1. 중앙값 구하기

중앙값: 숫자를 정렬하고 양쪽 끝부터 수를 셀 때 정중앙에 오는 값, 평균값에 비해 outlier에 영향 받지 않는다는 장점이 존재한다. 단순 평균(mean)과 다르게 아웃라이어에 영향을 받지 않는다.

\+ 중앙값 구하는 방법

레코드 개수가 홀수일 때: 중앙의 값을 사용  
레코드 개수가 짝수일 때: 중앙의 두 값을 평균내어 사용

**- 집합 지향적 방법**

```
SELECT AVG(weight)
FROM (SELECT W1.weight
        FROM Weights W1, Weights w2
        GROUP BY W1.weight
        HAVING SUM(CASE WHEN W2.weight>=W1.weight THEN 1 ELSE 0 END) >= COUNT(*)/2
        AND SUM(CASE WHEN W2.weight<=W1.weight THEN 1 ELSE 0 END) >= COUNT(*)/2 ) TMP;
```

테이블을 상위 집합과 하위 집합으로 분할하고 공통 부분을 검색하는 방법이다. 집합 지향적인 발상에 기반한 _SQL스러운_ 방법이다.
![문서 13_1](https://github.com/yubin21/db-db-deep/assets/80163835/07046853-9daf-4bbd-ae46-8e816908923b)

1. 코드가 복잡해서 무엇을 하고 있는 것인지 한 번에 이해하기 어렵다.
2. 자기 **결합**(w1과 w2간)을 수행하여 성능이 나쁘다.

**- 절차 지향적 방법 1 - 세계의 중심을 향해**

sql에서 자연수의 특징을 활용하면 ‘양쪽 끝부터 숫자 세기’를 할 수 있다

```
SELECT AVG(weight) AS median
FROM (SELECT weight,
        ROW_NUMBER() OVER (ORDER BY weight ASC, student_id ASC) AS hi,
        ROW_NUMBER() OVER (ORDER BY weight DESC, student_id DESC) AS lo
        FROM Weights) TMP
WHERE hi IN (lo, lo+1, lo-1);
```

만약 홀수일 경우 hi=lo가 될 것이고 짝수일 경우 hi 값은 lo-1, lo+1 중 하나가 될 것이므로 IN 연산자로 한꺼번에 비교한다. RANK 또는 DENSE_RANK를 사용해서는 안된다. 순위가 겹치거나 빌 수 있다.  
테이블 접근 1회로 감소, 대신 정렬이 2회로 늘었다. ROW_NUMBER에서 사용하는 정렬이 오름/내림차순 2개라서 그렇다.

주의 1) RANK, DENSE_RANK 대신 ROW_NUMBER 함수를 사용해야 레코드 집합에 자연수 할당해서 연속성과 유일성 가질 수 있음  
주의 2) ORDER BY 정렬 키에 weight 뿐만 아니라 student_id도 포함해야 정확한 결과 나옴

집합 지향적 방법과 비교할 때 **결합이 제거**되었고 **정렬이 1회 늘어**났으므로 성능 개선되었다고 볼 수 있다.
![문서 13_4](https://github.com/yubin21/db-db-deep/assets/80163835/6c7ec4ef-d7f7-4966-abf8-6f59b3962dcc)

**- 절차 지향적 방법 2 - 2빼기 1은 1**
성능적으로 개선하기

```
SELECT AVG(weight) AS median
FROM (SELECT weight,
        2 * ROW_NUMBER() OVER (ORDER BY weight) - COUNT(*) OVER() AS diff
        FROM Weights) TMP
WHERE diff BETWEEN 0 AND 2;
```

ROW_NUMBER() == (모든 레코드 개수의 절반±1)이 될 때 중간 값이라고 볼 수 있다.

절차 지향적 방법 (1)과 비교할 때 **정렬이 1회 줄어들었다.** 이 방법이 SQL 표준으로 중앙값을 구하는 가장 빠른 방법이다.

### 2. 순번을 사용한 테이블 분할

테이블을 여러 개의 그룹으로 분할하는 문제

**- 단절 구간 찾기**
비어있는 숫자를 다음처럼 출력하기

```
gap_start ~ gap_end
--------- - -------
        2 ~       2
        5 ~       6
       10 ~      11
```

**- 집합 지향적 방법 - 집합의 경계선**

```
SELECT (N1.num+1) AS gap_start,
        '~',
        (MIN*N2.num)-1) AS gap_end
FROM Numbers N1 INNER JOIN Numbers N2 ON N2.num > N1.num
GROUP BY N1.num
HAVING (N1.num+1) < MIN(N2.num);
```

N2.num을 사용해 현재 레코드 값 N1.num 보다 큰 숫자의 집합을 조건으로 지정한다.

min(N2.num)으로 N1.num의 바로 다음 숫자를 지정해 차이가 1보다 클 경우 비어있는 숫자로 간주한다.

집합 지향적 방법은 반드시 **자기 결합**을 사용하므로 리스크가 있다.

**- 절차 지향적 방법 - '다음 레코드'와 비교**
'현재 레코드와 다음 레코드를 비교해 차이가 1이 아니라면 사이에 비어있는 숫자가 있다'

```
SELECT num+1 AS gap_start,
        '~',
        (num+diff-1) AS gap_end
FROM (SELECT num,
            MAX(num) OVER (ORDER BY num ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING) - num
      FROM Numbers) TMP (num, diff)
WHERE diff <>1;
```

레코드의 순서를 활용하여 현재 레코드 값(num)과 다음 레코드의 숫자 차이(diff)를 비교한다.

테이블 접근 1회, 정렬 1회이며 정렬이 사용되지만 결합을 사용하지 않아 성능이 안정적이다.

### 3. 테이블에 존재하는 시퀀스 찾기

지금까지와는 반대로 테이블에 존재하는 수열을 그룹화한다.

**- 집합 지향적 방법 - 다시, 집합의 경계선**

```
SELECT MIN(num) AS low,
        '~'
        MAX(num) AS high
FROM (SELECT N1.num,
            COUNT(N2.num) - N1.num
        FROM Numbers N1 INNER JOIN Numbers N2 ON N2.num <= N1.num
        GROUP BY N1.num) N(num, gp)
GROUP BY gp;
```

자기 결합으로 num 필드 조합 만든 후 MIN, MAX 값으로 경계를 구하는 방식이다.
자기 결합 수행 후 극치 함수(MIN, MAX)로 집약을 수행한다.

**- 집합 지향적 방법 - 다시, 다음 레코드 하나와 비교**

```
SELECT low, high
FROM (SELECT low,
            CASE WHEN high IS NULL
            THEN MIN(high) OVER(ORDER BY seq
                                ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
            ELSE high END AS high
            FROM (SELECT CASE WHEN COALESCE(prev_diff,0) <>1
                            THEN num ELSE NULL END AS low,
                         CASE WHEN COALESCE(next_diff,0) <>1
                            THEN num ELSE NULL END AS high,
                         seq
                  FROM (SELECT num,
                              MAX(num) OVER (ORDER BY num ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING) - num AS next_diff,
                              num-MAX(num) OVER (ORDER BY num ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) - num AS prev_diff,
                              ROW_NUMBER() OVER (ORDER BY num) As seq
                        FROM numbers) TMP1) TMP2) TMP3
WHERE low IS NOT NULL;
```

1. TMP 1 서브쿼리

현재 레코드와 전후 레코드의 차이를 구해 prev_diff, next_diff 저장한다.  
차이가 1보다 크면 비어있는 부분이 존재한다.

2. TMP 2 서브쿼리

CASE 식으로 차이가 1보다 큰지 확인해 각 시퀀스의 양쪽 지점이 되는 값(low, high 필드)을 계산한다.

3. TMP 3 서브쿼리

high값이 없는 레코드에 현재 레코드 이후의 레코드들을 돌며 가장 작은 high값을 가져온다.
low값이 없는 레코드는 무시한다.

서브쿼리의 크기에 따라 중간 결과를 메모리에 유지할지 저장소를 사용할지 결정되므로 성능 측면에서 집합 지향 쿼리에 비해 좋은지 알 수 없다.

## 25강. 시퀀스 객체, IDENTIFY 필드, 채번 테이블

표준 SQL에는 순번을 다루는 기능으로 시퀀셜 객체나 IDENTIFY 필드가 존재한다. 하지만 **최대한 사용하지 않는다**. 사용한다면 시퀀스 객체를 사용한다.

### 1. 시퀀스 객체

```
CREATE SEQUENCE testseq
START WITH 1
INCREMENT BY 1
MAXVALUE 100000
MINVALUE 1
CYCLE;
```

테이블 또는 뷰처럼 스키마 내부에 존재하는 객체 중 하나로 CREATE문으로 생성한다. INSERT 구문에서 흔히 사용된다.

초깃값, 증가값, 최댓값, 최솟값, 최댓값에 도달했을 때 순환 유무 등의 옵션을 지정할 수 있으며, 시퀀스 객체가 생성하는 순번은 유일성, 연속성, 순서성을 가진다.

**- 시퀀스 객체의 문제점**

- 표준화가 늦어서, 구현에 따라 구문이 달라 이식성이 없고, 사용할 수 없는 구현도 있다.
- 시스템에서 자동으로 생성되는 값이므로 실제 엔티티 속성이 아니다.
- 성능적인 문제를 일으킨다

**- 시퀀스 객체로 발생하는 성능 문제**

시퀀스 객체가 생성하는 순번은 세 가지 특성을 가진다.  
**순서성(순번의 대소 관계가 유지됨), 유일성, 연속성**

사용자가 시퀀스 객체에서 NEXT VALUE를 검색할 때 처리 과정은 아래와 같음

1. 시퀀스 객체에 배타 락 적용
2. NEXT VALUE 검색
3. CURRENT VALUE 1만큼 증가시킴
4. 시퀀스 객체에 배타 락 해제
   위와 같은 과정으로 인해 동시에 여러 사용자가 시퀀스 객체에 접근할 경우 락 충돌으로 인한 성능 저하 문제 발생

대처법: CACHE, NOORDER 객체로 성능 문제 완화 가능

**- 시퀀스 객체로 발생하는 성능 문제의 대처**

(1) CACHE  
읽어들일 변수를 메모리에 설정하는 것. 값이 클수록 접근 비용을 줄일 수 있다. 다만 시스템 장애시 정상동작을 담보할 수 없다.

(2) NOORDER
순서성을 담보하지 않음으로써 오버 헤드를 줄인다.

**- 순번을 키로 사용할 때의 성능 문제**
DBMS의 저장 방식으로 인해 순번처럼 비슷한 데이터 연속으로 INSERT 시 물리적으로 같은 영역에 저장되어 특정 물리적 블록에만 I/O 부하 커져 성능 저하가 발생한다. = Hot spot, Hot block

시퀀스 객체를 사용해 INSERT를 반복하는 경우 발생하고, 대처가 불가능하다.

\* 핫 스팟: I/O 부하가 몰리는 특정 물리적 블록
![문서 13_2](https://github.com/yubin21/db-db-deep/assets/80163835/45a18015-051b-4eb3-92ba-2bece84e0371)

**- 순번을 키로 사용할 때의 성능 문제에 대처**

(1) Oracle의 열 키 인덱스  
연속된 값을 도입하는 경우라도 DBMS 내부에서 변화를 주어 제대로 분산할 수 있는 구조를 사용한다.
\- I/O양이 늘어나 SELECT 구문 성능이 나빠질 수 있으며 구현의존적 방법이다.

(2) 인덱스에 복잡한 필드를 추가해서 데이터의 분산도를 높인다.  
\- 복잡한 필드 추가할 경우 불필요한 의미를 생성하므로 다른 개발자가 이해하기 어려울 수 있어 논리적으로 좋은 설계가 아니다.

**→ 시퀀스 객체는 최대한 사용하지 말아야 하며, 리스크를 확실하게 인지하고 사용하자**

### 2. IDENTIFY 필드

‘자동 순번 필드’라고도 한다. 테이블의 필드로 정의하고, INSERT 발생할 때마다 자동을 순번을 붙여주는 기능이다.

시퀀스 객체에 비해 단점이 많다.

- 시퀀스 객체는 여러 테이블에서 사용 가능하지만, IDENTIFY 필드는 특정 테이블에 국한된다.
- CACHE, NOORDER를 지정할 수도 없거나 제한적으로만 사용할 수 있다.

**→ 이점이 거의 없다.**

### 3. 채번 테이블

순번을 부여하기 위해 어플리케이션에서 채번 테이블이라는 것을 만들어 사용했었다. 테이블을 활용해 유사적으로 시퀀스 객체 락 메커니즘을 구현한 것이다.

구시대 유물이며 문제가 안생기기를 바라는 것이 최선이다.(바틀넥이 걸려도 튜닝할 방법도 없다)

## 추가) TEMP 탈락 현상

**SQL 레벨업 - “4장 집약과 자르기”에서 이미 나온 개념. 이 교재에서만 정의된 용어!**

→ "인 메모리 부족 현상으로 인한 스왑현상" 정도로 이해할 수 있을 것 같다

💡 142p.

---

하지만 정렬과 해시 모두 메모리를 많이 사용하므로, 충분한 해시용 워킹 메모리가 확보되지 않으면 스왑이 발생한다. 따라서 저장소 위의 파일이 사용되면서 굉장히 느려진다.

예를 들어, 오라클에서 정렬 또는 해시를 위해 PGA라는 메모리 영역을 사용한다. 이때 PGA 크기가 집약 대상 데이터양에 비해 부족하면 일시 영역(저장소)을 사용해 부족한 만큼 채운다.

위 현상을 TEMP 탈락이라 한다. 이 현상이 발생하면 메모리만으로 처리가 끝나는 경우와 비교해 극단적으로 성능이 떨어지게 된다. 메모리와 저장소(일반적으로 디스크)의 접근속도가 굉장히 차이나기 때문이다.

### TEMP 영역을 자동으로 확장하게 만들 수 있는 DBMS도 존재한다.

**1. Oracle의 `AUTOEXTEND`**

**`TABLESAPCE_AUTOEXTEND` : 테이블스페이스에 연결되어 있는 데이터 파일의 용량이 자동으로 확장하도록 설정**

```sql
▶ 용량 부족 시 테이블스페이스가 자동으로 ~MB씩 증가하며 최대 ~MB까지 확장하도록 설정
[ SQL> alter database datafile '경로/파일명.dbf'
autoextend on next nm(증가치) maxsize nm(최대용량); ]
```

**2. Microsoft SQL Server의 `SSMS & T-SQL`**

TEMPDB 데이터베이스를 사용하여 TEMP 테이블스페이스 역할을 수행. TEMPDB의 크기를 동적으로 관리하려면 SQL Server Management Studio(SSMS) 또는 T-SQL을 사용하여 TEMPDB 설정을 변경할 수 있음. [공식 문서](https://learn.microsoft.com/ko-kr/azure/azure-sql/managed-instance/tempdb-configure?view=azuresql&tabs=ssms) 참조
