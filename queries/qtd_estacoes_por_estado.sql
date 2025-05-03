SELECT
    uf.cd_uf,
    uf.nm_uf,
    count(me.geom) AS qtd_estacoes
FROM
    unidades_federacao uf
    LEFT JOIN mv_estacoes me
    -- ON uf.sigla_uf = me.uf
    ON st_contains (uf.wkb_geometry, me.geom)
WHERE
    uf.cd_uf IS NOT NULL
GROUP BY
    1,
    2;

