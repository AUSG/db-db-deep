SELECT 
  DISTINCT t1.id,
  CASE 
    WHEN t1.p_id IS NULL THEN "Root"
    WHEN t2.id IS NULL THEN "Leaf"
    ELSE "Inner"
  END AS "Type"

FROM Tree t1
LEFT JOIN Tree t2 ON t1.id = t2.p_id
ORDER BY 1


----
select id, case 
when p_id is null then 'Root'
when p_id in (select id from tree) and id in (select p_id from tree) then 'Inner'
ELSE 'Leaf'
end as type
from Tree