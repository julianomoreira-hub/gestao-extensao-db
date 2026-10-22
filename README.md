# Sistema Web de Gestão de Atendimento e Demandas de Projetos de Extensão Universitária (UFMS) — Banco de Dados e Versionamento

Repositório referente à **Avaliação do Módulo 3 — Banco de Dados e Controle de Versão** do **Programa de Extensão UFMS Digital (`95DX7.200525`)**, Curso de Tecnologia em Análise e Desenvolvimento de Sistemas (UFMS).

- **Acadêmico:** Juliano de Carvalho Moreira
- **Disciplina:** Banco de Dados e Controle de Versão (`2026.2`)
- **Repositório Front-End (Módulo 2):** `https://github.com/julianomoreira-hub/gestao-extensao-web`
- **Repositório Banco de Dados (Módulo 3):** `https://github.com/julianomoreira-hub/gestao-extensao-db`

---

## 1. Sobre o Projeto
Este projeto implementa a camada de persistência relacional para o **Sistema Web de Gestão de Atendimento e Demandas de Projetos de Extensão da UFMS**, resolvendo o problema da descentralização de registros, ausência de rastreabilidade de solicitações da comunidade externa e falta de indicadores consolidados para coordenadores e bolsistas de extensão.

### Principais Características da Modelagem
- **Normalização até a 3ª Forma Normal (3FN)**: separação clara entre usuários, categorias temáticas PROECE, projetos de extensão, demandas de atendimento, trilha de auditoria (`historico_interacoes`) e avaliações de satisfação (`avaliacoes_atendimento`).
- **Integridade Referencial e de Domínio**: uso rigoroso de chaves primárias (`PRIMARY KEY`), chaves estrangeiras (`FOREIGN KEY` com políticas `ON DELETE RESTRICT`, `CASCADE` e `SET NULL`), restrições de unicidade (`UNIQUE`) e validação de domínios (`CHECK`).
- **Índices e Visão Analítica**: índices compostos para otimizar a triagem por status e prioridade (`idx_demandas_status_prio`) e view consolidada (`vw_painel_demandas`) para integração com o dashboard React.

---

## 2. Estrutura do Repositório

```text
gestao-extensao-db/
├── database/
│   └── gestao_extensao.db       # Banco de dados relacional SQLite3 populado e validado
├── docs/
│   ├── MODELAGEM_DADOS.md       # Dicionário de dados, cardinalidades e Formas Normais
│   └── der_banco_extensao.png   # Diagrama Entidade-Relacionamento (DER)
├── sql/
│   ├── 01_schema_ddl.sql        # Criação de tabelas, constraints, índices e view (DDL)
│   ├── 02_seed_dml.sql          # Carga inicial de dados institucionais da UFMS (DML)
│   └── 03_operacoes_dml_dql.sql # Inserções, atualizações, remoções e consultas (DML/DQL)
├── .gitignore                   # Regras de exclusão de arquivos temporários
└── README.md                    # Documentação principal e guia de execução
```

---

## 3. Como Executar os Scripts SQL

### Pré-requisitos
- **SQLite 3** (`sqlite3`) ou **PostgreSQL** (`psql` / DBeaver)
- **Git** (`git`)

### Passo a Passo (SQLite3)
```bash
# 1. Clonar o repositório
git clone https://github.com/julianomoreira-hub/gestao-extensao-db.git
cd gestao-extensao-db

# 2. Executar a criação do esquema (DDL)
sqlite3 database/gestao_extensao.db < sql/01_schema_ddl.sql

# 3. Executar a carga inicial de dados (DML)
sqlite3 database/gestao_extensao.db < sql/02_seed_dml.sql

# 4. Executar as operações de manipulação e consultas analíticas (DML/DQL)
sqlite3 -header -column database/gestao_extensao.db < sql/03_operacoes_dml_dql.sql
```

---

## 4. Boas Práticas de Controle de Versão (Git / GitHub)
O gerenciamento de código-fonte deste projeto adota:
1. **Estratégia Feature Branch**: desenvolvimento segmentado em branches temáticas (`feature/modelagem-ddl`, `feature/manipulacao-dml-dql`, `docs/diagrama-relatorio`) integradas à branch principal `main` via *merge* explícito (`--no-ff`) para preservar o histórico de evolução.
2. **Conventional Commits**: mensagens padronizadas (`chore:`, `docs:`, `feat(ddl):`, `feat(dml):`, `feat(dql):`) facilitando a leitura do log e auditoria técnica.

