CREATE TABLE IF NOT EXISTS estacoes (
    regiao varchar(2), -- HACK: References to IBGE data
    uf varchar(2), -- HACK: References to IBGE data
    estacao varchar,
    codigo varchar PRIMARY KEY,
    latitude numeric,
    longitude numeric,
    altitude numeric,
    data_fundacao varchar, -- FIX: To date
    observacoes varchar -- BUG: Extra column when import
);

