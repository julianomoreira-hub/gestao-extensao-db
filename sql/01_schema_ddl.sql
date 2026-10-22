-- ============================================================================
-- PROJETO DE EXTENSÃO UFMS DIGITAL (95DX7.200525)
-- SISTEMA WEB DE GESTÃO DE ATENDIMENTO E DEMANDAS DE PROJETOS DE EXTENSÃO
-- Arquivo: 01_schema_ddl.sql
-- Descrição: Implementação do Esquema Relacional (DDL), Restrições e Índices
-- Autor: Juliano de Carvalho Moreira
-- ============================================================================

PRAGMA foreign_keys = ON;

-- Remoção segura de objetos caso já existam (para reexecução idempotente)
DROP VIEW IF EXISTS vw_painel_demandas;
DROP TABLE IF EXISTS avaliacoes_atendimento;
DROP TABLE IF EXISTS historico_interacoes;
DROP TABLE IF EXISTS demandas_atendimento;
DROP TABLE IF EXISTS projetos_extensao;
DROP TABLE IF EXISTS categorias_extensao;
DROP TABLE IF EXISTS usuarios;

-- ----------------------------------------------------------------------------
-- 1. Tabela: usuarios
-- ----------------------------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario    INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_completo VARCHAR(120) NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    cpf           CHAR(11)     NOT NULL UNIQUE,
    telefone      VARCHAR(20),
    perfil        VARCHAR(30)  NOT NULL,
    ativo         BOOLEAN      NOT NULL DEFAULT 1,
    criado_em     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_usuarios_perfil CHECK (
        perfil IN ('SOLICITANTE_EXTERNO', 'DISCENTE_BOLSISTA', 'COORDENADOR', 'ADMIN')
    ),
    CONSTRAINT chk_usuarios_cpf_len CHECK (LENGTH(cpf) = 11)
);

-- ----------------------------------------------------------------------------
-- 2. Tabela: categorias_extensao
-- ----------------------------------------------------------------------------
CREATE TABLE categorias_extensao (
    id_categoria   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_categoria VARCHAR(80) NOT NULL UNIQUE,
    sigla_area     VARCHAR(10) NOT NULL UNIQUE,
    descricao      TEXT
);

-- ----------------------------------------------------------------------------
-- 3. Tabela: projetos_extensao
-- ----------------------------------------------------------------------------
CREATE TABLE projetos_extensao (
    id_projeto     INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo_sigproj VARCHAR(30)  NOT NULL UNIQUE,
    titulo         VARCHAR(160) NOT NULL,
    descricao      TEXT         NOT NULL,
    id_categoria   INTEGER      NOT NULL,
    id_coordenador INTEGER      NOT NULL,
    status_projeto VARCHAR(25)  NOT NULL DEFAULT 'ATIVO',
    data_inicio    DATE         NOT NULL,
    data_fim       DATE,
    CONSTRAINT fk_projetos_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias_extensao (id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_projetos_coordenador
        FOREIGN KEY (id_coordenador) REFERENCES usuarios (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_projetos_status CHECK (
        status_projeto IN ('EM_PLANEJAMENTO', 'ATIVO', 'SUSPENSO', 'CONCLUIDO')
    )
);

-- ----------------------------------------------------------------------------
-- 4. Tabela: demandas_atendimento
-- ----------------------------------------------------------------------------
CREATE TABLE demandas_atendimento (
    id_demanda              INTEGER PRIMARY KEY AUTOINCREMENT,
    protocolo               VARCHAR(25)  NOT NULL UNIQUE,
    id_projeto              INTEGER      NOT NULL,
    id_solicitante          INTEGER      NOT NULL,
    id_bolsista_responsavel INTEGER,
    titulo_demanda          VARCHAR(140) NOT NULL,
    descricao_solic         TEXT         NOT NULL,
    prioridade              VARCHAR(15)  NOT NULL DEFAULT 'MEDIA',
    status_demanda          VARCHAR(20)  NOT NULL DEFAULT 'ABERTA',
    data_abertura           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_conclusao          DATETIME,
    CONSTRAINT fk_demandas_projeto
        FOREIGN KEY (id_projeto) REFERENCES projetos_extensao (id_projeto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_demandas_solicitante
        FOREIGN KEY (id_solicitante) REFERENCES usuarios (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_demandas_bolsista
        FOREIGN KEY (id_bolsista_responsavel) REFERENCES usuarios (id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_demandas_prioridade CHECK (
        prioridade IN ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE')
    ),
    CONSTRAINT chk_demandas_status CHECK (
        status_demanda IN ('ABERTA', 'EM_TRIAGEM', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')
    )
);

-- ----------------------------------------------------------------------------
-- 5. Tabela: historico_interacoes
-- ----------------------------------------------------------------------------
CREATE TABLE historico_interacoes (
    id_interacao    INTEGER PRIMARY KEY AUTOINCREMENT,
    id_demanda      INTEGER     NOT NULL,
    id_autor        INTEGER     NOT NULL,
    status_anterior VARCHAR(20),
    status_novo     VARCHAR(20) NOT NULL,
    parecer_tecnico TEXT        NOT NULL,
    data_registro   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historico_demanda
        FOREIGN KEY (id_demanda) REFERENCES demandas_atendimento (id_demanda)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_historico_autor
        FOREIGN KEY (id_autor) REFERENCES usuarios (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 6. Tabela: avaliacoes_atendimento
-- ----------------------------------------------------------------------------
CREATE TABLE avaliacoes_atendimento (
    id_avaliacao   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_demanda     INTEGER  NOT NULL UNIQUE,
    nota           INTEGER  NOT NULL,
    comentario     TEXT,
    data_avaliacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avaliacoes_demanda
        FOREIGN KEY (id_demanda) REFERENCES demandas_atendimento (id_demanda)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_avaliacoes_nota CHECK (nota BETWEEN 1 AND 5)
);

-- ----------------------------------------------------------------------------
-- 7. Índices de Desempenho (Otimização de Consultas e Filtros de Triagem)
-- ----------------------------------------------------------------------------
CREATE INDEX idx_projetos_categoria    ON projetos_extensao (id_categoria);
CREATE INDEX idx_projetos_coordenador  ON projetos_extensao (id_coordenador);
CREATE INDEX idx_demandas_projeto      ON demandas_atendimento (id_projeto);
CREATE INDEX idx_demandas_solicitante  ON demandas_atendimento (id_solicitante);
CREATE INDEX idx_demandas_status_prio  ON demandas_atendimento (status_demanda, prioridade);
CREATE INDEX idx_historico_demanda     ON historico_interacoes (id_demanda);

-- ----------------------------------------------------------------------------
-- 8. Visão Analítica: vw_painel_demandas (Integração com o Dashboard Web)
-- ----------------------------------------------------------------------------
CREATE VIEW vw_painel_demandas AS
SELECT
    d.id_demanda,
    d.protocolo,
    d.titulo_demanda,
    d.prioridade,
    d.status_demanda,
    p.codigo_sigproj,
    p.titulo AS projeto_extensao,
    c.sigla_area AS area_tematica,
    sol.nome_completo AS nome_solicitante,
    COALESCE(bol.nome_completo, 'Aguardando Triagem') AS bolsista_responsavel,
    coord.nome_completo AS coordenador_projeto,
    d.data_abertura,
    d.data_conclusao,
    av.nota AS nota_satisfacao
FROM demandas_atendimento d
INNER JOIN projetos_extensao p      ON d.id_projeto = p.id_projeto
INNER JOIN categorias_extensao c    ON p.id_categoria = c.id_categoria
INNER JOIN usuarios sol             ON d.id_solicitante = sol.id_usuario
INNER JOIN usuarios coord           ON p.id_coordenador = coord.id_usuario
LEFT JOIN  usuarios bol             ON d.id_bolsista_responsavel = bol.id_usuario
LEFT JOIN  avaliacoes_atendimento av ON d.id_demanda = av.id_demanda;
