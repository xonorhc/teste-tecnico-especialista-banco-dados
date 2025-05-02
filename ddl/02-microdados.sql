CREATE TABLE microdados (
    codigo_estacao VARCHAR REFERENCES estacoes (codigo),
    data VARCHAR,
    hora_utc VARCHAR,
    precipitacao_total VARCHAR,
    pressao_atm_hora VARCHAR,
    pressao_atm_max VARCHAR,
    pressao_atm_min VARCHAR,
    radiacao_global VARCHAR,
    temperatura_bulbo_hora VARCHAR,
    temperatura_orvalho_hora VARCHAR,
    temperatura_max VARCHAR,
    temperatura_min VARCHAR,
    temperatura_orvalho_max VARCHAR,
    temperatura_orvalho_min VARCHAR,
    umidade_rel_max VARCHAR,
    umidade_rel_min VARCHAR,
    umidade_rel_hora VARCHAR,
    vento_direcao VARCHAR,
    vento_rajada_max VARCHAR,
    vento_velocidade VARCHAR
);

