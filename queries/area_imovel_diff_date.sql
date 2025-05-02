WITH ai AS (
    SELECT
        cod_imovel,
        to_date(dat_atuali::text, 'DD/MM/YYYY') AS data_atualizacao
    FROM
        area_imovel
    WHERE
        dat_atuali IS NOT NULL
    ORDER BY
        cod_imovel
),
sia AS (
    SELECT
        cod_imovel,
        to_date(data_atualizacao::text, 'YYYY-MM-DD'::text) AS data_atualizacao
    FROM
        sicar_imoveis_ac
    WHERE
        data_atualizacao IS NOT NULL
    ORDER BY
        cod_imovel
)
SELECT
    ai.cod_imovel,
    ai.data_atualizacao AS old_date,
    sia.data_atualizacao AS new_date
FROM
    ai
    LEFT JOIN sia ON ai.cod_imovel = sia.cod_imovel
WHERE
    ai.data_atualizacao < sia.data_atualizacao;

