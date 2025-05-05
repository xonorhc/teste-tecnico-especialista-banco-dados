SELECT
    uf.cd_uf,
    uf.nm_uf,
    count(eg.wkb_geometry) AS qtd_estacoes
FROM
    unidades_federacao uf
    LEFT JOIN estacoes_geom eg
    -- ON uf.sigla_uf = me.uf
    ON st_contains (uf.wkb_geometry, eg.wkb_geometry)
WHERE
    uf.cd_uf IS NOT NULL
GROUP BY
    1,
    2;

