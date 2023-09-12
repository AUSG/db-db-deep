-- [ LeetCode ] 608. Tree Node

-- UNION ALL 구 및 서브쿼리(Subquery) 중 인라인 뷰(Inline View)와 공통 테이블 표현식(Common Table Expression, CTE)을 사용한 풀이
WITH cte (p_id) AS (
    SELECT
        DISTINCT p_id
    FROM Tree
    WHERE p_id IS NOT NULL
)

SELECT
    id,
    'Root' AS type
FROM (
    SELECT
        id
    FROM Tree
    WHERE p_id IS NULL
) AS RootNode
UNION ALL
SELECT
    id,
    'Inner' AS type
FROM (
    SELECT
        id
    FROM Tree
    WHERE (
        p_id IS NOT NULL
        AND
        id IN (SELECT p_id FROM cte)
    )
) AS InnerNode
UNION ALL
SELECT
    id,
    'Leaf' AS type
FROM (
    SELECT
        id
    FROM Tree
    WHERE (
        p_id IS NOT NULL
        AND
        id NOT IN (SELECT p_id FROM cte)
    )
) AS LeaftNode;

-- CASE 문 및 서브쿼리(Subquery) 중 스칼라 서브쿼리(Scala Subquery)를 사용한 풀이
SELECT
    id,
    CASE
        WHEN p_id IS NULL THEN 'Root'
        WHEN id IN (SELECT DISTINCT p_id FROM Tree) THEN 'Inner'
        ELSE 'Leaf'
    END AS type
FROM Tree;

-- LEFT JOIN 및 GROUP BY를 사용한 풀이
SELECT
    Tree.id,
    CASE
        WHEN Tree.p_id IS NULL THEN 'Root'
        WHEN SubTree.id IS NULL THEN 'Leaf'
        ELSE 'Inner'
    END AS type
FROM Tree
LEFT JOIN Tree AS SubTree
ON Tree.id = SubTree.p_id
GROUP BY Tree.id, type;
