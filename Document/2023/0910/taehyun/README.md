# 디비 디비 딥(DB DB Deep) 스터디 2회차

## [ 데이터베이스 첫걸음 ] 5장 DBMS를 조작할 때 필요한 기본 지식 - 조작하기 전에 알아두어야 할 것

### MySQL과 커넥션 만들기

#### 로그인의 의미

`mysql>` 문자열은 프롬프트(Prompt)라고 읽으며 MySQL이 사용자로부터 명령을 입력받을 수 있는 상태라는 것을 표시하는 기호다. 이때 프롬프트는 특히 사람에게 무언가를 하라고 재촉할 때 사용하는 말을 뜻하는 단어다.


### 데이터베이스에 전화 걸기

#### 커넥션의 이미지는 전화

MySQL에 연결 했을 때 아래와 같이 `Your MySQL connection id is`라는 문구와 함께 실제 커넥션 번호를 반환 받게 되는데, 이는 MySQL이 동시에 여러 개의 커넥션을 유지하는 것이 가능하기 때문에 번호로 커넥션을 관리하기 때문이다.

```Bash
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
```

커넥션의 시작과 종료 사이에 DBMS와 여러 다양한 교환을 하게 되면서 해당 교환의 시작부터 종료까지의 단위를 세션(Session)이라 부른다. 커넥션과 세션은 1:1로 대응되어 커넥션이 성립되면 암묵적으로 세션이 시작되고, 세션이 종료되면 커넥션도 종료되기 때문에 유사한 개념을 가지고 있어 같은 의미로 사용할 때가 있지만, 커넥션이 확립된 후에 세션이 만들어지기 때문에 엄밀히 따지자면 둘은 다른 개념이다.

#### 커넥션의 상태를 조사하는 명령

보통 DBMS에는 커넥션의 상태나 수를 조사하기 위한 명령어가 존재하는데, MySQL의 경우 아래와 같이 `SHOW STATUS LIKE 'Threads_connected'`라는 명령어로 현재 연결된 커넥션의 수를 확인할 수 있다. 아래 예시는 두 명의 사용자가 동시 접속한 상황이다.

```Bash
mysql> SHOW STATUS LIKE 'Threads_connected';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| Threads_connected | 2     |
+-------------------+-------+
```

### 관계형 데이터베이스의 계층

#### 폴더에 해당하는 스키마

데이터베이스에서 스키마(Schema)는 디렉터리에 해당한다. 테이블은 이러한 스키마 속에 저장되는데, 스키마에 사용자 별로 접근 제한을 걸어 보안적인 이점을 가져갈 수도 있다. 이때 데이터베이스(Database)는 스키마의 상위 계층이다.

#### 최상위에 있는 인스턴스

인스턴스(Instance)는 데이터베이스의 상위 계층으로 DBMS가 작동할 때의 단위를 의미하는 물리적 개념이다. 따라서 운영 체제(Operating System, OS) 입장에서는 프로세스(Process)에 해당하며, 몇몇 DBMS에서는 인스턴스를 서버 프로세스(Server Process) 또는 서버(Server)라 부르기도 한다. 어떤 용어로 부르더라도 결국 메모리와 CPU를 사용하는 물리적 실체를 가리킨다.

#### MySQL과 Oracle의 계층 구조

MySQL은 데이터베이스와 스키마를 동일한 것으로 간주하여 계층 차이를 두지 않기 때문에 데이터베이스와 스키마가 동의어다. Oracle의 경우 4계층 구조이지만 인스턴스 아래에 데이터베이스를 한 개만 만드는 제약이 있기 때문에 실질적으로 3계층 구조라 할 수 있다.

#### 3계층과 4계층 어느 쪽이 맞는가

굳이 3계층과 4계층 중 어느 쪽을 정답으로 선택해야 하는지 묻는다면 정답은 4계층이다. 이는 미국국립표준협회(American National Standards Institute, ANSI)가 정한 표준 SQL로 결정되어 있기 때문이다.

#### 멀티 인스턴스와 가상화

단일 운영 체제 내에서 여러 개의 인스턴스를 갖는 구성, 다시 말해 멀티 인스턴스(Multi Instance) 구성을 구축할 수 있다. 그러나 운영 체제 입장에서 결국 메모리와 CPU 같은 물리 자원을 소비하는 프로세스에 해당하기 때문에 복수의 인스턴스를 실행할 자원이 부족하다면 멀티 인스턴스를 구동할 수 없게 된다. DBMS의 경우 일반적으로 가동될 때 최저 한계의 메모리 공간을 확보하려 하기 때문에 특히 메모리가 부족한 경우 인스턴스는 가동이 아예 불가능하다. 이러한 단점과 함께 최근 가상화 환경을 사용하는 경우가 증가함에 따라 멀티 인스턴스 구성이 점차 줄어드는 추세다.

## [ 데이터베이스 첫걸음 ] 6장 SQL 문의 기본 - SELECT 문의 이해

### SELECT 문으로 테이블 내용을 살펴보자

`district` 필드의 중복을 제거하여 검색하고 싶은 경우 아래와 같이 `DISTINCT` 키워드를 `SELECT` 구에 사용하면 된다. 실제 아래 쿼리를 실행해보면 기존 4,079개의 행을 가지고 있는 테이블에서 1,367개의 행만 출력되는 것을 확인할 수 있다.

```SQL
SELECT
    DISTINCT district
FROM city;
```

이와 비슷하게 중복을 제거한 `countrycode` 필드만 아래와 같이 출력하면 232개의 행이 출력된다.

```SQL
SELECT
    DISTINCT countrycode
FROM city;
```

그렇다면 만약 아래와 같이 복수 개의 필드를 `DISTINCT` 키워드로 사용하면 어떻게 될까?

```SQL
SELECT
    DISTINCT district,
    countrycode
FROM city;
```

실제로 해당 값을 출력해보면 1,412개의 행이 출력된 것을 확인할 수 있다. 어째서 `district` 필드와 `countrycode` 필드의 중복을 제거한 수보다 많은 행이 반환된 걸까? 이유는 `DISTINCT` 키워드를 사용하게 되는 순간 `SELECT` 구에 선택된 필드는 튜플(Tuple) 형태로 중복이 제거되기 때문이다. 따라서 `(district, country)`처럼 두 필드가 하나의 쌍(Pair)이 되어 취급된다.

### SELECT 문을 응용해보자

아래와 같이 `GROUP BY` 구, 그리고 `HAVING` 구에 `SELECT` 구에서 사용하는 별칭(Alias)을 사용하면 SQL 문은 원하는 대로 작동할까? 우리는 SQL 문의 작동 순서에 있어 `GROUP BY` 구 및 `HAVING` 구가 `SELECT` 구에 우선이 된다고 알고 있기 때문에 작동이 안 될 것으로 판단할 수 있다.

```SQL
SELECT
    district AS district_name,
    COUNT(ID) AS number_of_cities
FROM city
WHERE countrycode = 'KOR'
GROUP BY district_name
HAVING number_of_cities = 6;
```

그러나 MySQL에서 실제로 쿼리를 실행해보면 아래와 같이 정상적으로 작동하는 걸 확인할 수 있다. 이는 DBMS 내부에서 처리해주는 부분으로 [B.3.4.4 Problems with Column Aliases](https://dev.mysql.com/doc/refman/8.0/en/problems-with-alias.html) 문서를 확인해보면 `GROUP BY`, `ORDER BY`, `HAVING` 구에서는 별칭을 사용할 수 있으며, `WHERE` 구에서는 별칭을 사용할 수 없다고 적혀 있다.

```Bash
+---------------+------------------+
| district_name | number_of_cities |
+---------------+------------------+
| Chollabuk     |                6 |
| Chungchongnam |                6 |
+---------------+------------------+
```

별칭을 사용할 때도 식별자(Identifier)를 사용해야 하며 단순히 문자열을 의미하는 따옴표(`''`)를 사용할 경우, 문자열 리터럴(String Literal)로 참조되어 원하는 결과를 얻을 수 없다. 실제로 아래 쿼리를 실행하면 앞서 실행된 결과와 다른 결괏값을 반환한다.

```SQL
SELECT
    district AS district_name,
    COUNT(ID) AS 'number_of_cities'
FROM city
WHERE countrycode = 'KOR'
GROUP BY district_name
HAVING 'number_of_cities' = 6;

```

문자열 리터럴 `'number_of_cities'` 값 자체가 숫자 `6`과 다르기 때문에 거짓(False)을 의미하며, 결국 `HAVING` 구에 MySQL에서 거짓 불리언(Boolean) 대수 값을 의미하는 `0`이 전달 된다.

```Bash
Empty set, 1 warning (0.01 sec)
```

이때 `SHOW WARNINGS` 명령어를 실행하여 반환된 경고(Warning)를 살펴보면 아래와 같이 조건문, 다시 말해 `HAVING` 구에 비교할 수 없는 데이터가 존재할 때 반환하는 경고가 작성되어 있는 것을 확인할 수 있다.

```Bash
+---------+------+------------------------------------------------------+
| Level   | Code | Message                                              |
+---------+------+------------------------------------------------------+
| Warning | 1292 | Truncated incorrect DOUBLE value: 'number_of_cities' |
+---------+------+------------------------------------------------------+
```

### SELECT 문의 응용조작을 배워보자

#### 테이블을 요약하는 함수

집계함수의 종류는 아래와 같이 크게 다섯 가지가 있다.

1. `COUNT`
2. `SUM`
3. `AVG`
4. `MAX`
5. `MIN`

이때 기본적으로 `NULL` 값을 제외하고 집계하는데, `COUNT` 집계함수의 경우 `COUNT(*)`과 같이 애스터리스크(`*`)을 사용할 경우 `NULL` 값을 포함하여 집계하기 때문에 유의해야 한다. 또한 `SUM`과 `AVG` 집계함수를 제외한 나머지 집계함수의 경우 수치 데이터 외에도 사용할 수 있다.

#### 문자열을 집약하는 GROUP_CONCAT

문자열에 대한 집계는 SQL 표준에는 없지만 MySQL에는 `GROUP_CONCAT` 함수를 사용하여 집계할 수 있다. 이때 `group_concat_max_len` 시스템 변수 값을 통해 상한선이 기본적으로 1024 바이트로 제한되어 있어 만약 해당 크기를 넘는 값을 집계하려는 경우 생각하지 못했던 결과를 얻을 수 있다.

### 데이터의 갱신과 삽입

#### 데이터를 입력하는 INSERT 문

`INT` 형의 경우 `INT(11)`과 같이 괄호 안에 정수를 표기하는데, 이는 MySQL 특유의 화면 표시용 폭을 의미할 뿐 `CHAR` 형처럼 열의 크기를 의미하지는 않는다. `CHAR` 형의 경우 열의 크기를 지정할 수 있으며, 이때 MySQL 4.0 버전까지는 바이트를 기준으로 하지만 4.1 이후부터는 문자 수를 의미한다.

#### INSERT 문의 기본 구문

아래의 두 `INSERT` 문은 동일한 값을 저장한다. 기본 값을 저장할 때는 첫 번째 방식처럼 명시적으로 `DEFAULT` 키워드를 사용하거나, 두 번째 예시처럼 암묵적으로 열을 함께 제외하여 값을 저장하는 방법이 있다. 이때 모든 열에 기본 값이 지정되어 있더라도 값을 저장하기 위해서는 적어도 한 개의 열을 지정해야 한다.

```SQL
INSERT INTO city VALUES (DEFAULT, 'Gimpo', 'KOR', 'Kyonggi', 349900);
INSERT INTO city (name, countrycode, district, population) VALUES 'Gimpo', 'KOR', 'Kyonggi', 349900);
```

#### 데이터 입력에 자주 사용되는 구문

MySQL에서는 아래와 같이 `CREATE TABLE` 문에 `LIKE` 키워드를 붙여 특정 테이블과 동일한 구조를 가진 테이블을 생성할 수 있다. 이때 데이터는 복제되지 않는다.

```SQL
CREATE TABLE citycopy LIKE city;
```

그리고 다음과 같이 `INSERT INTO` 문에서도 `VALUES` 키워드를 별도로 사용하지 않고 `SELECT` 구를 통해 다른 테이블의 특정 값을 가져와 저장할 수 있다. 이때 `citycopy` 테이블은 `CREATE TABLE` 문에 `LIKE` 키워드를 사용하여 `city` 테이블의 구조를 복제한 테이블이기 때문에 두 테이블의 구조가 동일하여 별도로 열을 지정해 줄 필요 없이 데이터를 입력해도 문제가 발생하지 않는다.

```SQL
INSERT INTO citycopy SELECT * FROM city;
```

추가로 MySQL에서는 아래와 같이 콤마(`,`)를 사용하여 복수 행의 입력(Multi row insert)을 가능하게 하는 기능이 있으며, 해당 기능은 최초 MySQL에만 존재하다 이후 다른 DBMS에서도 많이 채용되었다.

```SQL
INSERT INTO city (name, countrycode, district, population)
VALUES ('Gimpo', 'KOR', 'Kyonggi', 349900),
VALUES ('Pocheon', 'KOR', 'Kyonggi', 155192)
```

#### SQL 표준어와 비 표준어의 차이

대표적으로 아래 6가지 항목이 표준화되지 않은 부분이다.

1. 준비된 데이터형, 그리고 함수의 기능이나 범위가 다르다.
2. 특정 데이터형, 비교 연산자에서의 `NULL` 값 취급이 다르다. 예를 들어 `VARCHAR2` 형에서는 길이가 0인 문자를 의미하는 빈 문자를 `NULL` 취급하며, SQL Server에서는 `ANSINULL=OFF`에서 `NULL` 값에 대한 비교 연산(`=`)이 `TRUE` 또는 `FALSE`를 반환한다.
3. 내부 결합(Inner Join)이나 외부 결합(Outer Join)에 SQL 표준 이외의 오래된 표기나 벤더 독자 표기가 있다. 예를 들어, 내부 결합에서 `INNER JOIN` 키워드는 사용하지 않고 `FROM` 구의 뒤에 테이블 2개를 열거하여 `WHERE` 구에 결합조건을 적거나 외부 결합의 `LEFT OUTER JOIN` 결합 조건에서 Oracle은 `A = B(+)`, SQL Server는 `A *= B`를 사용한다.
4. 데이터베이스 특유의 사용자 관리를 하지 않고 운영 체제 사용자와 연계할 수 있다.
5. 함수와 프로시저 같은 스토어드 루틴이나 트리거 유무, 그리고 어떤 경우에는 PL/SQL, T-SQL, SQL/PSM 같은 기술 언어에도 차이가 있다.
6. 비교적 새로운 SQL 표준 기능인 윈도우 함수(Window Function) 또는 SQL/MED 등의 유뮤가 있다.

### 뷰의 작성과 서브쿼리 및 결합

#### 뷰를 사용하는 이점

뷰는 SQL 시점에서 보면 테이블과 동일하지만 테이블과 같은 데이터는 가지고 있지 않으며, 테이블에 대한 `SELECT` 를 가지고 있다. 테이블 대신 뷰를 사용하여 얻을 수 있는 이점은 아래와 같이 크게 세 가지가 있다.

1. 복잡한 `SELECT` 문을 일일이 매번 기술할 필요가 없다.
2. 필요한 열과 행만 사용자에게 보여줄 수 있고, 갱신 시에도 뷰 정의에 따른 갱신으로 한정할 수 있다.
3. 1번과 2번의 이점을 데이터 저장 없이, 다시 말해 기억장치의 용량을 사용하지 않고 실현할 수 있다. 또한 `DROP VIEW` 문을 사용하여 뷰를 제거해도 참조하는 테이블은 영향 받지 않는다.

Oracle, PostgreSQL에서 제공하는 머티리얼라이즈드 뷰(Materialized View)는 실제로 데이터를 가진다. 주기적으로 기본 테이블에서 뷰로 데이터가 반영되는 구조다. MySQL이나 Firebird에는 이러한 기능이 없으며, DB2는 MQT, SQL Server는 인덱스 뷰라는 유사 기능이 존재한다.

#### 뷰로의 입력 및 갱신의 제한

뷰로의 입력과 갱신에는 몇 가지 제한이 있다. 대표적으로 어떤 행이 대응하는지 모르거나 어떤 값을 넣으면 좋을지 모르는 경우에는 갱신할 수 없다. 이외에도 PostgreSQL 9.2 이전 버전처럼 기본값으로 갱신할 수 없는 구현이나 MySQL에서 `updatable_views_with_limit` 시스템 변수를 사용하여 특정한 갱신을 금지하는 구현도 있다.

#### 서브쿼리의 실행이란

통상적으로 `SELECT` 문의 결과는 택한 열과 행으로 구성된 테이블 형식이다. 그리고 이 특수한 형태로 하나의 열과 하나의 행으로 구성된 테이블, 즉 단일값으로 구성된 결과를 만들 수 있다. SQL 문에서는 이런 `SELECT` 문의 결과를 마치 데이터처럼 다루거나 수치처럼 취급해 조건문에 이용할 수 있는데, 이런 쿼리를 메인 쿼리(Main Query)와 대비하여 서브쿼리(Subquery)라 부른다. 그리고 이러한 단일값을 스칼라 값이라 부르는데, 스칼라(Scalar)는 '단일'을 의미한다.

서브쿼리는 크게 세 가지 관점에서 분리되어 용어를 구분할 수 있다. 먼저 위치에 따라 구분할 수 있는데, 크게 세 가지 종류가 있다.

스칼라 서브쿼리(Scala Subquery)의 경우 `SELECT` 구 내부에 단일값을 출력하는 서브쿼리를 의미한다. 인라인 뷰(Inline View)의 경우 `FROM` 구 내부에 작성한 서브쿼리를 의미하며, `WHERE` 구 내부에 작성한 서브쿼리의 경우 중첩 서브쿼리(Nested Subquery)라 한다.

다음으로 메인 쿼리와의 관계성에 따라 서브쿼리를 구분할 수 있다. 먼저 메인 쿼리와 서브쿼리 간에 관계성이 없을 경우, 다시 말해 서브쿼리가 독자적으로 실행된 뒤 메인쿼리에게 그 결과를 던져주는 형태일 경우 비상관 서브쿼리(Non-correlated Subquery)라 한다. 이는 곧 실행 순서가 서브쿼리가 우선되고 이후에 메인 쿼리가 실행되는 것을 의미한다. 이와 반대로 메인 쿼리와 서브쿼리 간에 관계성이 있어 메인 쿼리의 값을 받아 서브쿼리가 실행되는 형태일 경우 상관 서브쿼리(Correlated Subquery)라 한다. 이는 곧 실행 순서가 메인 쿼리가 우선되고 이후에 서브 쿼리가 실행되는 것을 의미한다.

끝으로 반환 결과에 따라 서브쿼리를 구분할 수 있다. 먼저 서브쿼리 결과가 1건의 행으로 반환되는 서브쿼리를 단일행 서브쿼리(Single-row Subquery)라 한다. 이는 `SELECT` 구에서 주로 사용되는 스칼라 서브쿼리와 동일하다. 다음으로 여러 건의 행으로 반환되는 서브쿼리를 다중행 서브쿼리(Multiple-row Subquery)라 한다. 주로 조건절에서 `IN` 키워드와 함께 사용된다. 마지막으로 서브쿼리 결과가 여러 개의 열과 행으로 반환되는 서브쿼리를 다중열 서브쿼리(Multiple-column Subquery)라 한다. 다중행 서브쿼리와 마찬가지로 주로 조건절에서 `IN` 키워드와 함께 사용되지만 출력으로 여러 개의 컬럼이 반환되기 때문에 튜플 형태로 이를 비교해야 한다.

#### DBMS의 어둠? NULL

일부 DBMS에서는 `NULL` 값을 포함한 비교 연산자가 구현되어 있다. 예를 들어 MySQL에서는 아래와 같이 `<=>` 연산자가 독자적으로 존재하여 어느 쪽에 `NULL` 값이 포함되어 있어도 올바르게 비교가 가능하다. 그리고 이를 통해 일반적인 `NULL` 값 전파를 막을 수 있다.

```SQL
SELECT
    Code,
    Name,
    Capital
FROM country
WHERE NULL <=> NULL;
```

위 쿼리는 결국 `NULL` 값과 `NULL` 값에 대한 비교 연산자를 수행하며, `NULL` 값과 `NULL` 값은 같기 때문에 참(True)을 반환해 모든 레코드를 출력한다. 그러나 만약 아래와 같이 일반 비교 연산자를 실행할 경우 `NULL` 값과 `NULL` 값에 대한 동등 비교 연산자(`=`)의 반환 값은 `NULL` 값이기 때문에 아무런 값을 반환하지 않는다. 결국 `NULL` 값 전파란 일반적인 비교 연산자를 활용해 `NULL` 값에 대한 연산을 수행할 경우 그 값이 최종적으로 `NULL` 값을 반환하기 때문에 `NULL` 값이 점차 전파되는 경우를 의미한다. 이러한 맥락에서 외부로부터 매개변수를 전달 받아 비교 연산자를 수행할 때 `NULL` 값을 전달 받는 경우를 고려하여 안전한 비교 연산자(`<=>`)를 사용하는 게 좋다.

```SQL
SELECT
    Code,
    Name,
    Capital
FROM country
WHERE NULL = NULL
```

SQL 표준에는 `NULL` 값이 섞여 비교를 수행하는 `IS NOT DISTINCT FROM` 연산이 정의되어 있다. 예를 들어 PostgreSQL에서는 `IS NOT DISTINCT FROM` 연산을 다음과 같이 사용할 수 있다.

```SQL
SELECT
    Code,
    Name
    Capital
FROM country
WHERE Capital IS NOT DISTRINCT FROM 2331;
```

이를 풀어서 나타내면 아래와 같이 동등 비교 연산자(`=`)와 함께 `NULL` 값인 경우에 대해 `OR` 키워드로 묶은 경우가 된다. 결론적으로 `WHERE` 구 조건에 대해 `NULL` 값 또는 조건으로 주어진 값을 가진 행을 출력하게 되는 것이다.

```SQL
SELECT
    Code,
    Name,
    Capital
FROM country
WHERE (
    Capital = 2331
    OR
    Capital IS NULL
)
```

## [ LeetCode ] 문제 풀이

### 1075. Project Employees I

#### 풀이

`GROUP BY` 구와 함께 `AVG` 집계 함수를 사용하여 문제를 풀이했다.

```SQL
SELECT
    project_id,
    ROUND(AVG(experience_years), 2) AS average_years
FROM Project
JOIN Employee
USING (employee_id)
GROUP BY project_id;
```

이때 결합(Join)을 위해 `LEFT JOIN` 구 대신 `JOIN` 구를 사용한 것을 알 수 있다. 해당 문제 자체는 사실 어떤 구를 사용하더라도 문제를 풀 수 있지만, 실제 쿼리를 실행할 때는 관련해서 고민할 필요가 있다.

우선 실제 문제 조건은 아래와 같다.

_(project_id, employee_id) is the primary key of this table.
employee_id is a foreign key to Employee table._

`project_id` 필드와 `employee_id` 필드가 하나의 쌍(Pair)이 되어 기본 키(Primary Key, PK)가 된다. 이때 튜플 형태로 기본 키가 되더라도 기본 키의 모든 일부는 `NULL` 값이 올 수 없기 때문에 자연스레 `JOIN` 구를 사용할 수 있다는 것을 알 수 있다. `Employee` 테이블 내 특정 행을 삭제할 때 `Project` 테이블 내 외래 키(Foreign Key, FK) `employee_id` 필드의 값으로 `NULL` 값이 오지 못하기 때문에 제한(`RESTRCIT`)이 되거나 함께 삭제(`CASCADE`)가 될 것이기 때문이다.

다음으로 테이블의 메타 데이터를 확인하기 위해서는 `INFORMATION_SCHEMA` 데이터베이스를 사용하면 된다. 이때 MySQL의 경우 데이터베이스와 스키마를 동일한 것으로 간주하기 때문에 스키마(Schema)가 곧 데이터베이스의 정보를 확인하는 것이라 생각하면 된다.

그리고 해당 데이터베이스 내에는 여러 메타 데이터를 분류한 테이블이 존재하는데, 우리는 외래 키 제약조건(Foreign Key Constraint)을 확인하여 `JOIN` 구와 `LEFT JOIN` 구 중 어떤 구를 사용해야 할 지 판단해야 하기 때문에 `KEY_COLUMN_USAGE` 테이블에 접근하여 값을 출력한다. `INFORMATION_SCHEMA` 데이터베이스에 대한 더 많은 정보는 MySQL 공식 문서 [26.2 INFORMATION_SCHEMA Table Reference](https://dev.mysql.com/doc/refman/8.0/en/information-schema-table-reference.html)에서, 그리고 `KEY_COLUMN_USAGE` 테이블에 대한 더 많은 정보는 MySQL 공식 문서 [26.3.16 The INFORMATION_SCHEMA KEY_COLUMN_USAGE Table](https://dev.mysql.com/doc/refman/8.0/en/information-schema-key-column-usage-table.html)에서 확인 가능하다.

실제로 아래와 같은 쿼리를 실행하면 `Project` 테이블의 키와 관련된 메타 데이터 값을 반환 받을 수 있다. 이때 `SHOW databases;` 명령어를 통해 확인해보면 LeetCode의 경우 기본적으로 `test`라는 이름의 데이터베이스에 문제 테이블을 관리하고 있는 것을 알 수 있다.

```SQL
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE (
    REFERENCED_TABLE_SCHEMA = 'test'
    AND
    REFERENCED_TABLE_NAME = 'Project'
);
```

그러나 실제로 출력해보면 LeetCode 내에는 아무런 값이 저장되어 있지 않다. 결국 문제 조건을 통해 추상적인 개념으로 제약 조건을 만들고, 물리적으로는 어떠한 테이블 관계나 제약 조건도 설정하지 않았다는 것을 알 수 있다. 이는 문제 수정을 위해 스키마를 재설계 해야 할 때 마이그레이션 과정에서 이슈를 최대한 덜 적게 겪기 위해 결정한 판단으로 추측할 수 있으며, [GitHub에서 외래 키를 사용하지 않는 이유](https://github.com/github/gh-ost/issues/331#issuecomment-266027731)와 유사한 이유로 결정이라 할 수 있다.

문제 조건을 통해서는 결국 `JOIN` 구를 사용해야 한다는 것을 알게 되었으나, 실제 메타 데이터를 토대로 제약 조건을 판단했을 때는 `LEFT JOIN` 구를 사용할 수 있다. 그렇다면 이런 상황에서는 어떤 구를 사용해야 될까? 정답은 `JOIN` 구다.

MySQL 옵티마이저(Optimizer)의 경우 외부 결합(Outer Join), 다시 말해 `LEFT JOIN` 구를 사용하게 되면 결합되는 테이블을 드라이빙 테이블로 선택하지 못하기 때문이다.

결합을 할 때 테이블에 동시 접근을 할 수는 없기 때문에 테이블 접근에 대한 우선 순위가 생긴다. 이때 먼저 접근하는 테이블을 드라이빙 테이블(Driving Table)이라 하고, 이후에 접근하는 테이블을 드리븐 테이블(Driven Table)이라 한다. 결합하는 과정에서 인덱스에 해당하는 키를 사용할 경우 해당 키를 찾는 인덱스 탐색(Index Seek) 작업은 레코드를 가져오는 인덱스 스캔(Index Scan) 작업에 비해 부하가 크다. 그리고 바로 이 과정에서 드라이빙 테이블의 경우 인덱스 탐색 작업을 한 번만 수행한 뒤에 스캔만 실행하면 되지만, 드리븐 테이블에서는 인덱스 탐색 작업과 스캔 작업을 드라이빙 테이블에서 조회된 레코드 건수만큼 반복하여 테이블을 결합하게 된다. 그래서 옵티마이저는 항상 드라이빙 테이블이 아니라 드리븐 테이블을 최적으로 읽을 수 있게 실행 계획을 수립한다.

그런데 `LEFT JOIN` 구의 경우 앞서 이야기한 것처럼 결합되는 테이블을 드라이빙 테이블로 선택하지 못하기 때문에, 다시 말해 MySQL이 내부적으로 결합을 위한 테이블 접근 우선 순위 수립을 변경할 수 없기 때문이다. 결합되는 테이블을 풀 스캔(Full Scan)해야 하는 상황이 발생할 경우 쿼리의 성능이 떨어지는 실행 계획을 수립할 수밖에 없다.

실제 예시를 한 번 살펴보기 위해 아래와 같이 `Employee` 테이블 내 `employee_id` 값이 `1`인 경우에 대한 결합 결과를 반환 받는 쿼리를 실행한다고 가정해보자.

```SQL
SELECT
    project_id
FROM Project
JOIN Employee
ON (
    Project.employee_id = Employee.employee_id
    AND
    Employee.employee_id = 1
)
```

실제로 `EXPLAIN` 키워드를 붙여 `JOIN` 구를 사용한 실행 계획을 출력해보면 아래와 같다. 직관적인 확인을 위해 `\G` 키워드를 끝에 붙였다.


```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: Employee
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: Project
   partitions: NULL
         type: ref
possible_keys: employee_id
          key: employee_id
      key_len: 4
          ref: const
         rows: 2
     filtered: 100.00
        Extra: Using index
```

다음으로 `LEFT JOIN` 구의 실행 계획을 출력해보면 아래와 같다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: Project
   partitions: NULL
         type: index
possible_keys: NULL
          key: employee_id
      key_len: 4
          ref: NULL
         rows: 5
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: Employee
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using where; Using index
```

우리는 여기서 첫 번째 행, 다시 말해 결합을 위해 가장 먼저 접근한 드라이빙 테이블이 각각 `Employee` 테이블과 `Project` 테이블로 다르며 `rows` 컬럼의 값이 각각 `1`과 `4`로, `type` 컬럼 또한 `const`와 `index`로 다르다는 것을 알 수 있다.

`JOIN` 구를 사용한 경우 결합의 조건으로 `Employee` 테이블의 기본 키, 다시 말해 인덱스 키인 `employee_id` 값을 탐색해야 하고 이 과정에서 최적화를 위해 `Employee` 테이블을 드라이빙 테이블로 선택한 것을 알 수 있다. 그리고 인덱스 키를 탐색하기 때문에 결국 단 하나의 값을 조회하게 되어 실행 계획에서 `type` 컬럼의 값이 `const`로 출력되었으며, `rows` 컬럼 또한 `1`이 출력되었다.

이와 반대로 `LEFT JOIN` 구를 사용한 경우 결합되는 테이블인 `Employee` 테이블이 드라이빙 테이블로 오지 못하기 때문에 `Project` 테이블이 드라이빙 테이블로 선택되었고, 이 과정에서 인덱스를 처음부터 끝까지 전부 조회하는 인덱스 풀 스캔(Index Full Scan)을 해야 하기 때문에 `type` 컬럼의 값이 `index`로 출력되고, `rows` 컬럼의 값도 `Employee` 테이블의 총 행 개수와 동일한 `4`가 출력되었다.

이를 바탕으로 우리는 실제로 문제 해결을 위해 `LEFT JOIN` 구를 사용 했을 때 드라이빙 테이블로 `Employee` 테이블을 조회하지 못하기 때문에 `Project` 테이블에 대해 인덱스 풀 스캔을 실행할 것임을 알 수 있다. 실제로 `EXPLAIN` 키워드를 사용하여 실행 계획을 출력해보면 아래와 같다.

```Bash
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: Project
   partitions: NULL
         type: index
possible_keys: PRIMARY,employee_id
          key: PRIMARY
      key_len: 8
          ref: NULL
         rows: 5
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: Employee
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: 1075.Project.employee_id
         rows: 1
     filtered: 100.00
        Extra: NULL
2 rows in set, 1 warning (0.00 sec)
```

### 608. Tree Node

#### 풀이

먼저 아래와 같이 `UNION ALL` 구와 함께 서브쿼리(Subquery) 중 인라인 뷰(Inline View)를 사용하여 문제를 풀 수 있다.

```SQL
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
        id IN (
            SELECT
                DISTINCT p_id
            FROM tree
            WHERE p_id IS NOT NULL
        )
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
        id NOT IN (
            SELECT
                DISTINCT p_id
            FROM tree
            WHERE p_id IS NOT NULL
        )
    )
) AS LeaftNode;
```

그런데 사실 잘 보면 아래와 같은 쿼리가 인라인 뷰로 반복되고 있는 것을 알 수 있다.

```SQL
SELECT
    DISTINCT p_id
FROM tree
WHERE p_id IS NOT NULL
```

반복되고 있는 부분을 조금 더 효율적으로 활용하기 위해 아래와 같이 공통 테이블 표현식(Common Table Expression, CTE)을 사용하여 더 직관적인 쿼리로 문제를 해결할 수 있다. 공통 테이블 표현식은 단일 명령문(Single Statement) 내에 존재하여 해당 명령문에서 여러 번 참조할 수 있는 임시 결과 집합을 의미한다. 쉽게 해당 명령문 내에서만 사용할 수 있는 임시 테이블이라 생각하면 편하다. 우리가 `CREATE TEMPORARY TABLE` 명령어를 사용하여 임시 테이블을 생성할 경우 물리적인 저장소에 실질적으로 해당 테이블이 저장되는 것은 물론 `CREATE_TEMPORARY_TABLES` 권한(Privilege)을 가지고 있어야 하지만 공통 테이블 표현식의 경우 해당 명령어 내에서만 존재하는 생명 주기(Life Cycle)을 갖고 있기 때문에 메모리 효율적인 것은 물론 권한이 없어도 사용할 수 있다는 장점이 있다. 더욱이 자기 참조(Self Reference) 및 재귀(Recursive) 형태의 쿼리를 쉽게 수행할 수 있게 도와주기 때문에 여러 모로 유용하게 사용할 수 있다.

```SQL
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
```


다음으로 아래와 같이 `CASE` 문 및 서브쿼리(Subquery) 중 스칼라 서브쿼리(Scala Subquery)를 사용하여 문제를 풀 수 있다.

```SQL
SELECT
    id,
    CASE
        WHEN p_id IS NULL THEN 'Root'
        WHEN id IN (SELECT DISTINCT p_id FROM Tree) THEN 'Inner'
        ELSE 'Leaf'
    END AS type
FROM Tree;
```

끝으로 아래와 같이 `LEFT JOIN` 구 및 `GROUP BY` 구를 사용하여 문제를 풀 수 있다. 그런데 자세히 보면 `CASE` 문에 `MAX` 집계 함수를 사용한 것을 알 수 있다.

```SQL
SELECT
    Tree.id,
    MAX(
        CASE
            WHEN Tree.p_id IS NULL THEN 'Root'
            WHEN SubTree.id IS NULL THEN 'Leaf'
            ELSE 'Inner'
        END
    ) AS type
FROM Tree
LEFT JOIN Tree AS SubTree
ON Tree.id = SubTree.p_id
GROUP BY Tree.id;
```

LeetCode 내에서 문제를 풀 때는 집계 함수를 굳이 사용하지 않더라도, 다시 말해 아래와 같이 쿼리를 실행하더라도 문제가 발생하지 않고 정상적으로 원하는 답을 얻을 수 있다.

```SQL
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
GROUP BY Tree.id;
```

그러나 실제로 위를 로컬에 설치한 DBMS에서 실행할 경우 아래와 같은 오류를 반환 받는다.

```Bash
ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'leetcode.SubTree.id' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```

집계의 대상이 아닌 열(Nonaggregated Column)인 `SubTree.id` 값이 존재하여 문제가 발생하고 있으며 이는 `sql_mode` 시스템 변수의 값들 중 `only_full_group_by` 값에 모순되기 때문이라는 의미다.

실제로 `GROUP BY` 구를 제거한, 아래와 같은 쿼리를 실행한다고 가정해보자.

```SQL
SELECT
    Tree.id,
    CASE
        WHEN Tree.p_id IS NULL THEN 'Root'
        WHEN SubTree.id IS NULL THEN 'Leaf'
        ELSE 'Inner'
    END AS type
FROM Tree
LEFT JOIN Tree AS SubTree
ON Tree.id = SubTree.p_id;
```

위 쿼리는 결과적으로 아래와 같은 값을 반환한다. 우리는 `GROUP BY` 구의 대상 필드로 `Tree.id` 필드를 선정했기 때문에 DBMS 입장에서 중복된 값을 없애고 어떤 값을 선정해야 하는지 알고 있다. 그러나 최종적으로 `type` 필드의 경우 DBMS 입장에서 동일한 `Root` 값만 존재한다고 하더라도 어떤 행의 `Root` 값을 선정해야 하는지 알 수 없기 때문에 오류를 반환한 것이다. 그리고 이는 표준 SQL의 규칙이다.

```Bash
+----+-------+
| id | type  |
+----+-------+
|  1 | Root  |
|  1 | Root  |
|  2 | Inner |
|  2 | Inner |
|  3 | Leaf  |
|  4 | Leaf  |
|  5 | Leaf  |
+----+-------+
```

그렇다면 LeetCode에서는 어째서 오류를 반환하지 않고 원하는 결과를 얻을 수 있던 걸까? 이는 앞서 이야기한 `sql_mode` 시스템 변수의 값들 중 `only_full_group_by` 값과 연관되어 있다. MySQL의 공식 문서 [5.1.11 Server SQL Modes](https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html#sqlmode_only_full_group_by)를 살펴보면 아래와 같은 표현이 나온다.

_Reject queries for which the select list, HAVING condition, or ORDER BY list refer to nonaggregated columns that are neither named in the GROUP BY clause nor are functionally dependent on (uniquely determined by) GROUP BY columns._

이는 곧 `only_full_group_by` 값이 시스템 변수로 저장되어 있을 경우 집계의 대상이 아닌 열(Nonaggregated Column)을 참조하는 쿼리를 사용할 수 없다는 의미다.

우선 아래와 같이 공통 테이블 표현식의 재귀적 표현을 사용하여 실제로 `sql_mode` 시스템 변수로 어떤 값이 저장되어 있는지 한 번 확인해보자. 첫 `SELECT` 구를 실행한 뒤에 `UNION ALL` 키워드를 토대로 `remain` 값이 빈 문자열(`''`)이 아닐 때까지 자동으로 아래 행이 추가되는 방식이다.

```SQL
WITH RECURSIVE cte (variable, remain) AS (
    SELECT
        IF(
            LOCATE(',', @@sql_mode) = 0,
            @@sql_mode,
            LEFT(@@sql_mode, LOCATE(',', @@sql_mode) - 1)
        ) AS variable,
        IF(
            LOCATE(',', @@sql_mode) = 0,
            '',
            SUBSTRING(@@sql_mode, LOCATE(',', @@sql_mode) + 1)
        ) AS remain
    UNION ALL
    SELECT
        IF(
            LOCATE(',', remain) = 0,
            remain,
            LEFT(remain, LOCATE(',', remain) - 1)
        ) AS variable,
        IF(
            LOCATE(',', remain) = 0,
            '',
            SUBSTRING(remain, LOCATE(',', remain) + 1)
        ) AS remain
    FROM cte
    WHERE remain <> ''
)

SELECT variable
FROM cte;
```

그러면 아래와 같은 결과를 반환 받을 수 있다. 이때 `ONLY_FULL_GROUP_BY` 값이 포함되어 있는 것을 알 수 있으며, 이외에도 나눗셈 연산을 실행할 때 0을 분모로 할 수 없는 제약을 의미하는 `ERROR_FOR_DIVISION_BY_ZERO` 변수 등이 있다.

```Bash
+----------------------------+
| variable                   |
+----------------------------+
| ONLY_FULL_GROUP_BY         |
| STRICT_TRANS_TABLES        |
| NO_ZERO_IN_DATE            |
| NO_ZERO_DATE               |
| ERROR_FOR_DIVISION_BY_ZERO |
| NO_ENGINE_SUBSTITUTION     |
+----------------------------+
```

해당 쿼리를 LeetCode에서 실행해보면 아래와 같이 빈 값을 반환 받는다. 다시 말해 어떠한 `sql_mode` 시스템 변수 값도 설정 되어 있지 않다는 것을 의미하며 이러한 이유 때문에 어떤 값을 선택해야 하는지 DBMS가 모르더라도 임의의 값을 선정하여 반환하였고, 어떤 임의의 값이라도 전부 동일하기 때문에 별다른 문제가 발생하지 않고 문제를 해결할 수 있었던 것이다.

```Bash
| variable |
| -------- |
|          |
```


추가로 `MAX` 집계 함수를 사용하지 않고 아래와 같이 `GROUP BY` 구에 튜플 형태로 필드를 전달하는 것도 좋은 방법이 될 수 있다. 이때 MySQL의 경우 DBMS 내부에서 `GROUP BY` 구에 사용된 별칭을 내부적으로 처리하기 때문에 최종적으로 `CASE` 문의 결과인 `type` 컬럼을 `GROUP BY` 구의 대상으로 전달해도 문제가 발생하지 않는다.

```SQL
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
```

#### 기타

SQL 명세에는 반복문(Loop Statement)이 존재할까? MySQL의 경우 공식 문서 [13.6.5.5 LOOP Statement](https://dev.mysql.com/doc/refman/8.0/en/loop.html)를 살펴보면 프로시저(Procedure) 형태로 반복문을 생성해서 사용할 수 있다. 그러나 기본적으로 관계형 데이터베이스는 처음 설계 때 반복문을 사용하지 않는 것으로 결정했다. 실제 관계형 데이터베이스를 처음 고안한 Edgar F. Codd의 저서 [The Relational Model for Database Management 2판](https://dl.acm.org/doi/book/10.5555/77708)을 살펴보면 아래와 같은 표현이 등장한다.

_The relational approach is very powerful and flexible in access to information (by means of ad hoc queries from terminals) and in inter-relating information without resorting to programming concepts (e.g., iterative loops and recursion)._

다시 말해 관계형 접근 방식은 반복문, 재귀와 같은 기존 프로그래밍 개념에 의존하지 않고 정보에 접근하거나 관계를 만드는데 강력하고, 유연하게 사용될 수 있다는 의미다. 관련해서는 SQL 레벨업 5장 반복문에서 더 자세하게 다룬다.