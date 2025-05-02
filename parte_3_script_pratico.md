# Parte 3 – Script prático

## Desafio prático

Você deverá construir uma solução de ETL simples para dados geoespaciais públicos do CAR (Cadastro Ambiental Rural).

1. Crie um banco de dados armazene os dados do CAR disponíveis no arquivo enviado em anexo.

```sh
#!/bin/bash

DIR=$HOME/Downloads/
PGHOST=localhost
PGPORT=5432
PGDATABASE=teste
PGUSER=postgres
PGPASS=password

psql -U $PGUSER -h $PGHOST -p $PGPORT -d 'postgres' \
  -c "create database $PGDATABASE with owner $PGUSER;"

psql -U $PGUSER -h $PGHOST -p $PGPORT -d $PGDATABASE \
  -c "create extension if not exists postgis;"

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln area_imovel $DIR/area_imovel/*.shp \
  -nlt PROMOTE_TO_MULTI -lco precision=NO
```

2. Realize o download de uma versão mais atualizada dos dados, utilizando o WFS público disponibilizado pelo [SICAR](https://geoserver.car.gov.br/geoserver/sicar/ows?version=1.0.0&typeName=sicar%3Asicar_imoveis_ac)

```sh
#!/bin/bash

DIR=$HOME/Downloads/
PGHOST=localhost
PGPORT=5432
PGDATABASE=teste
PGUSER=postgres
PGPASS=password
BASIS_URL="https://geoserver.car.gov.br/geoserver/sicar/sicar_imoveis_ac/ows?service=WFS"
LAYER=sicar
LAYERNAME=sicar_imoveis_ac

ogr2ogr -skipfailures -f geojson $DIR/$LAYERNAME.json \
  --config GDAL_HTTP_UNSAFESSL YES WFS:$BASIS_URL "$LAYER":"$LAYERNAME"

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln $LAYERNAME \
  $DIR/"$LAYERNAME".json
```

3. Compare os dados baixados com os dados já existentes no banco, utilizando hash ou timestamp para identificar alterações.

Comparando dados pela data de atualizacao:

```sql
WITH ai AS (
    SELECT cod_imovel, to_date(dat_atuali::text, 'DD/MM/YYYY') AS data_atualizacao
    FROM area_imovel
    WHERE dat_atuali IS NOT NULL
    ORDER BY cod_imovel
), sia AS (
    SELECT cod_imovel, to_date(data_atualizacao::text, 'YYYY-MM-DD'::text) AS data_atualizacao
    FROM sicar_imoveis_ac
    WHERE data_atualizacao IS NOT NULL
    ORDER BY cod_imovel
)
SELECT ai.cod_imovel, ai.data_atualizacao AS old_date, sia.data_atualizacao AS new_date
FROM ai
    LEFT JOIN sia ON ai.cod_imovel = sia.cod_imovel
WHERE ai.data_atualizacao < sia.data_atualizacao;
```

Comparando dados pela geometria:

```sql
WITH ai AS (
    SELECT cod_imovel, wkb_geometry AS geom
    FROM area_imovel
    WHERE wkb_geometry IS NOT NULL
    ORDER BY cod_imovel
), sia AS (
    SELECT cod_imovel, wkb_geometry AS geom FROM sicar_imoveis_ac
    WHERE wkb_geometry IS NOT NULL
    ORDER BY cod_imovel
)
SELECT ai.cod_imovel, ai.geom AS old_geom, sia.geom AS new_geom
FROM ai
    LEFT JOIN sia ON ai.cod_imovel = sia.cod_imovel
WHERE NOT st_equals (ai.geom, sia.geom);
```

4. Atualize somente os registros alterados, preservando a integridade dos dados.

Atualizando dado conforme data de atualizacao:

```sql
BEGIN;
CREATE UNIQUE INDEX IF NOT EXISTS area_imovel_cod_imovel_idx ON area_imovel (cod_imovel);
CREATE UNIQUE INDEX IF NOT EXISTS sicar_imoveis_ac_cod_imovel_idx ON sicar_imoveis_ac (cod_imovel);
UPDATE area_imovel AS ai
SET (mod_fiscal, num_area, ind_status, ind_tipo, des_condic, municipio, cod_estado, dat_criaca, dat_atuali, wkb_geometry) = (
        SELECT sia.m_fiscal,
            sia.area,
            sia.status_imovel,
            sia.tipo_imovel,
            sia.condicao,
            sia.municipio,
            sia.uf,
            TO_CHAR(sia.dat_criacao, 'DD/MM/YYYY'::text),
            TO_CHAR(sia.data_atualizacao, 'DD/MM/YYYY'::text),
            sia.wkb_geometry
        FROM sicar_imoveis_ac sia
        WHERE ai.cod_imovel = sia.cod_imovel
            AND to_date(ai.dat_atuali::text, 'DD/MM/YYYY') < to_date(sia.data_atualizacao::text, 'YYYY-MM-DD'::text));
ROLLBACK; -- WARN: Substituir "ROLLBACK;" por "COMMIT;" para realizar a transacao;
```

Inserindo os novos dados:

```sql
BEGIN;
CREATE UNIQUE INDEX IF NOT EXISTS area_imovel_cod_imovel_idx ON area_imovel (cod_imovel);
CREATE UNIQUE INDEX IF NOT EXISTS sicar_imoveis_ac_cod_imovel_idx ON sicar_imoveis_ac (cod_imovel);
INSERT INTO area_imovel AS ai (cod_tema, nom_tema, cod_imovel, mod_fiscal, num_area, ind_status, ind_tipo, des_condic, municipio, cod_estado, dat_criaca, dat_atuali, wkb_geometry)
SELECT 'AREA_IMOVEL' AS cod_tema,
    'Area do Imovel' AS nom_tema,
    sia.cod_imovel,
    sia.m_fiscal,
    sia.area,
    sia.status_imovel,
    sia.tipo_imovel,
    sia.condicao,
    sia.municipio,
    sia.uf,
    TO_CHAR(sia.dat_criacao, 'DD/MM/YYYY'::text) AS dat_criacao,
    TO_CHAR(sia.data_atualizacao, 'DD/MM/YYYY'::text) AS data_atualizacao,
    sia.wkb_geometry
FROM sicar_imoveis_ac sia
WHERE sia.wkb_geometry IS NOT NULL
ON CONFLICT (cod_imovel) DO NOTHING;
ROLLBACK; -- WARN: Substituir "ROLLBACK;" por "COMMIT;" para realizar a transacao;
```
