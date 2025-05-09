# Teste Técnico – Especialista de Banco de Dados

### Objetivo

Avaliar a capacidade do(a) candidato(a) de:

- Otimizar consultas SQL e diagnósticos de performance;
- Projetar e modelar bancos de dados eficientes e escaláveis;
- Trabalhar com dados espaciais;
- Manipular e cruzar dados geográficos e temporais complexos.

### Parte 1 – Modelagem e Arquitetura

[/parte-1--modelagem-e-arquitetura](https://github.com/xonorhc/teste-tecnico-especialista-banco-dados/blob/main/parte-1--modelagem-e-arquitetura%0A.md)

### Parte 2 – Diagnóstico de Performance em Consulta Temporal-Espacial

[/parte-2--diagnostico-de-performance](https://github.com/xonorhc/teste-tecnico-especialista-banco-dados/blob/main/parte-2--diagnostico-de-performance%0A.md)

### Parte 3 – Script prático

[/parte-3--script-pratico](https://github.com/xonorhc/teste-tecnico-especialista-banco-dados/blob/main/parte-3--script-pratico%0A.md)

---

### Exemplo de banco de dados para o teste

Clone o repositorio:

```sh
git clone https://github.com/xonorhc/teste-tecnico-especialista-banco-dados.git
```

Instale as dependencias:

```sh
pacman -Syu postgresql postgis gdal
```

Apos configurar o gerenciador do banco de dados. Execute o shell script [/create-db.sh](https://github.com/xonorhc/teste-tecnico-especialista-banco-dados/blob/main/create-db.sh)

```sh
./create-db.sh 'your_pghost' 'your_pgport' 'your_dbname' 'your_dbuser' 'your_userpassword'
```

Substituir os parametros conforme suas configuracoes.
