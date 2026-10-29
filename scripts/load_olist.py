"""
Charge les 9 CSV Olist dans Snowflake (RAW.OLIST).
Etapes : PUT vers le stage -> création de la table -> COPY INTO.
Toutes les colonnes sont chargées en texte : le typage se fait dans dbt (staging).
"""
import glob
import os

import snowflake.connector

DATA_DIR = os.path.expanduser("~/Projects/olist_data")

conn = snowflake.connector.connect(
    account="OANMIUI-MN09277",
    user="NCRMED75",
    private_key_file=os.path.expanduser("~/.ssh/snowflake/rsa_key.p8"),
    role="SYSADMIN",
    warehouse="TRANSFORM_WH",
    database="RAW",
    schema="OLIST",
)
cur = conn.cursor()

for path in sorted(glob.glob(f"{DATA_DIR}/*.csv")):
    file_name = os.path.basename(path)
    table = (
        file_name.replace("olist_", "")
        .replace("_dataset", "")
        .replace(".csv", "")
        .upper()
    )
    print(f"-> {file_name}  =>  RAW.OLIST.{table}")

    # 1. Envoi du fichier dans le stage (compressé en .gz)
    cur.execute(f"PUT 'file://{path}' @OLIST_STAGE AUTO_COMPRESS=TRUE OVERWRITE=TRUE")

    # 2. Création de la table à partir des en-têtes du CSV (toutes colonnes en TEXT)
    cur.execute(f"""
        CREATE OR REPLACE TABLE {table} USING TEMPLATE (
            SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
                'COLUMN_NAME', UPPER(COLUMN_NAME),
                'TYPE', 'TEXT',
                'NULLABLE', TRUE
            )) WITHIN GROUP (ORDER BY ORDER_ID)
            FROM TABLE(INFER_SCHEMA(
                LOCATION => '@OLIST_STAGE/{file_name}.gz',
                FILE_FORMAT => 'CSV_FORMAT'
            ))
        )
    """)

    # 3. Chargement des données
    cur.execute(f"""
        COPY INTO {table}
        FROM @OLIST_STAGE/{file_name}.gz
        FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
        MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    """)

    rows = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"   OK : {rows:,} lignes")

cur.close()
conn.close()
print("\nChargement terminé.")