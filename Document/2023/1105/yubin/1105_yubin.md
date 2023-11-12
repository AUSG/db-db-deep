> 1105 김유빈 디비디비딥 정리

# 2장. SQL기초

> 자연 언어를 사용하는 것처럼

## SELECT 구문

데이터베이스의 핵심은 **검색** 이다. 검색은 다른 말로 **질의(query)** 또는 **추출(retrieve)** 라고 부른다. 

검색을 위해 사용하는 SQL구문을 SELECT 구문이라고 부른다. 문자 그대로 선택 한다는 의미!

### SELECT 구와 FROM 구

기본적으로 SELECT 구와 FROM 구로 이루어진다.

FROM구는 반드시 입력하야 하는 것은 아니지만, 테이블에서 데이터를 검색하는 경우에는 반드시 입력해야 한다. (Oracle의 경우 반드시 FROM 구를 입력해야 한다.)

| name(이름) | phone_nbr(전화번호) | address(주소) | sex(성별) | age(나이) |
| --- | --- | --- | --- | --- |
| 인성 | 080-3333-xxxx | 서울시 | 남 | 30 |
| 하진 | 090-0000-xxxx | 서울시 | 여 | 21 |
| 준 | 090-2984-xxxx | 서울시 | 남 | 45 |
| 민 | 080-3333-xxxx | 부산시 | 남 | 32 |
| 하린 | ​ | 부산시 | 여 | 55 |
| 빛나래 | 080-5848-xxxx | 인천시 | 여 | 19 |
| 인아 | ​ | 인천시 | 여 | 20 |

여기서 SQL의 특징을 알 수 있는데 데이터를 '**어떤 방법으로**' 선택할지 쓰여있지 않다는 것이다.

→ 어떤 데이터가 필요한지 정하기만 하면 DBMS가 프로그래밍에서 절차 지향 같은 부분은 알아서 처리해준다.

아래 sql 문을 보면

```sql
SELECT username, phone_bs, address, sex, age
FROM ADDRESS;
```

| name(이름) | phone_nbr(전화번호) | address(주소) | sex(성별) | age(나이) |
| --- | --- | --- | --- | --- |
| 인성 | 080-3333-xxxx | 서울시 | 남 | 30 |
| 하진 | 090-0000-xxxx | 서울시 | 여 | 21 |
| 준 | 090-2984-xxxx | 서울시 | 남 | 45 |
| 민 | 080-3333-xxxx | 부산시 | 남 | 32 |
| 하린 | ​ | 부산시 | 여 | 55 |
| 빛나래 | 080-5848-xxxx | 인천시 | 여 | 19 |
| 인아 | ​ | 인천시 | 여 | 20 |

공란으로 되어있는 하인과 인아의 전화번호를 통해 불명한 데이터를 공란(NULL)로 처리함을 확인할 수 있다.

### WHERE 구

WHERE 구를 사용해 추가적인 조건을 지정한다. WHERE은 ***어디*** 라는 의미가 아니라 ***~라는 경우*** 를 의미한다.

- WHERE 구의 다양한 조건 지정 연산자 → WHERE 구는 다양한 조건 지정 가능.

| 연산자 | 의미 |
| --- | --- |
| = | ~와 같음 |
| <> | ~와 같지 않음 |
| >= | ~ 이상 |
| > | ~보다 큼 |
| <= | ~ 이하 |
| < | ~ 보다 작음 |
- **WHERE 구는 거대한 벤다이어그램이다.** WHERE 구를 사용하면 테이블에 필터 조건을 붙일 수 있다. 하지만 실제로는 복합적인 조건을 사용할 때가 많다. 그럴땐 ‘AND’ 또는 ‘OR’로 연결 한다.
- ‘그리고’ 를 나타내는 AND는 다음과 작성할 수 있다.
    
    ```sql
    SELECT name, address.age
    	FROM Address
    WHERE address = '서울시'
    	AND age >= 30;
    ```
    

**IN 으로 OR 조건을 간단하게 작성**

```sql
**SELECT** name, address
**FROM** address
**WHERE** address **=** '서울시' **OR** address **=** '부산시' **OR** address **=** '인천시';
```

```sql
**SELECT** name, address
**FROM** address
**WHERE** address **IN** ('서울시', '부산시', '인천시');
```

- 실행 결고나는 같지만 훨씬 깔끔하게 바뀌었다.

**NULL 조건 검색**

WHERE 구로 조건을 지정할때 흔히 하는 실수

```sql
**SELECT** name, address
**FROM** address
**WHERE** phone_nbr **=** **NULL**;
```

위 쿼리는 사람 사람의 눈에는 정상적인 SELECT 구문이다. 하지만 실제로 작동하는 SELECT구문은 아니다.

→ NULL은 데이터 값이 아니므로, 데이터에 사용하는 연산자(=)를 사용할 수 없다.

반대로 NULL이 아닌 레코드는 IS NOT NULL이라는 키워드 사용. 

NULL은 데이터값이 아니므로, 데이터값에 적용하는 연산자인 = 을 적용할 수 없다. (=NULL을 사용하지 않는 이유)

SELECT 구문은 절차 지향형 언어의 **함수**와 동일한 역할을 한다.

SELECT 구문의 입력과 출력 자료형은 **테이블** 뿐이다. 이러한 성질 때문에 폐쇄성(closure property, 관계가 닫혀있다는 의미)을 띈다고 부른다. 이는 뷰와 서브쿼리를 함께 이해할 때 매우 중요한 개념이다. 75p.

### GROUP BY 구

GROUP BY 구를 사용해 합계, 평균과 같은 집계 연산을 수행한다. GROUP BY 구는 케이크를 자르는 칼과 같은 역할을 한다.

GROUP BY 구문을 사용해 여러 **그룹**을 만들고 숫자 관련 함수를 이용해 집계한다.

- GROUP BY 구에서 사용하는 집계함수 (생략)GROUP BY 구는 "GROUP BY ()"(생략 가능)를 이용해 테이블 전부를 하나의 그룹으로 만들 수 있다.

**그룹을 나누었을 때의 장점**

```sql
**SELECT** sex, **COUNT**(*****)
**FROM** Address
**GROUP** **BY** sex;

*-- 결과*
**|** sex **|** **count** **|
|**------+------|
****|** 남 **|** 4 **|
|** 여 **|** 5 **|**
```

케이크를 자르는 기준을 변경한다면

```sql
**SELECT** sex, **COUNT**(*****)
**FROM** Address
**GROUP** **BY** address;

*-- 결과*
**|** address **|** **count** **|
|**------+------|
****|** 서울시 **|** 3 **|
|** 인천시 **|** 2 **|
|** 부산시 **|** 2 **|
|** 속초시 **|** 1 **|**
| 서귀포시 | 1 |
```

 전체 인원수를 계산 (전체 케이크를 자르지 않고 먹는 경우)

```sql
**SELECT** sex, **COUNT**(*****)
	**FROM** Address
**GROUP** **BY** ();

*-- 결과*
**count**
*-----*
9
```

위 경우는 보통 GROUP BY를 생략한다.

```sql
**SELECT** sex, **COUNT**(*****)
	**FROM** Address
```

### HAVING 구

GROUP BY를 이용해 구한 그룹에 조건을 건다.

```sql
**SELECT** address, **COUNT**(*****)
**FROM** Address
**GROUP** **BY** address
**HAVING** **COUNT**(*****) **=** 1;

*-- 결과*
address **|** **count**
--------+-------
**속초시 **|** 1
서귀포시 **|** 1
```

HAVING 구를 사용하면 선택된 결과 집합에 또 다시 조건을 지정할 수 있다. 즉 WHERE 구가 ‘레코드’에 조건을 지정한다면, HAVING 구는 ‘집합’에 조건을 지정하는 기능이다.

### ORDER BY 구

결과 레코드들은 DBMS에 따라서 특정한 규칙을 가지고 정렬될 수 있겠지만, SQL의 일반적인 규칙에서는 정렬과 관련된 내용이 없다. 따라서 어떤 DBMS에서 순서를 가지고 출력된다 해도, 다른 DBMS에서는 그렇게 출력되지 않을 수 있다. 따라서 명시적으로 순서를 정할 때 ORDER BY 구를 사용한다.

ASC(ascending order, 오름차순), DESC(descending order, 내림차순)을 키워드로 사용해 차순을 정한다. (명시하지 않으면 ASC. 모든 DBMS의 공통 규칙)

```sql
**SELECT** name, age
**FROM** Address
**ORDER** **BY** age **DESC**;

*-- 결과*
name **|** age
-----+-------
**만혁 **|** 55
준 **|** 32
철수 **|** 32
준 **|** 20
```

실행 결과를 보면 32세의 사람이 두명이 있다. 이 사람들의 순서도 DBMS마다 다를 수 있다. 이 순서도 맞추고 싶다면 정렬 키워드를 추가해야 한다. 예를 들어 `ORDER BY age DESC, name ASC` 와 같이 작성해야 한다.

## 뷰와 서브쿼리

### 뷰

SELECT 구문을 DB에 저장하는 것을 **뷰**(View)라고 한다.

다만 테이블과 달리 내부에 데이터를 저장하지 않는다. 뷰는 어디까지나 '**SELECT 구문'을 저장**한 것이다.

따라서 SELECT 구문의 FROM 구에 뷰가 있다면 내부적으론 SELECT 구문이 중첩(nested)된 상태이다.

**뷰 만드는 방법**

```sql
**CREATE** **VIEW** [뷰이름] ([필드이름1], [필드이름2] ...) **AS**
```

아래는 주소별 사람수를 구하는 SELECT 구문을 뷰로 저장한 것.

```sql
**CREATE** **VIEW** CountAddress (v_address, cnt)
**AS
SELECT** address, **COUNT**(*****)
	**FROM** Address
**GROUP** **BY** address;
```

이렇게 만들어진 뷰는 일반적인 테이블처럼 SELECT 구문에서 사용할 수 있다.

```sql
**SELECT** v_address, cnt
	**FROM** CountAddress; -- 테이블 대신 뷰를 FROM 구에 지정
```

→ **테이블의 모습을 한 SELECT 구문!**

**익명 뷰**

뷰는 사용방법이 테이블과 같지만 내부에는 테이블을 보유하지 않는다는 점이 테이블과 다르다. 따라서 데이터를 선택하는 SELECT 구문은, 실제로는 내부적으로 ‘**추가적인 SELECT 구문**’을 실행하는 중첩(nested) 구조가 된다.

```sql
*-- 뷰에서 데이터를 선택할 때*
**SELECT** v_address, cnt
**FROM** CountAddress;

*-- 뷰는 실행할 때 SELECT 구문으로 전개*
 v_address, cnt
	 ( address, **COUNT**(****) 
		 Address 
		**GROUP** **BY** address) **AS** CountAddress;
```

위 코드는 뷰를 사용하는 경우와 뷰의 내용을 SELECT 구문으로 전개 했을때의 코드이다.이렇게 FROM 구에 직접 지정하는 SELECT 구문을 **서브쿼리** 라고 한다.

### 서브쿼리

SELECT 구문의 FROM 구에 직접 지정하는 SELECT 구문을 **서브쿼리**(subquery)라고 부른다.

IN 내부에서 서브쿼리를 사용하면 데이터가 변경되어도 따로 수정할 필요가 없다는 점에서 효율적이다.

**서브쿼리를 사용한 편리한 조건 지정**

WHERE 구의 조건에 서브쿼리를 사용할 수 있다. 이 방법을 통해서 **매칭** 을 쉽게 만들 수 있다. (이때 Addr2 테이블의 데이터는 addr 와 공통되는 2개의 데이터가 존재한다.)

```sql
-*- 전개 전: IN 내부에서 서브쿼리 사용*
**SELECT** name 
	**FROM** Address
**WHERE** name **IN** (**SELECT** name 
							**FROM** Address2);
-*- 서브쿼리 전개 후*
**SELECT** name 
	**FROM** Address
**WHERE** name **IN** ('인성', '민', '준서', '지연', '서준', '중진');
```

이러한 IN 과 서브쿼리를 함께 사용하는 구문은 데이터가 변경되어도 따로 수정할 필요가 없다는 점에서 굉장히 편리하다. 서브쿼리를 사용하면 IN 내부의 서브쿼리가 SELECT 구문 전체가 실행될때마다 다시 실행된다.

- 서브쿼리 추가 설명 (ref. [https://inpa.tistory.com/entry/MYSQL-📚-서브쿼리-정리#서브쿼리의_위치에_따른_명칭](https://inpa.tistory.com/entry/MYSQL-%F0%9F%93%9A-%EC%84%9C%EB%B8%8C%EC%BF%BC%EB%A6%AC-%EC%A0%95%EB%A6%AC#%EC%84%9C%EB%B8%8C%EC%BF%BC%EB%A6%AC%EC%9D%98_%EC%9C%84%EC%B9%98%EC%97%90_%EB%94%B0%EB%A5%B8_%EB%AA%85%EC%B9%AD))
    
    * 아래 내용은 mySQL 기준입니다.
    
    ### **서브쿼리의 위치에 따른 명칭**
    
    SQL
    
    ```sql
    SELECT col1, (SELECT ...)-- 스칼라 서브쿼리(Scalar Sub Query): 하나의 컬럼처럼 사용 (표현 용도)
    FROM (SELECT ...)-- 인라인 뷰(Inline View): 하나의 테이블처럼 사용 (테이블 대체 용도)
    WHERE col = (SELECT ...)-- 중첩 서브쿼리: 하나의 변수(상수)처럼 사용 (서브쿼리의 결과에 따라 달라지는 조건절)
    ```
    
    ### **중첩 서브쿼리( Nested Subquery )**
    
    - **WHERE** 문에 나타나는 서브쿼리
    
    SQL
    
    ```sql
    select name, height 
    from userTbl
    where height > 177;
    ```
    
    → 조건값을 상수로 할때
    
    SQL
    
    ```sql
    select name, height 
    from userTbl
    where height > (select height from userTbl where name in ('김경호'));
    ```
    
    → 조건값을 select로 특정할때 (단 결과가 값이 하나여야됨)
    
    SQL
    
    ```sql
    select name, height 
    from userTbl
    where height = any(select height from userTbl where addr in ('경남'));
    ```
    
    → 조건에 값이 여러개 들어올땐 any.
    
    → any는 in과 동일한 의미.
    
    → or를 의미한다.
    
    SQL
    
    ```sql
    select * 
    from city
    where population > all( select population from city where district = 'New York' );
    ```
    
    → all은 도출된 모든 조건값에 대해 만족할때.
    
    → and를 의미한다.
    
    ### **인라인 뷰(Inline View)**
    
    - **FROM** 문에 나타나는 서브쿼리
    - **참고로 서브 쿼리가 FROM 절에 사용되 경우 무조건 AS 별칭을 지정해 주어야 한다.**
    
    SQL
    
    ```sql
    SELECT EX1.name,EX1.salary
    FROM (
      SELECT *
      FROM employee AS Ii
      WHERE Ii.office_worker='사원'
    ) EX1; -- 서브쿼리 별칭
    ```
    
    ### **스칼라 서브쿼리( Scalar Subquery )**
    
    - **SELECT** 문에 나타나는 서브쿼리
    - **딴 테이블에서 어떠한 값을 가져올때 쓰임**
    - **하나의 레코드만 리턴**이 가능하며, **두개 이상의 레코드는 리턴할 수 없다**.
    - 일치하는 데이터가 없더라도 NULL값을 리턴할 수 있다. 이는 원래 그룹함수의 특징중에 하나인데 스칼라 서브쿼리 또한 이 특징을 가지고 있다.
    
    SQL
    
    ```sql
    SELECT D.DEPTNO, (SELECT MIN(EMPNO) FROM EMP WHERE DEPTNO = D.DEPTNO) as EMPNO 
    FROM DEPT D 
    ORDER BY D.DEPTNO
    ```
    
    ---
    
    ### **서브 쿼리 실행 조건**
    
    1. 서브쿼리는 SELECT문으로만 작성 할 수 있다. (정확히 SELECT문 쿼리밖에 사용 할 수 없는것 이다.)
    2. 반드시 괄호()안에 존재하여야 한다.
    3. 괄호가 끝나고 끝에 ;(세미콜론)을 쓰지 않는다.
    4. ORDER BY를 사용 할 수 없다.
    
    ### **서브쿼리 사용 가능 한 곳**
    
    MySQL에서 서브쿼리를 포함할 수 있는 외부쿼리는 SELECT, INSERT, UPDATE, DELETE, SET, DO 문이 있다.
    
    이러한 서브쿼리는 또 다시 다른 서브쿼리 안에 포함될 수 있다.
    
    - SELECT
    - FROM
    - WHERE
    - HAVING
    - ORDER BY
    - INSERT문의 VALUES 부분 대체제
    - UPDATE문의 SET 부분 대체제

## 조건 분기, 집합 연산, 윈도우 함수, 갱신

### SQL과 조건 분기

일반적인 절차 지향형 프로그래밍 언어에는 if, switch 조건문 등이 있다.

SQL은 프로그래밍 언어와 달리 절차적으로 기술하지 않기 때문에 '문장'이 아닌 '식'을 기준으로 조건 분기를 정한다.

SQL에서 조건 분기를 실현하는 기능이 **CASE 식**이다. CASE 식은 절차 지향의 switch 문과 거의 동일한 방식으로 작동한다.

**CASE 식의 구문**

CASE 식의 구문에는 ‘단순 CASE 식’과 ‘검색 CASE 식’이라는 두 종류가 있다. 검색 CASE 식은 단순 CASE 식의 기능을 모두 포함하고 있다.

```sql
**CASE** **WHEN** [평가식] **THEN** [식]
     **WHEN** [평가식] **THEN** [식]
     **WHEN** [평가식] **THEN** [식]
     *생략*
		 **ELSE** [식]
**END**
```

WHEN 구의 평가식이란 ‘필드 = 값’처럼 조건을 지정하는 식을 말한다.

**CASE 식의 작동** 

CASE 식의 작동은 절차 지향형 프로그래밍 언어의 switch 조건문과 비슷하다. 절차 지향형 언어의 조건 분기와 SQL 조건 분기 사이의 가장 큰 차이점은 **리턴 값** 이다. 절차 지향형 언어의 조건 분기는 문장을 실행하고 딱히 리턴하지는 않는다. 반면 SQL의 조건 분기는 특정한 값(상수)를 리턴한다.

CASE 식의 강점은 '식'이라는 것이다. 따라서 식을 적을 수 있는 모든 곳: SELECT, WHERE, GROUP BY, HAVING, ORDER BY 구와 같은 곳 어디에나 작성할 수 있다.

### SQL의 집합 연산

SQL에서 테이블을 활용해 집합 연산을 할 수 있다.

**UNION으로 합집합 구하기**

집합 연산의 기본은 합집합과 교집합이다. WHERE 구에서 합집합은 OR, 교집합은 AND를 사용했다. 하지만 집합 연산에서 합집합은 **UNION(합)** 을 사용한다.

특이점은 두 테이블의 중복을 제거한뒤 결과값을 출력한다. 중복을 허용하려면 **UNION ALL** 을 사용한다.

**INTERSECT로 교집합 구하기**

AND에 해당하는 교집합을 구하기 위한 연산자는 INTERSECT로, UNION과 마찬가지로 중복된 것이 있다면 해당 레코드는 제외된다.

**EXCEPT로 차집합 구하기**

주의사항: UNION과 INTERSECT는 순서에 관계없이 결과 값이 같지만 EXCEPT는 순서에 따라 결과가 다르다. 이는 사칙연산과 같은 것이다. (5 - 1과 1 - 5는 다르다!)

### 윈도우 함수

**책의 주제인 성능과 관련이 있어 굉장히 중요한 기능.**

윈도우 함수의 특징을 한마디로 정리하면 ‘**집약 기능이 없는 GROUP BY 구**’ 이다.

+ GROUP BY: 자르기 / 집약 | 윈도우 함수: 자르기만 존재.

GROUP BY 구는 필드로 테이블을 자르고, 이어서 잘라진 조각 개수만큼의 레코드 수를 더해서 출력한다.

반면에 윈도우함수는 ‘PARTITION BY’구로 수행 한다. 차이점은 테이블을 자른 후에 집약하지 않으므로 출력 결과의 레코드 수가 입력되는 테이블의 레코드 수와 같다는 것이다.

```sql
**SELECT** address, **COUNT**(*****)
	**FROM** Address
**GROUP** **BY** address;

*-- 결과*
address **|** **count**
--------+------
**서울시 **|** 3
인천시 **|** 2
부산시 **|** 2
속초시 | 1
서귀포시 | 1
```

GROUP BY와의 차이점은 자른 후에 집약하지 않으므로 출력 결과의 레코드 수가 입력되는 테이블의 레코드 수와 같다는 것이다.

윈도우 함수로 주소별 사람수를 계산하는 아래 SQL을 보자 (파티션 분할 결과를 쉽게 이해하기 위한 구분선 존재. 실제 출력에는 해당하지 X)

```sql
**SELECT** address,
  **COUNT**(*****) OVER(PARTITION **BY** address)
**FROM** Address;

*-- 결과*
address **|** **count**
--------+------
**속초시 **|** 1
---------------
인천시 **|** 2
인천시 **|** 2
---------------
서울시 **|** 3
서울시 **|** 3
서울시 **|** 3
---------------
부산시 **|** 2
부산시 **|** 2
---------------
서귀포시 **|** 2
```

지역별 사람의 수는 양쪽 모두 똑같지만 출력되는 레코드의 수가 다르다. → 집약 작업이 수행되지 않았기 때문!

윈도우 함수로 사용할 수 있는 함수는 COUNT 또는 SUM같은 일반함수 이외에도 RANK, ROW_NUMBER등이 있다.

### 트랜잭션과 갱신

SQL은 ‘Structured Query Language’의 약자이다. 즉 데이터 검색을 중심으로 수행하기 위한 언어이다. 따라서 **데이터를 갱신하는것은 부가적인 기능이다.**

SQL의 갱신 작업은 3종류로 분류된다.

1. 삽입 (Insert)
2. 제거 (Delete)
3. 갱신 (Update)

이외에도 1과 3을 합친 머지(Merge)도 존재한다.

**INSERT 로 데이터 삽입**

RDB는 데이터를 테이블에 보관한다. 테이블은 데이터를 보관하는 상자일 뿐으므로 내부에 데이터가 없으면 사용하는 의미가 없다. RDB에서 데이터를 등록하는 단위는 레코드(또는 행)다. 삽입할 때 INSERT 구문을 사용한다.

```sql
-- 기본적인 INSERT 구문
**INSERT** **INTO** [테이블 명] ([필드1], [필드2], [필드3] ... )
						**VALUES** ([값1, [값2], [값3] ...);
```

INSERT 구문은 기본적으로 레코드를 하나씩 삽입한다. 만약 100개의 레코드를 삽입해야 한다면 여러개의 레코드를 한 개의 INSERT 구문으로 삽이하는 multi-row insert 기능을 사용하면 된다.(일부 DBMS에서만 지원한다.)

그러나 오류가 발생했을때 어떤 레코드가 문제인지 확인하기 어렵다. (이런 방법도 있구나~ 정도로만 생각하기)

**DELETE 로 데이터 제거**

데이터를 삭제할 때는 하나의 레코드 단위가 아니라, 한 번에 여러개의 레코드 단위로 처리하게 된다. 

```sql
--- 기본적인 DELETE 구문
DELETE FROM [테이블 이름]
```

부분적으로만 레코드를 제거하고 싶을 때는 SELECT 구문에서 사용했던 WHERE 구로 제거 대상을 선별한다. 

```sql
--- 기본적인 DELETE 구문
DELETE FROM Address
	WHERE address = '인천시';
```

잘못된 구문

```sql
DELETE name FROM Address
```

- DELETE 구문의 삭제 대상은 필드가 아니라 레코드이므로, 일부 필드만 삭제할 수 없다.

```sql
DELETE * FROM Address
```

- *기호를 사용할 경우도 마찬가지로 오류가 발생한다. 레코드의 필드 일부만 지우고 싶다면 UPDATE 구문을 사용할 것.

**UPDATE 로 데이터 갱신**

등록된 데이터를 변경하기 위해 사용하는 구문으로, 테이블의 데이터를 갱신한다.

```sql
--- 기본적인 UPDATE 구문
UPDATE [테이블 이름]
	SET [필드 이름] = [식];
```

UPDATE 구문도 일부 레코드만 갱신하고 싶을 경우 WHERE 구로 필터링한다.

```sql
-- 빛나래의 전화번호를 갱신하는 구문
UPDATE Address
	SET phone_nbr = '080-5849-XXXX'
WHERE name = '빛나래'
```

UPDATE 구문의 SET 구에 여러 개의 필드를 입력하면 한 번에 여러개의 값을 변경할 수 있다.

```sql
-- UPDATE 구문을 한 번 사용해서 갱신
-- 1. 필드를 쉼표로 구분해서 나열
UPDATE Address
	SET phone_nbr = '080-5848-XXXX',
		age = 20
	WHERE name = '빛나래';

-- 2. 필드를 괄호로 감싸서 나열
UPDATE Address
	SET (phone_nbr, age) = ('080-5848-XXXX',20)
	WHERE name = '빛나래';
```
## Leet Code 풀이 

### 1731. The Number of Employees Which Report to Each Employee

[](https://leetcode.com/problems/the-number-of-employees-which-report-to-each-employee/description/)

```
# Write your MySQL query statement below
select e.employee_id, e.name,
    count(m.reports_to) as reports_count,
    round(avg(m.age*1),0) as average_age
from Employees e
join Employees m
on e.employee_id=m.reports_to
group by e.employee_id, e.name
order by e.employee_id
```

### 1934. Confirmation Rate
아직 못풀었습니다🥲 (아래는 풀던 틀린 답입니다)
```
SELECT s.user_id, ROUND(SUM(c.action = 'confirmed') / COUNT(*) * 100, 2) AS confirmation_rate
FROM Signups AS s
LEFT JOIN Confirmations AS c ON s.user_id = c.user_id
GROUP BY s.user_id;

```