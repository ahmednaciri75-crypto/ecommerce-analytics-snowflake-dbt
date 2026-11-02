with source as (

    select * from {{ source('olist', 'order_payments') }}

),

renamed as (

    select
        order_id,
        try_to_number(payment_sequential, 10, 0)::integer as payment_sequential,
        lower(trim(payment_type)) as payment_type,
        try_to_number(payment_installments, 10, 0)::integer as payment_installments,
        try_to_number(payment_value, 12, 2) as payment_value
    from source

)

select * from renamed
