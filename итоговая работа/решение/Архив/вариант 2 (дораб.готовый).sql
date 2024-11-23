--1. Выведите названия самолётов, которые имеют менее 50 посадочных мест.

select a.model 
from aircrafts a
join seats s using(aircraft_code)
GROUP by a.aircraft_code
having count(s.seat_no) < 50

--2.Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых

select date_trunc('month', b.book_date) as dt_m,
sum(b.total_amount) as sum_t_a,
round(((sum(b.total_amount) - lag(sum(b.total_amount)) over (order by date_trunc('month', b.book_date))) / lag(sum(b.total_amount)) over (order by date_trunc('month', b.book_date)) * 100),2) as "%-е изменение"
from bookings b	
group by 1
	
--3.Выведите названия самолётов без бизнес-класса. Используйте в решении функцию array_agg.

select model
from 
	(select s2.aircraft_code,
	array_agg (s2.fare_conditions) as f_conditions
	from (
		select s.aircraft_code, s.fare_conditions
		from seats s
		GROUP by s.aircraft_code, s.fare_conditions ) s2
	GROUP by s2.aircraft_code) s3
join aircrafts a on a.aircraft_code = s3.aircraft_code
where 'Business' != all(s3.f_conditions)
		
--4.Выведите накопительный итог количества мест в самолётах по каждому аэропорту на каждый день. 
--Учтите только те самолеты, которые летали пустыми и только те дни, когда из одного аэропорта вылетело более одного такого самолёта.
--Выведите в результат код аэропорта, дату вылета, количество пустых мест и накопительный итог.

select n1.день, n1.departure_airport, sum(n1.sum_1) as "количество пустых мест", sum_2 as "накопительный итог"
from
	(select f.actual_departure::date as "день", f.departure_airport, s1.total_seats,
		count(f.departure_airport) over (partition by f.actual_departure::date) as count_da,
		sum(s1.total_seats) as sum_1,
		sum(sum(s1.total_seats)) over (partition by f.departure_airport order by f.actual_departure::date) as sum_2
		from flights f
		join (
			select s.aircraft_code, count(*) as total_seats
			from seats s 
			group by s.aircraft_code) s1 on f.aircraft_code = s1.aircraft_code
		left join(
			select tf.flight_id, count(b.book_ref) as total_bookings
			from bookings b
			join tickets t using(book_ref)
			join ticket_flights tf on tf.ticket_no = t.ticket_no 
			GROUP by tf.flight_id) as t_b on f.flight_id = t_b.flight_id
		where f.actual_departure::date is not null
		and t_b.total_bookings is null
		and f.departure_airport = 'AER'
		group by f.actual_departure::date, f.departure_airport, s1.total_seats) n1
where n1.count_da > 1
group by n1.день, n1.departure_airport, n1.sum_2

--5.Найдите процентное соотношение перелётов по маршрутам от общего количества перелётов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Используйте в решении оконную функцию.

--v1
select (w1.airport_name ||' -> '|| a.airport_name) as "машрут", 
round((route_count / sum(route_count) over () * 100), 2) as "% от всех перелетов"
from 
	(select a.airport_name, f.departure_airport, f.arrival_airport, count(f.departure_airport) as route_count, 
	(f.departure_airport ||'->'|| f.arrival_airport) as route
	from flights f, airports a
	where f.departure_airport = a.airport_code
	group by route, f.departure_airport, f.arrival_airport, a.airport_name
	order by route_count desc) w1
left JOIN airports a ON w1.arrival_airport = a.airport_code
GROUP by w1.route_count, w1.route, w1.airport_name, a.airport_code --готовый вариант, только громоздкий

--v2
select (e1.airport_name ||' -> '|| a.airport_name) as "машрут", e1."% от всех перелетов"
from 
	(select a.airport_name, f.departure_airport, f.arrival_airport,
	round((count(f.flight_id) / sum(count(f.flight_id)) over () * 100), 2) as "% от всех перелетов"
	from flights f
	left JOIN airports a ON f.departure_airport = a.airport_code
	group by f.departure_airport, f.arrival_airport, a.airport_name) e1
left JOIN airports a ON e1.arrival_airport = a.airport_code --так и не понял как сделать двойной join без подзапроса

--6.Выведите количество пассажиров по каждому коду сотового оператора. 
--Код оператора – это три символа после +7

select substring((t.contact_data ->> 'phone') from 3 for 3) as phone_str, count(substring((t.contact_data ->> 'phone') from 3 for 3)) as sum_pass
from tickets t
group by phone_str
order by phone_str

--7.Классифицируйте финансовые обороты (сумму стоимости билетов) по маршрутам:
--●	до 50 млн – low
--●	от 50 млн включительно до 150 млн – middle
--●	от 150 млн включительно – high
--Выведите в результат количество маршрутов в каждом полученном классе

with cte1 as (
	select f.departure_airport, f.arrival_airport,
	sum(tf.amount) 
	from flights f, ticket_flights tf
	where f.flight_id = tf.flight_id
	group by f.departure_airport, f.arrival_airport)
select x1.case, count(x1.case)
from 
	(select *,
		case --не соответствует условию задачи
			when sum < 50000000 then 'low'
			when sum between 50000000 and 149000000 then 'middle'
			else 'high'
		end
	from cte1) x1
GROUP by x1.case

--8.Вычислите медиану стоимости билетов, медиану стоимости бронирования 
--и отношение медианы бронирования к медиане стоимости билетов, 
--результат округлите до сотых. 

with cte2 as (
	SELECT percentile_Disc(0.5)
	WITHIN GROUP (ORDER BY tf.amount) as ticket_p_d 
	FROM ticket_flights tf),
cte3 as (
	SELECT percentile_Disc(0.5)
	WITHIN GROUP (ORDER BY b.total_amount)  as bookings_p_d
	FROM bookings b)
select cte2 as "медиана стоимости билетов", 
cte3 as "медиана стоимости бронирования", 
round((bookings_p_d / ticket_p_d), 2) as "отношение"
from cte2, cte3
	

--9.Найдите значение минимальной стоимости одного километра полёта для пассажира. 
--Для этого определите расстояние между аэропортами и учтите стоимость билетов.
--Для поиска расстояния между двумя точками на поверхности Земли используйте дополнительный модуль earthdistance. 
--Для работы данного модуля нужно установить ещё один модуль – cube.
--Важно: 
--●	Установка дополнительных модулей происходит через оператор CREATE EXTENSION название_модуля.
--●	В облачной базе данных модули уже установлены.
--●	Функция earth_distance возвращает результат в метрах.

CREATE extension cube

CREATE extension earthdistance

--без учета класса для каждого полета, тк одинаковых полетов много, посчитал для каждого маршрута
select v1.flight_id, min(v1.c_am)
from (
	select e1.flight_id, e1.ssum,
	e1.ssum / (earth_distance(ll_to_earth(a.latitude, a.longitude), ll_to_earth(latitude_2, longitude_2)) / 1000) as c_am
	from(
		select *, a.longitude as longitude_2, a.latitude as latitude_2
		from flights f
		join (select tf.flight_id, sum(amount) as ssum
			from ticket_flights tf
			group by tf.flight_id) j1 using(flight_id)
		join airports a on a.airport_code = f.departure_airport) e1
	join airports a on a.airport_code = e1.arrival_airport) v1
group by v1.flight_id

--с учетом класса для каждого полета, тк одинаковых полетов много, посчитал для каждого маршрута
select v1.flight_id, v1.fare_conditions, min(v1.c_am)
from (
	select e1.flight_id, e1.amount, e1.fare_conditions,
	e1.amount / (earth_distance(ll_to_earth(a.latitude, a.longitude), ll_to_earth(latitude_2, longitude_2)) / 1000) as c_am
	from(
		select *, a.longitude as longitude_2, a.latitude as latitude_2
		from flights f
		join (select tf.flight_id, tf.amount, tf.fare_conditions
			from ticket_flights tf
			group by tf.flight_id, tf.amount, tf.fare_conditions) j1 using(flight_id)
		join airports a on a.airport_code = f.departure_airport) e1
	join airports a on a.airport_code = e1.arrival_airport) v1
group by v1.flight_id, v1.fare_conditions

--с учетом класса для каждого маршрута
select m1.departure_airport, m1.arrival_airport, m1.fare_conditions, min(c_am)
from
	(select r1.departure_airport, r1.arrival_airport, r1.fare_conditions,
	r1.amount / (earth_distance(ll_to_earth(latitude_1, longitude_1), ll_to_earth(a.latitude, a.longitude)) / 1000) as c_am
	from
		(select f.departure_airport, f.arrival_airport, j1.fare_conditions, j1.amount,
		a.longitude as longitude_1, a.latitude as latitude_1
		from flights f
		join (select tf.flight_id, tf.amount, tf.fare_conditions
				from ticket_flights tf
				group by tf.flight_id, tf.amount, tf.fare_conditions) j1 using(flight_id)
		join airports a on a.airport_code = f.departure_airport
		group by f.departure_airport, f.arrival_airport, j1.amount, j1.fare_conditions, longitude_1, latitude_1) r1
	join airports a on a.airport_code = r1.arrival_airport) m1
group by m1.departure_airport, m1.arrival_airport, m1.fare_conditions

--без учета класса для каждого маршрута
select m1.departure_airport, m1.arrival_airport,  min(c_am)
from
	(select r1.departure_airport, r1.arrival_airport,
	r1.summ / (earth_distance(ll_to_earth(latitude_1, longitude_1), ll_to_earth(a.latitude, a.longitude)) / 1000) as c_am
	from
		(select f.departure_airport, f.arrival_airport, j1.summ,
		a.longitude as longitude_1, a.latitude as latitude_1
		from flights f
		join (select tf.flight_id, sum(tf.amount) as summ
				from ticket_flights tf
				group by tf.flight_id) j1 using(flight_id)
		join airports a on a.airport_code = f.departure_airport
		group by f.departure_airport, f.arrival_airport, longitude_1, latitude_1, summ) r1
	join airports a on a.airport_code = r1.arrival_airport) m1
group by m1.departure_airport, m1.arrival_airport

