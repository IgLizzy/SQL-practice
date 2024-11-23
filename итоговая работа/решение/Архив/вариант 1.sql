--1. Выведите названия самолётов, которые имеют менее 50 посадочных мест.

select a.model 
from aircrafts a
join seats s using(aircraft_code)
GROUP by a.aircraft_code
having count(s.seat_no) < 50

--2.Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых

select *, sum_t_a - lag(sum_t_a) over (order by sum_t_a)
from (
	select
	date_trunc('month', b.book_date) as dt_m,
	b.total_amount,
	sum(b.total_amount) over (order by date_trunc('month', b.book_date)) as sum_t_a
	from bookings b ) r1 --практика 5 
	
--3.Выведите названия самолётов без бизнес-класса. Используйте в решении функцию array_agg.

select *
from aircrafts a
join seats s using(aircraft_code)

SELECT s2.aircraft_code, f_conditions
FROM (
	 SELECT s.aircraft_code, array_agg (s.fare_conditions) as f_conditions
	 FROM seats s
	 GROUP BY s.aircraft_code, s.fare_conditions
	 ORDER BY s.aircraft_code, s.fare_conditions
	 ) s2
--where 'Economy' = all(s2.f_conditions)
GROUP BY s2.aircraft_code, s2.f_conditions
ORDER BY s2.aircraft_code --практика 5

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

select *
from tickets t 