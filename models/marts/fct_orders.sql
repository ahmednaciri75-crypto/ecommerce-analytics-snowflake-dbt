-- Grain = 1 ligne par commande.
with orders as (

    select * from {{ ref('stg_olist__orders') }}

),

items as (

    select * from {{ ref('int_order_items_agg') }}

),

payments as (

    select * from {{ ref('int_order_payments_agg') }}

),

reviews as (

    select * from {{ ref('int_order_reviews_deduped') }}

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_status,
        orders.purchased_at,
        cast(orders.purchased_at as date) as purchase_date,
        orders.approved_at,
        orders.delivered_to_carrier_at,
        orders.delivered_to_customer_at,
        cast(orders.delivered_to_customer_at as date) as delivered_date,
        orders.estimated_delivery_at,
        cast(orders.estimated_delivery_at as date) as estimated_delivery_date,

        -- Délais en jours (NULL tant que la commande n'est pas livrée)
        datediff('day', orders.purchased_at, orders.delivered_to_customer_at) as delivery_days_actual,
        datediff('day', orders.purchased_at, orders.estimated_delivery_at) as delivery_days_estimated,
        datediff('day', orders.estimated_delivery_at, orders.delivered_to_customer_at) as delivery_delay_days,
        orders.delivered_to_customer_at > orders.estimated_delivery_at as is_delivered_late,

        coalesce(items.items_count, 0) as items_count,
        coalesce(items.items_amount, 0) as items_amount,
        coalesce(items.freight_amount, 0) as freight_amount,
        coalesce(payments.payment_amount, 0) as payment_amount,
        coalesce(payments.payments_count, 0) as payments_count,
        payments.main_payment_type,
        reviews.review_score
    from orders
    left join items on orders.order_id = items.order_id
    left join payments on orders.order_id = payments.order_id
    left join reviews on orders.order_id = reviews.order_id

)

select * from final
