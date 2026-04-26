# Módulo 5: Performance e Otimização de Consultas (Tuning)

Neste módulo, vamos abordar como escrever consultas SQL que não apenas trazem o resultado correto, mas fazem isso da maneira mais rápida e eficiente possível. Abordaremos como o banco de dados trabalha por baixo dos panos (planos de execução), o impacto dos relacionamentos (1 para N), uso de filtros, Joins e as melhores práticas comparando o jeito "certo" vs o jeito "errado".

## 1. Otimizando Filtros (Cláusula WHERE)

A cláusula `WHERE` é fundamental para o desempenho. O banco de dados tenta usar **Índices** para achar os dados rapidamente. Quando escrevemos os filtros da maneira incorreta, o banco de dados desiste de usar o índice e faz um **Table Scan** (lê a tabela inteira, o que é muito lento).

### O Errado vs O Correto (Sargability)
"Sargable" significa que um filtro pode utilizar um índice (Search ARGument ABLE). Para ser sargable, a coluna do banco de dados deve estar isolada de um lado do operador (como `=`), sem sofrer funções ou cálculos diretos.

**❌ Errado (Não Sargable): Usar funções na coluna do filtro**
```sql
-- O banco tem que aplicar a função YEAR em TODAS as linhas da tabela antes de conseguir filtrar.
-- Isso invalida o uso do índice na coluna DataVenda.
SELECT PedidoID, DataVenda, ValorTotal
FROM Vendas
WHERE YEAR(DataVenda) = 2023;
```

**✅ Correto (Sargable): Isolar a coluna**
```sql
-- O banco pode usar o índice na coluna DataVenda perfeitamente.
SELECT PedidoID, DataVenda, ValorTotal
FROM Vendas
WHERE DataVenda >= '2023-01-01' AND DataVenda < '2024-01-01';
```

**❌ Errado: Usar LIKE com curinga no início**
```sql
-- O índice é como uma lista telefônica. Se você procura por "%Silva", 
-- o banco não sabe em que letra começar, então ele lê a lista inteira (Table Scan).
SELECT Nome FROM Clientes WHERE Nome LIKE '%Silva';
```

**✅ Correto: Usar LIKE com curinga no final**
```sql
-- O banco vai direto na letra 'S' e acha todos os "Silvas" rapidamente usando o índice.
SELECT Nome FROM Clientes WHERE Nome LIKE 'Silva%';
```

## 2. Otimizando JOINS e Relacionamentos "1 para N"

Fazer `JOIN` em tabelas grandes pode ser o maior gargalo de performance se não for feito corretamente.

### Cuidado com relacionamentos 1 para N (Um para Muitos)

Quando você tem 1 Cliente que possui N (Muitos) Pedidos, o resultado de um Join tradicional vai **multiplicar** a linha do cliente para cada pedido que ele fez. 

**Problema de Performance com "1 para N": Explosão de Dados**
Imagine que você queira apenas responder à pergunta: *"Quais clientes fizeram compras em 2024?"*. 

**❌ Errado: Trazendo linhas duplicadas desnecessariamente (JOIN + DISTINCT)**
```sql
SELECT DISTINCT c.Nome
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.DataVenda >= '2024-01-01';
```
*(O banco faz o Join de 1 cliente com 50 pedidos, gera 50 linhas gigantescas na memória e, no final, precisa rodar um `DISTINCT` para apagar as 49 linhas duplicadas. Operações de ordenação para o `DISTINCT` são muito pesadas em CPU e Memória).*

**✅ Correto: Usando EXISTS (Melhor para checar existência em 1 para N)**
```sql
SELECT c.Nome
FROM Clientes c
WHERE EXISTS (
    SELECT 1 
    FROM Pedidos p 
    WHERE p.ClienteID = c.ClienteID 
      AND p.DataVenda >= '2024-01-01'
);
```
*(O `EXISTS` é um operador "Semi-Join". Ele para de procurar no exato momento em que acha o PRIMEIRO pedido em 2024 para aquele cliente. Ele não gera duplicações em memória e ignora o resto. É absurdamente mais rápido para checagens de existência).*

## 3. O Uso do TOP e Paginação

Trazer milhões de linhas para o aplicativo web (em C#, Python, Node, etc.) para que ele mostre apenas 10 em uma tabela na tela é um crime contra a rede, a memória do servidor e a paciência do usuário.

**❌ Errado: Trazer tudo para o backend filtrar**
```sql
-- Envia 1 milhão de clientes pela rede; o sistema sobrecarrega tentando pegar os 10 primeiros.
SELECT ClienteID, Nome, Email 
FROM Clientes;
```

**✅ Correto: Deixar o banco de dados trabalhar (Uso do TOP)**
```sql
-- Tráfego de rede ínfimo. Banco trabalha rápido.
SELECT TOP 10 ClienteID, Nome, Email 
FROM Clientes 
ORDER BY DataCadastro DESC;
```

### O Perigo do TOP sem ORDER BY
O `TOP` **sempre** deve vir acompanhado de um `ORDER BY`. O SQL Server não garante a ordem dos dados (ele não os guarda ordenados no disco por padrão na leitura de um scan). Se você usar o `TOP 10` sem o `ORDER BY`, o banco de dados vai retornar as 10 linhas que encontrar primeiro na memória, o que torna o seu resultado totalmente imprevisível e aleatório a cada vez que a query rodar.

## 4. O Mal Silencioso do `SELECT *`

Este é o erro mais comum e o que mais causa problemas estruturais a longo prazo.

**❌ Errado: Trazer todas as colunas**
```sql
SELECT * FROM Produtos WHERE CategoriaID = 5;
```
Por que isso destrói a performance?
- **Tráfego de Rede:** Você pode estar trazendo campos gigantescos, como um `VARCHAR(MAX)` com a descrição inteira ou um `VARBINARY` com a imagem do produto, sem precisar usar no aplicativo.
- **Morte aos Covering Indexes:** O SQL Server usa índices cobridores (Covering Indexes) para responder rápido apenas lendo o índice, sem nem tocar na tabela real. Se você pede um `*`, obriga o banco a ir buscar os dados na tabela principal na raiz do disco (operação conhecida como *Key Lookup*), o que diminui a performance em até 100x.

**✅ Correto: Especificar apenas o necessário**
```sql
-- Rápido, gasta pouca rede, e permite uso máximo dos índices.
SELECT ProdutoID, Nome, Preco 
FROM Produtos 
WHERE CategoriaID = 5;
```

## Resumo: Checklist de Performance
1. **Filtros (WHERE):** Isole a coluna (Sargable). Deixe funções e matemáticas do outro lado da igualdade `=`.
2. **LIKE:** Evite iniciar com `%` sempre que possível.
3. **1 para N:** Se você só precisa confirmar se algo existe na tabela filha, use `EXISTS` em vez de `JOIN` com `DISTINCT`.
4. **Colunas:** Declare exatamente as colunas que precisa. Diga **NÃO** ao `SELECT *`.
5. **Limites:** Use `TOP` para limitar as linhas se não for usar todas, sempre acompanhado de um `ORDER BY`.

---
## Exercício Prático

Abra o SQL Server Management Studio (SSMS) para testar os planos de execução (Execution Plans):
1. Escreva uma consulta utilizando o `SELECT *` e outra especificando as colunas.
2. Antes de executar, aperte o atalho `Ctrl + M` no SSMS (Include Actual Execution Plan).
3. Execute ambas as consultas juntas.
4. Vá para a aba **"Execution Plan"** que aparece perto da aba de "Results" e "Messages".
5. Observe se o SQL acusa um **"Index Seek"** (Busca Direta, excelente) ou um **"Index Scan / Table Scan"** (Leitura completa pesada, péssimo). Você também poderá comparar o custo (Cost) relativo entre as duas (Ex: Query 1 (90%), Query 2 (10%)).
