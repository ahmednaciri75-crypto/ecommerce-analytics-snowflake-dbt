-- Une commande peut avoir plusieurs avis : on garde le plus récent (grain = order_id).
with reviews as (

    select * from {{ ref('stg_olist__order_reviews') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by order_id
            order by
                review_answered_at desc nulls last,
                review_created_at desc nulls last,
                review_id desc
        ) as review_rank
    from reviews

),

deduped as (

    select
        order_id,
        review_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_created_at,
        review_answered_at
    from ranked
    where review_rank = 1

)

select * from deduped
