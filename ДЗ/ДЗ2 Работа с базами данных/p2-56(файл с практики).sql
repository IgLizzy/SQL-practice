https://www.sqlstyle.guide/ru/

Комментарии
--вбпвабповбап
/*
 * лвоапитлвоаиптлв
 * вапрдьважрдл
 * 
 * 
 */

select ... /*dfjkghksdfgjdf*/ ...

Отличие ' ' от " "  --` `

' ' - значений
" " - название сущности

set search_path to "dvd-rental"

dvd_rental

Зарезервированные слова

select name
from language

select "select"
from "from"

from user

select / insert / update / delete / truncate 

select power(5, 7)

синтаксический порядок инструкции select;
select - вывести в результат вычисления, столбцы
from - ключевая таблица 
join - соединение данынх из других таблиц
on - условие присоединение других данных
where - фильтрация данных
group by - группировка данных
having - фильтрация результатов агрегации
order by - сортировка данных
limit/offset

логический порядок инструкции select;
from
on 
join 
where 
group by
having
select -- алиасы as 
order by 
limit/offset

pg_typeof(), приведение типов

select pg_typeof(100) --integer

select pg_typeof(100.) --numeric

select pg_typeof('100.') --unknown

big integer | text | date | numeric
100		    '100.'			100.

select pg_typeof('100.'::text::numeric)

select pg_typeof(cast(cast('100.' as text) as numeric))

select pg_typeof(cast('100.' as text))

select pg_typeof(cast(cast('100.' as text) as numeric))

select pg_typeof(null::int)

1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select *
from film 

select film_id, title, description, release_year, 5*2, round(6*7)
from film 

select film_id FilmFilm_id, title FilmTitle, description FilmDescription, release_year FilmRelease_year
from film 

select film_id "FilmFilm_id", title "FilmTitle", description "FilmDescription", release_year "Год выпуска фильма"
from film 

select film_id as "FilmFilm_id", title as "FilmTitle", description as "FilmDescription", release_year as "Год выпуска фильма"
from film 

select *
from (
	select c.first_name cust_first_name, s.first_name st_first_name, 2 as x, 3, 4
	from customer c
	join staff s on s.store_id = c.store_id) t
where x = 2

/*select *
from (
	select c.first_name, s.first_name
	from customer c
	join staff s on s.store_id = c.store_id) t
where s.first_name*/

select 1 as "какое-то странное и очень длинное название  что будет плохо" 

названия сущностей < 64 байт
<32 символов

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

int2 small int
int4 int integer
int8 big int

2
4
8

2000000
4000000
8000000

integer
numeric - numeric (8, 2) 999999.99 - 9999.9999
float 

2.5 + 2.5 numeric = 2.5 + 2.5

2.5 + 2.5 float = 2.4999 + 2.5001

select film_id, title, rental_rate / rental_duration as cost_per_day
from film 

select film_id, title, rental_rate / rental_duration, 
	rental_rate * rental_duration, 
	rental_rate - rental_duration, 
	rental_rate + rental_duration, 
	power(rental_rate, rental_duration), 
	mod(rental_rate, rental_duration), 
	sqrt(rental_rate), 
	sin(rental_rate)
from film 


2*
- арифметические действия
- оператор round

select film_id, title, (rental_rate / rental_duration)::numeric(8,2)  
from film 

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 

round(numeric, int)

round(float)

select x,
	round(x::numeric) as x_num,
	round(x::float) as x_fl
from generate_series(0.5, 10.5, 1) x

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) --asc

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) desc

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by 3 desc

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by 3 desc, 2 

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc, title 

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by description

3.1* Отсортируйте таблицу платежей по возрастанию суммы платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select *
from payment 
order by amount asc

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
- используйте limit

1 - 1000
2,3,4 - 990
5-20 - 980

Топ - 3
3 квартиры 1 (2,3,4) только 2
конфеты 1-20

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc
limit 10

ACADEMY DINOSAUR
ACE GOLDFINGER
ADAPTATION HOLES
AFFAIR PREJUDICE

INNOCENT USUAL
VELVET TERMINATOR
BEHAVIOR RUNAWAY
TORQUE BOUND

CARIBBEAN LIBERTY
CASPER DRAGONFLY
AUTUMN CROW
BEAST HUNCHBACK

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc
fetch first 10 rows only

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc
fetch first 10 rows with ties

3.2.1 Вывести топ-1 самых дорогих фильмов по стоимости за день аренды, то есть вывести все 62 фильма
--начиная с 13 версии

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc
fetch first 1 rows with ties

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select film_id, title, round(rental_rate / rental_duration, 2) cost_per_day
from film 
order by cost_per_day desc
offset 57
limit 10

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и offset

select *
from payment 
order by amount
offset 13999
limit 15

4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select * --1 000
from film 

select release_year --1 000
from film 

select distinct release_year --1
from film 

select distinct release_year, film_id  --1 000
from film 

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select first_name --599
from customer 

select distinct first_name --591
from customer 

explain analyze --47.12 / 1.625
select distinct first_name, last_name --599
from customer 
order by 1

explain analyze --44.12 / 1.625
select first_name, last_name --599
from customer 
order by 1

explain analyze --23.98 / 0.25
select distinct first_name, last_name --599
from customer 

explain analyze --14.99 / 0.07
select first_name, last_name --599
from customer 

4.1 нужно получить последний платеж каждого пользователя

select distinct on (customer_id) *
from payment 
order by customer_id, payment_date desc

explain analyze
select distinct on (payment_id, customer_id, staff_id, rental_id, amount, payment_date) *
from payment 

explain analyze
select distinct payment_id, customer_id, staff_id, rental_id, amount, payment_date
from payment 

select *
from payment 

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

text 
varchar(N) varchar(10) 0-10 ''
char(N) char(10) 'xxxxx'->'xxxxx     '

select title || ' - ' || release_year, rating --223
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating --223
from film 
where rating = 'PG-13'

select concat(first_name, ' ', last_name, ' ', middle_name)
from person 

select concat_ws(' ', first_name, last_name, middle_name)
from person

select 'Hello' || null

select 2 + null

select concat('Hello', null)

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length

like / ilike 
% - любое кол-во символов
_ - один любой символ

select concat(title, ' - ', release_year), rating
from film 
where rating like 'PG%'

SQL Error [42883]: ОШИБКА: оператор не существует: mpaa_rating like unknown

select concat(title, ' - ', release_year), pg_typeof(rating) --mpaa_rating
from film 

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'P%3'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where not rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text not like '%-%'

select concat_ws(' ', first_name, last_name, middle_name)
from person
where last_name ilike 'а%'

select concat_ws(' ', first_name, last_name, middle_name)
from person
where last_name ilike 'а____'

select concat_ws(' ', first_name, last_name, middle_name)
from person
where last_name ilike 'а%' and char_length(last_name) = 12

select concat_ws(' ', first_name, last_name, middle_name)
from person
where lower(left(last_name, 1)) = 'а' and char_length(last_name) = 12

select concat_ws(' ', first_name, last_name, middle_name) --28
from person
where last_name ilike '__к___'

select concat_ws(' ', first_name, last_name, middle_name) --971
from person
where last_name ilike '%к%'

select concat_ws(' ', first_name, last_name, middle_name)
from person
where (lower(left(last_name, 1)) = 'а' or lower(left(last_name, 1)) = 'a') and char_length(last_name) = 12

select *
from film
where title like '%\%%'

select *
from film
where title like '%q%%' escape 'q'

select ''''

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания),
в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part

select upper(concat_ws(' ', first_name, last_name, middle_name))
from person

select lower(upper(concat_ws(' ', first_name, last_name, middle_name)))
from person

select initcap(lower(upper(concat_ws(' ', first_name, last_name, middle_name))))
from person

select initcap('aaabBB ccc8DDD!eee.yyY')
				Aaabbb Ccc8ddd!Eee.Yyy
				
select character_length((concat_ws(' ', first_name, last_name, middle_name))), 
	char_length((concat_ws(' ', first_name, last_name, middle_name))),
	length((concat_ws(' ', first_name, last_name, middle_name))),
	octet_length(((concat_ws(' ', first_name, last_name, middle_name))))
from person

select strpos('Hello world', 'world')

select substring('Hello world', 7, 3)

select substring('Hello world' from 7 for 3)

select substring('Hello world', 7)

select left('Hello world', 3)

select left('Hello world', -3)

select right('Hello world', 3)

select right('Hello world', -3)

select split_part(concat_ws(' ', first_name, last_name, middle_name), ' ', 1),
	split_part(concat_ws(' ', first_name, last_name, middle_name), ' ', 2),
	split_part(concat_ws(' ', first_name, last_name, middle_name), ' ', 3)
from person

АМЕЛИЯ 1 
ЛИТВИНОВА 2
ЕГОРОВНА 3

select replace(concat_ws(' ', last_name, first_name, middle_name), 'Николай', 'Nikolay')
from person
where first_name = 'Николай'

select concat_ws(' ', last_name, first_name, middle_name),
	overlay(concat_ws(' ', last_name, first_name, middle_name) placing 'Nikolay' 
	from strpos(concat_ws(' ', last_name, first_name, middle_name), 'Николай') 
	for char_length('Николай')-5)
from person
where first_name = 'Николай'

overlay(строка placing что_разместить from ... for кол-во символов)

Николай753 for 10

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval

date 
time 
timestamp
timetz 
timestamptz
interval

select now()

2023-08-31 21:35:29.103403+03

show lc_collate --Russian_Russia.1251 / Eu

yyyy-mm-dd
dd-mm-yyyy

select '2023-01-13'::date

select '2023-08-31 18:35:29.103403+12'::timestamptz

2023-08-31 09:35:29.103403+03

set time zone 'utc-12'

2023-08-31 18:35:29.103403+12

set time zone 'utc-3'

--ложный запрос
select *
from payment 
where payment_date >= '27-05-2005' and payment_date <= '28-05-2005'
order by payment_date desc

--ложный запрос
select *
from payment 
where payment_date between '27-05-2005' and '28-05-2005 00:00:00'
order by payment_date desc

--можно, но не нужно
select *
from payment 
where payment_date between '27-05-2005' and '29-05-2005'
order by payment_date desc

select *
from payment 
where payment_date between '27-05-2005' and '28-05-2005 24:00:00'
order by payment_date desc

select *
from payment 
where payment_date between '27-05-2005' and '28-05-2005'::date + interval ' 1 day'
order by payment_date desc

--как нужно
select *
from payment 
where payment_date::date between '27-05-2005' and '28-05-2005'
order by payment_date desc

select *
from payment 
where payment_date between '27-05-2005 10:00:00' and '28-05-2005 12:00:00'
order by payment_date desc


6* Вывести платежи поступившие после 2005-07-08
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select *
from payment 
where payment_date::date > '2005-07-08 00:00:00'
order by payment_date 

select payment_date,
	date_part('year', payment_date),
	date_part('month', payment_date),
	date_part('day', payment_date),
	date_part('hours', payment_date),
	date_part('minutes', payment_date),
	date_part('seconds', payment_date),
	date_part('week', payment_date),
	date_part('quarter', payment_date),
	date_part('epoch', payment_date),
	date_part('isodow', payment_date)
from payment 

date_part('year', payment_date), date_part('month', payment_date)

select payment_date,
	date_trunc('year', payment_date),
	date_trunc('month', payment_date),
	date_trunc('day', payment_date),
	date_trunc('hours', payment_date),
	date_trunc('minutes', payment_date),
	date_trunc('seconds', payment_date),
	date_trunc('week', payment_date),
	date_trunc('quarter', payment_date)
from payment 

date_trunc('month', payment_date)

2005-05-25 11:00:00

select *
from payment 
where date_part('isodow', payment_date) not in (6, 7) and payment_date::date not in (select ...)

7. Получить количество дней с '30-04-2007' по сегодняшний день.
Получить количество месяцев с '30-04-2007' по сегодняшний день.
Получить количество лет с '30-04-2007' по сегодняшний день.

select now()

select current_timestamp

select current_time

select current_date 

select current_user 

select current_schema

date - date = integer

timestamp - timestamp = interval

--дни:
select current_date - '30-04-2007'::date

--Месяцы:
select date_part('year', age('30-04-2007'::date)) * 12 + date_part('month', age('30-04-2007'::date))

--Года:
select date_part('year', age('30-04-2007'::date))

select round((current_date - '30-04-2007'::date)/365.25) -- очень плохо

select current_timestamp - '30-04-2007'::date

select age(current_date, '30-04-2007'::date)

select age(current_timestamp, '30-04-2007'::date)

select age('30-04-2007'::date)

select date_part('year', age('30-04-2007'::date))

select age('18-07-2017'::date, '30-04-2007'::date)

8. Булев тип

true  1 'yes'	'on'	'y'
false 0	'no'	'off'	'n'

select * --594
from customer 
where activebool

select * --594
from customer 
where activebool is true

select * --594
from customer 
where activebool = true

select * --594
from customer 
where activebool is not null

/*select * --594
from customer 
where not activebool = null*/

select * --594
from customer 
where activebool is false

9 Логические операторы and и or

and - *
or - +

select customer_id, amount
from payment
where customer_id = 2 or customer_id = 3 and amount = 2.99 or amount = 4.99

a + b * c + d

select customer_id, amount
from payment
where (customer_id = 2 or customer_id = 3) and (amount = 2.99 or amount = 4.99)

(a + b) * (c + d)

--так плохо
select customer_id, amount
from payment
where ((customer_id = 2) or (customer_id = 3)) and ((amount = 2.99) or (amount = 4.99)) 

@netonkh