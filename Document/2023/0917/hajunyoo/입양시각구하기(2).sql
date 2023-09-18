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
DATE_FORMAT : 날짜를 원하는 형식으로 변환
-> %H : 시간을 24시간 형식으로 변환 -> 08로 찍히는 문제점
이를 숫자로 변환이 필요

문자를 숫자로 숫자를 문자로 변환(CAST)
*/