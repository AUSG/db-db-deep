-- [ Programmers ] 입양 시각 구하기 (2)

-- 공통 테이블 표현식(Common Table Expression, CTE)의 재귀적(Recursive) 사용을 통한 풀이
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
