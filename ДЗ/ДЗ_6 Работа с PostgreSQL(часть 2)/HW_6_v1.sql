
--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

explain analyze--cost=77.50 | 0.34мс
select f.film_id , f.title ,f.special_features 
from film f 
where 'Behind the Scenes' = any(f.special_features)

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

--v2
explain analyze--cost=67.50 | 0.35мс
select f.film_id , f.title ,f.special_features 
from film f
where f.special_features @> array['Behind the Scenes']

--v3
explain analyze--cost=67.50 | 0.35мс
select f.film_id , f.title ,f.special_features 
from film f
where f.special_features && array['Behind the Scenes']

--v3.2 если v3 не подойдет
explain analyze--cost=113.75 | 0.75мс
select f.film_id , f.title ,f.special_features 
from film f
where 'Behind the Scenes' in (select unnest(special_features)) 

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

explain analyze --cost=1997.13 | 10мс
with cte1 as (
	select c.customer_id, f.film_id , f.title ,f.special_features 
	from film f 
	join inventory i on f.film_id = i.film_id
	join rental r on i.inventory_id = r.inventory_id
	join customer c on c.customer_id = r.customer_id
	where 'Behind the Scenes' = any(f.special_features))
select distinct customer_id, count(title) over (partition by customer_id)
from cte1
order by customer_id

--возможно имелось ввиду такое решение
explain analyze--cost=1997.13 | 10мс
with cte1 as (
	select f.film_id , f.title ,f.special_features 
	from film f 
	where 'Behind the Scenes' = any(f.special_features))
select distinct c.customer_id, count(cte1.title) over (partition by c.customer_id)
from cte1
join inventory i on i.film_id = cte1.film_id
join rental r on i.inventory_id = r.inventory_id
join customer c on c.customer_id = r.customer_id
order by customer_id

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze --cost=1997.13 | 10мс
select distinct c.customer_id, count(t1.title) over (partition by c.customer_id)
from (
	select f.film_id , f.title ,f.special_features 
	from film f 
	where 'Behind the Scenes' = any(f.special_features)) t1
join inventory i on i.film_id = t1.film_id
join rental r on i.inventory_id = r.inventory_id
join customer c on c.customer_id = r.customer_id
order by customer_id

--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view task_1 as select distinct c.customer_id, count(t1.title) over (partition by c.customer_id)
	from (
		select f.film_id , f.title ,f.special_features 
		from film f 
		where 'Behind the Scenes' = any(f.special_features)) t1
	join inventory i on i.film_id = t1.film_id
	join rental r on i.inventory_id = r.inventory_id
	join customer c on c.customer_id = r.customer_id
	order by customer_id
with no data

refresh materialized view task_1

create materialized view task_2 as select distinct c.customer_id, count(t2.title) over (partition by c.customer_id)
	from (
		select * 
		from film f 
		where 'Behind the Scenes' = any(f.special_features)) t2
	join inventory i on i.film_id = t2.film_id
	join rental r on i.inventory_id = r.inventory_id
	join customer c on c.customer_id = r.customer_id
	order by customer_id
with no data

refresh materialized view task_2

explain analyze--cost= 9.99 | 0.045мс
select *
from task_1

explain analyze--cost= 30.40 | 0.045мс
select *
from task_2

drop materialized view task_2

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.

--1.Материализованное представление
--2.В данном случае они затрачивают одинаковое количество ресурсов системы.


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

explain analyze --cost= 1090.40 | 32.5мс
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc


explain analyze--cost= 2040.30 | 18.5мс
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, f.special_features as sf_string
		from inventory i
		join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where 'Behind the Scenes' = any(ren.special_features)
order by count desc


--explain (format json, analyze)
explain analyze--cost= 2040.30 | 18мс
with cte_3 as (
	select inv.special_features, r.inventory_id as iid, inv.sf_string, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, f.special_features as sf_string
		from inventory i
		join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id)
select distinct cu.first_name  || ' ' || cu.last_name as name, 
count(cte_3.iid) over (partition by cu.customer_id)
from customer cu
join cte_3 on cte_3.cid = cu.customer_id
where 'Behind the Scenes' = any(cte_3.special_features)
order by count desc

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

select t1.staff_id, f.film_id, f.title, t1.amount, t1.payment_date, c.last_name, c.first_name 
from(
	select *, row_number() over (partition by p.staff_id order by p.payment_date)
	from payment p ) t1
join rental r on r.rental_id = t1.rental_id
join inventory i on i.inventory_id = r.inventory_id
left join film f on f.film_id = i.film_id 
join customer c on c.customer_id = t1.customer_id 
where row_number = 1

--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

select *, dense_rank() over (partition by s.store_id order by r.rental_date::date),
count(i.film_id) over (partition by r.rental_date::date)
from store s 
join inventory i using(store_id) 
join rental r using(inventory_id)
--where row_number = 1
where s.store_id = 1
--order by count desc



select distinct *, max(count) over (partition by q1.store_id)--count(q1.rental_date) over (partition by dense_rank), max(dense_rank) over (partition by q1.store_id)
from 
	(select e1.store_id, e1.rental_date, dense_rank, 
	count(e1.film_id) over (partition by e1.rental_date::date)
	--count(e1.rental_date) over (partition by dense_rank)
	from (
		select *, row_number() over (partition by s.store_id order by r.rental_date::date),
		dense_rank() over (partition by s.store_id order by r.rental_date::date)
		--count(i.film_id) over (partition by r.rental_date::date)
		from store s 
		join inventory i using(store_id) 
		join rental r using(inventory_id)) e1) q1
--where dense_rank = max
where q1.store_id = 1
