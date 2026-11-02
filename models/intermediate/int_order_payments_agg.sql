-- Paiements agrégés au grain commande (order_id).
with payments as (

    select * from {{ ref('stg_olist__order_payments') }}

),

main_type as (

    -- Type principal = celui du paiement au montant le plus élevé (égalité : le premier).
    select
        order_id,
        payment_type as main_payment_type
    from payments
    qualify row_number() over (
        partition by order_id
        order by payment_value desc, payment_sequential asc
    ) = 1

),

totals as (

    select
        order_id,
        sum(payment_value) as payment_amount,
        count(*) as payments_count,
        max(payment_installments) as max_installments
    from payments
    group by order_id

),

joined as (

    select
        totals.order_id,
        totals.payment_amount,
        totals.payments_count,
        totals.max_installments,
        main_type.main_payment_type
    from totals
    inner join main_type on totals.order_id = main_type.order_id

)

select * from joined
