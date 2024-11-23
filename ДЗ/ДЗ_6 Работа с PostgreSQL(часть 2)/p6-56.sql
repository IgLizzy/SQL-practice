============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create view task_1a as
	explain analyze --2148.35 / 10
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join inventory i on r.inventory_id = i.inventory_id
	join film f on f.film_id = i.film_id
	join customer c on c.customer_id = r.customer_id
	where row_number = 1

create view task_1b as
select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.film_id, f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental) r 
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id
where row_number = 1

explain analyze --2148.35 / 10
select *
from task_1a

select t.*, p.sum
from task_1b t
join (
	select customer_id, sum(amount) 
	from payment
	group by 1) p on t.customer_id = p.customer_id

4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_2 as 
	select f.title, concat(a.last_name, ' ', a.first_name), count(f.film_id) over (partition by a.actor_id)
	from actor a
	join film_actor fa on fa.actor_id = a.actor_id
	join film f on f.film_id = fa.film_id
	
select *
from task_2
	
============= материализованные представления =============

5. Создайте материализованное представление с колонками клиент (ФИО; email) и title фильма, 
который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные 

create materialized view task_3a as
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join inventory i on r.inventory_id = i.inventory_id
	join film f on f.film_id = i.film_id
	join customer c on c.customer_id = r.customer_id
	where row_number = 1
with no data

explain analyze --2148.35 / 10
select *
from task_1a

explain analyze --12.99 / 0.045
select * 
from task_3a

select 10 / 0.045

refresh materialized view task_3a

create materialized view task_3b as
	select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.film_id, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join inventory i on r.inventory_id = i.inventory_id
	join film f on f.film_id = i.film_id
	join customer c on c.customer_id = r.customer_id
	where row_number = 1
--with data
	
select t.*, p.sum
from task_3b t
join (
	select customer_id, sum(amount) 
	from payment
	group by 1) p on t.customer_id = p.customer_id

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные

create materialized view task_4 as 
	select c."name"
	from category c
	join film_category fc on c.category_id = fc.category_id
	join film f on f.film_id = fc.film_id
	group by c.category_id
	having avg(f.rental_duration) > 5
 
select * from task_4
 
--запрос на проверку времени обновления мат представлений

WITH pgdata AS (
    SELECT setting AS path
    FROM pg_settings
    WHERE name = 'data_directory'
),
path AS (
    SELECT
    	CASE
            WHEN pgdata.separator = '/' THEN '/'    -- UNIX
            ELSE '\'                                -- WINDOWS
        END AS separator
    FROM 
        (SELECT SUBSTR(path, 1, 1) AS separator FROM pgdata) AS pgdata
)
SELECT
        ns.nspname||'.'||c.relname AS mview,
        (pg_stat_file(pgdata.path||path.separator||pg_relation_filepath(ns.nspname||'.'||c.relname))).modification AS refresh
FROM pgdata, path, pg_class c
JOIN pg_namespace ns ON c.relnamespace=ns.oid
WHERE c.relkind='m';

schema | mat_view | user | time_start | time_end | status | count | --настраивается через стороннее ПО

drop view

drop materialized view

explain analyze --1983.37 / 11
select *
from task_1a
where lower(left(concat, 1)) in ('a', 'e')

explain analyze --17.48 / 0.26
select * 
from task_3a
where lower(left(concat, 1)) in ('a', 'e')

create index first_letter_idx on task_3a (lower(left(concat, 1)))

explain analyze --15.77 / 0.026
select * 
from task_3a
where lower(left(concat, 1)) in ('a', 'e')

============ Индексы ===========

btree = > < in null between
hash = 
gist сложными типами
gin сложными типами
интерфейсные

DROP INDEX public.film_fulltext_idx;
DROP INDEX public.idx_fk_language_id;
DROP INDEX public.idx_fk_original_language_id;
DROP INDEX public.idx_title;

alter table film drop constraint film_pkey cascade

0 индексов - 472кб

select *
from film

create index title_idx on film (title)

select title, film_id, *
from film

1 индекс - 528кб

explain analyze --Seq Scan on film  (cost=0.00..67.50 rows=1 width=386) (actual time=0.057..0.230 rows=1 loops=1)
select *
from film 
where film_id = 189

alter table film add constraint film_pkey primary key (film_id)

explain analyze --Index Scan using film_pkey on film  (cost=0.28..8.29 rows=1 width=386) (actual time=0.022..0.022 rows=1 loops=1)
select *
from film 
where film_id = 189

explain analyze --Index Scan using film_pkey on film  (cost=0.28..66.82 rows=648 width=386) (actual time=0.022..0.219 rows=648 loops=1)
select *
from film 
where film_id < 649

explain analyze --Seq Scan on film  (cost=0.00..67.50 rows=649 width=386) (actual time=0.010..0.251 rows=649 loops=1)
select *
from film 
where film_id < 650

1-1000
1-500 501-1000
1-250 251-500 501-750 751-1000
1-125 126-250 ...

explain analyze
select *
from film 
where title = 'AGENT TRUMAN'

a-z 
a-k l-z

a-z 
a-k l-z

2 индекс - 568кб

create index strange_1_idx on film (rental_rate, rental_duration, length, replacement_cost)

explain analyze
select *
from film 
where rental_rate = 2.99 and length > 300

3 индекс - 624кб

create index strange_2_idx on film (rental_rate, rental_duration, length, replacement_cost, description, title)

4 индекс - 800кб

explain analyze --Index Scan using film_pkey on film  (cost=0.28..8.29 rows=1 width=386) (actual time=0.022..0.022 rows=1 loops=1)
select *
from film 
where film_id = 189

create index film_id_hash_idx on film using hash (film_id)

5 индекс - 848кб

select - все здорово, работает быстро
insert - внести в таблицу + в 5 индексов
update - изменить в таблице + в индексах
delete - внести в таблицу + в 5 индексов

explain analyze --Index Scan using film_id_hash_idx on film  (cost=0.00..8.02 rows=1 width=386) (actual time=0.033..0.011 rows=1 loops=1)
select *
from film 
where film_id = 189

explain analyze --Index Scan using film_id_hash_idx on film  (cost=0.00..8.02 rows=1 width=386) (actual time=0.033..0.011 rows=1 loops=1)
select *
from film 
where film_id < 189

explain analyze --Seq Scan on payment  (cost=0.00..359.74 rows=80 width=12) (actual time=0.351..1.588 rows=8 loops=1)
select payment_id, payment_date
from payment 
where payment_date::date = '2005-05-24'

create index payment_date_idx on payment (payment_date)

explain analyze --Seq Scan on payment  (cost=0.00..359.74 rows=80 width=12) (actual time=0.351..1.588 rows=8 loops=1)
select payment_id, payment_date
from payment 
where payment_date::date = '2005-05-24'

create index payment_date_date_idx on payment (cast(payment_date as date))

explain analyze --Seq Scan on payment  (cost=0.00..359.74 rows=80 width=12) (actual time=0.351..1.588 rows=8 loops=1)
select payment_id, payment_date
from payment 
where payment_date::date = '2005-05-24'

Bitmap Index Scan - делит данные на слои
Bitmap Heap Scan - накладывает слои друг на друга и получает нужные значения

drop index payment_date_date_idx

create index payment_date_date_idx on payment (cast(payment_date as date)) where cast(payment_date as date) > '01.08.2005'

explain analyze --Seq Scan on payment  (cost=0.00..359.74 rows=80 width=12) (actual time=0.517..2.520 rows=8 loops=1)
select payment_id, payment_date
from payment 
where payment_date::date = '2005-05-24'

explain analyze --Bitmap Heap Scan on payment  (cost=55.61..254.86 rows=5350 width=12) (actual time=0.176..0.906 rows=5198 loops=1)
select payment_id, payment_date
from payment 
where payment_date::date > '2005-08-01'

select *
from pg_catalog.pg_indexes pi2

============ explain ===========

Ссылка на сервис по анализу плана запроса 
https://explain.depesz.com/ -- открывать через ВПН
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/

explain analyze --2148.35 / 10
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join inventory i on r.inventory_id = i.inventory_id
	join film f on f.film_id = i.film_id
	join customer c on c.customer_id = r.customer_id
	where row_number = 1
	
Nested Loop  (cost=1559.44..2126.42 rows=80 width=79) (actual time=6.696..9.960 rows=599 loops=1)
	
cost 
time 

< time 
< cost
	
explain (format json, analyze) --2148.35 / 10
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join inventory i on r.inventory_id = i.inventory_id
	join film f on f.film_id = i.film_id
	join customer c on c.customer_id = r.customer_id
	where row_number = 1
	
======================== json ========================

СЛОЖНЫЕ ТИПЫ ДАННЫХ НЕЛЬЗЯ ПРИВОДИТЬ К СТРОКЕ, НЕДОПУСТИМО, ПЛОХО И УЖАСНО.

Создайте таблицу orders

CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "Beer","qty": 6,"a":345}, "customer": "John Doe"}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "01.01.2023","qty": "fgdfgh"}, "customer": "John Doe"}'
 )

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )

select  * from orders

|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|

6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select info, pg_typeof(info)
from orders

select info->'items', pg_typeof(info->'items')
from orders

select info->'items'->'qty', pg_typeof(info->'items'->'qty')
from orders

select sum((info->'items'->'qty')::numeric)--, pg_typeof(info->'items'->'qty')
from orders

select info->'items'->>'qty', pg_typeof(info->'items'->>'qty')
from orders

select sum((info->'items'->>'qty')::numeric)--, pg_typeof((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'qty' ~ '^[0-9\.]+'

6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'qty' ~ '^[0-9\.]+' and info->'items'->>'product' ilike 'Toy%'

select json_object_keys(info->'items')
from orders

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

time[] ['10:00', '17:00']
int[] [4563,23,867,53]
text[] ['45345', '01.02.2023', 'dfgadkjgad']

массив text[] [, 'y'] к логическому типу привести возможно?

'n'::boolean

2023: {01: 50}

[[2023, 01, 50],[2023, 02, 30],[2023, 03, 70]]

2023Х01-50,2023Х02-30,2023Х03-70

create table a (
	id serial primary key,
	val int[])
	
insert into a (val)
values (array[50])

insert into a (val)
values ('{77}')

select val[1]
from a

update a 
set val[-10] = 100
where id = 1

select val
from a

{[-10:1]={100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50}}

select val[-10:-5]
from a

select title, array_length(special_features, 1)
from film 

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 1)

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2)

select cardinality('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[])

select title, array_lower(special_features, 1), array_upper(special_features, 1)
from film 

select title, special_features, array_append(special_features, 'dfjkghsakl;dfbg;i')
from film 

select title, special_features || '{1,2,34}'::text[]
from film 

7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

https://postgrespro.ru/docs/postgresql/14/functions-subquery
https://postgrespro.ru/docs/postgrespro/14/functions-array

-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
select title, special_features --535
from film 
where special_features::text ilike '%Trailers%'

Trailers
Trailers1
Trailers2

-- ПЛОХАЯ ПРАКТИКА --
select title, special_features --535
from film 
where special_features[1] = 'Trailers' or special_features[2] = 'Trailers' or
	special_features[3] = 'Trailers' or special_features[4] = 'Trailers'
	
select title, special_features --535
from film 
where special_features[2] = 'Trailers' 
	
-- ЧТО-ТО СРЕДНЕЕ ПРАКТИКА --
select f.title, f.special_features --535
from (
	select film_id, title, unnest(special_features) 
	from film) t 
join film f on f.film_id = t.film_id and t.unnest = 'Trailers'

select title, special_features
from film
where 'Trailers' in (select unnest(special_features))

-- ХОРОШАЯ ПРАКТИКА --
select title, special_features --535
from film
where special_features && array['Trailers', 'Trailers_b '] -- хотя бы одно

select title, special_features --535
from film
where special_features @> array['Trailers'] -- все справа должны быть слева

select title, special_features 
from film
where special_features <@ array['Trailers'] --слева ровно такие же, как справа

select title, special_features --535
from film
where 'Trailers' = any(special_features) -- хотя бы один элемет равен тому, что слева   some - синоним any

select title, special_features
from film
where 'Trailers' = all(special_features) -- все элеметы равны тому, что слева 

select title, special_features, array_position(special_features, 'Deleted Scenes')-- Deleted Scenes
from film
where array_position(special_features, 'Deleted Scenes') is not null

select title, array_append(special_features, 'Deleted Scenes'), array_positions(array_append(special_features, 'Deleted Scenes'), 'Deleted Scenes')-- Deleted Scenes
from film
where array_length(array_positions(array_append(special_features, 'Deleted Scenes'), 'Deleted Scenes'), 1) > 0

select title, special_features, array_positions(special_features, 'Deleted Scenes')-- Deleted Scenes
from film

'hello world'

select title, special_features[2] as dffddf
from film