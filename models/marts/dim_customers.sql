-- Grain = customer_id (identifiant par commande). customer_unique_id regroupe les achats d'une même personne.
with customers as (

    select * from {{ ref('stg_olist__customers') }}

),

geolocation as (

    select * from {{ ref('int_geolocation_by_zip') }}

),

final as (

    select
        customers.customer_id,
        customers.customer_unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        geolocation.latitude,
        geolocation.longitude
    from customers
    left join geolocation
        on customers.zip_code_prefix = geolocation.zip_code_prefix

)

select * from final
