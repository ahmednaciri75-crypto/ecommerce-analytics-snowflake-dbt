with source as (

    select * from {{ source('olist', 'orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        lower(trim(order_status)) as order_status,
        try_to_timestamp_ntz(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') as purchased_at,
        try_to_timestamp_ntz(order_approved_at, 'YYYY-MM-DD HH24:MI:SS') as approved_at,
        try_to_timestamp_ntz(order_delivered_carrier_date, 'YYYY-MM-DD HH24:MI:SS') as delivered_to_carrier_at,
        try_to_timestamp_ntz(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') as delivered_to_customer_at,
        try_to_timestamp_ntz(order_estimated_delivery_date, 'YYYY-MM-DD HH24:MI:SS') as estimated_delivery_at
    from source

)

select * from renamed
