-- ============================================================================
-- PROJETO DE EXTENSÃO UFMS DIGITAL (95DX7.200525)
-- SISTEMA WEB DE GESTÃO DE ATENDIMENTO E DEMANDAS DE PROJETOS DE EXTENSÃO
-- Arquivo: 03_operacoes_dml_dql.sql
-- Descrição: Operações de Manipulação (INSERT, UPDATE, DELETE) e Consultas (SELECT)
-- Autor: Juliano de Carvalho Moreira
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ============================================================================
-- PARTE 1: OPERAÇÕES DE INSERÇÃO ADICIONAL (INSERT)
-- ============================================================================
-- Cenário: Abertura de uma nova solicitação de atendimento pela comunidade externa
INSERT INTO demandas_atendimento (
    protocolo, id_projeto, id_solicitante, id_bolsista_responsavel,
    titulo_demanda, descricao_solic, prioridade, status_demanda,
    data_abertura, data_atualizacao
) VALUES (
    'UFMS-2026-0006', 1, 6, NULL,
    'Manutenção evolutiva e backup do banco de dados comunitário',
    'Solicitação de rotina automatizada de backup e ajuste de relatórios mensais da associação.',
    'ALTA', 'ABERTA',
    '2026-10-20 10:15:00', '2026-10-20 10:15:00'
);

-- ============================================================================
-- PARTE 2: OPERAÇÕES DE ATUALIZAÇÃO (UPDATE)
-- ============================================================================
-- Cenário: Coordenador realiza a triagem da demanda urgente 'UFMS-2026-0004',
-- atribuindo o bolsista Juliano de Carvalho Moreira (id_usuario = 3) e alterando
-- o status de 'ABERTA' para 'EM_ANDAMENTO'.
UPDATE demandas_atendimento
SET id_bolsista_responsavel = 3,
    status_demanda          = 'EM_ANDAMENTO',
    data_atualizacao        = '2026-10-21 09:00:00'
WHERE protocolo = 'UFMS-2026-0004';

-- Registra a movimentação correspondente na trilha de auditoria (historico_interacoes)
INSERT INTO historico_interacoes (
    id_demanda, id_autor, status_anterior, status_novo, parecer_tecnico, data_registro
) VALUES (
    4, 1, 'ABERTA', 'EM_ANDAMENTO',
    'Triagem prioritária realizada. Bolsista Juliano Moreira alocado para ministrar a capacitação.',
    '2026-10-21 09:00:00'
);

-- ============================================================================
-- PARTE 3: OPERAÇÕES DE REMOÇÃO (DELETE)
-- ============================================================================
-- Cenário: Exclusão de registros abertos em duplicidade e já marcados como 'CANCELADA'
-- sem interações técnicas ativas (Protocolo 'UFMS-2026-0005').
DELETE FROM demandas_atendimento
WHERE protocolo = 'UFMS-2026-0005'
  AND status_demanda = 'CANCELADA';

-- ============================================================================
-- PARTE 4: CONSULTAS ANALÍTICAS E OPERACIONAIS (SELECT / DQL)
-- ============================================================================

-- 4.1. Consulta Operacional: Painel Geral de Demandas (INNER JOIN e LEFT JOIN via View)
SELECT
    protocolo,
    SUBSTR(titulo_demanda, 1, 42) AS demanda_resumo,
    prioridade,
    status_demanda,
    area_tematica,
    bolsista_responsavel,
    COALESCE(CAST(nota_satisfacao AS TEXT), 'Pendente') AS avaliacao
FROM vw_painel_demandas
ORDER BY
    CASE prioridade
        WHEN 'URGENTE' THEN 1
        WHEN 'ALTA'    THEN 2
        WHEN 'MEDIA'   THEN 3
        ELSE 4
    END,
    data_abertura DESC;

-- 4.2. Consulta Gerencial: Indicadores por Projeto de Extensão (GROUP BY e Funções de Agregação)
SELECT
    p.codigo_sigproj,
    SUBSTR(p.titulo, 1, 48) AS projeto,
    COUNT(d.id_demanda) AS total_demandas,
    SUM(CASE WHEN d.status_demanda = 'CONCLUIDA' THEN 1 ELSE 0 END) AS concluidas,
    SUM(CASE WHEN d.status_demanda = 'EM_ANDAMENTO' THEN 1 ELSE 0 END) AS em_andamento,
    SUM(CASE WHEN d.status_demanda = 'ABERTA' THEN 1 ELSE 0 END) AS aguardando_triagem,
    ROUND(AVG(av.nota), 2) AS media_satisfacao
FROM projetos_extensao p
LEFT JOIN demandas_atendimento d   ON p.id_projeto = d.id_projeto
LEFT JOIN avaliacoes_atendimento av ON d.id_demanda = av.id_demanda
GROUP BY p.id_projeto, p.codigo_sigproj, p.titulo
ORDER BY total_demandas DESC;

-- 4.3. Consulta de Auditoria: Histórico Completo de Movimentações por Protocolo
SELECT
    d.protocolo,
    u.nome_completo AS responsavel_acao,
    u.perfil,
    h.status_anterior || ' -> ' || h.status_novo AS transicao_status,
    h.parecer_tecnico,
    h.data_registro
FROM historico_interacoes h
INNER JOIN demandas_atendimento d ON h.id_demanda = d.id_demanda
INNER JOIN usuarios u             ON h.id_autor = u.id_usuario
ORDER BY h.data_registro ASC;

-- 4.4. Consulta de Produtividade: Demandas Atribuídas por Bolsista de Extensão
SELECT
    u.nome_completo AS bolsista,
    u.email,
    COUNT(d.id_demanda) AS demandas_atribuidas,
    SUM(CASE WHEN d.status_demanda = 'CONCLUIDA' THEN 1 ELSE 0 END) AS demandas_finalizadas
FROM usuarios u
LEFT JOIN demandas_atendimento d ON u.id_usuario = d.id_bolsista_responsavel
WHERE u.perfil = 'DISCENTE_BOLSISTA'
GROUP BY u.id_usuario, u.nome_completo, u.email
ORDER BY demandas_atribuidas DESC;
