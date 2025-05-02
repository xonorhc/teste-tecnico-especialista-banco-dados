WITH ai AS (
    SELECT
        cod_imovel,
        wkb_geometry AS geom
    FROM
        area_imovel
    WHERE
        wkb_geometry IS NOT NULL
    ORDER BY
        cod_imovel
),
sia AS (
    SELECT
        cod_imovel,
        wkb_geometry AS geom
    FROM
        sicar_imoveis_ac
    WHERE
        wkb_geometry IS NOT NULL
    ORDER BY
        cod_imovel
)
SELECT
    ai.cod_imovel,
    ai.geom AS old_geom,
    sia.geom AS new_geom
FROM
    ai
    LEFT JOIN sia ON ai.cod_imovel = sia.cod_imovel
WHERE
    NOT st_equals (ai.geom, sia.geom);

