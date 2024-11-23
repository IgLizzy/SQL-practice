--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select concat_ws(' ', c.last_name, c.first_name ) as "Customer name" , a.address, c2.city, c3.country  from customer c
join address a on c.address_id = a.address_id
join city c2 on a.city_id  = c2.city_id 
join country c3 on c2.country_id = c3.country_id 

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select c.store_id, count(s.store_id) as "Количество покупателей", c2.city, concat_ws(' ', s.last_name, s.first_name ) as "Имя сотрудника"  from customer c  
join staff s  on c.store_id = s.store_id
join store s2 on s2.store_id = s.store_id
join address a on s2.address_id = a.address_id 
join  city c2 on a.city_id = c2.city_id 
group by c.store_id, s.last_name, s.first_name, c2.city
having count(s.store_id) > 300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat_ws(' ', c.last_name, c.first_name ) as "Фамилия и имя покупателя", count(r.rental_id) as "Количество фильмов" from rental r 
join customer c on r.customer_id = c.customer_id 
group by c.customer_id
order by count(r.rental_id) desc 
limit 5

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select concat_ws(' ', c.last_name, c.first_name ) as "Фамилия и имя покупателя", round(sum(p.amount), 0) as "Общая стоимость платежей", 
count(r.rental_id) as "Количество фильмов", min(p.amount), max(p.amount)
from rental r
join payment p using(rental_id,  customer_id)
join customer c using(customer_id)
group by c.customer_id --группирую по первичному ключу и вроде правильные данные получаются, но не как в примере правильного запроса

select concat_ws(' ', c.last_name, c.first_name ) as "Фамилия и имя покупателя", round(sum(p.amount), 0) as "Общая стоимость платежей", 
count(p.customer_id) as "Количество фильмов", min(p.amount), max(p.amount)
from rental r
join payment p on p.rental_id  = r.rental_id
join customer c on p.customer_id = c.customer_id
group by c.last_name, c.first_name

--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
select c.city as "Город 1", c2.city as "Город 2"  from city c 
cross join city c2
where c.city != c2.city

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
select r.customer_id ,round(avg(r.return_date::date  - r.rental_date::date),2) from rental r  
group by r.customer_id 
order by r.customer_id

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select f.title , f.rating , c."name"  , f.release_year , l."name", count(r.inventory_id) , sum(p.amount)  from film f 
join "language" l on f.language_id = l.language_id 
join film_category fc on f.film_id = fc.film_id 
join category c on fc.category_id = c.category_id 
join inventory i  on i.film_id  = f.film_id 
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id 
group by f.film_id , c.category_id  , l.language_id 
order by f.title


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.

