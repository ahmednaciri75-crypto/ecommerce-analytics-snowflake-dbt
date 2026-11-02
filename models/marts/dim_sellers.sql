with sellers as (

    select * from {{ ref('stg_olist__sellers') }}

),

geolocation as (

    select * from {{ ref('int_geolocation_by_zip') }}

),

final as (

    select
        sellers.seller_id,
        sellers.zip_code_prefix,
        sellers.city,
        sellers.state,
        geolocation.latitude,
        geolocation.longitude
    from sellers
    left join geolocation
        on sellers.zip_code_prefix = geolocation.zip_code_prefix

)

select * from final
