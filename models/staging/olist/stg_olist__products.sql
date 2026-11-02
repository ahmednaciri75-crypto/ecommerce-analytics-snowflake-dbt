with source as (

    select * from {{ source('olist', 'products') }}

),

renamed as (

    select
        product_id,
        nullif(trim(product_category_name), '') as product_category_name,
        try_to_number(product_name_lenght, 10, 0)::integer as product_name_length,
        try_to_number(product_description_lenght, 10, 0)::integer as product_description_length,
        try_to_number(product_photos_qty, 10, 0)::integer as product_photos_qty,
        try_to_number(product_weight_g, 10, 0)::integer as product_weight_g,
        try_to_number(product_length_cm, 10, 0)::integer as product_length_cm,
        try_to_number(product_height_cm, 10, 0)::integer as product_height_cm,
        try_to_number(product_width_cm, 10, 0)::integer as product_width_cm
    from source

)

select * from renamed
