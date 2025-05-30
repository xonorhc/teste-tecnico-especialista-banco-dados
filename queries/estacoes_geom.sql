WITH e AS (
    SELECT
        regiao, -- HACK: References to IBGE data
        uf, -- HACK: References to IBGE data
        estacao,
        codigo,
        st_setsrid (st_makepoint (translate(longitude, ',', '.')::numeric, translate(latitude, ',', '.')::numeric), 4326) AS wkb_geometry,
        translate(altitude, ',', '.')::numeric AS altitude,
        to_date(data_fundacao::text, 'DD/MM/YY') AS data_fundacao
    FROM
        estacoes
)
SELECT
    e.codigo AS cod_estacao,
    e.wkb_geometry,
    e.estacao AS nm_estacao,
    e.altitude,
    e.data_fundacao,
    uf.cd_uf AS cod_uf,
    uf.cd_regia AS cod_regiao
FROM
    e
    LEFT JOIN unidades_federacao uf ON uf.sigla_uf = e.uf
WHERE
    uf.cd_uf IS NOT NULL
    AND e.wkb_geometry IS NOT NULL;

