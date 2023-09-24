-- 코드를 입력하세요
WITH dataset AS (
    SELECT ANIMAL_ID, CAST(DATE_FORMAT(DATETIME, "%H") AS UNSIGNED) AS HOUR
    FROM ANIMAL_OUTS
    )

SELECT HOUR, COUNT(ANIMAL_ID) AS COUNT
FROM dataset
GROUP BY 1
ORDER BY 1
;


/*
DESC ANIMAL_OUTS; 
ANIMAL_ID -> primary key null x

DATE_FORMAT : 날짜를 원하는 형식으로 변환
-> %H : 시간을 24시간 형식으로 변환 -> 08로 찍히는 문제점
이를 숫자로 변환이 필요

문자를 숫자로 숫자를 문자로 변환(CAST)


하지만 이 테이블은 6시 이전부터 데이터가 존재하지 않기 때문에 생성해줘야 한다

쿼리문에서 로컬 변수를 활용

*/

SET @hour := -1; -- 변수 선언

SELECT (@hour := @hour + 1) as HOUR,
(SELECT COUNT(*) FROM ANIMAL_OUTS WHERE HOUR(DATETIME) = @hour) as COUNT
FROM ANIMAL_OUTS
WHERE @hour < 23



-- 태현님 풀이 -> Recursive cte

WITH RECURSIVE TIME AS ( 
    SELECT 0 AS HOUR
    UNION ALL
    SELECT HOUR + 1
    FROM TIME
    WHERE HOUR < 23 
)
                
SELECT TIME.HOUR, COUNT(ANI.ANIMAL_ID)
FROM TIME
LEFT JOIN ANIMAL_OUTS AS ANI ON TIME.HOUR = HOUR(ANI.DATETIME)
GROUP BY TIME.HOUR

/*
SQL 쿼리에서 WITH RECURSIVE 구문은 Common Table Expressions (CTE)를 정의하는 데 사용됩니다. 
CTE는 일시적인 결과 집합을 생성하는 데 사용되며, 
이 결과 집합은 쿼리 내에서 하나 이상의 SELECT 문에서 사용할 수 있습니다.

주어진 쿼리에서 (n)은 CTE의 열 이름을 정의합니다. 
이는 CTE 결과 집합에서 반환되는 열의 이름을 지정하는 데 사용됩니다.

다시 말해, (n)은 CTE에서 반환되는 열의 이름을 n으로 정의하는 역할을 합니다.

CTE의 내용을 보면:

SELECT 1
UNION ALL
SELECT n + 1 FROM cte WHERE n < 5

첫 번째 SELECT 문에서 1을 반환하며, 이 값은 n 열에 할당됩니다. 그 후, 재귀적으로 다음 SELECT 문이 실행되며, 이전에 반환된 n 값에 1을 더한 값을 다시 n 열에 할당합니다. 이 과정은 n < 5 조건을 만족할 때까지 계속됩니다.

따라서 주어진 쿼리의 결과는:


n
-
1
2
3
4
5
이 됩니다.

https://velog.io/@sangmin7648/MySQL-WITH-RECURSIVE
*/