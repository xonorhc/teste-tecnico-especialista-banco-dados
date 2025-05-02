#!/bin/bash

DIR="$(dirname "$0")"
PGHOST=$1
PGPORT=5432
PGDATABASE=teste
PGUSER=$2
PGPASS=$3

# NOTE: Criar o banco de dados com suposta configuracao:

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d 'postgres' \
  -c "create database $PGDATABASE encoding 'WIN1252' locale_provider icu icu_locale 'pt-BR' locale 'pt-BR-x-icu' template template0;"

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE \
  -c "create extension if not exists postgis;"

# NOTE: Criar as tabelas:

find "$DIR"/ddl -type f -name "*.sql" -exec \
  psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE -b \
  -f {} \;

# NOTE: Importar os dados do INMET:

Y=2021

wget --no-check-certificate -O "$DIR"/dml/$Y.zip \
  'https://portal.inmet.gov.br/uploads/dadoshistoricos/'$Y'.zip'

unzip "$DIR"/dml/$Y.zip -d "$DIR"/dml/$Y

# NOTE: Extrair as informacoes das estacoes:

find "$DIR"/dml/$Y/ -type f -name "*.CSV" -print0 | xargs -0 -I{} \
  awk -F ';' 'FNR <= 8 { printf "%s;", $2 } END { print "" }' '{}' \
  >"$DIR"/dml/$Y/estacoes.csv

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE \
  -c "\copy estacoes from '$DIR/dml/$Y/estacoes.csv' with delimiter ';' csv;"

# NOTE: Extrair os dados temporais:

find "$DIR"/dml/$Y/ -type f -name "*.CSV" -print0 | xargs -0 -I{} \
  awk -F ';' \
  '/CODIGO/{ CODIGO=$2; next } /UTC/{ print CODIGO ";" $1 ";" $2";" $3";" $4";" $5";" $6";" $7";" $8";" $9";" $10";" $11";" $12 ";" $13 ";" $14 ";" $15 ";" $16 ";" $17 ";" $18 ";" $19 }' '{}' \
  >"$DIR"/dml/$Y/microdados.csv

psql -U "$PGUSER" -h "$PGHOST" -p $PGPORT -d $PGDATABASE \
  -c "\copy microdados from '$DIR/dml/$Y/microdados.csv' with header delimiter ';' csv encoding 'win1252';"

rm -rf "$DIR"/dml/"$Y"*

# NOTE: Adicionar o anexo no banco de dados:

unzip "$DIR"/dml/AREA_IMOVEL.zip -d "$DIR"/dml/area_imovel

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln area_imovel "$DIR"/dml/area_imovel/*.shp \
  -nlt PROMOTE_TO_MULTI -lco precision=NO

rm -rf "$DIR"/dml/area_imovel/

# NOTE: Importar dados do SICAR:

BASIS_URL="https://geoserver.car.gov.br/geoserver/sicar/sicar_imoveis_ac/ows?service=WFS"
LAYER="sicar:"
LAYERNAME="sicar_imoveis_ac"

ogr2ogr -skipfailures -f geojson "$DIR"/dml/$LAYERNAME.json \
  --config GDAL_HTTP_UNSAFESSL YES WFS:"$BASIS_URL" "$LAYER$LAYERNAME"

ogr2ogr -f PostgreSQL \
  PG:"host=$PGHOST user=$PGUSER password=$PGPASS dbname=$PGDATABASE" \
  -nln "$LAYERNAME" \
  "$DIR"/dml/"$LAYERNAME".json

rm "$DIR"/dml/"$LAYERNAME".json
