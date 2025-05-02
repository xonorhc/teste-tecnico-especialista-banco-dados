BEGIN;
CREATE UNIQUE INDEX IF NOT EXISTS area_imovel_cod_imovel_idx ON area_imovel (cod_imovel);
CREATE UNIQUE INDEX IF NOT EXISTS sicar_imoveis_ac_cod_imovel_idx ON sicar_imoveis_ac (cod_imovel);
INSERT INTO area_imovel AS ai (cod_tema, nom_tema, cod_imovel, mod_fiscal, num_area, ind_status, ind_tipo, des_condic, municipio, cod_estado, dat_criaca, dat_atuali, wkb_geometry)
SELECT
    'AREA_IMOVEL' AS cod_tema,
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
FROM
    sicar_imoveis_ac sia
WHERE
    sia.wkb_geometry IS NOT NULL
ON CONFLICT (cod_imovel)
    DO NOTHING;
ROLLBACK;

-- WARN: Substituir "ROLLBACK;" por "COMMIT;" para realizar a transacao;
