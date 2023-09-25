> 0917 김유빈 디비디비딥 정리


(7장의 경우, 이전 요약과 일치하여 생략하였습니다.)

## 8장. 테이블 설계의 기초 - 테이블 개념과 정규형

관계형 데이터베이스에서는 전체 데이터가 테이블에 포함되고 저장됨. → 테이블을 사용하여 데이터를 적절히 다루는 것이 중요

### 테이블 설계 규칙

- 테이블
    - 열과 행으로 구성된 데이터 구조
    - **고유한 기본키를 가지는 공통 속성을 가진 요소들의 집합**
    - 현실 세계의 개념이나 집합을 나타낸 것

### 공통점을 가진 사물의 집합을 나타내야 함

- 테이블명은 반드시 복수형이나 집합 명사로 표현해야 함
- 관련성이 없는 무작위 집합을 생성해서는 안됨
- 가장 상위의 개념 집합으로 정리하기
- 열은 개체의 속성(Attribute)
    
    → 테이블은 메소드를 뺀 클래스 
    

### 반드시 기본키(Primary Key) 설정하기

- 한 테이블의 내용에 중복 행을 허용하지 않음
- 하나의 테이블에 반드시 하나만 존재하는 고유 식별 정보 필요
- NULL을 가지는 열은 기본키로 지정할 수 없음
- 변경가능성이 있거나 중복될 수 있는 값을 가지는 열은 기본키로 지정 금지
- 기본키 값이 바뀌면 변경 후 값의 유일성을 보증할 수 없고 과거 데이터와의 매칭이 어려움

### 정규형 (Normal Form)

- 데이터의 갱신이 발생한 경우에도 부정합이 발생하기 어려운 테이블의 형태
- 제 1 정규형 ~ 제 5 정규형
- 실질적으로는 제 3 정규형까지 사용

**제 1 정규형 (1NF)**

- 스칼라 값(단일 값) 외의 복합적인 값을 포함하지 않는 테이블
- 복합적인 값(배열: 복수의 값을 하나로 정리한 데이터형 등)은 별도의 테이블로 분리 필요 → 레코드의 단일성 보증 필요 **(테이블은 함수이다.)**

**제 2 정규형 (2NF)**

- 부분함수 종속성이 제거된 테이블
- 부분함수 종속
    
    ```
    {기본키} → {열 A}
    {기본키} → {열 B}
    ```
    
    - 기본키를 구성하는 열의 일부에만 함수 종속이 존재하는 것
    - 동일한 내용이 복수행으로 존재하여 갱신 시 데이터 부정합 발생 가능 → 갱신 이상
    - 테이블 분리 필요

**제 3 정규형 (3NF)**

- 이행함수 종속성이 제거된 테이블
- 이행함수 종속 (추이 함수 종속)
    
    ```
    {기본키} → {열 A} → {열 B}
    ```
    
    - 2단계의 함수 종속 발생
    - 열 B에 데이터를 추가할 수 없는 갱신 이상 발생
    - 테이블 분리 필요

## ER 다이어그램

- 복잡한 업무 시스템에서는 테이블의 수가 수백 개에 달함
- 전체 테이블의 관계성 파악을 위해 ER 다이어그램(Entity-Relationship Diagram) 작성

### IE (Information Engineering) 표기법

- ER 다이어그램의 여러 표기법 중 하나
- Entity
    - 사각형으로 표시
    - 사각형의 윗부분에는 기본키(PK), 아래에는 일반 열 기재
- Relationship
    
    - 외래키를 통한 엔티티 간의 관련성 표현
    - 1:1 관계, 1:N 관계 등 표현 가능

### + 추가 - 문제풀이
> [입양 시각 구하기(2)](https://school.programmers.co.kr/learn/courses/30/lessons/59413)

**recursive CTE solution**

```
WITH RECURSIVE TIMETABLE(HOUR) AS (
    SELECT 0
    UNION
    SELECT TIMETABLE.HOUR + 1 FROM TIMETABLE WHERE TIMETABLE.HOUR < 23
)

SELECT HOUR, COUNT(A.ANIMAL_ID)
FROM TIMETABLE AS T LEFT JOIN ANIMAL_OUTS AS A ON T.HOUR = HOUR(A.DATETIME)
GROUP BY HOUR
ORDER BY HOUR
```

1. RECURSIVE CTE 사용하여 시간대별로 0부터 23까지의 숫자를 생성
2. TIMETABLE과 ANIMAL_OUTS를 LEFT JOIN하여 시간대별로 ANIMAL_OUTS 데이터와 일치
3. 시간대별로 ANIMAL_ID의 COUNT를 계산하고 결과를 반환
4. 시간대 순 정렬

**other solution**

```
SET @HOUR = -1;
SELECT (@HOUR := @HOUR +1) AS HOUR,
    (SELECT COUNT(HOUR(DATETIME)) 
    FROM ANIMAL_OUTS 
    WHERE HOUR(DATETIME)=@HOUR) AS COUNT 
    FROM ANIMAL_OUTS
WHERE @HOUR < 23;
```

출처: https://jaaamj.tistory.com/155

1. @HOUR 변수를 선언하고 -1로 초기화
2. 하위 쿼리를 사용하여 시간대별로 ANIMAL_OUTS 테이블의 데이터를 계산
3. @HOUR 변수를 1씩 증가시키면서 시간대별로 COUNT를 계산하고 결과를 반환
4. @HOUR 값이 23보다 작은 경우에만 데이터를 처리