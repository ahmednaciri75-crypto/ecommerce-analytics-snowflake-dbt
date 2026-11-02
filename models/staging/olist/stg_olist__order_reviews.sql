with source as (

    select * from {{ source('olist', 'order_reviews') }}

),

renamed as (

    select
        review_id,
        order_id,
        try_to_number(review_score, 1, 0)::integer as review_score,
        nullif(trim(review_comment_title), '') as review_comment_title,
        nullif(trim(review_comment_message), '') as review_comment_message,
        try_to_timestamp_ntz(review_creation_date, 'YYYY-MM-DD HH24:MI:SS') as review_created_at,
        try_to_timestamp_ntz(review_answer_timestamp, 'YYYY-MM-DD HH24:MI:SS') as review_answered_at
    from source

)

select * from renamed
