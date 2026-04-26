# Módulo 3: Avançado - Estrutura, Performance e Funções Complexas

## Visão Geral
Engenheiros sabem rodar código, engenheiros de nível avançado sabem escrever o código de forma Estrutural, Rápida e com classificadores dinâmicos sem a ajuda de programação externa.

*Cenário de Negócio*: Base do "FastDelivery" — Empresa de entregas com frotas, motoristas e um pipeline manipulando milhares de atualizações de status via satélite diariamente.

---

## 1. Abstração Segura (Views)

### Teoria
Aplicações necessitam consultar blocos de dados blindados diariamente. As `VIEWS` agem como lentes de óculos; facilitando criar recortes de segurança e abstraindo a complexidade gigante de um script escondendo dados pesados e mostrando em tela só as colunas em que não há perigo sistêmico num Select Virtual.

### Prática
**Cenário**: O parceiro quer ler as compras atrelado aos clientes.
```sql
CREATE VIEW vw_carteira_transparente AS
SELECT p.id_pedido, p.data_pedido, c.cidade 
FROM pedidos p 
JOIN clientes c ON p.id_cliente = c.id_cliente;

-- Consumo externo seguro sem dor de cabeça no JOIN do desenvolvedor app:
SELECT * FROM vw_carteira_transparente;
```
> 🛡️ **Tuning**: Cuidado com ninhos de views (Views dentro de Views), farão seu banco perder toda referência na navegação do Execution Plan.

---

## 2. Abstrações de Código "Top-Down" (CTEs - Cláusula WITH)

### Teoria
Se as _Views_ rodam fora do código, e as _Subqueries_ ficam no meio de forma poluída; a Estrutura `CTE` cria Tabelas Virtuais no momento de rodar a query escrita organizando os pensamentos do desenvolvedor e reusando bloco lógico numa Query inteira.

### Prática
**Cenário**: Destacar Cidades com alto número de clientes e usá-las para extrair relatórios da rota atrelada em Join posterior de maneira legiível.
```sql
WITH CidadesAlvo AS (
    SELECT cidade, COUNT(*) as volume_pessoas
    FROM clientes
    GROUP BY cidade
    HAVING COUNT(*) > 1
)
SELECT t.cidade, t.volume_pessoas, tb_real.nome
FROM CidadesAlvo t
JOIN clientes tb_real ON t.cidade = tb_real.cidade;
```

---

## 3. Classificadores Absolutos: Funções de Janela (RANK, ROW_NUMBER)

### Teoria
Funções de Janela (Window Functions) agem em grupo (por "gavetas" de repartição de dados via sintaxe `OVER(PARTITION BY...)`) mas sem fundir as linhas como o `GROUP BY` exige. Uma das maiores ferramentas do BI é a classificação, ranqueamento inteligente via: `ROW_NUMBER()`, `RANK()` (pula sequência se empatar) e `DENSE_RANK()`.

### Prática
**Cenário**: Gerar Quadro de medalhas de performance para Produtos mais caros DENTRO DENTRO específicos estados ordenados sem bagunçar tabelas.
```sql
SELECT 
    nome_produto,
    preco,
    RANK() OVER(ORDER BY preco DESC) AS ranking_geral_precos
FROM produtos;
```

---

## 4. Índices Turbinados (Indexes e Performance Real)

### Teoria
"Índices" no banco de dados agem com a exata lógica do índice remissivo final de um livro de 3000 páginas. Eles aceleram radicalmente a entrega abidicando de uma fina fatia de memória (`Index Seek` vs `Table Scan`).

### Prática
**Cenário**: O aplicativo de motoristas paralisou na busca por Cidades ao estourar de dados.
```sql
CREATE INDEX idx_cidade_cliente 
ON clientes (cidade);
```
> 🛡️ **Boas Práticas de Tuning**: Não faça índice indiscriminado de TODAS colunas! Sempre Indexe aquelas colunas usadas no WHERE de consultas grandes limitando as operações de "Insert" pesadas.

---

## 5. Raio-X do Plano de Execução (Explain Plan)

### Teoria
Bancos de Dados modernos não dizem só "deu erro" ou "tá lento". Adicionando Comando Genérico antes, o banco revela o caminho matemático desenhando sua falha da arquitetura para ser lida e refeita.
```sql
EXPLAIN SELECT id_cliente, nome FROM clientes WHERE cidade = 'São Paulo';
```

---

## 🔥 Desafio de Código - Prática do Módulo 3

**Sua Tarefa (Análise de Funções Nativas):**
Abra o banco gerado na infraestrutura local do Python.
Escreva contra as tabelas recém geradas do desafio uma Query para aplicar uma Função de Classificação e uma CTE combinada.
1. Primeiramente monte uma CTE `WITH TopProdutos` rastreando da Tabela "produtos".
2. Integre em seguida a janela lógica com `RANK()` ou `DENSE_RANK()`.
3. *(Ouro do Database)* Execute e entenda a lógica de particionamento e ranqueamento sobre eles no bloco executado do DBeaver/SQLManagement.
