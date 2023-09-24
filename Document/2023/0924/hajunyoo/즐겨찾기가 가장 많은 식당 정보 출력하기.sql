WITH Dataset AS (
    SELECT 
        FOOD_TYPE, 
        REST_ID,
        REST_NAME,
        FAVORITES,
        ROW_NUMBER() OVER(PARTITION BY FOOD_TYPE ORDER BY FAVORITES DESC) AS rank
    FROM 
        REST_INFO
)
SELECT 
    FOOD_TYPE, 
    REST_ID, 
    REST_NAME, 
    FAVORITES
FROM 
    Dataset
WHERE 
    rank = 1
ORDER BY 
    FOOD_TYPE DESC;


/*
ROW_NUMBER()를 사용하여 각 음식 종류별로 즐겨찾기수가 높은 순서대로 순번을 부여하고, 그 중에서 순번이 1인 식당만 선택하는 방식을 사용
*/