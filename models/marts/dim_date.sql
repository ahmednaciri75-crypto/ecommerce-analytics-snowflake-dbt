-- Calendrier généré (pas issu des données) : couvre toutes les dates du dataset, y compris les livraisons estimées.
with spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2019-01-01' as date)"
    ) }}

),

final as (

    select
        cast(date_day as date) as date_day,
        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        monthname(date_day) as month_name,
        date_trunc('month', date_day)::date as month_start_date,
        weekofyear(date_day) as week_of_year,
        dayofweekiso(date_day) as day_of_week,
        dayname(date_day) as day_name,
        dayofweekiso(date_day) in (6, 7) as is_weekend
    from spine

)

select * from final
