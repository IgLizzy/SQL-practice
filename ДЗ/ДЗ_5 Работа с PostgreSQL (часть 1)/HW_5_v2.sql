SET search_path TO public

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select customer_id, payment_id , payment_date, row_number() over (order by payment_date), row_number, dense_rank, sum
from (
	select *,
	row_number() over (partition by customer_id order by payment_date),
	dense_rank() over (partition by customer_id order by payment_date::date), --В задании 1.4 направление ранжирования не соответствует условию задания.
	sum(amount) over (partition by customer_id order by payment_date, amount asc) --В задании 1.3 ложное направление сортировки по второму критерию в рамках оконной функции
	from payment) t--нужно переделать
	
	
select customer_id, payment_id , payment_date, row_number() over (order by payment_date), row_number, sum, dense_rank
from (
	select *,
	row_number() over (partition by customer_id order by payment_date),
	dense_rank() over (partition by customer_id order by amount desc),
	sum(amount) over (partition by customer_id order by payment_date, amount)
	from payment) t
order by customer_id, dense_rank

--заданиe 1.4
select customer_id, payment_id, payment_date,  amount , 
dense_rank() over (partition by customer_id order by amount desc)
from payment

--заданиe 1.3
select customer_id, payment_id, payment_date,  amount , 
sum(amount) over (partition by customer_id order by payment_date::date, amount)
from payment

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.

select customer_id, payment_id, payment_date,  amount , COALESCE(lag(amount) over (partition by customer_id  order by payment_id), 0)
from payment --нужно переделать "В задании 2 для указания значения по умолчанию нужно использовать синтаксис функции lag, без использования лишних функций"
--В заданиях 2 и 3 Вы работаете не с конкретными предыдущими или следующими платежами, а с какими-то случайными, 
--так как отсутствует направление сортировки, которое задавало бы верную последовательность данных.

select customer_id, payment_id, payment_date,  amount , lag(amount, 1,0) over (partition by customer_id  order by payment_date desc)
from payment

select customer_id, payment_id, payment_date,  amount , lag(amount, 1,0) over (partition by customer_id  order by payment_date)
from payment

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select p.customer_id, p.payment_id, p.payment_date,  p.amount ,p.amount - lead(p.amount) over (partition by p.customer_id  order by p.payment_id)
from payment p --нужно переделать "В заданиях 2 и 3 Вы работаете не с конкретными предыдущими или следующими платежами, а с какими-то случайными, 
--так как отсутствует направление сортировки, которое задавало бы верную последовательность данных."

select p.customer_id, p.payment_id, p.payment_date,  p.amount ,p.amount - lead(p.amount) over (partition by p.customer_id  order by p.payment_date)
from payment p

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select customer_id, payment_id, payment_date, amount
from (
	select *, last_value(payment_id) over (partition by customer_id)
	from (
		select *
		from payment
		order by customer_id, payment_date) t1) t2
where payment_id = last_value

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

select *
from payment p  



--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
