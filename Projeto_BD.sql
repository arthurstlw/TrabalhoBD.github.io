-- ============================================================
--  Projeto BD — Controle de Estoque
--  Banco: SQL Server (compatível com SSMS / SQL Server Express)
-- ============================================================

USE master;
GO

-- Recria o banco do zero (remova este bloco se o banco já existir)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'estoque')
BEGIN
    ALTER DATABASE estoque SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE estoque;
END
GO

CREATE DATABASE estoque
    COLLATE Latin1_General_CI_AI;
GO

USE estoque;
GO

-- ─── SETOR ────────────────────────────────────────────────────
CREATE TABLE setor (
    id_setor   INT IDENTITY(1,1) PRIMARY KEY,
    nome_setor VARCHAR(100) NULL
);
GO

INSERT INTO setor (nome_setor) VALUES
    ('TI'),
    ('Administrativo'),
    ('Financeiro');
GO

-- ─── GRUPO_PRODUTO ────────────────────────────────────────────
CREATE TABLE grupo_produto (
    id_grupo   INT IDENTITY(1,1) PRIMARY KEY,
    nome_grupo VARCHAR(100) NOT NULL
);
GO

INSERT INTO grupo_produto (nome_grupo) VALUES
    ('Eletrônicos'),
    ('Periféricos'),
    ('Escritório');
GO

-- ─── FORNECEDOR ───────────────────────────────────────────────
CREATE TABLE fornecedor (
    id_fornecedor INT IDENTITY(1,1) PRIMARY KEY,
    nome_fr       VARCHAR(100) NOT NULL,
    telefone      VARCHAR(20)  NULL,
    email         VARCHAR(100) NULL
);
GO

INSERT INTO fornecedor (nome_fr, telefone, email) VALUES
    ('Tech Distribuidora', '11999999999', 'tech@email.com'),
    ('MegaInfo',           '11888888888', 'mega@email.com');
GO

-- ─── PRODUTO ──────────────────────────────────────────────────
CREATE TABLE produto (
    id_produto     INT IDENTITY(1,1) PRIMARY KEY,
    nome           VARCHAR(100)   NOT NULL,
    descricao      VARCHAR(255)   NULL,
    id_grupo       INT            NULL,
    estoque_atual  INT            DEFAULT 0,
    estoque_minimo INT            DEFAULT 0,
    preco_medio    DECIMAL(10,2)  NULL,
    CONSTRAINT fk_produto_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo_produto (id_grupo)
);
GO

-- Desabilita IDENTITY temporariamente para inserir IDs fixos
SET IDENTITY_INSERT produto ON;
INSERT INTO produto (id_produto, nome, descricao, id_grupo, estoque_atual, estoque_minimo, preco_medio) VALUES
    (1, 'Mouse Gamer',      'Mouse RGB',       2, 50, 10,  120.00),
    (2, 'Teclado Mecânico', 'Teclado RGB',     2, 30,  5,  250.00),
    (3, 'Monitor 24',       'Monitor Full HD', 1, 15,  3,  900.00);
SET IDENTITY_INSERT produto OFF;
GO

-- ─── PRODUTO_FORNECEDOR ───────────────────────────────────────
CREATE TABLE produto_fornecedor (
    id_produto    INT           NOT NULL,
    id_fornecedor INT           NOT NULL,
    preco_compra  DECIMAL(10,2) NULL,
    CONSTRAINT pk_pf  PRIMARY KEY (id_produto, id_fornecedor),
    CONSTRAINT fk_pf_produto    FOREIGN KEY (id_produto)    REFERENCES produto    (id_produto),
    CONSTRAINT fk_pf_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor)
);
GO

INSERT INTO produto_fornecedor (id_produto, id_fornecedor, preco_compra) VALUES
    (1, 1,  90.00),
    (1, 2,  95.00),
    (2, 1, 180.00),
    (3, 2, 700.00);
GO

-- ─── COMPRA ───────────────────────────────────────────────────
CREATE TABLE compra (
    id_compra     INT IDENTITY(1,1) PRIMARY KEY,
    data_c        DATETIME      NULL,
    id_fornecedor INT           NULL,
    numero_nota   VARCHAR(50)   NULL,
    total         DECIMAL(10,2) NULL,
    CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedor (id_fornecedor)
);
GO

SET IDENTITY_INSERT compra ON;
INSERT INTO compra (id_compra, data_c, id_fornecedor, numero_nota, total) VALUES
    (1, '2026-05-11 15:49:41', 1, 'NF001', 360.00),
    (2, '2026-05-11 15:49:41', 2, 'NF002', 700.00);
SET IDENTITY_INSERT compra OFF;
GO

-- ─── DETALHE_COMPRA ───────────────────────────────────────────
CREATE TABLE detalhe_compra (
    id_detalhe_compra INT IDENTITY(1,1) PRIMARY KEY,
    id_compra         INT           NULL,
    id_produto        INT           NULL,
    quantidade        INT           NULL,
    preco_unitario    DECIMAL(10,2) NULL,
    CONSTRAINT fk_dc_compra  FOREIGN KEY (id_compra)  REFERENCES compra   (id_compra),
    CONSTRAINT fk_dc_produto FOREIGN KEY (id_produto) REFERENCES produto  (id_produto)
);
GO

INSERT INTO detalhe_compra (id_compra, id_produto, quantidade, preco_unitario) VALUES
    (1, 1, 2,  90.00),
    (1, 2, 1, 180.00),
    (2, 3, 1, 700.00);
GO

-- ─── CONSUMIDOR ───────────────────────────────────────────────
CREATE TABLE consumidor (
    id_consumidor INT IDENTITY(1,1) PRIMARY KEY,
    id_setor      INT      NULL,
    data          DATETIME NULL,
    CONSTRAINT fk_consumidor_setor FOREIGN KEY (id_setor)
        REFERENCES setor (id_setor)
);
GO

SET IDENTITY_INSERT consumidor ON;
INSERT INTO consumidor (id_consumidor, id_setor, data) VALUES
    (1, 1, '2026-05-11 15:51:07'),
    (2, 2, '2026-05-11 15:51:07');
SET IDENTITY_INSERT consumidor OFF;
GO

-- ─── DETALHE_CONSUMIDOR ───────────────────────────────────────
CREATE TABLE detalhe_consumidor (
    id_detalhe_consumidor INT IDENTITY(1,1) PRIMARY KEY,
    id_consumidor         INT           NULL,
    id_produto            INT           NULL,
    quantidade            INT           NULL,
    preco_unitario        DECIMAL(10,2) NULL,
    CONSTRAINT fk_dcons_consumidor FOREIGN KEY (id_consumidor) REFERENCES consumidor (id_consumidor),
    CONSTRAINT fk_dcons_produto    FOREIGN KEY (id_produto)    REFERENCES produto    (id_produto)
);
GO

INSERT INTO detalhe_consumidor (id_consumidor, id_produto, quantidade, preco_unitario) VALUES
    (1, 1, 1, 120.00),
    (2, 2, 1, 250.00);
GO

-- ─── MOVIMENTO_ESTOQUE ────────────────────────────────────────
CREATE TABLE movimento_estoque (
    id_movimento   INT IDENTITY(1,1) PRIMARY KEY,
    id_produto     INT          NULL,
    data           DATETIME     NULL,
    tipo_movimento VARCHAR(20)  NULL,
    quantidade     INT          NULL,
    referencia     VARCHAR(100) NULL,
    CONSTRAINT fk_mov_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto)
);
GO

INSERT INTO movimento_estoque (id_produto, data, tipo_movimento, quantidade, referencia) VALUES
    (1, '2026-05-11 15:51:59', 'ENTRADA', 2, 'Compra NF001'),
    (2, '2026-05-11 15:51:59', 'ENTRADA', 1, 'Compra NF001'),
    (3, '2026-05-11 15:51:59', 'ENTRADA', 1, 'Compra NF002'),
    (1, '2026-05-11 15:51:59', 'SAIDA',   1, 'Setor TI');
GO

-- ─── FIM ──────────────────────────────────────────────────────
PRINT 'Banco "estoque" criado e populado com sucesso!';
GO
