with source as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        order_id,
        try_to_number(order_item_id, 10, 0)::integer as order_item_id,
        product_id,
        seller_id,
        try_to_timestamp_ntz(shipping_limit_date, 'YYYY-MM-DD HH24:MI:SS') as shipping_limit_at,
        try_to_number(price, 12, 2) as price,
        try_to_number(freight_value, 12, 2) as freight_value
    from source

)

select * from renamed
