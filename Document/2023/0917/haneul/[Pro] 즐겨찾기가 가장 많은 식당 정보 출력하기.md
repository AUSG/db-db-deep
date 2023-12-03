```sql
SELECT food_type, rest_id, rest_name, favorites
FROM rest_info a
WHERE favorites = (
    SELECT max(favorites)
    FROM rest_info b
    WHERE a.food_type = b.food_type
)
ORDER BY food_type DESC;

