-- ============================================================================
-- PROJETO DE EXTENSÃO UFMS DIGITAL (95DX7.200525)
-- SISTEMA WEB DE GESTÃO DE ATENDIMENTO E DEMANDAS DE PROJETOS DE EXTENSÃO
-- Arquivo: 02_seed_dml.sql
-- Descrição: Carga Inicial de Dados (INSERT INTO) para Testes e Validação
-- Autor: Juliano de Carvalho Moreira
-- ============================================================================

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- ----------------------------------------------------------------------------
-- 1. Inserção de Usuários (Coordenadores, Bolsistas e Solicitantes Externos)
-- ----------------------------------------------------------------------------
INSERT INTO usuarios (nome_completo, email, cpf, telefone, perfil, ativo) VALUES
('Prof. Dr. Carlos Eduardo Mendes', 'carlos.mendes@ufms.br', '12345678901', '(67) 3345-7001', 'COORDENADOR', 1),
('Profa. Dra. Helena Souza Albuquerque', 'helena.albuquerque@ufms.br', '23456789012', '(67) 3345-7002', 'COORDENADOR', 1),
('Juliano de Carvalho Moreira', 'juliano.moreira@ufms.br', '34567890123', '(67) 99123-4501', 'DISCENTE_BOLSISTA', 1),
('Mariana Costa Ferreira', 'mariana.ferreira@ufms.br', '45678901234', '(67) 99234-5602', 'DISCENTE_BOLSISTA', 1),
('Roberto Almeida Nascimento', 'roberto.nascimento@gmail.com', '56789012345', '(67) 99811-2233', 'SOLICITANTE_EXTERNO', 1),
('Associação Comunitária Bairro Universitário', 'contato@acbu.org.br', '67890123456', '(67) 99722-3344', 'SOLICITANTE_EXTERNO', 1),
('Escola Estadual Prof. Henrique Ciryllo', 'direcao@eehc.ms.gov.br', '78901234567', '(67) 3314-9088', 'SOLICITANTE_EXTERNO', 1),
('Administração PROECE UFMS', 'proece.extensao@ufms.br', '89012345678', '(67) 3345-7200', 'ADMIN', 1);

-- ----------------------------------------------------------------------------
-- 2. Inserção de Categorias de Extensão (Áreas Temáticas PROECE/UFMS)
-- ----------------------------------------------------------------------------
INSERT INTO categorias_extensao (nome_categoria, sigla_area, descricao) VALUES
('Tecnologia e Produção', 'TEC-PROD', 'Projetos de inovação tecnológica, desenvolvimento de software, inclusão digital e assessoria técnica.'),
('Educação e Cidadania', 'EDU-CID', 'Ações voltadas à formação continuada de professores, reforço escolar e educação tecnológica.'),
('Saúde e Qualidade de Vida', 'SAU-VIDA', 'Atendimentos preventivos, orientação em saúde comunitária e bem-estar social.'),
('Direitos Humanos e Justiça', 'DH-JUST', 'Assistência jurídica comunitária, mediação de conflitos e promoção da cidadania.');

-- ----------------------------------------------------------------------------
-- 3. Inserção de Projetos de Extensão
-- ----------------------------------------------------------------------------
INSERT INTO projetos_extensao (codigo_sigproj, titulo, descricao, id_categoria, id_coordenador, status_projeto, data_inicio, data_fim) VALUES
('95DX7.200525', 'Programa de Extensão UFMS Digital: Assessoria em TI Comunitária', 'Desenvolvimento de soluções web e suporte tecnológico para entidades sem fins lucrativos e escolas públicas.', 1, 1, 'ATIVO', '2026-02-15', '2026-12-15'),
('88ED4.190310', 'Laboratório Aberto de Robótica e Pensamento Computacional nas Escolas', 'Oficinas práticas de programação, lógica e robótica educacional para estudantes do ensino público.', 2, 2, 'ATIVO', '2026-03-01', '2026-11-30'),
('72DH9.210890', 'Clínica de Direitos Digitais e Proteção de Dados (LGPD)', 'Orientação técnica e normativa sobre privacidade digital e adequação à LGPD para microempreendedores.', 4, 1, 'ATIVO', '2026-04-01', '2026-12-20');

-- ----------------------------------------------------------------------------
-- 4. Inserção de Demandas de Atendimento
-- ----------------------------------------------------------------------------
INSERT INTO demandas_atendimento (
    protocolo, id_projeto, id_solicitante, id_bolsista_responsavel,
    titulo_demanda, descricao_solic, prioridade, status_demanda,
    data_abertura, data_atualizacao, data_conclusao
) VALUES
(
    'UFMS-2026-0001', 1, 6, 3,
    'Implantação de portal de transparência para associação comunitária',
    'Solicitamos apoio técnico da equipe UFMS Digital para estruturar página web e banco de dados de prestação de contas da Associação Comunitária.',
    'ALTA', 'CONCLUIDA',
    '2026-09-02 09:15:00', '2026-09-18 16:40:00', '2026-09-18 16:40:00'
),
(
    'UFMS-2026-0002', 2, 7, 4,
    'Oficina de introdução ao pensamento computacional para 9º ano',
    'Agendamento de ciclo de 3 oficinas práticas no laboratório de informática da escola para 45 alunos do ensino fundamental.',
    'MEDIA', 'EM_ANDAMENTO',
    '2026-09-25 14:20:00', '2026-10-05 10:00:00', NULL
),
(
    'UFMS-2026-0003', 3, 5, 3,
    'Consultoria sobre termo de consentimento LGPD para comércio local',
    'Necessito de orientação para adequar o cadastro de clientes de pequeno comércio às normas da Lei Geral de Proteção de Dados.',
    'MEDIA', 'CONCLUIDA',
    '2026-10-01 11:00:00', '2026-10-12 17:30:00', '2026-10-12 17:30:00'
),
(
    'UFMS-2026-0004', 1, 7, NULL,
    'Capacitação de secretaria escolar em ferramentas digitais em nuvem',
    'Solicitação de minicurso presencial ou EAD para servidores administrativos da escola sobre gestão eletrônica de documentos.',
    'URGENTE', 'ABERTA',
    '2026-10-18 08:30:00', '2026-10-18 08:30:00', NULL
),
(
    'UFMS-2026-0005', 1, 5, NULL,
    'Solicitação duplicada de teste - cadastro externo',
    'Registro criado em duplicidade pelo solicitante durante teste de formulário.',
    'BAIXA', 'CANCELADA',
    '2026-10-19 19:05:00', '2026-10-19 19:10:00', NULL
);

-- ----------------------------------------------------------------------------
-- 5. Inserção de Histórico de Interações (Rastreabilidade e Triagem)
-- ----------------------------------------------------------------------------
INSERT INTO historico_interacoes (id_demanda, id_autor, status_anterior, status_novo, parecer_tecnico, data_registro) VALUES
(1, 1, 'ABERTA', 'EM_TRIAGEM', 'Demanda validada pela coordenação e classificada com prioridade ALTA.', '2026-09-03 10:00:00'),
(1, 3, 'EM_TRIAGEM', 'EM_ANDAMENTO', 'Bolsista Juliano Moreira designado. Levantamento de requisitos realizado com a diretoria da associação.', '2026-09-05 14:30:00'),
(1, 3, 'EM_ANDAMENTO', 'CONCLUIDA', 'Portal implantado e treinamento da equipe concluído com sucesso.', '2026-09-18 16:40:00'),
(2, 2, 'ABERTA', 'EM_ANDAMENTO', 'Bolsista Mariana Ferreira alocada para preparar o material didático das oficinas.', '2026-10-05 10:00:00'),
(3, 3, 'ABERTA', 'CONCLUIDA', 'Cartilha orientativa e modelo de termo de consentimento entregues ao solicitante.', '2026-10-12 17:30:00');

-- ----------------------------------------------------------------------------
-- 6. Inserção de Avaliações de Atendimento (Feedback da Comunidade)
-- ----------------------------------------------------------------------------
INSERT INTO avaliacoes_atendimento (id_demanda, nota, comentario, data_avaliacao) VALUES
(1, 5, 'Excelente atendimento! O sistema desenvolvido organizou todas as nossas demandas comunitárias.', '2026-09-19 09:00:00'),
(3, 5, 'Orientação muito clara, rápida e objetiva por parte do bolsista e do coordenador.', '2026-10-13 11:20:00');

COMMIT;
