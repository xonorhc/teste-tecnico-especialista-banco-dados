BEGIN;
CREATE UNIQUE INDEX IF NOT EXISTS area_imovel_cod_imovel_idx ON area_imovel (cod_imovel);
CREATE UNIQUE INDEX IF NOT EXISTS sicar_imoveis_ac_cod_imovel_idx ON sicar_imoveis_ac (cod_imovel);
UPDATE
    area_imovel AS ai
SET
    (mod_fiscal,
        num_area,
        ind_status,
        ind_tipo,
        des_condic,
        municipio,
        cod_estado,
        dat_criaca,
        dat_atuali,
        wkb_geometry) = (
        SELECT
            sia.m_fiscal,
            sia.area,
            sia.status_imovel,
            sia.tipo_imovel,
            sia.condicao,
            sia.municipio,
            sia.uf,
            TO_CHAR(sia.dat_criacao, 'DD/MM/YYYY'::text),
            TO_CHAR(sia.data_atualizacao, 'DD/MM/YYYY'::text),
            sia.wkb_geometry
        FROM
            sicar_imoveis_ac sia
        WHERE
            ai.cod_imovel = sia.cod_imovel
            AND to_date(ai.dat_atuali::text, 'DD/MM/YYYY') < to_date(sia.data_atualizacao::text, 'YYYY-MM-DD'::text));
ROLLBACK;

-- WARN: Substituir "ROLLBACK;" por "COMMIT;" para realizar a transacao;
