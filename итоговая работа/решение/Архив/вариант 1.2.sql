--1. Выведите названия самолётов, которые имеют менее 50 посадочных мест.

select a.model 
from aircrafts a
join seats s using(aircraft_code)
GROUP by a.aircraft_code
having count(s.seat_no) < 50

--2.Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых

select extract (month from dt_m) as "месяц", round(((sum_t_a - lag(sum_t_a) over (order by dt_m)) / lag(sum_t_a) over () * 100),2) as "%-е изменение"
from (
	select date_trunc('month', b.book_date) as dt_m,
	sum(b.total_amount) as sum_t_a
	from bookings b	
	group by 1) s1

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

select *
from flights f 
--join ticket_flights tf using(flight_id)
--where f.status  = 'Arrived'
 

select *
from flights f 
join ticket_flights tf using(flight_id)
join boarding_passes bp on tf.ticket_no = bp.ticket_no and f.flight_id = bp.flight_id 

--5.Найдите процентное соотношение перелётов по маршрутам от общего количества перелётов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Используйте в решении оконную функцию.

select * 
from flights f, airports a 
where f.departure_airport = a.airport_code
GROUP by f.flight_id, a.airport_code


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

select a.airport_name, f.departure_airport, f.arrival_airport, count(f.departure_airport) as route_count, 
(f.departure_airport ||'->'|| f.arrival_airport) as route,
round((count(f.departure_airport) / sum(count(f.departure_airport)) over () * 100), 2) as "% от всех перелетов"
from flights f
left JOIN airports a ON f.departure_airport = a.airport_code
group by route, f.departure_airport, f.arrival_airport, a.airport_name
order by route_count desc --рабочий вариант, но без азвания аэропортов.надо понять как джойнить по двум внешним ключам.см практику 5
