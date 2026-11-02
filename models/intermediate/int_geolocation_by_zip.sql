-- Une ligne par préfixe de code postal : évite de démultiplier les lignes à la jointure.
with geolocation as (

    select * from {{ ref('stg_olist__geolocation') }}

),

by_zip as (

    select
        zip_code_prefix,
        avg(latitude) as latitude,
        avg(longitude) as longitude
    from geolocation
    group by zip_code_prefix

)

select * from by_zip
