# 5장

## MySQL과 커넥션 만들기

### 커넥션이란

로그인해서 프롬프트가 표시되었다는 것은 로그인전과 로그인 후로 사용자와 MySQL의 관계가 변했다는 것을 의미한다. 이는 사용자와 MySQL이 접속되었다 즉, 연결되었다는 뜻. 이 연결이라는 것을 시스템 세계에서는 커넥션이라고 부릅니다.

### Prompt의 의미.

Prompt라는 단어는 사람에게 무언가를 하라고 재촉할 때 사용하는 말이다. 따라서 'mysql >' 이란 MySQL 사용자를 향해서 '명령을 입력하라'고 재촉하는 것.

## 데이터베이스에 전화 걸기

### 커넥션의 이미지는 전화

1. 상대방의 전화번호를 입력한다 -> 2. 전화를 건다. -> 3. 상대방이 전화를 받는다.

이 3단계를 통해 만들어진 연결이 '커넥션'. 커넥션이 유지되는 동아에는 대화할 수 있다.
말하자면 로그인이라는 행위는 상대방을 호출하는 행위와 같다.

```java
Your MySQL connection id is 11
```

MySQL은 동시에 여러 개의 커넥션을 유지하는 것이 가능 (동시에 복수의 사용자와 연결하는 것이 가능) 해서 이렇게 번호로 관리하지 않으면 어떤 커넥션이 어느 사용자를 위한 것인지를 모름.

이 커넥션의 시작과 종료 사이에 다양한 교환을 하게 되는데, 그 교환과 시작의 종료까지의 단위를 '세션' 이라고 한다.
커넥션과 세션은 매우 유사한 개념이라 같은 의미로 사용되는 경우도 많지만 정확하게는 커넥션이 확립된 후 세션이 만들어집니다.

이 둘을 잘 구분하지 않는 이유는 기본적으로 커넥션과 세션은 1:1로 대응되어서 커넥션이 성립되면 동시에 암묵적으로 세션도 시작되고 세션을 끊으면 커넥션도 끊어지는 경우가 많기 때문이다.

### 커넥션의 상태를 조사하는 명령

거의 모든 DBMS는 커넥션의 상태나 수를 조사하기 위한 명령어를 준비해 두고 있다.

```
mysql> show status like 'Threads_connected';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| Threads_connected | 15    |
+-------------------+-------+
```

### SQL과 관리 명령의 차이

#### show status

```
mysql> show status like 'Uptime';
+---------------+---------+
| Variable_name | Value   |
+---------------+---------+
| Uptime        | 1430468 |
+---------------+---------+
1 row in set (0.00 sec)
```

```
mysql> show status like 'Queries';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Queries       | 39266 |
+---------------+-------+
1 row in set (0.00 sec)
```

# 6장 - SELECT 문으로 테이블 내용을 살펴보자

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| article            |
| board-app          |
| bookMark           |
| book_store         |
| cafe               |
| delivery           |
| headfirst          |
| information_schema |
| mysql              |
| nodejs             |
| performance_schema |
| reallyou           |
| sbadge             |
| simple_board       |
| statistc           |
| sys                |
| test2              |
| theater            |
| user               |
| world              |
+--------------------+
20 rows in set (0.00 sec)
```

```
mysql> use world;
Database changed
mysql> show tables;
+-----------------+
| Tables_in_world |
+-----------------+
| city            |
| country         |
| countrylanguage |
+-----------------+
3 rows in set (0.00 sec)
```

### 조건을 지정해서 출력해보자 1.

```
mysql> select * from city where countrycode = 'KOR';
+------+------------+-------------+---------------+------------+
| ID   | Name       | CountryCode | District      | Population |
+------+------------+-------------+---------------+------------+
| 2331 | Seoul      | KOR         | Seoul         |    9981619 |
| 2332 | Pusan      | KOR         | Pusan         |    3804522 |
| 2333 | Inchon     | KOR         | Inchon        |    2559424 |
| 2334 | Taegu      | KOR         | Taegu         |    2548568 |
| 2335 | Taejon     | KOR         | Taejon        |    1425835 |
| 2336 | Kwangju    | KOR         | Kwangju       |    1368341 |
| 2337 | Ulsan      | KOR         | Kyongsangnam  |    1084891 |
| 2338 | Songnam    | KOR         | Kyonggi       |     869094 |
| 2339 | Puchon     | KOR         | Kyonggi       |     779412 |
| 2340 | Suwon      | KOR         | Kyonggi       |     755550 |
| 2341 | Anyang     | KOR         | Kyonggi       |     591106 |
| 2342 | Chonju     | KOR         | Chollabuk     |     563153 |
| 2343 | Chongju    | KOR         | Chungchongbuk |     531376 |
| 2344 | Koyang     | KOR         | Kyonggi       |     518282 |
| 2345 | Ansan      | KOR         | Kyonggi       |     510314 |
| 2346 | Pohang     | KOR         | Kyongsangbuk  |     508899 |
| 2347 | Chang-won  | KOR         | Kyongsangnam  |     481694 |
| 2348 | Masan      | KOR         | Kyongsangnam  |     441242 |
| 2349 | Kwangmyong | KOR         | Kyonggi       |     350914 |
| 2350 | Chonan     | KOR         | Chungchongnam |     330259 |
| 2351 | Chinju     | KOR         | Kyongsangnam  |     329886 |
| 2352 | Iksan      | KOR         | Chollabuk     |     322685 |
| 2353 | Pyongtaek  | KOR         | Kyonggi       |     312927 |
| 2354 | Kumi       | KOR         | Kyongsangbuk  |     311431 |
| 2355 | Uijongbu   | KOR         | Kyonggi       |     276111 |
| 2356 | Kyongju    | KOR         | Kyongsangbuk  |     272968 |
| 2357 | Kunsan     | KOR         | Chollabuk     |     266569 |
| 2358 | Cheju      | KOR         | Cheju         |     258511 |
| 2359 | Kimhae     | KOR         | Kyongsangnam  |     256370 |
| 2360 | Sunchon    | KOR         | Chollanam     |     249263 |
| 2361 | Mokpo      | KOR         | Chollanam     |     247452 |
| 2362 | Yong-in    | KOR         | Kyonggi       |     242643 |
| 2363 | Wonju      | KOR         | Kang-won      |     237460 |
| 2364 | Kunpo      | KOR         | Kyonggi       |     235233 |
| 2365 | Chunchon   | KOR         | Kang-won      |     234528 |
| 2366 | Namyangju  | KOR         | Kyonggi       |     229060 |
| 2367 | Kangnung   | KOR         | Kang-won      |     220403 |
| 2368 | Chungju    | KOR         | Chungchongbuk |     205206 |
| 2369 | Andong     | KOR         | Kyongsangbuk  |     188443 |
| 2370 | Yosu       | KOR         | Chollanam     |     183596 |
| 2371 | Kyongsan   | KOR         | Kyongsangbuk  |     173746 |
| 2372 | Paju       | KOR         | Kyonggi       |     163379 |
| 2373 | Yangsan    | KOR         | Kyongsangnam  |     163351 |
| 2374 | Ichon      | KOR         | Kyonggi       |     155332 |
| 2375 | Asan       | KOR         | Chungchongnam |     154663 |
| 2376 | Koje       | KOR         | Kyongsangnam  |     147562 |
| 2377 | Kimchon    | KOR         | Kyongsangbuk  |     147027 |
| 2378 | Nonsan     | KOR         | Chungchongnam |     146619 |
| 2379 | Kuri       | KOR         | Kyonggi       |     142173 |
| 2380 | Chong-up   | KOR         | Chollabuk     |     139111 |
| 2381 | Chechon    | KOR         | Chungchongbuk |     137070 |
| 2382 | Sosan      | KOR         | Chungchongnam |     134746 |
| 2383 | Shihung    | KOR         | Kyonggi       |     133443 |
| 2384 | Tong-yong  | KOR         | Kyongsangnam  |     131717 |
| 2385 | Kongju     | KOR         | Chungchongnam |     131229 |
| 2386 | Yongju     | KOR         | Kyongsangbuk  |     131097 |
| 2387 | Chinhae    | KOR         | Kyongsangnam  |     125997 |
| 2388 | Sangju     | KOR         | Kyongsangbuk  |     124116 |
| 2389 | Poryong    | KOR         | Chungchongnam |     122604 |
| 2390 | Kwang-yang | KOR         | Chollanam     |     122052 |
| 2391 | Miryang    | KOR         | Kyongsangnam  |     121501 |
| 2392 | Hanam      | KOR         | Kyonggi       |     115812 |
| 2393 | Kimje      | KOR         | Chollabuk     |     115427 |
| 2394 | Yongchon   | KOR         | Kyongsangbuk  |     113511 |
| 2395 | Sachon     | KOR         | Kyongsangnam  |     113494 |
| 2396 | Uiwang     | KOR         | Kyonggi       |     108788 |
| 2397 | Naju       | KOR         | Chollanam     |     107831 |
| 2398 | Namwon     | KOR         | Chollabuk     |     103544 |
| 2399 | Tonghae    | KOR         | Kang-won      |      95472 |
| 2400 | Mun-gyong  | KOR         | Kyongsangbuk  |      92239 |
+------+------------+-------------+---------------+------------+
70 rows in set (0.02 sec)
```

### 조건을 지정해서 출력해보자 2.

```
mysql> select * from city where district = 'chollanam';
+------+------------+-------------+-----------+------------+
| ID   | Name       | CountryCode | District  | Population |
+------+------------+-------------+-----------+------------+
| 2360 | Sunchon    | KOR         | Chollanam |     249263 |
| 2361 | Mokpo      | KOR         | Chollanam |     247452 |
| 2370 | Yosu       | KOR         | Chollanam |     183596 |
| 2390 | Kwang-yang | KOR         | Chollanam |     122052 |
| 2397 | Naju       | KOR         | Chollanam |     107831 |
+------+------------+-------------+-----------+------------+
5 rows in set (0.00 sec)
```

### 불필요한 열을 제거하고 표시해 보자.

```

mysql> select Name,Population from city where district = 'chollanam';
+------------+------------+
| Name       | Population |
+------------+------------+
| Sunchon    |     249263 |
| Mokpo      |     247452 |
| Yosu       |     183596 |
| Kwang-yang |     122052 |
| Naju       |     107831 |
+------------+------------+
5 rows in set (0.00 sec)

```

### 다양한 조건을 추가해 보자 1.

```
mysql> select Name,Population from city where district = 'chollanam' and population > 150000;
+---------+------------+
| Name    | Population |
+---------+------------+
| Sunchon |     249263 |
| Mokpo   |     247452 |
| Yosu    |     183596 |
+---------+------------+
3 rows in set (0.02 sec)
```

### 다양한 조건을 추가해 보자 2.

```
mysql> select distinct district  from city where countrycode ='KOR';
+---------------+
| district      |
+---------------+
| Seoul         |
| Pusan         |
| Inchon        |
| Taegu         |
| Taejon        |
| Kwangju       |
| Kyongsangnam  |
| Kyonggi       |
| Chollabuk     |
| Chungchongbuk |
| Kyongsangbuk  |
| Chungchongnam |
| Cheju         |
| Chollanam     |
| Kang-won      |
+---------------+
15 rows in set (0.01 sec)
```

# 7장 - SELECT 문을 응용해보자

### order by

```

mysql> select * from city where countrycode = 'KOR' order by population;
+------+------------+-------------+---------------+------------+
| ID   | Name       | CountryCode | District      | Population |
+------+------------+-------------+---------------+------------+
| 2400 | Mun-gyong  | KOR         | Kyongsangbuk  |      92239 |
| 2399 | Tonghae    | KOR         | Kang-won      |      95472 |
| 2398 | Namwon     | KOR         | Chollabuk     |     103544 |
| 2397 | Naju       | KOR         | Chollanam     |     107831 |
| 2396 | Uiwang     | KOR         | Kyonggi       |     108788 |
| 2395 | Sachon     | KOR         | Kyongsangnam  |     113494 |
| 2394 | Yongchon   | KOR         | Kyongsangbuk  |     113511 |
| 2393 | Kimje      | KOR         | Chollabuk     |     115427 |
| 2392 | Hanam      | KOR         | Kyonggi       |     115812 |
| 2391 | Miryang    | KOR         | Kyongsangnam  |     121501 |
| 2390 | Kwang-yang | KOR         | Chollanam     |     122052 |
| 2389 | Poryong    | KOR         | Chungchongnam |     122604 |
| 2388 | Sangju     | KOR         | Kyongsangbuk  |     124116 |
| 2387 | Chinhae    | KOR         | Kyongsangnam  |     125997 |
| 2386 | Yongju     | KOR         | Kyongsangbuk  |     131097 |
| 2385 | Kongju     | KOR         | Chungchongnam |     131229 |
| 2384 | Tong-yong  | KOR         | Kyongsangnam  |     131717 |
| 2383 | Shihung    | KOR         | Kyonggi       |     133443 |
| 2382 | Sosan      | KOR         | Chungchongnam |     134746 |
| 2381 | Chechon    | KOR         | Chungchongbuk |     137070 |
| 2380 | Chong-up   | KOR         | Chollabuk     |     139111 |
| 2379 | Kuri       | KOR         | Kyonggi       |     142173 |
| 2378 | Nonsan     | KOR         | Chungchongnam |     146619 |
| 2377 | Kimchon    | KOR         | Kyongsangbuk  |     147027 |
| 2376 | Koje       | KOR         | Kyongsangnam  |     147562 |
| 2375 | Asan       | KOR         | Chungchongnam |     154663 |
| 2374 | Ichon      | KOR         | Kyonggi       |     155332 |
| 2373 | Yangsan    | KOR         | Kyongsangnam  |     163351 |
| 2372 | Paju       | KOR         | Kyonggi       |     163379 |
| 2371 | Kyongsan   | KOR         | Kyongsangbuk  |     173746 |
| 2370 | Yosu       | KOR         | Chollanam     |     183596 |
| 2369 | Andong     | KOR         | Kyongsangbuk  |     188443 |
| 2368 | Chungju    | KOR         | Chungchongbuk |     205206 |
| 2367 | Kangnung   | KOR         | Kang-won      |     220403 |
| 2366 | Namyangju  | KOR         | Kyonggi       |     229060 |
| 2365 | Chunchon   | KOR         | Kang-won      |     234528 |
| 2364 | Kunpo      | KOR         | Kyonggi       |     235233 |
| 2363 | Wonju      | KOR         | Kang-won      |     237460 |
| 2362 | Yong-in    | KOR         | Kyonggi       |     242643 |
| 2361 | Mokpo      | KOR         | Chollanam     |     247452 |
| 2360 | Sunchon    | KOR         | Chollanam     |     249263 |
| 2359 | Kimhae     | KOR         | Kyongsangnam  |     256370 |
| 2358 | Cheju      | KOR         | Cheju         |     258511 |
| 2357 | Kunsan     | KOR         | Chollabuk     |     266569 |
| 2356 | Kyongju    | KOR         | Kyongsangbuk  |     272968 |
| 2355 | Uijongbu   | KOR         | Kyonggi       |     276111 |
| 2354 | Kumi       | KOR         | Kyongsangbuk  |     311431 |
| 2353 | Pyongtaek  | KOR         | Kyonggi       |     312927 |
| 2352 | Iksan      | KOR         | Chollabuk     |     322685 |
| 2351 | Chinju     | KOR         | Kyongsangnam  |     329886 |
| 2350 | Chonan     | KOR         | Chungchongnam |     330259 |
| 2349 | Kwangmyong | KOR         | Kyonggi       |     350914 |
| 2348 | Masan      | KOR         | Kyongsangnam  |     441242 |
| 2347 | Chang-won  | KOR         | Kyongsangnam  |     481694 |
| 2346 | Pohang     | KOR         | Kyongsangbuk  |     508899 |
| 2345 | Ansan      | KOR         | Kyonggi       |     510314 |
| 2344 | Koyang     | KOR         | Kyonggi       |     518282 |
| 2343 | Chongju    | KOR         | Chungchongbuk |     531376 |
| 2342 | Chonju     | KOR         | Chollabuk     |     563153 |
| 2341 | Anyang     | KOR         | Kyonggi       |     591106 |
| 2340 | Suwon      | KOR         | Kyonggi       |     755550 |
| 2339 | Puchon     | KOR         | Kyonggi       |     779412 |
| 2338 | Songnam    | KOR         | Kyonggi       |     869094 |
| 2337 | Ulsan      | KOR         | Kyongsangnam  |    1084891 |
| 2336 | Kwangju    | KOR         | Kwangju       |    1368341 |
| 2335 | Taejon     | KOR         | Taejon        |    1425835 |
| 2334 | Taegu      | KOR         | Taegu         |    2548568 |
| 2333 | Inchon     | KOR         | Inchon        |    2559424 |
| 2332 | Pusan      | KOR         | Pusan         |    3804522 |
| 2331 | Seoul      | KOR         | Seoul         |    9981619 |
+------+------------+-------------+---------------+------------+
70 rows in set (0.01 sec)
```

### 테이블을 집약해 보자

```
mysql> select count(*) from city where countrycode = 'KOR';
+----------+
| count(*) |
+----------+
|       70 |
+----------+
1 row in set (0.00 sec)
```

```
mysql> select min(population), max(population), sum(population), avg(population) from city where countrycode='KOR';
+-----------------+-----------------+-----------------+-----------------+
| min(population) | max(population) | sum(population) | avg(population) |
+-----------------+-----------------+-----------------+-----------------+
|           92239 |         9981619 |        38999893 |     557141.3286 |
+-----------------+-----------------+-----------------+-----------------+
1 row in set (0.01 sec)
```

```
mysql> select name from city where district = 'Chollabuk' and countrycode = 'KOR';
+----------+
| name     |
+----------+
| Chonju   |
| Iksan    |
| Kunsan   |
| Chong-up |
| Kimje    |
| Namwon   |
+----------+
6 rows in set (0.01 sec)

```

#### group_concat

```

mysql> select group_concat(name) from city where countrycode = 'KOR' and district = 'Chollabuk';
+-------------------------------------------+
| group_concat(name)                        |
+-------------------------------------------+
| Chonju,Iksan,Kunsan,Chong-up,Kimje,Namwon |
+-------------------------------------------+
1 row in set (0.00 sec)
```

#### count(\*) , group by

```
mysql> select district, count(*) from city where countrycode = 'KOR' group by district;
+---------------+----------+
| district      | count(*) |
+---------------+----------+
| Cheju         |        1 |
| Chollabuk     |        6 |
| Chollanam     |        5 |
| Chungchongbuk |        3 |
| Chungchongnam |        6 |
| Inchon        |        1 |
| Kang-won      |        4 |
| Kwangju       |        1 |
| Kyonggi       |       18 |
| Kyongsangbuk  |       10 |
| Kyongsangnam  |       11 |
| Pusan         |        1 |
| Seoul         |        1 |
| Taegu         |        1 |
| Taejon        |        1 |
+---------------+----------+
15 rows in set (0.00 sec)
```

```
mysql> select district, count(*) from city where countrycode = 'KOR' group by district  having count(*)=6;
+---------------+----------+
| district      | count(*) |
+---------------+----------+
| Chollabuk     |        6 |
| Chungchongnam |        6 |
+---------------+----------+
2 rows in set (0.00 sec)
```

## SELECT 문의 응용조작을 배워보자

### 검색결과 정렬

#### order by

주의점 : order by 사용할 땐 정확하게 순서를 매길 수 컬럼을 지정해줘야함 가령, district와 같은 컬럼을 지정해줬는데 해당 컬럼의 갯수가 복수개면 무작위한 순서로 order by됨. (각각의 컬럼이 유니크하면 상관 X)

그래서 order by 순으로 지정해주고 싶으면 위의 경우 district,name 식으로 유니크한 name 컬럼을 동반시켜줘야함.

```

mysql> select * from city where countrycode = 'KOR' order by population desc;
+------+------------+-------------+---------------+------------+
| ID   | Name       | CountryCode | District      | Population |
+------+------------+-------------+---------------+------------+
| 2331 | Seoul      | KOR         | Seoul         |    9981619 |
| 2332 | Pusan      | KOR         | Pusan         |    3804522 |
| 2333 | Inchon     | KOR         | Inchon        |    2559424 |
| 2334 | Taegu      | KOR         | Taegu         |    2548568 |
| 2335 | Taejon     | KOR         | Taejon        |    1425835 |
| 2336 | Kwangju    | KOR         | Kwangju       |    1368341 |
| 2337 | Ulsan      | KOR         | Kyongsangnam  |    1084891 |
| 2338 | Songnam    | KOR         | Kyonggi       |     869094 |
| 2339 | Puchon     | KOR         | Kyonggi       |     779412 |
| 2340 | Suwon      | KOR         | Kyonggi       |     755550 |
| 2341 | Anyang     | KOR         | Kyonggi       |     591106 |
| 2342 | Chonju     | KOR         | Chollabuk     |     563153 |
| 2343 | Chongju    | KOR         | Chungchongbuk |     531376 |
| 2344 | Koyang     | KOR         | Kyonggi       |     518282 |
| 2345 | Ansan      | KOR         | Kyonggi       |     510314 |
| 2346 | Pohang     | KOR         | Kyongsangbuk  |     508899 |
| 2347 | Chang-won  | KOR         | Kyongsangnam  |     481694 |
| 2348 | Masan      | KOR         | Kyongsangnam  |     441242 |
| 2349 | Kwangmyong | KOR         | Kyonggi       |     350914 |
| 2350 | Chonan     | KOR         | Chungchongnam |     330259 |
| 2351 | Chinju     | KOR         | Kyongsangnam  |     329886 |
| 2352 | Iksan      | KOR         | Chollabuk     |     322685 |
| 2353 | Pyongtaek  | KOR         | Kyonggi       |     312927 |
| 2354 | Kumi       | KOR         | Kyongsangbuk  |     311431 |
| 2355 | Uijongbu   | KOR         | Kyonggi       |     276111 |
| 2356 | Kyongju    | KOR         | Kyongsangbuk  |     272968 |
| 2357 | Kunsan     | KOR         | Chollabuk     |     266569 |
| 2358 | Cheju      | KOR         | Cheju         |     258511 |
| 2359 | Kimhae     | KOR         | Kyongsangnam  |     256370 |
| 2360 | Sunchon    | KOR         | Chollanam     |     249263 |
| 2361 | Mokpo      | KOR         | Chollanam     |     247452 |
| 2362 | Yong-in    | KOR         | Kyonggi       |     242643 |
| 2363 | Wonju      | KOR         | Kang-won      |     237460 |
| 2364 | Kunpo      | KOR         | Kyonggi       |     235233 |
| 2365 | Chunchon   | KOR         | Kang-won      |     234528 |
| 2366 | Namyangju  | KOR         | Kyonggi       |     229060 |
| 2367 | Kangnung   | KOR         | Kang-won      |     220403 |
| 2368 | Chungju    | KOR         | Chungchongbuk |     205206 |
| 2369 | Andong     | KOR         | Kyongsangbuk  |     188443 |
| 2370 | Yosu       | KOR         | Chollanam     |     183596 |
| 2371 | Kyongsan   | KOR         | Kyongsangbuk  |     173746 |
| 2372 | Paju       | KOR         | Kyonggi       |     163379 |
| 2373 | Yangsan    | KOR         | Kyongsangnam  |     163351 |
| 2374 | Ichon      | KOR         | Kyonggi       |     155332 |
| 2375 | Asan       | KOR         | Chungchongnam |     154663 |
| 2376 | Koje       | KOR         | Kyongsangnam  |     147562 |
| 2377 | Kimchon    | KOR         | Kyongsangbuk  |     147027 |
| 2378 | Nonsan     | KOR         | Chungchongnam |     146619 |
| 2379 | Kuri       | KOR         | Kyonggi       |     142173 |
| 2380 | Chong-up   | KOR         | Chollabuk     |     139111 |
| 2381 | Chechon    | KOR         | Chungchongbuk |     137070 |
| 2382 | Sosan      | KOR         | Chungchongnam |     134746 |
| 2383 | Shihung    | KOR         | Kyonggi       |     133443 |
| 2384 | Tong-yong  | KOR         | Kyongsangnam  |     131717 |
| 2385 | Kongju     | KOR         | Chungchongnam |     131229 |
| 2386 | Yongju     | KOR         | Kyongsangbuk  |     131097 |
| 2387 | Chinhae    | KOR         | Kyongsangnam  |     125997 |
| 2388 | Sangju     | KOR         | Kyongsangbuk  |     124116 |
| 2389 | Poryong    | KOR         | Chungchongnam |     122604 |
| 2390 | Kwang-yang | KOR         | Chollanam     |     122052 |
| 2391 | Miryang    | KOR         | Kyongsangnam  |     121501 |
| 2392 | Hanam      | KOR         | Kyonggi       |     115812 |
| 2393 | Kimje      | KOR         | Chollabuk     |     115427 |
| 2394 | Yongchon   | KOR         | Kyongsangbuk  |     113511 |
| 2395 | Sachon     | KOR         | Kyongsangnam  |     113494 |
| 2396 | Uiwang     | KOR         | Kyonggi       |     108788 |
| 2397 | Naju       | KOR         | Chollanam     |     107831 |
| 2398 | Namwon     | KOR         | Chollabuk     |     103544 |
| 2399 | Tonghae    | KOR         | Kang-won      |      95472 |
| 2400 | Mun-gyong  | KOR         | Kyongsangbuk  |      92239 |
+------+------------+-------------+---------------+------------+
70 rows in set (0.00 sec)
```

## 테이블을 요약하는 함수

함수는 크게 2종류

- 1. 복수 행(이나 행의 값)에 대해 집계를 수행하는 함수
- 2. 단일 행의 값에 대해 조작이나 계산을 수행하는 함수

COUNT 함수는 전자에 해당하는데, 이런 집계용 함수를 집약함수(집계함수) 라고 부름.

[대표 집약함수]

- COUNT : 테이블 행수를 알려주는 함수
- SUM : 테이블의 수치 데이터를 합계하는 함수
- AVG : 테이블의 수치 데이터 평균을 구하는 함수
- MAX: 테이블의 임의열 데이터 중 최대값을 구하는 함수
- MIN : 테이블의 임의열 데이터 중 최소값을 구하는 함수

이러한 집약함수는 기본적으로 NULL을 제외. COUNT 함수만은 COUNT(\*) 로 표기하여 NULL 포함 !!

또한 SUM,AVG 함수 제외 집약함수는 수치 데이터 외에도 이용 가능.
다만 문자 표현하는 내부 코드에 의존하므로 이용할 수 있는 예는 한정됨.
EX) 도시명 최대값 : Y로 시작하는 Yosu(여수), 최소값은 A로 시작하는 Andong.

```

mysql> select max(name) from city where countrycode = 'KOR';
+-----------+
| max(name) |
+-----------+
| Yosu      |
+-----------+
1 row in set (0.01 sec)
```

## 문자열을 집약하는 GROUP_COUNT

GROUP_COUNT 함수는 '문자열'에 대한 집계를 '문자열의 결합'으로 수행.
따라서 콤마로 구분되는 매우 긴 데이터를 결과로 돌려줌.

#### DISTINCT로 중복 회피

```
mysql> select group_concat(district) from city where countrycode = 'KOR';

| Seoul,Pusan,Inchon,Taegu,Taejon,Kwangju,Kyongsangnam,Kyonggi,Kyonggi,Kyonggi,Kyonggi,Chollabuk,Chungchongbuk,Kyonggi,Kyonggi,Kyongsangbuk,Kyongsangnam,Kyongsangnam,Kyonggi,Chungchongnam,Kyongsangnam,Chollabuk,Kyonggi,Kyongsangbuk,Kyonggi,Kyongsangbuk,Chollabuk,Cheju,Kyongsangnam,Chollanam,Chollanam,Kyonggi,Kang-won,Kyonggi,Kang-won,Kyonggi,Kang-won,Chungchongbuk,Kyongsangbuk,Chollanam,Kyongsangbuk,Kyonggi,Kyongsangnam,Kyonggi,Chungchongnam,Kyongsangnam,Kyongsangbuk,Chungchongnam,Kyonggi,Chollabuk,Chungchongbuk,Chungchongnam,Kyonggi,Kyongsangnam,Chungchongnam,Kyongsangbuk,Kyongsangnam,Kyongsangbuk,Chungchongnam,Chollanam,Kyongsangnam,Kyonggi,Chollabuk,Kyongsangbuk,Kyongsangnam,Kyonggi,Chollanam,Chollabuk,Kang-won,Kyongsangbuk |
```

--> 행정구역을 단순히 GROUP_CONCAT 수행한다면 경상남도는 결과 값에 따라 여러 번 나오게된다.

#### DISTINCT 사용 시

```
mysql> select group_concat(DISTINCT district) from city where countrycode = 'KOR';
+------------------------------------------------------------------------------------------------------------------------------------------+
| group_concat(DISTINCT district)                                                                                                          |
+------------------------------------------------------------------------------------------------------------------------------------------+
| Cheju,Chollabuk,Chollanam,Chungchongbuk,Chungchongnam,Inchon,Kang-won,Kwangju,Kyonggi,Kyongsangbuk,Kyongsangnam,Pusan,Seoul,Taegu,Taejon |
+------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)

```

## 데이터를 그룹으로 나누는 GROUP BY

- 대상이 되는 데이터를 그룹으로 나눠서 집약!
- 그룹으로 나눌 떄는 나누는 키가 되는 열을 지정
- GROUP BY로 지정한 열을 집약 키나 그룹화 키로 부르며 이들은 ORDER BY 처럼 복수 열을 콤마로 구분해 지정 가능

- 행정구역 별로 그룹을 지어서 카운트를 나타냄 !

```
mysql> select district, count(*) from city where countrycode = 'KOR' GROUP BY district;
+---------------+----------+
| district      | count(*) |
+---------------+----------+
| Cheju         |        1 |
| Chollabuk     |        6 |
| Chollanam     |        5 |
| Chungchongbuk |        3 |
| Chungchongnam |        6 |
| Inchon        |        1 |
| Kang-won      |        4 |
| Kwangju       |        1 |
| Kyonggi       |       18 |
| Kyongsangbuk  |       10 |
| Kyongsangnam  |       11 |
| Pusan         |        1 |
| Seoul         |        1 |
| Taegu         |        1 |
| Taejon        |        1 |
+---------------+----------+
15 rows in set (0.01 sec)
```

### 나눈 그룹에 조건 추가

- and count(\*)로 조건 추가!
- COUNT 같은 집약함수를 작성할 수 있는 경우는 SELECT와 ORDER BY, HAVING 뿐이다.

```
mysql> select district, count(*) from city where countrycode = 'KOR'  and count(*) =4 GROUP BY district;
ERROR 1111 (HY000): Invalid use of group function
```

### order by + group by

- 행정 구역을 기준으로 그룹핑 한 것을 오름차순으로 정리 !
- 여기서 오름차순으로 정렬하려면 count(\*)가 district 보다 먼저 나와야함.
- district 가 먼저 나오면 지명 맨 앞글자 알파벳순으로 정렬됨.

```
mysql> SELECT district, count(*) FROM city WHERE countrycode = 'KOR' GROUP BY district ORDER BY count(*), district;
+---------------+----------+
| district      | count(*) |
+---------------+----------+
| Cheju         |        1 |
| Inchon        |        1 |
| Kwangju       |        1 |
| Pusan         |        1 |
| Seoul         |        1 |
| Taegu         |        1 |
| Taejon        |        1 |
| Chungchongbuk |        3 |
| Kang-won      |        4 |
| Chollanam     |        5 |
| Chollabuk     |        6 |
| Chungchongnam |        6 |
| Kyongsangbuk  |       10 |
| Kyongsangnam  |       11 |
| Kyonggi       |       18 |
+---------------+----------+
15 rows in set (0.00 sec)
```

## 집약한 결과에 조건 지정

그룹마다 집약한 값을 조건으로 선택하고 싶다면 'HAVING' 뒤에 조건을 추가

```
mysql> select district, count(*) from city where countrycode = 'KOR' GROUP BY district having count(*)=6;
+---------------+----------+
| district      | count(*) |
+---------------+----------+
| Chollabuk     |        6 |
| Chungchongnam |        6 |
+---------------+----------+
2 rows in set (0.00 sec)
```

## order by + group by + count(\*)

```
mysql> select district, count(*) from city where countrycode = 'KOR' GROUP BY district having count(*)>6 order by count(*) asc;
+--------------+----------+
| district     | count(*) |
+--------------+----------+
| Kyongsangbuk |       10 |
| Kyongsangnam |       11 |
| Kyonggi      |       18 |
+--------------+----------+
3 rows in set (0.00 sec)
```

## 순서 !!

SELECT -> FROM -> WHERE -> GROUP BY -> HAVING -> ORDER BY !!!

---

## LEETCODE 문제

1. https://leetcode.com/problems/project-employees-i/description/

#### My Answer

```
SELECT p.project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM Employee e
INNER JOIN Project p ON e.employee_id = p.employee_id
GROUP BY p.project_id;
```

- 주요점 1 : ROUND는 반올림 함수 , EX) ROUND( , 2) 이면 소수점 셋째자리에서 반올림 수행 후 둘째 자리까지 표현하라는 의미.
- 주요점 2: FROM 으로 기준 테이블 잡고 JOIN 수행 전치사 ON을 붙여 조인할 컬럼 지정

2. https://leetcode.com/problems/tree-node/submissions/

```
select id,
    CASE
        when p_id IS NULL THEN 'Root'
        when id NOT IN (SELECT DISTINCT p_id from Tree where p_id is not null) THEN 'Leaf'
        else 'Inner'

    END AS type

from Tree

```

- 주요점 1 : CASE ~ WEHN 구절 사용시 select 하고 컬럼 지정후 ',' 붙이고 CASE 들어가야함
- 주요점 2 : p_id 를 DISTINCT로 필터링한 결과에 id값이 존재하지 않으면 그것은 자식 노드가 없는 leaf 노드 (is not null 꼭 체크!!!! 널값 체킹 안해주면 다 else로 빠져서 Inner로 처리됨)
- 주요점 3 : 케이스문 다 끝나면 END 로 마무리 짓기.
