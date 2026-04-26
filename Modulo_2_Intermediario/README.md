# Módulo 2: Intermediário - Agregações e Relações

## Visão Geral
Chegou o momento de avançar. Sabendo extrair as informações filtradas da tabela, agora aprenderemos a juntar dados em de tabelas diferentes para cruzar informações ou condensar em blocos estatísticos que façam sentido.

*Cenário de Negócio*: Um banco digital e fintech chamado "FinBank", necessitando criar relatórios gerenciais das suas de milhares contas e transações.

---

## 1. Agregações e Estatísticas (GROUP BY)

### Teoria
O `GROUP BY` agrupa diferentes linhas que dividem os mesmos valores. Usamos muito em conjunto com as funções de agregação, como `COUNT()` (contar os dados), `SUM()` (somar todos os valores), `AVG() `(média), entre outras, para calcular grandes indicadores rapidamente.

### Prática
**Cenário**: O Head do banco precisa saber o saldo total armazenado em cada tipo de conta (Corrente e Poupança), além da contagem de quantas contas existem de cada uma.
```sql
SELECT 
    tipo_conta, 
    COUNT(id_conta) AS volume_de_contas,
    SUM(saldo) AS total_acumulado 
FROM contas 
GROUP BY tipo_conta;
```

---

## 2. Filtrando sobre Agrupações (HAVING)

### Teoria
Muitos iniciantes tentam usar `WHERE` com agregações e encontram erro. A função `HAVING` foi incorporada a linguagem por isso: ela filtra os dados *só e unicamente depois* que eles já foram fatiados/agrupados pelo `GROUP BY`.

### Prática
**Cenário**: Identificar e recompensar as lideranças nas agências bancárias que possuem em sua dependência um volume real de mais do que 1000 contas ativadas.
```sql
SELECT 
    id_agencia, 
    COUNT(id_conta) AS quantidade_contas_ativas 
FROM contas 
WHERE status_conta = 'Ativa' -- Esse executa PRIMEIRO 
GROUP BY id_agencia 
HAVING COUNT(id_conta) > 1000; -- Esse executa SOBRE O RESULTADO do Count
```

---

## 3. Cruzamento e Relacionamento de Dados (JOINs)

### Teoria
Múltiplas formas do `JOIN` (`INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`) operam como soldadores. Elas juntam colunas de duas ou mais tabelas baseando-se sempre em um ponto comum de ligação entre elas (geralmente chaves primárias/estrangeiras como ID). O `INNER JOIN`, modelo mais normal, traz a combinação onde a ligação exata é encontrada em ambas as pontas.

### Prática
**Cenário**: Entregar o histórico detalhado mesclando a base pura com a transação na ponta para gerar um extrato simples para o usuário. 
```sql
SELECT 
    c.nome_cliente, 
    t.data_transacao, 
    t.valor_transacao, 
    t.tipo_transacao
FROM clientes c
INNER JOIN transacoes t ON c.id_cliente = t.id_cliente;
```

---

## 4. O Poder Aninhado das Subconsultas (Subqueries)

### Teoria
Uma _Subquery_ ou consulta aninhada é um script Select colocado dentro de um outro Select, Where ou From maior. É executada primeiro pela Database, servindo os próprios dados levantados como um parâmetro ou insumo para que o bloco externo de código consiga agir. 

### Prática
**Cenário**: O time de inteligência pediu o nome e o saldo de todos os clientes excepcionais do banco. Regra p/ ser excepcional: Ter um montante acima da própria MÉDIA GERAL do próprio banco.
```sql
SELECT 
    nome_cliente, 
    saldo 
FROM contas 
WHERE saldo > (SELECT AVG(saldo) FROM contas);
```

---

## 🔥 Desafio de Código - Módulo 2

**Instruções**:
A equipe de auditoria do Banco Central notou uma anomalia em movimentos atípicos e está te cobrando um relatório tático.

**Sua Tarefa (Escreva e valide esse código em seu ambiente)**:
1. Precisamos do relátorio trazendo exatamente as colunas `nome_cliente` (da Tabela clientes) e do `calculo total acumulado` das transações dele por dia.
2. É obrigatório haver o cruzamento usando `JOIN` de ambas.
3. Use a função Group By e aplique ao final dela o Having para garantir a seguinte regra da auditoria: O arquivo do relatório final gerado apenas pode mostrar linhas em que a soma desse valor do mês das transações do indivíduo passarem de exatos R$ 10.000,00.
