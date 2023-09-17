각 장은 pdf으로 정리되어 있습니다.

## 목차

- [7장](#7장)
- [8장](#8장)

## 7장
- [7장](./7장.pdf)
## 8장
- [8장](./8장.pdf)


## SQL

### 입양시각 구하기(2)
- SQL 문제
    - 0부터 23시까지의 시간대별로 입양이 몇 건이나 발생했는지 조회하는 SQL문을 작성
    - 결과는 시간대 순으로 정렬
    - @ 변수
        - MySQL에서 @ 변수는 사용자 정의 변수를 나타내며, 일종의 사용자 정의 세션 변수
            - 다른 클라이언트 세션에서는 그 값을 보거나 변경 불가
        - SET 옆에 변수명과 초기값을 설정할 수 있습니다.
        - @가 붙은 변수는 프로시저가 종료되어도 유지된다고 생각하면 됩니다.
            - 일반적인 로컬 변수 (즉, DECLARE를 사용하여 선언된 변수)와는 대조적입니다. 로컬 변수는 프로시저나 함수가 종료될 때 사라집니다.
            ```sql
            DELIMITER //
            CREATE PROCEDURE setSessionVar()
            BEGIN
                SET @mySessionVar = 'Hello, World!';
            END//
            DELIMITER ;

            CALL setSessionVar();

            -- 이후에도 아래 쿼리는 값을 반환합니다.
            SELECT @mySessionVar;
            ```
        - @ 변수는 SELECT 문에서 사용할 수 있습니다.
        - 이를 통해 값을 누적하여 0부터 23까지 표현 가능.
    - @hour은 초기값을 -1로 설정합니다. PL/-SQL 문법에서 :=은 비교 연산자 =과 혼동을 피하기 위한의 대입 연산입니다.
    - SELECT (@hour := @hour +1) 은 @hour의 값에 1씩 증가시키면서 SELECT 문 전체를 실행.
    ```sql
    SET @hour := -1; -- 변수 선언

    SELECT (@hour := @hour + 1) as HOUR,
    (SELECT COUNT(*) FROM ANIMAL_OUTS WHERE HOUR(DATETIME) = @hour) as COUNT
    FROM ANIMAL_OUTS
    WHERE @hour < 23
    ```

    - 이 때 처음에 @hour 값이 -1 인데, 이 식에 의해 +1 이 되어 0이 저장됩니다.
        HOUR 값이 0부터 시작할 수 있습니다.
        WHERE @hour < 23일 때까지, @hour 값이 계속 + 1씩 증가