```sql
SET @hour := -1;
SELECT (@hour := @hour+1) as HOUR,
(
  SELECT COUNT(*)
  FROM animal_outs
  WHERE HOUR(datetime) = @hour
) as COUNT
FROM animal_outs
WHERE @hour < 23;
```
