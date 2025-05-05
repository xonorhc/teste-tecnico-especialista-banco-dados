CREATE TABLE dados_temporais (
    codigo_estacao varchar REFERENCES estacoes (codigo),
    data varchar, -- FIX: To date
    hora_utc varchar, -- FIX: To integer?
    precipitacao_total numeric,
    pressao_atm_hora numeric,
    pressao_atm_max numeric,
    pressao_atm_min numeric,
    radiacao_global numeric,
    temperatura_bulbo_hora numeric,
    temperatura_orvalho_hora numeric,
    temperatura_max numeric,
    temperatura_min numeric,
    temperatura_orvalho_max numeric,
    temperatura_orvalho_min numeric,
    umidade_rel_max numeric,
    umidade_rel_min numeric,
    umidade_rel_hora numeric,
    vento_direcao numeric,
    vento_rajada_max numeric,
    vento_velocidade numeric
);

-- CREATE INDEX ON dados_temporais (data);
