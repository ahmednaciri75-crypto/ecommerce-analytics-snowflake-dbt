with source as (

    select * from {{ source('olist', 'geolocation') }}

),

renamed as (

    select
        geolocation_zip_code_prefix as zip_code_prefix,
        try_to_number(geolocation_lat, 18, 15) as latitude,
        try_to_number(geolocation_lng, 18, 15) as longitude,
        lower(trim(geolocation_city)) as city,
        upper(trim(geolocation_state)) as state
    from source

)

select * from renamed
