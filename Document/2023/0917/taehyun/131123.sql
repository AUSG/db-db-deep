-- [ Programmers ] 즐겨찾기가 가장 많은 식당 정보 출력하기

-- 중첩 서브쿼리(Nested Subquery)면서 다중열 서브쿼리(Multiple-column Subquery)인 서브쿼리를 사용한 풀이
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

