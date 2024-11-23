from
on 
join 
where 
group by 
having 
over --оконная функция
select 
order by

cust_id | amount | 
1			5
1			10
1			2
2			3
2			7
2			5

sum(amount) group by cust_id

cust_id | amount | 
1			17
2			15

cust_id | amount | sum(amount) over (partition by cust_id)
1			5		17
1			10		17
1			2		17
2			3		15
2			7		15
2			5		15

функция(аргументы) over (partition by arg1, arg2 order by  arg3, arg4)


============= оконные функции =============

1. Вывести ФИО пользователя и название пятого фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате аренды
* Задайте окно с использованием предложений over, partition by и order by
* Соедините с customer
* Соедините с inventory
* Соедините с film
* В условии укажите 3 фильм по порядку

explain analyze --2444.01 / 14
select concat(c.last_name, ' ', c.first_name), f.title
from (
	select customer_id, array_agg(rental_id)
	from (
		select *
		from rental 
		order by customer_id, rental_date) t1
	group by customer_id) t2
join rental r on r.rental_id = t2.array_agg[5]
join customer c on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

explain analyze --1959.63 / 12
select concat(c.last_name, ' ', c.first_name), f.title
from (
	select customer_id, array_agg(inventory_id)
	from (
		select *
		from rental 
		order by customer_id, rental_date) t1
	group by customer_id) t2
join inventory i on i.inventory_id = t2.array_agg[5]
join customer c on c.customer_id = t2.customer_id
join film f on f.film_id = i.film_id

explain analyze --2148.35 / 11
select concat(c.last_name, ' ', c.first_name), f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental) r 
join customer c on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where row_number = 5

explain analyze --2148.35 / 17
select concat(c.last_name, ' ', c.first_name), f.title
from (
	select *, nth_value(rental_id, 5) over (partition by customer_id order by rental_date)
	from rental) r 
join customer c on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where nth_value = rental_id

select concat(c.last_name, ' ', c.first_name), f.title
from (
	select *, nth_value(rental_id, 5) over (partition by customer_id order by rental_date 
		rows between unbounded preceding and unbounded following)
	from rental) r 
join customer c on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where nth_value = rental_id

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж 
каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

select concat, title, avg(amount) over (partition by customer_id)
from (
	select c.customer_id, f.film_id, concat(c.last_name, ' ', c.first_name), f.title, p.amount
	from customer c
	join payment p on c.customer_id = p.customer_id
	join rental r on r.rental_id = p.rental_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id) t
	
select concat, title, 
	avg(amount) over (partition by customer_id), 
	sum(amount) over (partition by customer_id), 
	count(amount) over (partition by customer_id), 
	min(amount) over (partition by customer_id), 
	max(amount) over (partition by customer_id), 
	avg(amount) over (), 
	sum(amount) over (), 
	count(amount) over (), 
	min(amount) over (), 
	max(amount) over (),
	avg(amount) over (partition by film_id), 
	sum(amount) over (partition by film_id), 
	count(amount) over (partition by film_id), 
	min(amount) over (partition by film_id), 
	max(amount) over (partition by film_id) 
from (
	select c.customer_id, f.film_id, concat(c.last_name, ' ', c.first_name), f.title, p.amount
	from customer c
	join payment p on c.customer_id = p.customer_id
	join rental r on r.rental_id = p.rental_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id) t

explain analyze --689.84 / 7
select customer_id, sum(amount), sum(amount) * 100 / (select sum(amount) from payment)
from payment 
group by 1

explain analyze --377.71 / 4.5
select customer_id, sum(amount), sum(amount) * 100 / sum(sum(amount)) over ()
from payment 
group by 1

/*select customer_id, sum(sum(amount)) 
from payment 
group by 1*/

over () - по всем данным глобально без какой либо последовательности
over (partition by) по каждой группе в отдельности без какой либо последовательности
over (order by) по всем данным глобально в определенной последовательности
over (partition by order by) по каждой группе в отдельности в определенной последовательности
	
-- формирование накопительного итога
НАКОПИТЕЛЬНЫЙ ИТОГ ФОРМИРУЕТСЯ ТОЛЬКО ЧЕРЕЗ ORDER by

select customer_id, payment_date, amount
from payment 

2.99 = 2.99
2.99 + 0.99 = 3.98
2.99 + 0.99 + 5.99 = 9.97

select customer_id, payment_date, amount, sum(amount) over (partition by customer_id order by payment_date)
from payment 

sum(amount) over (partition by customer_id order by customer_id, payment_date) --так сортировать не нужно

select customer_id, payment_date::date, amount, 
	sum(amount) over (partition by customer_id order by payment_date::date),
	sum(amount) over (partition by customer_id)
from payment 

2.99 = 2.99
2.99 + 0.99 = 3.98
2.99 + 0.99 + 5.99 + 0.99 + 9.99 = 20.95

select customer_id, payment_date::date, amount, 
	avg(amount) over (partition by customer_id order by payment_date::date)
from payment 

-- работа функций lead и lag

дата_убытия_1 | дата_прибытия_1
дата_убытия_2 | дата_прибытия_2
дата_убытия_3 | дата_прибытия_3

дата_убытия_2 - lag(дата_прибытия_1) over (partition by .. order by дата_убытия_1)

select customer_id, payment_date, 
	lag(amount) over (partition by customer_id order by payment_date),
	amount,
	lead(amount) over (partition by customer_id order by payment_date)
from payment 

select customer_id, payment_date, 
	lag(amount, 3) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 3) over (partition by customer_id order by payment_date)
from payment 

select customer_id, payment_date, 
	lag(amount, 3, 0.) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 3, 0.) over (partition by customer_id order by payment_date)
from payment 

select date_trunc('month', payment_date), sum(amount),
	lag(sum(amount)) over (order by date_trunc('month', payment_date)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment 
group by 1


select date_trunc('month', created_at), sum(amount),
	lag(sum(amount)) over (order by date_trunc('month', created_at)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', created_at))
from projects  
group by 1

select date_trunc('month', created_at), sum(amount),
	lag(sum(amount), 12, 0.) over (order by date_trunc('month', created_at)),
	sum(amount) - lag(sum(amount), 12, 0.) over (order by date_trunc('month', created_at))
from projects  
group by 1

-- работа с рангами и порядковыми номерами
row_number - сквозная нумерация
dense_rank - получение общего ранга по общему знаменателю и каждый последующий ранг увеличивается на +1
rank - получение общего ранга по общему знаменателю и каждый последующий ранг увеличивается на значение предыдущего ранга + кол-во записей
в предыдущем ранге

1 1:00
2,3 0:59
4 0:58

1 - 1
2 - 2,3
3 - 4

1 - 1
2 - 2,3
4 - 4

select customer_id, payment_date::date,
	row_number() over (partition by customer_id order by payment_date::date), 
	dense_rank() over (partition by customer_id order by payment_date::date), 
	rank() over (partition by customer_id order by payment_date::date)
from payment 

-- last_value / first_value / nth_value
first_value - все хорошо, используйте, не бойтесь
last_value, nth_value - ИСПОЛЬЗОВАТЬ НА СВОЙ СТРАХ И РИСК, ТАК КАК МОГУТ ВОЗВРАЩАТЬ ТО, ЧЕГО НЕ ОЖИДАЕТЕ
--получить информацию по первой аренде пользователя

explain analyze --1511.31 / 6
select distinct on (customer_id) *
from rental 
order by customer_id, rental_date asc

explain analyze --806.3 / 5.4
select *
from rental 
where (customer_id, rental_date) in (
	select customer_id, min(rental_date)
	from rental
	group by 1)

explain analyze --2433.84 / 30
select distinct first_value(rental_id) over (partition by customer_id order by rental_date),
	first_value(rental_date) over (partition by customer_id order by rental_date),
	first_value(inventory_id) over (partition by customer_id order by rental_date),
	first_value(customer_id) over (partition by customer_id order by rental_date),
	first_value(return_date) over (partition by customer_id order by rental_date),
	first_value(staff_id) over (partition by customer_id order by rental_date),
	first_value(last_update) over (partition by customer_id order by rental_date)
from rental 

explain analyze --1952.52 / 15
select *
from (
	select * , first_value(rental_id) over (partition by customer_id order by rental_date)
	from rental) t
where rental_id = first_value

--ложный запрос
select *
from (
	select * , last_value(rental_id) over (partition by customer_id order by rental_date desc)
	from rental) t
where rental_id = last_value

--ложный запрос
select *
from (
	select * , last_value(rental_id) over (partition by customer_id)
	from rental
	order by rental_date desc) t
where rental_id = last_value

select *
from (
	select *, last_value(rental_id) over (partition by customer_id)
	from (
		select *
		from rental
		order by customer_id, rental_date desc) t1) t2 
where rental_id = last_value

select *
from (
	select * , last_value(rental_id) over (partition by customer_id order by rental_date desc
		rows between unbounded preceding and unbounded following)
	from rental
	order by rental_date desc) t
where rental_id = last_value

select customer_id, payment_date, amount,
	avg(amount) over (partition by customer_id order by payment_date rows between 5 preceding and current row)
from payment 

select customer_id, payment_date, amount,
	avg(amount) over (partition by customer_id order by payment_date rows between 3 preceding and 3 following)
from payment 

--алиасы
select customer_id, payment_date, amount,
	avg(amount) over w_1,
	sum(amount) over w_1,
	count(amount) over w_1,
	avg(amount) over w_2,
	sum(amount) over w_2,
	count(amount) over w_2,
	avg(amount) over w_3,
	sum(amount) over w_3,
	count(amount) over w_3
from payment 
window w_1 as (partition by customer_id order by payment_date rows between 3 preceding and 3 following),
	w_2 as (),
	w_3 as (partition by customer_id, payment_date::date)
order by 1

--фильтрация
select customer_id, payment_date, amount, 
	sum(amount) filter (where amount < 5) over (partition by customer_id order by payment_date),
	sum(amount) filter (where amount >= 5) over (partition by customer_id order by payment_date)
from payment 

============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Название фильма продолжительностью более 3 часов и к какой категории относится фильм
* Создайте CTE:
 - Используйте таблицу film
 - отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category

select version() --PostgreSQL 15.0, compiled by Visual C++ build 1914, 64-bit

select version() --PostgreSQL 10.22, compiled by Visual C++ build 1800, 64-bit
 
explain analyze -- 15 / 53.79 / 0.4   10 / 96.82 / 0.32
with cte1 as (
	select film_id, title
	from film 
	where length > 180),
cte2 as (
	select category_id, name
	from category 
	where lower(left(name, 1)) = 'c'),
cte3 as (
	select cte1.title, cte2.name
	from cte1
	join film_category fc on fc.film_id = cte1.film_id
	join cte2 on fc.category_id = cte2.category_id)
select * 
from cte3

with cte1 as (
	select customer_id, amount, payment_date 
	from payment p)
select *
from (
	select customer_id, sum(amount)
	from cte1
	group by 1) t1
join (
	select customer_id, avg(amount)
	from cte1
	group by 1) t2 on t1.customer_id = t2.customer_id

2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие остановки
 + Напишите запрос к CTE

with recursive r as (
	--стартовая часть
	select 1 as x, 1 as factorial
	union 
	--рекурсивная часть
	select x + 1 as x, factorial * (x + 1) as factorial
	from r
	where x < 10)
select *
from r

SQL Error [22003]: ОШИБКА: целое вне диапазона

with recursive r as (
	select *, 1 as level
	from "structure" s
	where unit_id = 114
	union 
	--рекурсивная часть
	select s.*, level + 1 as level
	from r
	join "structure" s on r.unit_id = s.parent_id)
select count(*)
from r
join position p on r.unit_id = p.unit_id
join employee e on e.pos_id = p.pos_id

114	12	Отдел	Центр разработки Medio	1

with recursive r as (
	select *, 1 as level
	from "structure" s
	where unit_id = 114
	union 
	--рекурсивная часть
	select s.*, level + 1 as level
	from r
	join "structure" s on r.parent_id = s.unit_id)
select *
from r

1 блок 
2 департамент
3 группа

with recursive r as (
	select *, 1 as level
	from "structure" s
	where parent_id = 0
	union 
	--рекурсивная часть
	select s.*, level + 1 as level
	from r
	join "structure" s on r.unit_id = s.parent_id)
select *
from r

3.2 Работа с рядами.

with recursive r as (
	select 1 as x
	union 
	--рекурсивная часть
	select x + 1 as x
	from r
	where x < 10)
select *
from r

explain analyze --3.57 / 0.032
with recursive r as (
	select 1 as x
	union 
	--рекурсивная часть
	select x + 3 as x
	from r
	where x < 100)
select *
from r

select x
from generate_series(1, 10, 1) x

explain analyze --0.34 / 0.007
select x
from generate_series(1, 100, 3) x

explain analyze --3.57 / 0.27
with recursive r as (
	select '01.01.2023'::date x
	union 
	--рекурсивная часть
	select x + 1 as x
	from r
	where x < '31.12.2023')
select *
from r

explain analyze --12.51 / 0.1
select x::date
from generate_series('01.01.2023'::date, '31.12.2023'::date, interval '1 day') x

select date_trunc('month', payment_date), sum(amount),
	lag(sum(amount)) over (order by date_trunc('month', payment_date)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment 
group by 1

explain analyze --5177.71 / 11
with recursive r as (
	select min(date_trunc('month', payment_date)) x
	from payment
	union 
	--рекурсивная часть
	select x + interval '1 month' as x
	from r
	where x < (select max(date_trunc('month', payment_date)) from payment))
select x::date, coalesce(sum, 0.), lag(coalesce(sum, 0.), 1, 0.) over (order by x),
	coalesce(sum, 0.) - lag(coalesce(sum, 0.), 1, 0.) over (order by x)
from r
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by 1) t on date_trunc = x
order by 1

select coalesce(null, null, null, 7, null, 8)

explain analyze --16366.55 / 11.5
select x::date, coalesce(sum, 0.), lag(coalesce(sum, 0.), 1, 0.) over (order by x),
	coalesce(sum, 0.) - lag(coalesce(sum, 0.), 1, 0.) over (order by x)
from generate_series((select min(date_trunc('month', payment_date)) from payment p), 
	(select max(date_trunc('month', payment_date)) from payment p), interval '1 month') x
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by 1) t on date_trunc = x
order by 1

with cte as (
	with recursive r as ())
		
with recursive r as (
	with recursive r1 as (
		select 1 as y
		union 
		select y + 1 as y
		from r1 
		where y < 3)
	select *
	from r1
	union 
	--рекурсивная часть	
	select y + 1 as y
	from r
	where y < 100)
select *
from r

with recursive r as (
	select 1 as x
	union 
	--рекурсивная часть
	select x + 1 as x
	from r
	where x < 10)
select *
from r

SQL Error [42P19]: ОШИБКА: рекурсивный запрос "r" должен иметь форму {нерекурсивная часть} UNION [ALL] {рекурсивная часть}