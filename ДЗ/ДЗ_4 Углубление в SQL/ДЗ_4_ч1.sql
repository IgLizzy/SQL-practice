create schema lecture_4

set search_path to lecture_4
	
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table language (
	language_id serial2 primary key,
	language_name varchar (30) not null unique,
	created_at timestamp not null default current_timestamp)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
insert into language(language_name)
values ('Русский'), ('Французский'), ('Японский'), ('Английский'),  ('Немецкий')

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table nationality (
	nationality_id serial2 primary key,
	nationality_name varchar (30) not null unique,
	created_at timestamp not null default current_timestamp)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
insert into nationality(nationality_name)
values ('славяне'), ('романцы'), ('ямато'), ('кельты'),  ('германцы')

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country (
	country_id serial2 primary key,
	country_name varchar (50) not null unique,
	created_at timestamp not null default current_timestamp)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
insert into country(country_name)
values ('Россия'), ('Франция'), ('Япония'), ('Англия'),  ('Германия')

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationality_language (
	language_id int not null unique references language(language_id),
	nationality_id int2 not null references nationality(nationality_id),
	primary key(language_id, nationality_id))

select * from public.film_category fc 

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into nationality_language(language_id, nationality_id)
values (1, 1),(2, 2), (3, 3), (4, 4), (5, 5)

select * from nationality_language nl 

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationality_country (
	country_id int2 not null unique references country(country_id),
	nationality_id int2 not null unique references nationality(nationality_id),
	primary key(nationality_id, country_id))


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into nationality_country(nationality_id, country_id)
values (1, 1),(2, 2), (3, 3), (4, 4), (5, 5)


select * from nationality_country 