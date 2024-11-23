Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим 
итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: letsdocode.ru...in/5-5.png

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment 
where date_trunc('month', payment_date) = '01.08.2005'
group by 1, 2

select pp.staff_id, pp.payment_date, sum(pp.sum) over (partition by pp.staff_id order by pp.payment_date)
from
 (
 select staff_id, payment_date::date, sum(amount)
 from payment
 where payment_date::date between '2005-08-01' and '2005-08-31'
 group by staff_id, payment_date::date) as pp;

select staff_id, payment_date::date, amount, sum
from 
	(select *, sum (amount) over (order by payment_date)
	from payment p ) foo
where payment_date::date between '2005-08-01' and '2005-08-31'

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную 
скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
Ожидаемый результат запроса: letsdocode.ru...in/5-6.png

select customer_id, row_number
from (
	select *, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') t 
--where row_number % 100 = 0
where mod(row_number,100) = 0

select *
from
(
select *, row_number() over (order by payment_date)
from payment
where payment_date::date = '2005-08-20'
) as rn
where row_number % 100=0;

with cte_row_cust as 
	(select *, row_number () over (order by payment_date)
		from (select *
				from payment p 
			where payment_date::date = '2005-08-20'
			) foo)
select *
from cte_row_cust
where cte_row_cust.row_number in (100,200,300,400,500,600,700,800)

select 10 % 5, 9 % 5, 2 % 4, 100 % 3

9 - 5 = 4

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: letsdocode.ru...in/5-7.png

explain analyze --6272.37 / 26
select distinct c.country,
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by count(r.rental_id) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by sum(p.amount) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by max(r.rental_date) desc)
from country c
left join city c2 on c.country_id = c2.country_id
left join address a on a.city_id = c2.city_id
left join customer c3 on a.address_id = c3.address_id
left join rental r on r.customer_id = c3.customer_id
left join payment p on r.rental_id = p.rental_id
group by c.country_id, c3.customer_id

explain analyze --1088.66 / 9
with cte1 as (
	select r.customer_id, count, sum, max
	from (
		select customer_id, sum(amount)
		from payment 
		group by customer_id) p
	join (
		select customer_id, count(*), max(rental_date)
		from rental 
		group by customer_id) r on r.customer_id = p.customer_id),
cte2 as (
	select c2.country_id, concat(c.last_name, ' ', c.first_name), count, sum, max,
		case when count = max(count) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name) end cc,
		case when sum = max(sum) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name) end cs,
		case when max = max(max) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name) end cm
	from cte1 
	join customer c on cte1.customer_id = c.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on a.city_id = c2.city_id)
select c.country, string_agg(cc, ', ') , string_agg(cs, ', '), string_agg(cm, ', ')
from country c
left join cte2 on c.country_id = cte2.country_id
group by c.country_id

Задание 1. Откройте по ссылке SQL-запрос.
Сделайте explain analyze этого запроса.
Основываясь на описании запроса, найдите узкие места и опишите их.
Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть по ссылке.

explain analyze --1090.40 / 50
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

unnest - 260

sub query scan 572

select 996 - 424

explain analyze --623.59 / 7
select concat(c.last_name, ' ', c.first_name), count(r.rental_id)
from rental r
right join inventory i on r.inventory_id = i.inventory_id and 
	i.film_id in (
		select film_id
		from film 
		where special_features && array['Behind the Scenes'])
join customer c on c.customer_id = r.customer_id
group by c.customer_id

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
Ожидаемый результат запроса: letsdocode.ru...in/6-5.png

select *
from (
	select *, row_number() over (partition by staff_id order by payment_date)
	from payment) t 
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
Ожидаемый результат запроса: letsdocode.ru...in/6-6.png



/*select *
from payment p 
join rental r on p.rental_id = r.rental_id*/

with men_arr_date as (
	with cte_arr_date as (
		with cte_date as (
		select rental_id, inventory_id, customer_id, staff_id, rental_date::date
		from (
			select *, row_number () over (partition by rental_date order by rental_date)
			from rental r) foo)
		select *, array_agg(rental_date) over (partition by rental_date) as array_date
		from cte_date)
	select *, array_length(array_date, 1) as men_arr
	from cte_arr_date)
select st.store_id, men_arr_date.rental_date 
	from (select *, dense_rank () over (order by men_arr desc)
	from men_arr_date) men_arr_date
join staff st on men_arr_date.staff_id = st.staff_id
join store s on s.store_id = st.store_id
where dense_rank = 1

select *
from (
	select i.store_id, r.rental_date::date, count(*),
		row_number() over (partition by i.store_id order by count(*) desc)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id
	group by i.store_id, r.rental_date::date) r 
join (
	select s.store_id, p.payment_date::date, sum(p.amount),
		row_number() over (partition by s.store_id order by sum(p.amount))
	from payment p
	join staff s on p.staff_id = s.staff_id
	group by s.store_id, p.payment_date::date) p on p.store_id = r.store_id
where p.row_number = 1 and r.row_number = 1

select *
from (
	select i.store_id, r.rental_date::date, count(*),
		row_number() over (partition by i.store_id order by count(*) desc)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id
	group by i.store_id, r.rental_date::date) r 
join (
	select i.store_id, p.payment_date::date, sum(p.amount),
		row_number() over (partition by i.store_id order by sum(p.amount))
	from payment p
	join rental r on r.rental_id = p.rental_id
	join inventory i on r.inventory_id = i.inventory_id
	group by i.store_id, p.payment_date::date) p on p.store_id = r.store_id
where p.row_number = 1 and r.row_number = 1

платеж		аренда
диск		диск 
сотрудник	сотрудник
диск		сотрудник
сотрудник	диск
пользовательпользователь
пользовательдиск
пользовательсотрудник
диск		пользователь
сотрудник	пользователь