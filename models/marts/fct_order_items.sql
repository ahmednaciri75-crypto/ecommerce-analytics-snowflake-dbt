-- Grain = 1 ligne par article (order_id, order_item_id).
with items as (

    select * from {{ ref('stg_olist__order_items') }}

),

orders as (

    select * from {{ ref('stg_olist__orders') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['items.order_id', 'items.order_item_id']) }} as order_item_key,
        items.order_id,
        items.order_item_id,
        items.product_id,
        items.seller_id,
        orders.customer_id,
        cast(orders.purchased_at as date) as purchase_date,
        orders.order_status,
        items.shipping_limit_at,
        items.price,
        items.freight_value,
        items.price + items.freight_value as total_item_amount
    from items
    inner join orders on items.order_id = orders.order_id

)

select * from final
