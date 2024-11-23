--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов
select distinct city from city

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
select city from city 
where city like 'L%a' and city NOT like '% %'

--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.
select payment_id, payment_date, amount  from payment
where payment_date::date between '2005-06-17' and '2005-06-19' and amount > 1.00
order by payment_date

--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
select payment_id, payment_date, amount  from payment
order by payment_date desc
limit 10

--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

select concat_ws(' ', last_name, first_name) as "Имя и фамилия", email as "Электронная почта",
char_length(email) as "Длина электронной почты", 
last_update::date as "Дата последнего обновления" from customer

--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
select lower(last_name) as last_name, lower(first_name) as first_name, active  from customer
where first_name ilike 'KELLY' or first_name ilike 'WILLIE' and active = 1.00








--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 
--0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.
select title , rating ,rental_rate  from film
where rating::text  like 'R' and 0.00 <= rental_rate and rental_rate <= 3.00 
or rating::text  like 'PG-13' and 4.00 <= rental_rate

--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.
select film_id ,title from film
order by char_length(description) desc
limit 3

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
 V1
SELECT customer_id ,email, (regexp_match(email , '(.*)(\@)(.*)'))[1] as "Email before @",
(regexp_match(email , '(.*)(\@)(.*)'))[3] as "Email after @" from customer

V2
SELECT customer_id ,email, substring(email , '(.*)[(\@)]') as "Email before @",
substring(email , '[(\@)](.*)') as "Email after @" from customer


--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква строки должна быть заглавной, остальные строчными.
SELECT customer_id ,email, concat(upper(left(substring(email , '(.*)[(\@)]'),1)),lower(right(substring(email , '(.*)[(\@)]'),-1))) as "Email before @",
concat(upper(left(substring(email , '[(\@)](.*)'),1)),lower(right(substring(email , '[(\@)](.*)'),-1))) as "Email after @"
from customer
