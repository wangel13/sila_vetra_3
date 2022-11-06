-- final_rating

truncate final_rating;
WITH grouped_rating as (
    select year, tnved, sum(score) as score from rating group by year, tnved
                       )
insert
into final_rating
(
    year,
    tnved,
    tnved_title,
    import_amount_usd,
    export_amount_usd,
    score
)
SELECT
    rt.year as year,
    rt.tnved as tnved,
    tn.title as tnved_title,
    rt.import_amount_usd::bigint as import_amount_usd,
    rt.export_amount_usd::bigint as export_amount_usd,
    gr.score as score
from
    per_year_ratio_declarations as rt
    join tnved tn on rt.tnved = tn.tnved
    join grouped_rating as gr on gr.tnved = rt.tnved and gr.year = rt.year;