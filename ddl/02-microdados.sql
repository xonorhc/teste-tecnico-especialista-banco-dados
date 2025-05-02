CREATE TABLE microdados (
    codigo_estacao varchar REFERENCES estacoes (codigo),
    data varchar,
    hora_utc varchar,
    precipitacao_total varchar,
    pressao_atm_hora varchar,
    pressao_atm_max varchar,
    pressao_atm_min varchar,
    radiacao_global varchar,
    temperatura_bulbo_hora varchar,
    temperatura_orvalho_hora varchar,
    temperatura_max varchar,
    temperatura_min varchar,
    temperatura_orvalho_max varchar,
    temperatura_orvalho_min varchar,
    umidade_rel_max varchar,
    umidade_rel_min varchar,
    umidade_rel_hora varchar,
    vento_direcao varchar,
    vento_rajada_max varchar,
    vento_velocidade varchar
);

