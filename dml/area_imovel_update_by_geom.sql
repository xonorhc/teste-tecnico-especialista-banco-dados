BEGIN;
CREATE UNIQUE INDEX IF NOT EXISTS area_imovel_cod_imovel_idx ON area_imovel (cod_imovel);
CREATE INDEX IF NOT EXISTS area_imovel_geom_idx ON area_imovel USING gist (wkb_geometry);
CREATE UNIQUE INDEX IF NOT EXISTS sicar_imoveis_ac_cod_imovel_idx ON sicar_imoveis_ac (cod_imovel);
CREATE INDEX IF NOT EXISTS sicar_imoveis_ac_geom_idx ON sicar_imoveis_ac USING gist (wkb_geometry);
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
            TO_CHAR(sia.dat_criacao, 'DD/MM/YYYY'::text) AS dat_criacao,
            TO_CHAR(sia.data_atualizacao, 'DD/MM/YYYY'::text) AS data_atualizacao,
            sia.wkb_geometry
        FROM
            sicar_imoveis_ac sia
        WHERE
            ai.cod_imovel = sia.cod_imovel
            AND to_date(ai.dat_atuali::text, 'DD/MM/YYYY') < to_date(sia.data_atualizacao::text, 'YYYY-MM-DD'::text)
            AND NOT st_equals (ai.wkb_geometry, sia.wkb_geometry));
ROLLBACK;

-- WARN: Substituir "ROLLBACK;" por "COMMIT;" para realizar a transacao;
