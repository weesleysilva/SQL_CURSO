# Módulo 1: Iniciante - Fundamentos do SQL

## Visão Geral
Neste módulo, iniciaremos a nossa jornada no mundo do SQL (Structured Query Language). O foco será em aprender a extrair informações básicas de um banco de dados, utilizando filtros, lógicas simples e ordenações.

*Cenário de Negócio*: Uma plataforma de E-commerce chamada "TechStore", onde analisaremos os nossos clientes, produtos e o histórico pedidos.

---

## 1. Consultas Básicas (SELECT)

### Teoria
O comando `SELECT` é o pilar central de qualquer consulta em SQL. Ele é utilizado para selecionar colunas com dados de um banco de dados (tabelas). Os dados retornados são armazenados em uma estrutura chamada de *result-set*.

### Prática
**Cenário**: O setor de comunicação precisa da lista com os nomes e e-mails de todos os clientes cadastrados na loja para enviar um disparo de promoções.
```sql
SELECT 
    nome, 
    email 
FROM clientes;
```

---

## 2. Filtros e Lógica Condicional (WHERE)

### Teoria
A cláusula `WHERE` é usada para extrair apenas os registros que cumprem uma condição específica em uma consulta. Funciona exatamente como um filtro refinado sobre os dados brutos.

### Prática
**Cenário**: O E-commerce decidiu realizar uma promoção focada apenas em clientes que moram no estado de "São Paulo" (SP).
```sql
SELECT 
    nome, 
    email, 
    cidade, 
    estado 
FROM clientes 
WHERE estado = 'SP';
```

---

## 3. Ordenação Estruturada (ORDER BY)

### Teoria
A palavra-chave `ORDER BY` organiza o conjunto de resultados retornados, ordenando os valores da sua busca de forma natural em ordem Crescente (`ASC`) ou então em ordem Decrescente (`DESC`).

### Prática
**Cenário**: Listar todo o catálogo de produtos da nossa loja, começando sempre a visualização pelos produtos mais caros (ordem decrescente de valor).
```sql
SELECT 
    nome_produto, 
    preco 
FROM produtos 
ORDER BY preco DESC;
```

---

## 4. Limitação de Resultados (LIMIT ou TOP)

### Teoria
A cláusula `LIMIT` (ou equivalente `SELECT TOP`, como usado no SQL Server) especifica o número máximo e estrito de registros que o banco de dados deve retornar. Isso é excelente em tabelas muito volumosas para otimizar tempo de resposta e criar rapidamente rankings.

### Prática
**Cenário**: A tela inicial do painel de administração da TechStore precisa mostrar de forma rápida quem foram os autores e os valores dos 5 pedidos mais recentes feitos na plataforma.
```sql
SELECT 
    id_pedido,
    nome_cliente,
    data_pedido, 
    valor_total 
FROM pedidos 
ORDER BY data_pedido DESC 
LIMIT 5;
```

---

## 🔥 Desafio de Código - Módulo 1

**Instruções**:
O time de marketing precisa rodar as campanhas de remarketing. Eles querem concentrar esforços oferecendo produtos baratos (que costumam converter impulsivamente) para clientes concentrados puramente no estado de "Minas Gerais" (MG).

**Sua Tarefa (Escreva esse código em sua IDE)**:
1. Trabalhando com a tabela `produtos`, extraia uma lista exibindo *só* a coluna `nome_produto` e `preco`.
2. O filtro da tabela precisa desconsiderar falhas de cadastro (ou seja: liste apenas produtos que tenham `preco > 0`).
3. Retorne apenas os 10 mais baratos.
4. *(Bônus de Lógica)*: Onde, e como, a cláusula que filtraria usuários do estado de Minas Gerais ('MG') se encaixaria se o código buscasse dados na tabela de "clientes"?
