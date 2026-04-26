-- LIMPEZA DE GARGALOS (Caso você queira rodar o popular_banco.py mil vezes para resetar tudo de novo)
-- Esse macete de Drop via Try impede que existam chaves amarradas e trava o sistema.
IF OBJECT_ID('transacoes', 'U') IS NOT NULL DROP TABLE transacoes;
IF OBJECT_ID('contas', 'U') IS NOT NULL DROP TABLE contas;
IF OBJECT_ID('pedidos', 'U') IS NOT NULL DROP TABLE pedidos;
IF OBJECT_ID('produtos', 'U') IS NOT NULL DROP TABLE produtos;
IF OBJECT_ID('clientes', 'U') IS NOT NULL DROP TABLE clientes;
IF OBJECT_ID('funcionarios', 'U') IS NOT NULL DROP TABLE funcionarios;

--------------------------------------------------------------------------------------
-- BLOCO 1 - CRIAÇÃO DE ESTRUTURAS DDL REAIS PARA ESTUDO COM CHAVES E REGRAS:
--------------------------------------------------------------------------------------

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    cidade VARCHAR(50),
    estado VARCHAR(2)
);

CREATE TABLE produtos (
    id_produto INT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) CHECK (preco > 0) -- Constraint que bloqueia lixo lógico
);

CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_produto INT NOT NULL,
    data_pedido DATETIME DEFAULT GETDATE(),
    valor_total DECIMAL(10,2),
    -- Relacionamento Fundamental PK/FK (A integridade base abordada num Banco bem planejado)
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_pedido_produto FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

CREATE TABLE contas (
    id_conta INT PRIMARY KEY,
    id_agencia INT DEFAULT 1,
    nome_cliente VARCHAR(100),
    tipo_conta VARCHAR(50),
    saldo DECIMAL(15,2),
    status_conta VARCHAR(20)
);

CREATE TABLE transacoes (
    id_transacao INT PRIMARY KEY,
    id_conta INT NOT NULL,
    data_transacao DATETIME DEFAULT GETDATE(),
    valor_transacao DECIMAL(15,2),
    tipo_transacao VARCHAR(20),
    CONSTRAINT fk_transacao_conta FOREIGN KEY (id_conta) REFERENCES contas(id_conta)
);

CREATE TABLE funcionarios (
    id_rh INT PRIMARY KEY IDENTITY(1,1),
    nome_funcionario VARCHAR(MAX),
    cargo VARCHAR(MAX)
);

--------------------------------------------------------------------------------------
-- BLOCO 2 - DML INSERTS: POPULANDO COM DADOS RICOS PARA CRUZAMENTO NOS ESTUDOS
--------------------------------------------------------------------------------------

INSERT INTO clientes VALUES (1, 'Silvio Santos JR', 'silvio@email.com', 'São Paulo', 'SP');
INSERT INTO clientes VALUES (2, 'Maria Antonieta', 'maria@email.com', 'Belo Horizonte', 'MG');
INSERT INTO clientes VALUES (3, 'Carlos Lima Rocha', 'carlos@email.com', 'Curitiba', 'PR');
INSERT INTO clientes VALUES (4, 'Isabela Freitas', 'isabela@email.com', 'Rio de Janeiro', 'RJ');
INSERT INTO clientes VALUES (5, 'Antonio Fagundes', 'antonio@email.com', 'Belo Horizonte', 'MG');

INSERT INTO produtos VALUES (1, 'ThinkPad T14 AMD', 7500.00);
INSERT INTO produtos VALUES (2, 'Mouse Wirelless Light', 85.00);
INSERT INTO produtos VALUES (3, 'Teclado Mecânico Keychron', 450.00);
INSERT INTO produtos VALUES (4, 'Suporte Duplo VESA', 300.00);

-- Vendas com suas referencias exatas FK
INSERT INTO pedidos (id_pedido, id_cliente, id_produto, data_pedido, valor_total) VALUES (101, 1, 1, '2026-05-10 14:30', 7500.00);
INSERT INTO pedidos (id_pedido, id_cliente, id_produto, data_pedido, valor_total) VALUES (102, 2, 2, '2026-05-11 09:15', 85.00);
INSERT INTO pedidos (id_pedido, id_cliente, id_produto, data_pedido, valor_total) VALUES (103, 2, 4, '2026-05-11 10:00', 600.00);
INSERT INTO pedidos (id_pedido, id_cliente, id_produto, data_pedido, valor_total) VALUES (104, 3, 3, '2026-05-18 19:42', 450.00);

-- Segmento FinBank - Modulo 2 em Diante
INSERT INTO contas (id_conta, id_agencia, nome_cliente, tipo_conta, saldo, status_conta) VALUES (1001, 50, 'Empresa Gigante LTDA', 'Corrente', 450000.00, 'Ativa');
INSERT INTO contas (id_conta, id_agencia, nome_cliente, tipo_conta, saldo, status_conta) VALUES (1002, 50, 'Maria Antonieta', 'Poupança', 23000.00, 'Ativa');
INSERT INTO contas (id_conta, id_agencia, nome_cliente, tipo_conta, saldo, status_conta) VALUES (1003, 10, 'José Santos', 'Corrente', 50.00, 'Inativa');

INSERT INTO transacoes (id_transacao, id_conta, valor_transacao, tipo_transacao) VALUES (50001, 1001, 50000.00, 'Entrada_DOC');
INSERT INTO transacoes (id_transacao, id_conta, valor_transacao, tipo_transacao) VALUES (50002, 1002, 2500.00, 'Saída_PIX');
INSERT INTO transacoes (id_transacao, id_conta, valor_transacao, tipo_transacao) VALUES (50003, 1001, 100.00, 'Tarifação');

-- Mockups p/ Base de RH e Rank
INSERT INTO funcionarios (nome_funcionario, cargo) VALUES ('Marcos Analista', 'Junior');
INSERT INTO funcionarios (nome_funcionario, cargo) VALUES ('Sandra Cientista', 'Senior');
