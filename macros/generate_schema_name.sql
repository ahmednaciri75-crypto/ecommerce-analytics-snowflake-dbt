{#
    En dev : tout est écrit dans le schéma du profil (DBT_AHMED), ce qui évite
    de polluer les schémas partagés et garde un sandbox par développeur.
    Ailleurs (prod) : on utilise le nom exact du schéma personnalisé
    (STAGING, INTERMEDIATE, MARTS) au lieu du défaut dbt <schéma_profil>_<custom>.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'dev' or custom_schema_name is none -%}
        {{ target.schema | trim }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
