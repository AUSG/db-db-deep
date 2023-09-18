# 7장 - 트랜잭션과 동시성 제어

## 트랜잭션

- 단일한 논리적인 작업 단위
- 논리적인 이유로 여러 SQL문들을 단일작업으로 묶어서 나눠질 수 없게 만드는 것이 transaction이다.
- transaction의 SQL문들 중에 일부만 성공해서 DB에 반영되는 일은 일어나지 않는다.

```java
mysql> use TransactionTest
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+---------------------------+
| Tables_in_TransactionTest |
+---------------------------+
| account                   |
+---------------------------+
1 row in set (0.00 sec)

mysql> START TRANSACTION;
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE account SET balance = balance - 20000 where name = "철수";
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> UPDATE account SET balance = balance + 20000 where name = "영희";
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> COMMIT;
Query OK, 0 rows affected (0.00 sec)

mysql>
```

### COMMIT

- 지금까지 작업한 내용을 DB에 영구적으로 저장하는 것
- transaction을 종료한다.

### 결과

```java
mysql> select * from account;
+----+---------+--------+
| id | balance | name   |
+----+---------+--------+
|  1 |  220000 | 영희   |
|  2 |  980000 | 철수   |
+----+---------+--------+
2 rows in set (0.01 sec)
```

## ROLLBACK

- 지금까지 작업들을 모두 취소하고 transaction 이전 상태로 되돌린다.
- transaction을 종료한다.

```java

mysql> START TRANSACTION;
Query OK, 0 rows affected (0.01 sec)

mysql> UPDATE account SET balance = balance - 200000 where name = "철수";
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from account;
+----+---------+--------+
| id | balance | name   |
+----+---------+--------+
|  1 |  220000 | 영희   |
|  2 |  780000 | 철수   |
+----+---------+--------+
2 rows in set (0.01 sec)

mysql> ROLLBACK;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from account;
+----+---------+--------+
| id | balance | name   |
+----+---------+--------+
|  1 |  220000 | 영희   |
|  2 |  980000 | 철수   |
+----+---------+--------+
2 rows in set (0.00 sec)
```

## AUTOCOMMIT

- 각각의 SQL문을 자동으로 transaction 처리 해주는 개념
- SQL문이 성공적으로 실행되면 자동으로 commit 한다.
- 실행 중에 문제가 있었다면 알아서 ROLLBACK 한다.
- MYSQL에서는 default로 autocommit이 enabled 되어 있다.
- 다른 DBMS에서도 대부분 같은 기능을 제공한다.

<b> AUTOCOMMIT 활성화 여부 확인 </b>
1 == True

```java

mysql> SELECT @@AUTOCOMMIT;
+--------------+
| @@AUTOCOMMIT |
+--------------+
|            1 |
+--------------+
1 row in set (0.01 sec)

```

- AUTOCOMMIT이 활성화 되어있는 상태에서 SQL문 수행 시 자동적으로 COMMIT.

```java
mysql> INSERT INTO account (balance, name) VALUES (400000, '호식');
Query OK, 1 row affected (0.03 sec)

mysql> select * from account;
+----+---------+--------+
| id | balance | name   |
+----+---------+--------+
|  1 |  220000 | 영희   |
|  2 |  980000 | 철수   |
|  3 |  400000 | 호식   |
+----+---------+--------+
3 rows in set (0.00 sec)
```

### AUTOCOMMIT이 비활성화 된다면?

```java
mysql> SET AUTOCOMMIT=0;
Query OK, 0 rows affected (0.00 sec)

mysql> DELETE FROM account where balance <= 900000;
Query OK, 2 rows affected (0.04 sec)

mysql> select * from account;
+----+---------+--------+
| id | balance | name   |
+----+---------+--------+
|  2 |  980000 | 철수   |
+----+---------+--------+
1 row in set (0.00 sec)
```

AUTOCOMMIT을 OFF 한 후에 DELETE 수행했기에 ROLLBACK 수행 시 다시 이전 상태로 돌아갈 수 있다.

```java
mysql> ROLLBACK;
Query OK, 0 rows affected (0.01 sec)

mysql> select * from account;
+----+---------+--------+
| id | balance | name   |
+----+---------+--------+
|  1 |  220000 | 영희   |
|  2 |  980000 | 철수   |
|  3 |  400000 | 호식   |
+----+---------+--------+
3 rows in set (0.09 sec)
```

그렇다면, 다음과 같은 의문이 들 수 있다
위에서 본 서로 예금을 주고 받는 쿼리 역시 AUTOCMMIT이 되는 것 아니야 ?
하지만, MySQL에서는 START TRANSACTION 실행과 동시에 AUTOCOMMIT은 '비'활성화된다.
그래서, 트랜잭션을 시작한 후에는 자동적으로 COMMIT이 되지않고, 비로소 COMMIT이라는 명령을 내려야 DB에 반영된다.

그리고 COMMIT/ROLLBACK과 함께 트래잭션 종료 시, "원래" AUTOCOMMIT 상태로 돌아간다.
그래서 START TRANSACTION 수행 이전에 오토커밋이 활성화 되어있다면, 트랜잭션 종료시 기존의 활성화된 상태로 돌아간다.

## 일반적인 트랜잭션 사용 패턴

1. Transaction 시작(begin) 한다.
2. 데이터를 읽거나 쓰는 등의 SQL문들을 포함해서 로직을 수행한다.
3. 일련의 과정들이 문제없이 동작했다면 transaction을 commit 한다.
4. 중간에 문제 발생 시 ROLLBACK.

### pseudocode로 알아보는 트래잭션 예시

```java

public void transfer (String fromld, String told, int amont) {

    try {

        Connection connection = ...;  // get DB connection.
        connection.setAutoCommit(false); // AUTOCOMMIT 속성을 false로 지정  == 'START TRANSACTION' 💫
        ...
        ...   // 비지니스 로직 구현

        connection.commit();  // 로직 성공적으로 수행 시 커밋 수행

    } catch (Exception e) {

        ...
        connection.rollback(); // 예외 발생 시 ROLLBACK 처리.

    } finally {

        connection.setAutoCommit(true); // 커밋이 됬든 롤백이 됬든 ROLLBACK 속성은 true로 변경. 이유 : 해당 커넥션은 일회용이 아닌 재사용되므로 원래가지고 있던 기존의 상태로 변경 필요. 따라서, '단일' SQL문을 실행해도 바로바로 COMMIT이 됨.

    }
}
```

하지만 지금은 트랜잭션 처리 로직과 비지니스 로직이 짜장면 아니, 짬뽕되어 있음.

따라서 스프링 부트로 개발 시 , @Transactional 이라는 어노테이션 사용 시 트랜잭션과 관련된 부가적인 코드는 숨길 수 있음.

따라서 실제 이체와 관련된 코드는 다음과 같이 작성됨.

```java

public void transfer(String fromId, String toId, int amount) {

    ...  //update at fromId

    ... // update at toId

}

```

## ACID

### Atomicity

- 위에서 살펴본 이체의 경우 모든 SQL 로직이 순리대로 돌아가야 의미가 있는 작업이 됨.
- 따라서 기면 기고 아니면 아닌 정책
- 모두 성공하거나 모두 실패하거나
- 원자성
- ALL OR NOTING
- 살라면 사고 아니면 마이소!
- transaciton은 논리적으로 쪼갤 수 없는 단위이기에 내부의 SQL문들이 '모두' 성공해야 한다.
- 중간에 실패가 발생하면 지금까지 수행된 모든 작업을 취소해 마치 아무일도 없었던 것처럼 rollback.
- 그럼 DBMS가 담당하는 부분과 개발자가 담당하는 부분의 경계는>

#### commit 실행 시 DB에 영구적으로 저장하는 것 -> DBMS

#### rollback 실행 시 이전 상태로 되돌리는 것도 -> DBMS

#### commit / rollback '실행시점' 결정 -> 개발자 ! 즉, 트랜잭션의 단위를 얼마만큼의 SQL문의 단위 집합으로 정의를 내릴 것이냐 + 어떤 문제가 발생 시 rollback을 수행할 것이냐

문제가 발생한다고 하더라도 무조건 롤백 수행이 아닌 다른 로직으로 처리해 해당 로직을 처리할 수도 있기에 그렇다.

### Consistency

가령, CREATE TABLE account ( ... , balacne INT, <b>check(balance>=0)</b> ) 과 같이 특정 계좌에 대한 최소금액은 0원 이상이 되어야 한다는 조건을 걸었다고 가정하자.

해당 조건 아래, 특정 개인이 이체를 수행 후 자신의 계좌가 0원 미만으로 떨어진는 SQL문을 실행한다면 해당 SQL문은 데이터베이스의 일관성을 깨뜨리는 행위가 된다.

따라서, 해당 transaction은 해당 쿼리문을 실행시키지 않고 ROLLBACK을 수행한다.

- transaction DB 상태를 consistent 상태에서 또 다른 consistent 상태로 바꿔줘야 한다.
- constraints, trigger 등을 통해 DB에 정의된 rules을 transaction이 위반했다면 롤백을 해야한다.
- transaciton이 DB에 정의된 rule을 위반했는지 DBMS가 commit 전에 확인하고 알려준다.
- 하지만, DBMS에만 100프로 의존할 수 없으므로 DB에 정의된 룰 이외에도 어플리케이션 관점에서 트랜잭션이 consistent하게 동작하는지 개발자가 챙겨야 한다.

### Isolation

현재 철수의 계좌에는 100만원이 있다.

영희가 철수에게 20만원을 입금하였고 해당 입금을 수행하기위해 현재 잔액인 100만원을 읽어왔다. 하지만 하필 동시다발적으로 철수가 본인 계좌에 현금 30만원을 입금하였다.
따라서 30만원에 대한 트랜잭션이 우선적으로 발생해 현재 철수의 현재 계좌 잔액에 대한 read가 수행되고 영희가 보낸 20만원은 입금되기 이전이므로 입금 전의 금액인 100만원을 읽어온다.

그러고 본인이 입금한 30만원의 금액만 추가된 금액 130만원에 대한 write 연산이 수행되고 commit 후 해당 트랜잭션은 끝을 맺는다.

하지만 우리에겐 영희가 20만원을 입금하는 트랜잭션이 수행중임을 잊으면 안된다. 영희는 최초에 100만원에 대한 read를 수행했기에 현재 30만원이 입금되기 전의 계좌 잔액으로 인식한다.

따라서, 100만원에 20만원을 더한 120만원을 write 한다.그러고 나서 해당 트랜잭션이 종료되고 철수가 입금한 30만원에 대한 입금액은 사라지게 되는 이상한 현상이 발생한다.

즉, 여러 트랜잭션이 동시다발적으로 이루어짐에 따라 발생하는 기이한 현상 중 하나이다.

- 여러 트랜잭션들이 동시에 실행됨에도 불구하고 마치 각각의 트랜잭션들이 혼자 실행되는 것처럼 동작하게 만든다
- DBMS는 여러 종류의 isolation level을 제공한다.
- 개발자는 isolation level 중에 어떤 레벨로 트랜잭션을 처리할지 설정할 수 있다.
- concurrecny control(동시성 제어)의 주된 목표가 isolation 이다.

### Durability

특정 쿼리 commit 후 해당 트랜잭션은 DB에 영구적으로 저장된다.

여기서 영구적이라는것은 전원이 나간다거나 혹은 DB에 Crash가 발생해 DB 서버가 죽어버림에도 불구하고 commit된 트랜잭션은 한 번 데이터베이스에 기록됬으므로 DB에 여전히 남아있다라는 의미이다.

- 일반적으로 비휘발성 메모리에 저장됨
- 기본적으로 트랜잭션의 지속성은 DBMS가 보장

# 트랜잭션들이 동시에 실행될 때 발생 가능한 이상 현상들 (Isolation Level)

x = 10 , y = 20 이 있다고 하자.

Transaction 1 : x에 y를 더한다
Transaction 2 : y를 70으로 바꾼다.

### [ 문제 가능성 지점 ] - Dirty Read

1. Transaction1을 수행하기 위해 read(x) => 10
2. 그리고 y를 더하기 위해 y값을 읽어야 하는데 해당 타이밍에 Transaciton 2가 끼어들어 Write(y=70) 수행.
3. y = 70 으로 업데이트 됨.
4. Transaction 1 이 재수행 되어서 read(y) => 70
5. write(x=80) (10+70)
6. x = 80 , y = 70
7. T1 commit 후 종료.

그런데,

T2에 대한 문제가 생겨 ABORT 됨. 따라서 롤백이 수행되어 y=20 으로 변경됨

여기서 문제는 T1에 대한 80의 결과는 T2가 y를 70으로 변경했기 때문에 나올 수 있었던 결과이다.
그런데 T2가 롤백을 해버렸기 때문에 70의 값은 유효한 값이 아니다.

따라서, 연장선상의 관점에서 T1에서 기록된 80 역시 정상적인 값이 아니게 된다.

이러한 현상을 Dirty Read 라고함.
==> commit되지 않은 변화를 읽음

### [ 문제 가능성 지점 2 ] - Non-Repeatable Read

x = 10 이다.

T1 : x를 두 번 읽는다.
T2 : x에 40을 더한다.

1. T1이 실행되어 read(x) => 10
2. T2가 실행되고 40을 더해주기 위해 read(x)를 우선적으로 수행하고 40을 더하는 write(x=50)을 수행한다.
3. T2 commit
4. T1이 read(x) => 50 수행.

여기서 문제의 지점은 "같은" T1 안에서 "같은" 데이터를 읽었음에도 불구하고 서로 다른 값을 읽게되는 것.
트랜잭션의 고립성의 속성은 여러 트랜잭션이 동시다발적으로 수행됨에도 불구하고 각각의 트랜잭션들이 마치 "혼자서" 수행되는 것처럼 동작해야 한다는 것인데, 그러면 T1은 같은 데이터를 두번 세번 아니 백번을 읽어도 같은 값을 읽어야 한다.

==> Non-Repeatable Read == Fuzzy Read (반복할 수 없는 읽기)

### [ 문제 가능성 지점 3 ] - Phantom read

Tuple t1 (..., v=10)
Tuple t2 (..., v=50) 이 있다.

T1 : v가 10인 데이터를 두 번 읽는다.
T2 : t2의 v를 10으로 바꾼다.

1. v가 10인 튜플을 읽는다 : read(v=10) => t1
2. T2가 실행되어 t2의 v값을 10으로 바꾸는 write(t2,v=10) 수행 => t2(..., v=10)
3. T2 COMMIT 수행
4. T1은 두 번 읽는 것이기에 v=10인 튜플을 읽으려고 시도.
5. read(v=10) => t1,t2 둘 다 반환 후 COMMIT

여기서 문제점은 동일한 조건으로 두 번을 읽었는데 각각의 결과가 t1, (t1,t2)로 다름.
따라서 하나의 트랜잭션 안에서 "같은" 조건을 수행했음에도 불구하고 고립성의 가치에 부합하지 못하는 "다른"결과가 나옴

===> Phantom read (없던 데이터가 생김)

결론적으로, Dirty Read, 반복할 수 없는 읽기, Phantom Read는 피할 수 있어야 한다.
하지만 그렇게되면 제약사항이 많아져 동시 처리 가능한 트랜잭션 수가 줄어들어 결국 DB의 전체 처리량이 하락한다.

그러므로 일부 이상한 현상은 허용하는 몇 가지 레벨을 만들어 사용자가 필요에 따라 적절하게 선택할 수 있게함.

---

## Isolation Level

1. Read uncommited => 세가지 모두 허용

- 좋게 말하면 가장 자유로운 레벨이기에 동시성 수준이 좋아 전체 처리량을 좋음 반대로는 위에서 언급한 사례들이 가장 빈번하게 나올 수 있는 수준

2. Read committed (커밋된 데이터만 읽음) => Dirty Read (X), 반복할 수 없는 읽기(O), Phantom Read(O)

3. Repeatable read -> Dirty Read (X), 반복할 수 없는 읽기(X), Phantom Read(O)

4. Serialize -> Dirty Read (X), 반복할 수 없는 읽기(X), Phantom Read(X)

- 시리얼라이즈는 위에서 언급한 3가지 상황에 추가적으로 어떠한 이상한 상황이 발생하지 않는 레벨을 뜻함.

세가지 현상을 정의하고 어떤 현상을 허용하는지에 따라 각각의 고립성 수준이 구분된다.
어플리케이션 설게자는 고립성 수준을 통해 전체 처리량과 데이터 일관성 사이에서 어느 정도 trad-off 를 고려해야 한다.

---

지금까지 언급한 3가지의 이상 징후는 1992년도 11월에 발표된 SQL 표준에서 정의된 내용 (Information technology - Database languaes - SQL) 이다.

하지만 해당 표준 내용을 비판하는 논문이 95년도에 발표되는 해당 내용은 다음과 같다.

1. 세 가지 이상 현상의 정의가 모호하다.
2. 이상 현상은 세가지 이외에도 더 있다.
3. 상업적인 DBMS에서 사용하는 방법을 반영해서 고립성 수준을 구분하지 않았다.

---

## 95년도에 발간된 논문에서 정의한 이상한 현상

### [ 이상 현상 1]

x = 0 이다.

T1: x를 10으로 바꾼다.
T2: x를 100으로 바꾼다.

1. T1 먼저 수행 시 write(x=10) 수행
2. x= 10 으로 변경
3. T2가 write(x=100) 수행 시 x= 100으로 변경.
4. T1 abort가 되어서 롤백이 되면 x = 0 으로 바꿔줘야 하는데 이렇게 되면 3번에서 수행된것이 무용지물 되기에 롤백 작업 수행을 안했다고 가정.
5. 그러던 중 T2 역시 abort가 되면 이전의 값으로 변경해야 하는데 그 값은 10.
6. 하지만 10 역시 4번에서 abort가 된 값이기에 10으로 돌려놓으면 안된다.

이처럼 두개의 트랜잭션이 "write" 수행하고 롤백을 하는 상황에서 이상한 현상이 발생하는 것을 => Dirty Write.
--> 커밋이 안된 데이터를 write 할 때 발생 가능.

추가적으로 T2에서 write(x=100)이 COMMIT이 된 후 T1이 abort가 되어 x=0으로 돌려놓게 되면 T2의 wirte(x=100)이 COMMIT까지 됬음에도 사라지게 된다.

따라서 롤백시 정상적인 recovery는 매우 중요하기 때문에 모든 고립성 수준에서 Dirty Write를 허용하면 안된다.

### [ 이상 현상 2]

x = 50이다.

T1 : x에 50을 더한다.
T2 : x에 150을 더한다.

1. T1 수행하여 read(x) => 50
2. T2가 수행되어 x를 읽는다 (50), 150을 더해 write(x=200)
3. x=200으로 업데이트되고 COMMIT 수행
4. 이어 T1은 사전에 읽은 x의 값 50에 50을 더해 write(x=100)수행 후 COMMIT

해당 과정의 문제는 T2의 COMMIT 결과가 완전히 사라지는 형국임.
만약 T1,T2가 차례를 지켜 실행되었가면 x의 결괏괎은 250 이었을 것.
하지만 겹쳐 진행되다 보니 T2의 작업이 아예 사라짐
===> Lost Udpate

은행 계좌 이체로 비유 시 50만원을 입금하고

### [ 이상 현상 3]

이상 현상1에서 특정 transaction의 abort가 발생되어 ROLLBACK이 발생하면 중간에 특정 transaction이 바꿔놓은 값을 읽게된 다른 transaction은 유효하지 않은 데이터를 읽게된 형국을 살펴보았다.

하지만, 꼭 ROLLBACK을 수행하지 않아도 Dirty Read가 되는 상황을 살펴보겠다.

x = 50 , y = 50

T1 : x가 y에 40을 이체한다.
T2 : x와 y를 읽는다.

1. T1이 사직되어 read(x=50) 수행.
2. x에서 40을 빼고 write(x=10) 수행.
3. x=10 으로 변화시켜줌.
4. T2가 수행되어 read(x=10) 수행
5. 연이어 read(y=50) 수행
6. T2 COMMIT 후 종료
7. T1은 x에서 40 뺀 값을 y에 더하기 위해 read(y=50) 수행.
8. 40을 더해 write(y=90) 수행 후 COMMIT.

겉보기엔 문제가 없는 것 처럼 보인다. 하지만 자세히 살펴보면 x=10, y=90이라는 결괏값을 합치면 100이지만 T2에서 읽은 값들을 합치면 60이 되는 즉, 데이터 정합성이 깨지는 데이터 불일치가 발생

COMMIT되지 않은 데이터를 읽을 때 이상현상1에서는 롤백이 수반되어야지만 문제가 발생하는 것처럼 얘기했지만 지금같은 경우엔 롤백이 발생하지 않더라도 Dirty Read라고 주장한다.

### [ 이상 현상 3-2]

1. T2이 read(x=50) 수행.
2. T1이 read(x=50) 수행.
3. T1을 지속적으로 수행하기 위해 x = 50에서 40을 빼고 write(x=10) 수행
4. x = 10 으롭 변경
5. y에 40을 더해주기 위해 우선적으로 y값 읽음 read(y=50)
6. 50+40을 수행해 write(y=90) 수행
7. y=90 으로 변경
8. T1 COMMIT 수행
9. T2의 나머지 수행동작인 read(y=90) 수행

문제점은 디비 상 x,y값의 합은 100인데 T2가 각각 읽게된 값의 합은 140된다. (데이터 불일치)
==> Read Skew (inconsistent한 데이터 읽기)

## SNAPSHOT ISOLATION

앞서 95년도에서 발표한 내용 중 3번의 내용이 "상업적인 DBMS에서 사용하는 방법을 반영해서 고립성 수준을 구분하지 않았다." 라는 점이었는데 논문에서는 대안으로 소개한 ISOLATION LEVEL이 있다. (SNAPSHOT ISOLATION)

기존에 발표한 논문에서는 이상현상들을 사전에 정의하고 해당 이상 현상들에 대한 허용 유무에 따라 고립성 수준에 따른 정도를 구분했다면, SNAPSHOT ISOLATION은 Concurrency Contorl이 어떻게 구현될지에 대한 정의를 바탕으로 정의된 ISOLATION LEVEL 이다.

즉, 고립성 수준을 "어떻게 구현" 할 것인지에 따라 결정됨.

### [ 예제 ]

x = 50, y = 50 이다.

T1 : x가 y에 40을 이체한다.
T2 : y에 100을 입금한다.

1. T1 시작 -> read(x=50)
2. 해당 트랜잭션의 고립성 수준은 스냅샷을 통해서 구현하는데 스냅샷을 찍는 시점은 해당 트랙재션이 "시작"하는 지점이다.
3. 따라서, T1이 read(x=50)을 읽는 첫 트랜잭션이 시작되는 시점에서의 x=50을 스냅샷에 기록한다.
4. T1은 x에서 40을 뺀 10을 DB에 바로 기록하는것이 아닌 사전에 찍어놓은 스냅샷에 기록.
5. 따라서 스냅샷에는 x=10이 기록되어있고 DB에서는 아직 변화되지 않은 50의 값이 기록되어 있다.
6. T2가 시작되어 read(y=50) 수행 => x와 마찬가지로 y=50의 값을 스냅샷에 기록.
7. 100 입금 후 write(y=150)을 수행 후 스냅샷에 기록 : y=150
8. T2가 COMMIT 하는 순간 y=150이라는 값이 DB에 적용
9. 따라서 이 이후 y의 값을 읽어야만 하는 트랜잭션들은 150의 값을 읽게 된다.
10. T1의 남은 연산 (y에 40을 더해주는 것)을 수행하기 위해 read(y) 수행

11번으로 들어가기전에 ! 여기서 T1이 읽게 되는 값은 150일까? NO!!!
그 이유는 T1이 최초에 스냅샷을 찍은 시점은 y=50이었기에 최초의 시점을 기준으로 해당 값을 읽게됨.

11. 따라서 y=50에 40을 더해 write(y=90) 수행
12. T1의 스냅샷에 y=90 기록

그러고나서 T1이 커밋을 하려고하는데 y에 대해 동일하게 write한 흔적이 존재.
따라서 T1을 커밋하게 되면 y=90으로 DB의 값도 변경이 되고 T2가 수행한 y에 대한 업데이트는 무용지물이 됨.

하지만, 스냅샷 고립수준에서는 같은 데이터에 대해서 중복 쓰기가 발생했을 때 "먼저" 커밋된 트랜잭션만 인정해주어 뒤에 커밋을 시도하려는 트랜잭션에 대해서는 Abort 처리.

따라서, T1에 기록된 스냅샷의 기록은 모두 폐기된다.

이렇게 동작하는 것을 MVCC(= Multiversion concurrency control)의 한 종류라고 한다.

정리하자면 해당 고립의 큰 특징 두 가지는

- 트랜잭션 시작 전에 commit된 데이터만 보임
  -> T1이 y값을 읽을 때 T2에 의해 150이 되었음에도 불구하고 T1의 시작 시점 시 y의 값은 50이었기에 y=50이라고 읽음

- First - commiter WIN !
  -> 같은 데이터에 대해 write conflict가 발생 시 먼저 커밋된 트랜잭션이 승리자 그 뒤의 충돌되는 커밋은 삭제됨

## 실무에서 사용되는 RDBMS에서의 고립성 수준 정의

- MySQL (innoDB) -> 표준에서 정의한 고립성 수준과 동일하게 정의 (Serializable, Repeatable Read, Read Committed, Read Uncommitted)

- Oracle -> Read Committed, Serializable(SNAPSHOT ISOLATION)

- SQL SEVER -> 표준SQL에서 정의한 고립성 수준을 택함 (Dirty Read, Non-Repeatable Read, Phantom)

- PostgreSQL -> Serializable, Repeatable Read(SNAPSHOT), Read Committed, Read Uncommitted

# LOCK을 활용한 Concurrency Control 구현하기

실제로 데이터를 읽고 쓰는 일은 파일처리 등과 같이 복잡한 로직이 함께 끼어있을 수 도 있으며 또한 같은 데이터에 read/write 동작이 동시적으로 수행된다면 예상치 못한 동작을 유발할 수 있다.

다음과 같은 상황을 가정하자.

#### [situation 1.]

x = 10이다.

T1 : x를 20으로 바꾼다.
T2 : x를 90으로 바꾼다.

1. T1이 작업을 수행하기 위해선 write_lock(x)을 수행해야 한다.
2. 동시에 T2가 수행 시작. -> write_lock(x) 시도. 하지만 이미 x에 대한 락은 T1이 쥐고 있기에 T2는 기다려야 한다.
3. T1은 write(x=20) 수행하고 DB에서 x의 값은 20으로 바뀐다.
4. T1은 자신의 업무가 끝났기에 unlock(x) 수행
5. 기다리던 T2가 반납된 락의 티켓을 거머쥐고 write(x=90) 수행
6. x = 90으로 기록됨
7. T2는 unlocK(x) 수행

#### [situation 2.]

x= 10.

T1 : x를 20으로 바꾼다
T2 : x를 읽는다

1. T1이 write_lock(x) 수행
2. T2는 x를 읽기 위해 read_loc(x) 수행 그렇지만 이미 T1이 티켓을 가지고 있기에 T2는 기다려야함.
3. T1은 write(x=20)
4. x = 20
5. unlock(x)
6. T2가 티켓 쥐고 read_lock(x)
7. read(x) => 20
8. unlock(x)

여기까지 정리하면,

write_lock(exclusive lock)은 <b>read/write</b> 할 때 사용 핵심은 exclusive하다라는 특징
즉, write_lock에 대한 티켓을 특정 트랜잭션이 거머쥐면 다른 트랜잭션은 해당 데이터에 대해서 Read/Write 수행 불가

read-lock(shared lock)은 read 할 때 사용. write 할 땐 read-lock 사용 X. 해당 락은 다른 트랜잭션이 같은 데이터를 동시에 read하는 것을 허용 대신에 내가 읽고 있을 때 다른 트랜잭션의 write 시도는 차단 !

#### [situation 3.]

x = 10
T1 : x를 20으로 바꾼다
T2 : x를 읽는다.

1. T2가 먼저 시작되어 read_lock(x) 수행
2. T1이 시작돼 write_lock(x)를 시도하지만 이미 락이 걸려있기에 T1은 대기.
3. T2가 read(x=10) 수행 후 unlock(x)
4. T1이 write_lock(x) 획득
5. write(x=20) 수행 후 unlock(x)

#### [situation 4.]

x = 10
T1 : x를 읽는다.
T2 : x를 읽는다.

1. T2가 먼저 시작되어 read_lock(x) 수행
2. T1이 시작되어 read_lock(x) 수행
3. read_lock 같은 경우에 같은 트랜잭션이 같은 데이터에 대해서 단순 "읽기" 수행을 하는 경우라면 허용
4. T1도 read_lcok 획득
5. T1:read(x=10), T2:read(x=10) 둘 다 수행 가능

### 프로그래머스 문제 (https://school.programmers.co.kr/learn/courses/30/lessons/59413)

정답

```
SELECT HOUR, COUNT(ANIMAL_ID) AS 'COUNT'
FROM (
  SELECT 0 AS HOUR UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
  UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
  UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14
  UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19
  UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24
) AS hours
LEFT JOIN ANIMAL_OUTS ON EXTRACT(HOUR FROM DATETIME) = hours.HOUR
GROUP BY hours.HOUR
ORDER BY hours.HOUR ASC;

```

우선 처음엔 아래와 같이 해당 시간대만 추출해서 해당 시간대에 아이디가 있으면 집계시켜줌.

```
SELECT EXTRACT(HOUR FROM DATETIME) AS 'HOUR', COUNT(ANIMAL_ID) AS 'COUNT'
FROM ANIMAL_OUTS
GROUP BY HOUR
ORDER BY HOUR ASC;

```

근데 이렇게 하면 시간대(0-24시간)에 없는 것들은 집계가 안됨

따라서 임시 테이블 즉, 0-24시간을 다 담고 있는 테이블을 만들어야함.

```
FROM (
  SELECT 0 AS HOUR UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
  UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
  UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14
  UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19
  UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24
) AS hours
```

위와같이 입력 시

```
HOUR
0
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
```

다음과 같은 테이블이 생성됨.

그러고 나서, hours 테이블을 기준으로 ANIMAL_OUT와 조인 수행. 왼쪽 조인은 ANIMAL_OUT에서 추출한 시간대와 hours 테이블을 조인 (단 여기서 일치하는 값이 없으면 NULL)

- EXTRACT(HOUR FROM DATETIME)은 ANIMAL_OUTS 테이블의 DATETIME 열에서 시간을 추출

중요한 점은

왼쪽 조인(LEFT JOIN)을 사용할 때, 조인 기준 열에 맞지 않는 경우 (즉, 일치하는 행이 없는 경우) 결과로 NULL 값이 나옵니다. 이때 COUNT 함수를 사용하여 집계를 수행하면 NULL 값은 집계되지 않고, 대신 0으로 표시됩니다.

그 다음,

GROUP BY hours.HOUR를 수행해 결과를 시간대(hours.HOUR)로 그룹화합니다. 이렇게 하면 동일한 시간대의 모든 행이 하나의 그룹으로 집계됩니다.

### 문제 2. https://school.programmers.co.kr/learn/courses/30/lessons/131123

정답

```
SELECT FOOD_TYPE, REST_ID, REST_NAME, FAVORITES
FROM REST_INFO
WHERE (FOOD_TYPE, FAVORITES) IN (
    SELECT FOOD_TYPE, MAX(FAVORITES)
    FROM REST_INFO
    GROUP BY FOOD_TYPE
)
ORDER BY FOOD_TYPE DESC;

```

풀이

핵심은 IN 의 서브쿼리를 통해 목표 대상을 추출하는 것.

서브쿼리는 음식 종류(FOOD_TYPE)별로 가장 많은 즐겨찾기수(FAVORITES)를 찾아낸다.

그리고 서브쿼리에 나온 결과를 기반으로 REST_INFO의 테이블 중 FOOD_TYPE과 FAVORITES를 추출한다.

만약 GROUP BY FOOD_TYPE 없이 단순히 SELECT FOOD_TYPE, MAX(FAVORITES) FROM REST_INFO라고만 한다면, 데이터의 모든 행을 하나의 그룹으로 간주하고 그 중 가장 큰 즐겨찾기수를 찾게 됩니다. 이것은 모든 음식 종류를 무시하고 전체 데이터 중에서 가장 큰 즐겨찾기수를 반환하게 됩니다.

그러나 GROUP BY FOOD_TYPE을 사용하면 데이터를 음식 종류(FOOD_TYPE)별로 그룹화하고, 각 그룹 내에서 MAX(FAVORITES)를 계산하여 각 음식 종류별로 가장 큰 즐겨찾기수를 찾습니다. 결과적으로 각 음식 종류에 대한 최대 즐겨찾기수가 찾기 가능.
