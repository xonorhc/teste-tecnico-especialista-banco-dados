#!/bin/bash

DIR="$(dirname "$0")"
PGHOST=$1
PGPORT=5432
PGDATABASE=teste
PGUSER=$2
PGPASS=$3

# NOTE: CRIAR O BANCO DE DADOS COM SUPOSTA CONFIGURACAO:

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d 'postgres' \
  -c "create database $PGDATABASE with owner $PGUSER template template0 encoding 'WIN1252' locale 'pt-BR-x-icu' icu_locale 'pt-BR' locale_provider icu ;"

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE \
  -c "create extension if not exists postgis;"

# NOTE: IMPORTAR OS DADOS DO IBGE:

curl "https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2024/Brasil/BR_UF_2024.zip" \
  --output "$DIR"/data/uf.zip

unzip "$DIR"/data/uf.zip -d "$DIR"/data/uf/

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln unidades_federacao "$DIR"/data/uf/*.shp \
  -nlt PROMOTE_TO_MULTI -lco precision=NO

rm -rf "$DIR"/data/uf*

# NOTE: CRIAR AS TABELAS:

find "$DIR"/ddl -type f -name "*.sql" -print0 | sort -z | xargs -0 -I{} \
  psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE -b \
  -f "{}"

# NOTE: DOWNLOAD DOS DADOS DO INMET:

Y=2021

wget --no-check-certificate -O "$DIR"/data/$Y.zip \
  'https://portal.inmet.gov.br/uploads/dadoshistoricos/'$Y'.zip'

unzip "$DIR"/data/$Y.zip -d "$DIR"/data/$Y

# NOTE: IMPORTAR AS INFORMACOES DAS ESTACOES:

find "$DIR"/data/$Y/ -type f -name "*.CSV" -print0 | xargs -0 -I{} \
  awk -F ';' 'FNR <= 8 { printf "%s;", $2 } END { print "" }' '{}' \
  >"$DIR"/data/$Y/estacoes.csv

sed -i 's/,/\./g' "$DIR"/data/$Y/estacoes.csv

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE \
  -c "\copy estacoes from '$DIR/data/$Y/estacoes.csv' with delimiter ';' csv;"

# NOTE: IMPORTAR OS DADOS TEMPORAIS:

find "$DIR"/data/$Y/ -type f -name "*.CSV" -print0 | xargs -0 -I{} \
  awk -F ';' \
  '/CODIGO/{ CODIGO=$2; next } /UTC/{ print CODIGO ";" $1 ";" $2";" $3";" $4";" $5";" $6";" $7";" $8";" $9";" $10";" $11";" $12 ";" $13 ";" $14 ";" $15 ";" $16 ";" $17 ";" $18 ";" $19 }' '{}' \
  >"$DIR"/data/$Y/dadostemporais.csv

sed -i 's/,/\./g' "$DIR"/data/$Y/dadostemporais.csv

gawk -i inplace '!/Hora/' "$DIR"/data/$Y/dadostemporais.csv
# sed -i '/Hora/d' "$DIR"/data/$Y/dadostemporais.csv

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE \
  -c "\copy dados_temporais from '$DIR/data/$Y/dadostemporais.csv' with delimiter ';' csv encoding 'win1252';"

rm -rf "$DIR"/data/"$Y"*

# NOTE: ADICIONAR O ANEXO NO BANCO DE DADOS:

unzip "$DIR"/data/AREA_IMOVEL.zip -d "$DIR"/data/area_imovel

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln area_imovel "$DIR"/data/area_imovel/*.shp \
  -nlt PROMOTE_TO_MULTI -lco precision=NO

rm -rf "$DIR"/data/area_imovel/

# NOTE: IMPORTAR DADOS DO SICAR:

BASIS_URL="https://geoserver.car.gov.br/geoserver/sicar/sicar_imoveis_ac/ows?service=WFS"
LAYER="sicar:"
LAYERNAME="sicar_imoveis_ac"

ogr2ogr -skipfailures -f geojson "$DIR"/data/$LAYERNAME.json \
  --config GDAL_HTTP_UNSAFESSL YES WFS:"$BASIS_URL" "$LAYER$LAYERNAME"

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln "$LAYERNAME" \
  "$DIR"/data/"$LAYERNAME".json

rm "$DIR"/data/"$LAYERNAME".json
