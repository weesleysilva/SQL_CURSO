# Módulo 1: Iniciante - Fundamentos e Modelagem de SQL

## Visão Geral
Neste módulo, iniciaremos a jornada no mundo da persistência e consulta. O SQL não é apenas "puxar tabelas do Excel pro código", mas criar e extrair dados garantindo confiabilidade de restrições por chaves, além de lógicas condicionais simples.

*Cenário de Negócio*: Uma plataforma de E-commerce chamada "TechStore".

---

## 0. O Pilar de Modelagem: Constraint PK e FK

### Teoria
Um banco de dados só funciona se houver relação estrutural. Modelagens quebradas geram lixo eterno que nenhuma consulta resolve.
*   **Primary Key (PK)**: É o "CPF" digital da sua linha e da tabela. Sendo exclusiva (`UNIQUE`), ela garante nunca ocorrer duplicação e cria alta performance de identificação (ex: `id_cliente`).
*   **Foreign Key (FK - Chave Estrangeira)**: É uma constraint (restrição) vital. A Chave estrangeira localiza um elemento originado fortemente em OUTRA tabela e proíbe a inconsistência no seu negócio (Ou seja, seu código será bloqueado caso tente registrar uma compra usando na fatura o CPF de um cliente que nunca sequer completou o cadastro raiz na Tabela Clientes original. Essa é a base de um ERP e do princípio da ACID em banco).

### Prática
**Cenário**: Durante nosso projeto com script `.env`, modelamos as engrenagens apontando as chaves:
```sql
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,           -- Essa tabela Nasce livre, esse é o núcleo dela
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT NOT NULL,              -- Coluna associativa que abrigará o id nas rotinas de fluxo
    CONSTRAINT amarra_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)  -- A trava do DBA!
);
```

---

## 1. Consultas Básicas (SELECT)

### Teoria
O comando `SELECT` é o pilar que fará leitura aos discos. Os dados retornados são armazenados em uma matriz virtual no seu monitor de *result-set*.

### Prática
**Cenário**: Relatório com nomes e e-mails de todos na loja para e-mail marketing.
```sql
SELECT 
    nome, 
    email 
FROM clientes;
```

---

## 2. Filtros e Lógicas (WHERE)

### Teoria
Agindo como filtro rígido, o `WHERE` desconsidera todos os dados volumosos antes de retornar para a rede.

### Prática
**Cenário**: Focar promoções só no estado de SP.
```sql
SELECT nome, email, cidade, estado FROM clientes WHERE estado = 'SP';
```

---

## 3. Ordenação Estruturada (ORDER BY)

### Teoria
O `ORDER BY` organiza tudo no eixo nativo de forma natural (Alfabeto/Numérico) do Crescente (`ASC`) ao Decrescente (`DESC`).

### Prática
**Cenário**: Produtos exibidos do mais caro para o barato na Dashboard Front-end.
```sql
SELECT nome_produto, preco FROM produtos ORDER BY preco DESC;
```

---

## 4. Otimização Front-End: Limitação (LIMIT ou TOP)

### Teoria
Usando em MYSQL/POSTGRES `LIMIT` e SQLServer `TOP`, informamos a Engine que o sistema requer que devolva um montante fixo estritizado no topo, o banco ignorará processar o "restante dos zilhões de elementos", caindo o processamento para frações de milisegundo.

### Prática
**Cenário**: Widget "Vendas de hoje" rodando um Top 5 rápidos (SQL Server Example).
```sql
SELECT TOP 5 id_pedido, data_pedido FROM pedidos ORDER BY data_pedido DESC;
```

---

## 🔥 Desafio de Código - Prática do Módulo 1

**Sua Tarefa (Acesse seu servidor e rode):**
O time de marketing quer os dados limpos das "pechinchas".
1. Escreva em sua IDE/Painel contra a tabela `produtos` trazendo só o `nome_produto` e o `preco`.
2. Filtre para não exibir lixos operacionais acidentais (ou seja `preco > 0`).
3. Ordene logicamente (`ASC` no *value*) de modo que o foco incida só nas margens baratas de liquidação.
4. *(Avançado)* Extra: Liste apenas os 'Top 3' mais baratos de toda lista.
