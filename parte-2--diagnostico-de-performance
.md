# Parte 2 – Diagnóstico de Performance em Consulta Temporal-Espacial

## Cenário:

O banco de dados clima_audsat contém a tabela eventos_meteorologicos, com mais de 500 milhões de registros horários dos últimos 10 anos, referentes a diversas variáveis (chuva, temperatura, vento, etc.) com cobertura para todo o Brasil. Essa tabela (eventos_meteorologicos) é frequentemente utilizada para análises de cruzamento com áreas rurais, por exemplo:

```sql
SELECT AVG(precipitacao)
FROM eventos_meteorologicos e
    JOIN propriedades_rurais p ON ST_Intersects (e.geom, p.geom)
WHERE e.datahora BETWEEN '2021-01-01 00:00:00' AND '2022-01-01 00:00:00' AND p.id_cliente = 123;
```

## Desafio:

#### 1. A consulta acima está demorando mais de 2 minutos para retornar resultados. Quais ações de otimização você sugeriria para melhorar significativamente o desempenho dessa consulta?

```sql
WITH em AS (
    SELECT geom, AVG(precipitacao) AS precipitacao
    FROM eventos_meteorologicos
    WHERE e.datahora BETWEEN '2021-01-01 00:00:00' AND '2022-01-01 00:00:00'
    GROUP BY geom
),
pr AS (
    SELECT id_cliente, geom
    FROM propriedades_rurais
    WHERE id_cliente = 123
)
SELECT id_cliente, precipitacao
FROM pr
    LEFT JOIN em st_intersects (pr.geom, em.geom)
WHERE em.geom IS NOT NULL AND pr.geom IS NOT NULL;
```

#### 2. Considere tanto a estrutura da base quanto a modelagem, indexação, particionamento e uso de ferramentas/funções específicas do PostGIS/PostgreSQL.

Em andamento ...
