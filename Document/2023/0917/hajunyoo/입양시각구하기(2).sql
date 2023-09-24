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