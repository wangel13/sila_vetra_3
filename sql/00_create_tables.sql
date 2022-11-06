create table if not exists dataset (
    napr text not null,
    period text not null,
    nastranapr text not null,
    tnved text not null,
    edizm text not null,
    stoim text not null,
    netto text not null,
    kol text not null,
    region text not null,
    region_s text not null,
    primary key (tnved, napr, nastranapr, period, stoim)
);

comment on table dataset is 'Таблица в которой хранятся данные из CSV файлов в исходном формате';

drop table if exists declarations;
create table declarations (
    direction char(2) not null,
    month smallint not null,
    year smallint not null,
    country_code text not null,
    tnved text not null,
    measurement_units text not null,
    amount_usd DECIMAL not null,
    net_weight text not null,
    kol text not null,
    region text not null,
    region_s text not null,
    primary key (year, month, tnved, direction, country_code, amount_usd)
);

comment on table declarations is 'Таблица в которой хранятся типизированные данные из CSV приведенные к нужным тимам';

--

drop table if exists per_year_declarations;
create table per_year_declarations (
    direction char(2) not null,
    year smallint not null,
    tnved text not null,
    amount_usd DECIMAL not null,
    primary key (direction, year, tnved)
);

comment on table per_year_declarations is 'Содержит данные агрегированные за год для ТН ВЭД';

--

drop table if exists per_year_ratio_declarations;

create table per_year_ratio_declarations (
    year smallint not null,
    tnved text not null,
    import_amount_usd DECIMAL,
    export_amount_usd DECIMAL,
    primary key (year, tnved)
);

comment on table per_year_ratio_declarations is 'Содержит данные агрегированные за год для ТН ВЭД где в одну строку собра';


drop table if exists countries_friendliness;
create table countries_friendliness (
    country_code text not null,
    country_friendliness bool,

    primary key (country_code)
);

comment on table countries_friendliness is 'Таблица в которой хранятся соответствие кодов стран и дружелюбность их к россии';
comment on column countries_friendliness.country_code is 'Двух буквенный код страны';
comment on column countries_friendliness.country_friendliness is 'Дружественность отношений: true - дружественный, false - не дружественный, null - не определено';

drop table if exists rating;
create table rating (
    tnved text not null,
    year smallint not null,
    criterion_name text not null,
    score integer not null,

    primary key (tnved, year, criterion_name)
);

drop table if exists tnved_vital;
create table tnved_vital (
    tnved text not null,

    primary key (tnved)
);

comment on table tnved_vital is 'перечень товаров критического импорта';

--

drop table if exists import_year_to_year_declarations;
create table import_year_to_year_declarations (
    tnved text not null,
    year smallint not null,
    amount_usd DECIMAL not null,

    before_year smallint,
    before_amount_usd DECIMAL,

    primary key (year, tnved)
);

comment on table import_year_to_year_declarations is 'Содержит данные агрегированные данные за год и предыдущий год';

--

drop table if exists tnved;
create table tnved (
    tnved text not null,
    title text not null,

    primary key (tnved)
);

comment on table tnved is 'Содержит с названиями для кодов ТН ВЭД.';

--

drop table if exists countries;
CREATE TABLE countries (
    country_code text not null,
    country_name text not null,

    primary key (country_code)
);

COMMENT ON table countries IS 'Таблица в которой хранятся соответствие кодов стран и их названий на русском';
COMMENT ON COLUMN countries.country_code IS 'Двух буквенный код страны';
COMMENT ON COLUMN countries.country_name IS 'Название страны на русском';

--

drop table if exists adjustment_scores;
CREATE TABLE adjustment_scores (
    tnved text not null,
    score integer not null,

    primary key (tnved)
);

COMMENT ON table adjustment_scores IS 'Содержит список ТН ВЭД которому мы явно корректируем баллы';
COMMENT ON COLUMN adjustment_scores.tnved IS 'ТН ВЭД';
COMMENT ON COLUMN adjustment_scores.score IS 'Количество баллов';

--

drop table if exists final_rating;
create table final_rating (
    year smallint not null,
    tnved text not null,
    tnved_title text not null,
    import_amount_usd bigint,
    export_amount_usd bigint,
    score int not null,
    primary key (year, tnved)
);