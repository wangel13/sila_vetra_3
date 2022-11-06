truncate rating;

-- Критерий: если имеем чистый импорт добавляем 2 балла;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'чистый_импорт_wdywwpjo' as criterion_name,
        '2' as score
    from
        per_year_ratio_declarations
    where
        export_amount_usd is null
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: если импорт больше экспорта то добавляем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'импорт_больше_экспорта_bgjkhtn0' as criterion_name,
        '1' as score
    from
        per_year_ratio_declarations
    where
        import_amount_usd > export_amount_usd
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: если экспорт больше импорта то отнимаем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'экспорта_больше_импорт_cj1aq72c' as criterion_name,
        '-1' as score
    from
        per_year_ratio_declarations
    where
        export_amount_usd > import_amount_usd
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Если разница между импортом и экспортом +- 10% тогда считаем их равными, и отнимаем 1 балл;
-- if(0.9 <= napr_import/napr_export <= 1.1):
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'импорт_и_экспорт_10_процентов_kpurd7xb' as criterion_name,
        '-1' as score
    from
        per_year_ratio_declarations
    where
        '0.9'::decimal <= import_amount_usd / export_amount_usd
        and (import_amount_usd / export_amount_usd)::decimal <= '1.1'::decimal
        and export_amount_usd notnull
        and export_amount_usd > 0
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Если импорт за прошлый год меньше чем за текущий то добавляем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'объем_импорта_вырос_с_прошлого_года_htatejbo' as criterion_name,
        '1' as score
    from
        import_year_to_year_declarations
    where
        before_amount_usd < amount_usd
        and before_amount_usd notnull
        and before_year notnull
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Если импорт за прошлый год больше чем за текущий то отнимаем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'объем_импорта_вырос_с_прошлого_года_htatejbo' as criterion_name,
        '-1' as score
    from
        import_year_to_year_declarations
    where
        before_amount_usd > amount_usd
        and before_amount_usd notnull
        and before_year notnull
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Если ТН ВЭД входит в перечень жизненно важных то добавляем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'перечень_жизненно_важных_lnaridko' as criterion_name,
        '1' as score
    from
        declarations
    where
        direction = 'им'
        and declarations.tnved in (
        select tnved_vital.tnved
        from tnved_vital
                                  )
    group by year, tnved
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Если импорт из не дружественной станы тогда добавляем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'импорт_из_не_дружественной_страны_ntevcild' as criterion_name,
        '1' as score
    from
        declarations
    where
        direction = 'им'
        and declarations.country_code in (
        select country_code from countries_friendliness where country_friendliness = false
                                         )
    group by tnved, year
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Если импорт из дружественной станы тогда отнимаем 1 балл;
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select
        tnved,
        year,
        'импорт_из_не_дружественной_страны_ntevcild' as criterion_name,
        '1' as score
    from
        declarations
    where
        direction = 'им'
        and declarations.country_code in (
        select country_code from countries_friendliness where country_friendliness = true
                                         )
    group by tnved, year
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: Добавляем корректировочные баллы
insert into rating
(
    tnved,
    year,
    criterion_name,
    score
) (
    select distinct
        l.tnved as tnved,
        r.year as year,
        'корректировочные_баллы_aktauwaw' as criterion_name,
        l.score as score
    from
        adjustment_scores as l
        inner join per_year_declarations r on l.tnved = r.tnved
  )
on conflict (tnved,year,criterion_name) do update set
    score = EXCLUDED.score;

-- Критерий: