	 a 					 b
a_id | a_val	b_id | b_val | a_id
1				1				1
2				2				1
	 		 
				ab
a_id | a_val | b_id | b_val | a_id
1				1				1
1				2				1
	
============= теория =============

create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five');

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight');

select * from table_one;

select * from table_two;

--left, right, inner, full, cross

select table_one.name_one, table_two.name_two
from table_one
inner join table_two on table_one.name_one = table_two.name_two

select table_one.name_one, table_two.name_two
from table_one
join table_two on table_one.name_one = table_two.name_two

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1 
left join table_two t2 on t1.name_one = t2.name_two

select c.last_name, c.address_id, a.address_id --599
from customer c 
join address a on a.address_id = c.address_id

select c.last_name, c.address_id, a.address_id --599
from customer c 
left join address a on a.address_id = c.address_id

--удалили 3 адреса

select c.last_name, c.address_id, a.address_id --596
from customer c 
join address a on a.address_id = c.address_id

select c.last_name, c.address_id, a.address_id --599
from customer c 
left join address a on a.address_id = c.address_id

select t1.name_one, t2.name_two
from table_one t1 
right join table_two t2 on t1.name_one = t2.name_two

select c.last_name, c.address_id, a.address_id --603
from customer c 
right join address a on a.address_id = c.address_id

select t1.name_one, t2.name_two
from table_one t1 
full join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1 
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select c.last_name, c.address_id, a.address_id --603
from customer c 
right join address a on a.address_id = c.address_id
where c.address_id is null

select *
from rental r
left join payment p on r.rental_id = p.rental_id
where p.payment_id is null

select t1.name_one, t2.name_two
from table_one t1 
cross join table_two t2 

select c1.first_name, c2.first_name --358 801
from customer c1, customer c2

select c1.first_name, c2.first_name --358 186
from customer c1, customer c2
where c1.first_name != c2.first_name

select c1.first_name, c2.first_name --179 093
from customer c1, customer c2
where c1.first_name > c2.first_name

--AARON	ADAM
ADAM	AARON

select t1.name_one, t2.name_two
from table_one t1, table_two t2 
where t1.name_one = t2.name_two

cross / inner / left|right|full

В ОДНОЙ ИЗ ТАБЛИЦ ОБЩИЙ ЗНАМЕНАТЕЛЬ ДОЛЖЕН БЫТЬ УНИКАЛЕН!!!!!

delete from table_one;
delete from table_two;

insert into table_one (name_one)
select unnest(array[1,1,2]);

insert into table_two (name_two)
select unnest(array[1,1,3]);

select * from table_one

select * from table_two

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

1A	1B
1a	1b
2c	3d

1A1B
1A1b
1a1B
1a1b

select t1.name_one, t2.name_two
from table_one t1 
left join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1 
right join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1 
full join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1 
cross join table_two t2 

select count(*) --599
from customer 

select count(*) --16048
from payment  

select count(*) --16043
from rental 

select count(*) --16048
from customer c 
join payment p on c.customer_id = p.customer_id

p.c_id  c.c_id
1		1	
1
1
1

--ЛОЖНОЕ РЕШЕНИЕ
select count(*) --445420
from customer c 
join payment p on c.customer_id = p.customer_id
join rental r on r.customer_id = c.customer_id

p_c.c_id  r.c_id
1			1		
1			1
1			1
1			1

--ВЕРНОЕ РЕШЕНИЕ
select count(*) --16048
from customer c 
join payment p on c.customer_id = p.customer_id
join rental r on r.rental_id = p.rental_id
--join country c2 on нет условия

--union / except

select lower(first_name) --599
from customer 
union --distinct
select lower(first_name) --2
from staff 
--591

select lower(first_name) --599
from customer 
union all
select lower(first_name) --2
from staff 
--601

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 2 as y) t
except --distinct
select 1 as x, 1 as y

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 2 as y) t
except all--distinct
select 1 as x, 1 as y

-- case
< 5 - малый платеж
5 - 10 средний платеж
> 10 большой платеж

select payment_id, amount,
	case
		when amount < 5 then 'малый платеж'
		when amount between 5 and 10 then 'средний платеж'
		else 'большой платеж'
	end
from payment 

select ca, count(*)
from (
	select payment_id, amount,
		case
			when amount < 5 then 'малый платеж'
			when amount between 5 and 10 then 'средний платеж'
			else 'большой платеж'
		end ca
	from payment) t
group by ca

============= соединения =============

1. Выведите список названий всех фильмов и их языков
* Используйте таблицу film
* Соедините с language
* Выведите информацию о фильмах:
title, language."name"

select f.title, l."name"
from film f
join "language" l on f.language_id = l.language_id

1. Выведите все фильмы и их категории:
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Соедините используя оператор using

select f.title, c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select f.film_id
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select *
from film f
join film_category fc using(film_id)
join category c using(category_id)

select film_id, category_id
from film f
join film_category fc using(film_id)
join category c using(category_id)

select *
from customer c
join store s using(store_id)
join staff s2 using(store_id)
join address a on a.address_id = c.address_id

select *
from customer c
join store s using(store_id)
join staff s2 using(store_id)
join address a using(address_id)

SQL Error [42702]: ОШИБКА: имя общего столбца "address_id" фигурирует в таблице слева неоднократно

select *
from payment p
join payment p2 on p.payment_date::date = p2.payment_date::date - 1

2. Выведите уникальный список фильмов, которые брали в аренду '24-05-2005'. 
* Используйте таблицу film
* Соедините с inventory
* Соедините с rental
* Отфильтруйте, используя where 

--ложный запрос
select f.title, r.rental_date
from film f
join inventory i on f.film_id = i.film_id
join rental r on r.rental_id = i.inventory_id

select f.title, r.rental_date
from film f
join inventory i on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id
where r.rental_date::Date = '24-05-2005'

select f.title, r.rental_date
from film f
join inventory i on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id and r.rental_date::Date = '24-05-2005'

select f.title, r.rental_date
from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id and r.rental_date::Date = '24-05-2005'

2.1 Выведите все магазины из города Woodridge (city_id = 576)
* Используйте таблицу store
* Соедините таблицу с address 
* Соедините таблицу с city 
* Соедините таблицу с country 
* отфильтруйте по "city_id"
* Выведите полный адрес искомых магазинов и их id:
store_id, postal_code, country, city, district, address, address2, phone

explain analyze
select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a on a.address_id = s.address_id and a.city_id = 576
join city c on c.city_id = a.city_id
join country c2 on c2.country_id = c.country_id

============= агрегатные функции =============

count 
sum 
min 
max 
avg 
array_agg()
string_agg()

3. Подсчитайте количество актеров в фильме Grosse Wonderful (id - 384)
* Используйте таблицу film
* Соедините с film_actor
* Отфильтруйте, используя where и "film_id" 
* Для подсчета используйте функцию count, используйте actor_id в качестве выражения внутри функции
* Примените функцильные зависимости

select count(*), count(1), count('все что угодно из того, что нет в данных')
from film_actor fa
where film_id = 384

select count(*), count(address_id)
from customer c

select count(distinct customer_id), count(*)
from payment 

--ЛОЖНЫЙ ЗАПРОС
select f.title, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.title

SQL Error [42803]: ОШИБКА: столбец "f.title" должен фигурировать в предложении GROUP BY 
или использоваться в агрегатной функции

--ЛОЖНЫЙ ЗАПРОС
select f.title, f.rating, f.description, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.title, f.rating, f.description

select f.title, f.rating, f.description, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.film_id

select f.rating, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.rating


3.1 Посчитайте среднюю стоимость аренды за день по всем фильмам
* Используйте таблицу film
* Стоимость аренды за день rental_rate/rental_duration
* avg - функция, вычисляющая среднее значение
--4 агрегации

select round(avg(rental_rate/rental_duration), 2),
	sum(rental_rate/rental_duration), 
	count(*), 
	min(rental_rate/rental_duration),
	max(rental_rate/rental_duration)
from film f

select r.customer_id, f.title
from (
	select customer_id, array_agg(rental_id)
	from (
		select customer_id, rental_id
		from rental 
		order by customer_id, rental_date) t1
	group by customer_id) t2
join rental r on r.rental_id = t2.array_agg[5] and r.customer_id = t2.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select customer_id, string_agg(rental_id::text, ', ')
from (
	select customer_id, rental_id
	from rental 
	order by customer_id, rental_date) t1
group by customer_id

============= группировки =============

4. Выведите месяцы, в которые было сдано в аренду более чем на 10 000 у.е.
* Используйте таблицу payment
* Сгруппируйте данные по месяцу используя date_trunc
* Для каждой группы посчитайте сумму платежей
* Воспользуйтесь фильтрацией групп, для выбора месяцев с суммой продаж более чем на 10 000 у.е.

select date_trunc('month', payment_date), sum(amount)
from payment 
group by date_trunc('month', payment_date)

explain analyze
select date_trunc('month', payment_date), sum(amount)
from payment 
group by date_trunc('month', payment_date)
having sum(amount) > 10000 and date_trunc('month', payment_date) < '01.08.2005'

select date_trunc('month', payment_date), sum(amount)
from payment 
where date_trunc('month', payment_date) < '01.08.2005'
group by date_trunc('month', payment_date)
having sum(amount) > 10000

select customer_id, sum(amount)
from payment 
group by customer_id

1	2
1	3
1	4
1	7
1	1
1	5
2	2
2	5	
2	3
id sum 
1	22
2	10

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by customer_id, staff_id, date_trunc('month', payment_date)
order by 1, 2, 3

select customer_id a, staff_id b, date_trunc('month', payment_date) c, sum(amount)
from payment 
where customer_id < 4 
group by a, b, c
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by 1, 2, 3
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by grouping sets(1, 2, 3)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by grouping sets(1, 2, 3), grouping sets(1, 2)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by cube(1, 2, 3)
order by 1, 2, 3

create temporary table x as (
select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by cube(1, 2, 3)
order by 1, 2, 3)

select *
from x 
where customer_id is not null and date_trunc is not null and staff_id is null

select *
from x 
where customer_id is null and date_trunc is not null and staff_id is not null

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 4 
group by rollup(1, 2, 3)
order by 1, 2, 3

4.0.1 найти сумму платежей пользователей, где размер платежа меньше 5 у.е и сумму платежей пользователей, 
	где размер платежа больше 5 у.е

explain analyze --489.07 / 6
select customer_id, 
	sum(case when amount < 5 then amount end) rr5,
	sum(case when amount >= 5 then amount end) hhh7
from payment 
group by customer_id

explain analyze --489.07 / 5.8
select customer_id, 
	sum(amount) filter (where amount < 5),
	sum(amount) filter (where amount >= 5)
from payment 
group by customer_id


4.1 Выведите список категорий фильмов, средняя продолжительность аренды которых более 5 дней
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней

select c."name"
from category c
join film_category fc on fc.category_id = c.category_id
join film f on f.film_id = fc.film_id
group by c.category_id
having avg(f.rental_duration) > 5

============= подзапросы =============

5. Выведите количество фильмов, со стоимостью аренды за день больше, 
чем среднее значение по всем фильмам
* Напишите подзапрос, который будет вычислять среднее значение стоимости 
аренды за день (задание 3.1)
* Используйте таблицу film
* Отфильтруйте строки в результирующей таблице, используя опретаор > (подзапрос)
* count - агрегатная функция подсчета значений

скаляр  - не имеет алиаса и используется в select, условии и крайне редко в cross join
одномерный массив - не миеет алиаса используется в условиях
таблицу - обязательно алиас используется во from и join 

select title, rental_rate/rental_duration
from film f

select avg(rental_rate/rental_duration) from film f

select title, rental_rate/rental_duration
from film f
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film f)

explain analyze
select customer_id, sum(amount) * 100. / (select sum(amount) from payment) 
from payment 
group by customer_id

select customer_id, payment_date::date, sum(amount)
from payment 
where (customer_id, payment_date::date) in (
	select distinct customer_id, rental_date::date
	from rental)
group by 1, 2

select distinct customer_id, rental_date::date
from rental 


6. Выведите фильмы, с категорией начинающейся с буквы "C"
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
* Используйте подзапрос во from, join, where

select category_id, "name"
from category 
where "name" like 'C%'

explain analyse 
select f.title, t.s
from (
	select category_id, c."name" s
	from category c
	where "name" like 'C%') t
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id --175 / 53.54 / 0.38   

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
left join film_category fc on fc.category_id = t.category_id
left join film f on f.film_id = fc.film_id --175 / 53.54 / 0.38   

explain analyse
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.54 / 0.38 
	
explain analyze
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.54 / 0.43	

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and  
	fc.category_id in --(3, 4, 5)
		(select category_id
		from category 
		where "name" like 'C%') 
join category c on c.category_id = fc.category_id --175 / 47.36 / 0.34	


explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (--3, 4, 5) --(
	select category_id
	from category 
	where "name" like 'C%') --175 / 47.21 / 0.337	
	
explain analyze
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c."name" like 'C%'  --175 / 53.54	/ 0.38


--так не надо
explain analyze
select f.title, c.name
from (
	select film_id, title
	from film) f
join (
	select film_id, category_id 
	from film_category) fc on fc.film_id = f.film_id 
join (
	select category_id, name
	from category) c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%')	--47.21
	

select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%') --175 / 47.21 / 0.337	
	
-- ГРУБАЯ ОШИБКА, ЗА ЭТО УВОЛЬНЯЮТ
-- ГРУБАЯ ОШИБКА, ЗА ЭТО УВОЛЬНЯЮТ
-- ГРУБАЯ ОШИБКА, ЗА ЭТО УВОЛЬНЯЮТ
-- ГРУБАЯ ОШИБКА, ЗА ЭТО УВОЛЬНЯЮТ
-- ГРУБАЯ ОШИБКА, ЗА ЭТО УВОЛЬНЯЮТ
explain analyze --738210 / 674
select distinct customer_id, 
	(select sum(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select count(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select min(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select max(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select avg(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id)
from payment p
order by 1

-- ТАК НУЖНО
explain analyze --518 / 6.5
select customer_id, sum(amount), count('все что угодно'), min(amount), max(amount), avg(amount)
from payment
group by customer_id
order by 1

select 738210 / 518

select 674 / 6.5

explain analyze
select *
from payment p
where customer_id in (select customer_id from rental r where r.rental_id = p.rental_id)