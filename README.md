# E-commerce Analytics : Snowflake + dbt

Pipeline d'analytics engineering de bout en bout sur le dataset e-commerce brésilien Olist
(~100 000 commandes, 2016-2018) : ingestion, transformation, tests de qualité et schéma en étoile.

## Architecture

```
CSV Olist  →  Stage Snowflake  →  RAW.OLIST (9 tables, texte)
                                      │  dbt
                                      ▼
              STAGING (vues) → INTERMEDIATE (vues) → MARTS (tables)
                                                       │
                                                       ▼
                                            BI (Power BI / Streamlit)
```

## Stack

- **Snowflake** : entrepôt de données, rôles séparés (`TRANSFORMER` pour dbt, `REPORTER` en lecture seule), plafond de crédits
- **dbt Core** : transformations SQL, tests, documentation
- **Python** : script d'ingestion (`PUT` vers stage, puis `COPY INTO`)
- **Git / GitHub** : versioning

## Modélisation

- **Staging** : un modèle par table source, typage explicite (`try_to_number`, `try_to_timestamp_ntz`), aucune jointure
- **Intermediate** : dédoublonnage des avis, agrégation des paiements et des articles, géolocalisation à une ligne par code postal
- **Marts** : schéma en étoile
  - Faits : `fct_orders` (1 ligne par commande), `fct_order_items` (1 ligne par article)
  - Dimensions : `dim_customers`, `dim_products`, `dim_sellers`, `dim_date`

## Qualité des données

106 objets dbt construits en production : **104 tests passent, 2 avertissements assumés, 0 erreur**.

| Problème détecté | Traitement |
|---|---|
| 789 `review_id` dupliqués (avis rattachés à plusieurs commandes) | Un seul avis par commande dans `int_order_reviews_deduped` |
| 13 catégories de produits sans traduction anglaise | `coalesce(anglais, portugais, 'unknown')` |
| ~280 000 lignes de géolocalisation en doublon | Moyenne des coordonnées par code postal |
| 278 codes postaux clients absents de la géolocalisation | `left join` : le client est conservé |

## Choix techniques

- Données brutes chargées en texte : le typage est versionné et testé dans dbt
- Macro `generate_schema_name` : sandbox personnel en dev, schémas propres en prod
- Les deux faits ont des grains différents : ne jamais sommer leurs montants ensemble
- Limite connue : `customer_id` change à chaque commande, `customer_unique_id` identifie la personne

## Lancer le projet

```bash
conda activate dbt
dbt deps
dbt build              # développement
dbt build --target prod
```

Les scripts d'infrastructure Snowflake se trouvent dans `snowflake/` et le chargement dans `scripts/load_olist.py`.