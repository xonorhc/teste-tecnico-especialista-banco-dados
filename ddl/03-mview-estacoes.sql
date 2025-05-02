CREATE MATERIALIZED VIEW mv_estacoes AS
SELECT
    regiao, -- HACK: References to IBGE data
    uf, -- HACK: References to IBGE data
    estacao,
    codigo,
    st_setsrid (st_makepoint (translate(longitude, ',', '.')::numeric, translate(latitude, ',', '.')::numeric), 4326) AS geom,
    translate(altitude, ',', '.')::numeric AS altitude,
    to_date(data_fundacao::text, 'DD/MM/YYYY') AS data_fundacao
FROM
    estacoes;

CREATE UNIQUE INDEX ON mv_estacoes (codigo);

CREATE INDEX ON mv_estacoes USING gist (geom);

