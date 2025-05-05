# Parte 1 – Modelagem e Arquitetura

## Desafio:

Você foi encarregado(a) de projetar o banco de dados para armazenar os dados climáticos horários dos últimos 10 anos, com cobertura para todo o Brasil. Considere que haverá cruzamentos espaciais frequentes com polígonos de municípios e áreas rurais.

Os dados disponibilizados acerca das grandezas medidas são obtidos de hora em hora e têm a seguinte estrutura:

- t_max: Temperatura máxima
- t_inst: Temperatura
- t_min: Temperatura
- precipitacao: precipitação em mm
- press_min: Pressão
- press_max: Pressão
- press_inst: Pressão
- latitude: em graus decimais (SIRGAS2000 - EPSG 4674)
- longitude: em graus decimais (SIRGAS2000 - EPSG 4674)
- vento_vel: Velocidade do vento em Km/h
- uf: Unidade da Federação
- data: Data da medição
- hora_utc: Hora em relação ao meridiano de Greenwitch
- cod_estacao: Código da estação meteorológica

## Pergunta

Apresente uma proposta de modelagem conceitual e física para esse cenário, destacando como você faria para ser:

- Escalável e de alta performance;
- Suportar cruzamentos espaciais e temporais com eficiência;
- Preservar a precisão e facilite análises históricas complexas;
- Permitir consultas ágeis com múltiplos filtros (tempo, localização, variável climática)

---

### Modelo de dados conceitual

Em andamento ...

@startuml
@startchen

entity estacoes {
}
entity estacoes_geom {
}
estacoes -1- estacoes_geom
entity unidades_federacao {
}
entity dados_temporais {
}

relationship codigo_uf {
}
estacoes_geom -N- codigo_uf
codigo_uf -1- unidades_federacao

relationship codigo_estacao {
}
estacoes_geom -1- codigo_estacao
codigo_estacao -N- dados_temporais

@endchen
@enduml

### Modelo de dados logico

Em andamento ...

```mermaid
erDiagram
estacoes{
  regiao char
  uf char
  estacao char
  codigo char PK
  latitude num
  longitude num
  altitude num
  data_fundacao date
}

estacoes ||--|| estacoes_geom : create
estacoes_geom{
  codigo char PK
  geom geometry
  cod_mun int FK
}

estacoes_geom ||--|{ dados_temporais : has
dados_temporais{
  t_max num
  t_inst num
  t_min num
  precipitacao num
  press_min num
  press_max num
  press_inst num
  vento_vel num
  data date
  hora_utc time
  cod_estacao char FK
}

estacoes_geom }|--|| municipios : within
sicar_imoveis }|--|| municipios : within
municipios }|--|| unidades_federacao : within
```

### Modelo de dados fisico

Em andamento ...

```sql
CREATE TABLE estacoes (
    regiao varchar(2),
    uf varchar(2),
    estacao varchar,
    codigo varchar PRIMARY KEY,
    latitude numeric,
    longitude numeric,
    altitude numeric,
    data_fundacao date
);

CREATE MATERIALIZED VIEW estacoes_geom AS
WITH e AS (
    SELECT
        regiao,
        uf,
        estacao,
        codigo,
        st_setsrid (st_makepoint (longitude::numeric, latitude::numeric), 4326) AS wkb_geometry,
        altitude,
        data_fundacao
    FROM
        estacoes
)
SELECT
    e.codigo AS cod_estacao,
    e.wkb_geometry,
    e.estacao AS nm_estacao,
    e.altitude,
    e.data_fundacao,
    uf.cd_uf AS cod_uf,
    uf.cd_regia AS cod_regiao
FROM
    e
    LEFT JOIN unidades_federacao uf ON uf.sigla_uf = e.uf
WHERE
    uf.cd_uf IS NOT NULL
    AND e.wkb_geometry IS NOT NULL;
CREATE UNIQUE INDEX ON estacoes_geom (cod_estacao);
CREATE INDEX ON estacoes_geom USING gist (wkb_geometry);

CREATE TABLE dadostemporais (
    ano int,
    data date,
    hora time,
    codigo_estacao varchar REFERENCES estacoes_geom (codigo),
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
)
PARTITION BY RANGE (data);

CREATE TABLE dadostemporais_y2025m01 PARTITION OF microdados
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE dadostemporais_y2025m02 PARTITION OF microdados
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

...

CREATE INDEX ON dadostemporais (data);
```
