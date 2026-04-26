# Módulo 2: Intermediário - Agregações e O Poder Relacional Pleno

## Visão Geral
Chegou o momento de explodirmos em horizontal a capacidade relacional. O SQL puro extrai registros limpos, mas sistemas densos necessitam de cruzamento profundo de dezenas de tabelas de forma contigente.

*Cenário*: Banco Fintech "FinBank", necessitando criar relatórios gerenciais das suas de milhares contas e estatísticas transversais na mesa de operações com precisão de auditoria.

---

## 1. Agregações e Estatísticas Gerenciais (GROUP BY)

### Teoria
O `GROUP BY` agrupa diferentes linhas em um só balde baseado numa categoria comum e as funde. Ele requer a injeção do uso das matemáticas `COUNT()`, `SUM()`, `AVG()` para sumarizar a lógica do balde.

### Prática
**Cenário**: O Head do banco pediu para visualizar a quantidade massiva de contas resumida por cada tipo existente (poupança x corrente) e o total em dinheiro flutuando ali.
```sql
SELECT 
    tipo_conta, 
    COUNT(id_conta) AS volume_de_contas_agrupadas,
    SUM(saldo) AS montante_dinheiro
FROM contas 
GROUP BY tipo_conta;
```

---

## 2. Refinadores (HAVING) vs WHERE

### Teoria
Muitos iniciantes tentam aplicar lógicas `> ou <` e desabam no erro na hora de usar em resultados dinâmicos gerados pelas matemáticas do agrupamento. Enquanto o `WHERE` atua nos "DADOS CRUS" (Antes do Motor Agrupar), o `HAVING` possui capacidade de filtro especial que age apenas DEPOIS nos "DADOS JÁ PROCESSADOS".

### Prática
**Cenário**: Filtrar e expurgar lideranças em agências que, na realidade prática da contabilização, falharam em demonstrar movimentação agregada acima do teto de retenção de R$10.000.
```sql
SELECT 
    id_agencia, 
    SUM(saldo) AS dinheiro_custodia 
FROM contas 
WHERE status_conta = 'Ativa' -- Rodado 1o: Filtra as limpas iniciais (ignorando canceladas p/ poupar memória)
GROUP BY id_agencia 
HAVING SUM(saldo) > 10000;   -- Rodado 2o: Aqui sim avalio sobre a Métrica e ignoro se as ativas renderam miséria.
```

---

## 3. A Espinha Dorsal Integradora (Dominando os JOINs)

### Teoria
A função "Juntar/Cruzar" é o que dá a letra R ("Relational") à RDBMS.
Usando as chaves (PK e FK referenciadas no Modulo 1) amarramos planilhas. Compreenda a variação da Arquitetura:
*   `INNER JOIN`: Combinação estrita. Retorna apenas, e tão somente as linhas, que a correspondência da amarração existiu *AMBOS* OS LADOS. Fatiando as anomalias ou vazios.
*   `LEFT JOIN` (O mais comum em relatórios abertos): Trás absolutamente TODAS AS LINHAS cruas da sua Tabela original A (Esquerda), tentando anexar colados à ela os dados da Tabela B. Se o cliente na A nunca realizou compras na B, ele ainda vem no resultado na Tela mas devolvendo os campos nulos (NULL) da outra. Excelente pra relatórios "Geral".

### Prática
**Cenário**: Extrair extrato absoluto sem perdão de perdas. A auditoria pediu a lista onde mesmo usuários Sem Registro ainda apareçam acusando zero (Left Join).
```sql
SELECT 
    c.nome_cliente, 
    c.saldo,
    t.valor_transacao
FROM contas c
LEFT JOIN transacoes t ON c.id_conta = t.id_conta;
```

---

## 4. Consulta Dinâmica e Lógica "Subquery" / EXISTS

### Teoria
Você frequentemente sofre para filtrar grandes listas limitantes. Uma _Subquery_ aninhada é um Select rodado de forma oculta na memória do sistema devolvendo um parâmetro virtual. Usar combinações de Subqueries com `IN` (lista de verificação de lote) e `EXISTS` (valida num piscar de olhos e retorna TRUE se encontrar ocorrência) salva sua infraestrutura.

### Prática
**Cenário**: Listar titulares operantes de contas que simultaneamente existam operando na base autônoma do e-commerce da Techstore separada.
```sql
SELECT id_conta, nome_cliente 
FROM contas 
WHERE nome_cliente IN (
    SELECT nome FROM clientes  -- Resolve PRIMEIRO e cospe um List na memória. "João, Maria..."
);
```

---

## 5. Empilhando Dicionários Absolutos (UNION vs UNION ALL)

### Teoria
Enquanto as Joins associam horizontalmente colunas, operadores de conjunto trabalham empilhando a mesma estrutura num eixo vertical (linha a linha). 
*   **UNION**: Empilha todos arquivos juntos. O motor exige poder computacional caçando e eliminando linhas 100% repitidas.
*   **UNION ALL**: Operação "Burra", rápida e bruta. Trás tudo e cola sem checar repetições (recomendado p/ auditorias rápidas sem perda CPU).

### Prática
**Cenário**: Empilhar um arquivo tático rápido de "Identificaveis", listando Clientes da Loja empilhados aos nossos próprios Funcionários de RH.
```sql
SELECT nome AS identidade_geral FROM clientes
UNION ALL
SELECT nome_funcionario AS identidade_geral FROM funcionarios;
```

---

## 🔥 Desafio de Código - Integrador de Análise

**Sua Tarefa:**
A Receita notificou seu Diretor com urgência de um cruzamento estatístico.
Escreva contra sua Engine Local esse Script de solução: Faça um `JOIN` estrito da tabela de "contas" atrelada perfeitamente na tabela de "transacoes" da base Finbank. Utilize `GROUP BY` e `HAVING` apenas validando saldos transacionais totais acima de mil reais sobre os IDs listados do conjunto do Join. E para testar e desafiar, construa um Relatório Subquery extraindo de volta IDs da base de `clientes` usando operador `EXISTS` acoplado ao sub-relatorio.
