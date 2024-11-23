
======================== Создание таблиц ========================

https://dbdiagram.io/, https://sqldbm.com, https://pgmodeler.io

create database название_базы_данных

create schema lecture_4

set search_path to lecture_4

1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(100) not null,
	nick_name varchar(25),
	born_date date not null check (date_part('year', born_date) >= 1700 and born_date < current_date),
	city_id int2 not null references city (city_id),
	--language_id int2 not null references language (language_id),
	created_at timestamp not null default current_timestamp,
	created_user varchar(64) not null default current_user,
	deleted boolean not null default false)

author_name varchar(255)

имя 20 
отчество 25
фамилия 30

факт 50		100		255
			50		127

50 000 000
127 000 000

serial = integer + sequence + nextval(sequence)

cust_id
1	Москва
2	Москва
3 	Москва

city
Москва
Питера
Саратов

Москва + Питер + Саратов

Москва + Саратов

Москва

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table city (
	city_id serial2 primary key,
	city_name varchar (30) not null,
	country_id int2 not null references country(country_id))

create table language (
	language_id serial2 primary key,
	language_name varchar (30) not null unique)
	
create table country (
	country_id serial2 primary key,
	country_name varchar (50) not null unique)

id varchar(24)	6/12


unique_id
table_name	id

?id=dkljgbndjkbgfzbcx;kfvjb&user=......

uuid

select gen_random_uuid()

'0d22b602-8b45-4039-ab71-f8a9a63c5af7'

create table ... (
	id uuid default gen_random_uuid() primary key,
)

create extension "uuid-ossp"

select uuid_generate_v1()


== Отношения / связи ==
А		Б
один к одному  		Б является атрибутом А
один ко многим		А и Б два отдельных справочника
многие ко многим	в реляционной модели не существует, реализуется через два отношения один 
					ко многим А-В и В-Б
			
--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int not null unique,
	language_id int2 not null unique)
	
1	2
2	3
3	1

--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int not null,
	language_id int2 not null unique)
	
1	1
1	2
1	4
2	3

--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int not null unique,
	language_id int2 not null)
	
1	1
2	1
3	2
4	2

--ТАК ДЕЛАТЬ НУЖНО
create table author_language (
	author_id int not null references author(author_id),
	language_id int2 not null language(language_id),
	primary key(author_id, language_id))
	
1	1
1	2
2	1
2	2

comment on column author.author_name is 'имя автора'

======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into language (language_name)
values ('Русский'), ('Французский'), ('Японский')

select * from language

insert into language 
values (4, 'Монгольский')

SQL Error [22P02]: ОШИБКА: неверный синтаксис для типа smallint: "Монгольский"

insert into language (language_name)
values ('Канадский')

SQL Error [23505]: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "language_pkey"
  Подробности: Ключ "(language_id)=(4)" уже существует.
  
-- демонстрация работы счетчика и сброс счетчика
    
alter sequence language_language_id_seq restart with 1450

insert into language (language_name)
values ('Финский')

drop table "language"

create table language (
	language_id int2 primary key generated always as identity,
	language_name varchar (30) not null unique)
	
insert into language (language_name)
values ('Русский'), ('Французский'), ('Японский')

select * from language

insert into language 
OVERRIDING SYSTEM VALUE
values (4, 'Монгольский')

SQL Error [22P02]: ОШИБКА: неверный синтаксис для типа smallint: "Монгольский"

insert into language (language_name)
values ('Канадский')

--Работает начиная с 13 версии PostgreSQL - stored

create table strange (
	id int primary key generated always as identity,
	cust_id int,
	product_id int,
	amount_per_one numeric,
	qty numeric,
	total_amount_with_tax numeric generated always as (round(amount_per_one * qty * 1.2, 2)) stored)
	
insert into strange (cust_id, product_id, amount_per_one, qty)
values (1, 1, 1000, 0.75), (2, 6, 5000, 3)

select *
from strange

2.1 Вставьте данные в таблицу со странами из таблиц country базы dvd-rental:

select *
from country c

select country_id, country
from public.country c

insert into country (country_id, country_name)
select country_id, country
from public.country c

alter sequence country_country_id_seq restart with 110


2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

select *
from city c

select city, country_id
from public.city c

insert into city (city_name, country_id)
select city, country_id
from public.city c

alter sequence city_city_id_seq restart with 601

2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

insert into author (author_name, nick_name, born_date, city_id)
values ('Жюль Верн', null, '08.02.1828', 543),
	('Михаил Лермонтов', 'Диарбекир', '03.10.1814', 34),
	('Харуки Мураками', null, '12.01.1949', 7)
	
SQL Error [23514]: ОШИБКА: новая строка в отношении "author" нарушает ограничение-проверку "author_born_date_check"
Подробности: Ошибочная строка содержит (2, Михаил Лермонтов, Диарбекир, 1614-10-03, 34, 2023-09-07 20:32:55.807337, postgres, f).

select * from author
where deleted is false

select * from author
where deleted --is false

======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;
 
-- добавление нового столбца
 
alter table author add column language_id int2

select * from author a

-- удаление столбца

alter table author drop column language_id 

-- добавление ограничения not null

alter table author alter column language_id set not null

-- удаление ограничения not null

alter table author alter column language_id drop not null

-- добавление ограничения unique

alter table author add constraint author_name_unique unique (author_name)

-- удаление ограничения unique

alter table author drop constraint author_name_unique

-- изменение типа данных столбца

alter table author alter column language_id type varchar (15)

alter table author alter column language_id type varchar (30)

alter table author alter column language_id type int

SQL Error [42804]: ОШИБКА: столбец "language_id" нельзя автоматически привести к типу integer
  Подсказка: Возможно, необходимо указать "USING language_id::integer".
  
alter table author alter column language_id type int using (language_id::int)

-- добавление ограничения внешнего ключа

alter table author add constraint language_id_pkey foreign key (language_id) references language(language_id)

alter table author drop constraint language_id_pkey

alter table author add constraint language_id_fkey foreign key (language_id) references language(language_id)

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский

внесении кортежа - insert 
внесении значения в существующий котеж - update 

select *
from author a

5	Харуки Мураками
3	Жюль Верн
4	Михаил Лермонтов

select * from "language" l

1	Русский
2	Французский
3	Японский

update author 
set language_id = 1
where author_id = 4

update author 
set language_id = 3

update author 
set language_id = 2, nick_name = 'отсутствует', city_id = 123
where author_id = 3

 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

delete from author
where author_id = 4

delete from author

5.1 Удалите все страны

delete from country

select * from author 

truncate "language" cascade 

delete - сканирование данных, создается новый снимок данных, когда БД будет удобно, тогда удалятся данные с hdd.

truncate - vacuum 

drop table "language" cascade

drop schema lecture_4 cascade

drop database 

low format

create table country (
	country_id serial2 primary key,
	country_name varchar (50) not null unique)

create table city (
	city_id serial2 primary key,
	city_name varchar (30) not null,
	country_id int2 references country(country_id) on delete set default on update set null default 2)
	
cascade 
restrict 
no action
set null 
set default
	
insert into country (country_id, country_name)
select country_id, country
from public.country 

insert into city (city_name, country_id)
select city, country_id
from public.city 

select * from city 

select * from country 

drop table country cascade

drop table city cascade

truncate country cascade

update country
set country_id = 5000
where country_id = 2

delete from country
where country_id = 1

drop cascade - удалится FK, данные сохранятся
truncate cascade - сохранит FK, удалит данные
delete cascade - сохранит FK, удалит данные
	
----------------------------------------------------------------------------------------

set search_path to public

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
group by cube (1,2,3)
order by 1,2,3

create temporary table temp_table as (
	select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
	from payment 
	group by cube (1,2,3)
	order by 1,2,3)
	
explain analyze

select * from payment

alter table temp_table drop column staff_id

create table payment_temp (like payment)

drop table payment_temp

create table payment_temp (like payment including all)

explain analyze --347.14 / 2.15
select distinct c.customer_id, c.email
from payment p 
join customer c on c.customer_id = p.customer_id
where amount > 10

explain analyze --430.63 / 6.4
select distinct c.customer_id, c.email
from payment p 
join customer c on c.customer_id = p.customer_id

create table payment_temp (like payment) partition by range (amount)

create table payment_low partition of payment_temp for values from (minvalue) to (5)

create table payment_mid partition of payment_temp for values from (5) to (10)

create table payment_hight partition of payment_temp for values from (10) to (maxvalue)

insert into payment_temp
select * from payment

explain analyze --23.94 / 0.17
select distinct c.customer_id, c.email
from payment_temp p 
join customer c on c.customer_id = p.customer_id
where amount > 10

explain analyze --510.88 / 7.2
select distinct c.customer_id, c.email
from payment_temp p 
join customer c on c.customer_id = p.customer_id

select * 
from only payment_temp pt

select * 
from payment_mid

select 347.14 / 23.94 --14.5

select 2.15 / 0.17 --13

1 000 000
2 000 000

explain analyze --19.48 / 0.26
select *
from customer 
where lower(left(last_name, 1)) in ('a', 'd')

create table customer_temp (like customer) partition by list (lower(left(last_name, 1)))

create table customer_a_k partition of customer_temp for values in ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k')

create table customer_l_q partition of customer_temp for values in ('l', 'm', 'n', 'o', 'p', 'q')

create table customer_r_z partition of customer_temp for values in ('r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')

select 'c' between 'a' and 'd'

insert into customer_temp
select * from customer

explain analyze --13.68 / 0.145
select *
from customer_temp 
where lower(left(last_name, 1)) in ('a', 'd')

select 0.26 / 0.145