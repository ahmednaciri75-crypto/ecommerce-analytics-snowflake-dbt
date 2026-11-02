-- Produits + catégorie anglaise. Repli : nom portugais, puis 'unknown'.
with products as (

    select * from {{ ref('stg_olist__products') }}

),

translation as (

    select * from {{ ref('stg_olist__product_category_name_translation') }}

),

enriched as (

    select
        products.product_id,
        coalesce(
            translation.product_category_name_english,
            products.product_category_name,
            'unknown'
        ) as category_name,
        products.product_category_name as category_name_pt,
        products.product_name_length,
        products.product_description_length,
        products.product_photos_qty,
        products.product_weight_g,
        products.product_length_cm,
        products.product_height_cm,
        products.product_width_cm
    from products
    left join translation
        on products.product_category_name = translation.product_category_name

)

select * from enriched
