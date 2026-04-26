# Módulo 4: Expert - Programação Interna e Gestão

## Visão Geral
Poucos dominam essa camada profunda do conhecimento do banco. Como nível Expert, você aprenderá a encapsular as regras organizacionais para que residam perfeitamente integradas no sistema, criar gatilhos, e prover a governança rígida sobre quem e onde cada engrenagem roda na sua rede corporativa.

*Cenário de Negócio*: ERP para Controle de Estoque Operacional de uma cadeia nacional de Supermercados chamada "MegaMarket".

---

## 1. Lógica Procedural no Banco (Stored Procedures)

### Teoria
O banco SQL vai muito além das consultas: tem lógica avançada de programação inteiramente completa e autônoma. Uma `Stored Procedure` é um artefato executável salvo em que você consegue agrupar instruções enormes utilizando Condicionais Matemáticos, IF/ELSE, Loops de Resumo e controle massivo, e pode ser chamada via API web, via Bot etc.

### Prática
**Cenário**: Gerar o fechamento diário do caixa local e atualizar em conjunto a parte da contabilidade, evitando qualquer perigo caso as internet feche uma operação no meio deixando erro com valores parciais nas contas.
```sql
CREATE PROCEDURE prc_fechar_diaria_caixa (
    IN p_id_unidade INT,
    IN p_data_lancamento DATE
)
BEGIN
    -- O 'BEGIN' inicia a amarração para a transação bloqueada se houver a pane no meio de qualquer update.
    START TRANSACTION;
    
    -- Atualiza e consolida todo saldo
    UPDATE unidade_financeiro
    SET total_fechado = (SELECT SUM(volume) FROM vendas WHERE unidade = p_id_unidade AND dia = p_data_lancamento)
    WHERE unidade_fk = p_id_unidade;
    
    -- Inseri um rastreamento final na tabela de segurança no mesmo momento
    INSERT INTO trilha_auditoria (sistema, ocorrencia, acao_em)
    VALUES ('CAIXA', 'Fechamento final efetuado', NOW());
    
    -- Executa ambos se nenhum der Error: 'salva tudo real'
    COMMIT;
END;

-- App rodando a API na noite:
CALL prc_fechar_diaria_caixa(1234, '2026-05-15');
```
> 🛡️ **Boas Práticas (Lógica Segura)**: Adote extrema obrigatoriedade do Gerenciamento de Transações. Códigos de INSERT ou UPDATE complexos não encapsulados num bloco transacional de rollback farão o ERP quebrar em cenários paralelos com falhas sistêmicas na nuvem (o clássico "sacar o dinheiro" em A e "dar erro antes de incluir dinheiro na conta B" fazendo o saldo total se alterar ilicitamente na ponta da rede).

---

## 2. Automação e Trabalhos Agendados Naturais (Jobs)

### Teoria
A necessidade de rodar grandes comandos nas madrugadas diárias faz os Administradores escalarem o próprio Banco SQL como agente automatizador. Jobs Internos do banco executam em background cronogramas rigorosos para efetuar expurgos silenciosos programados para manutenção (no Postgres se usa ext pg_cron, SQL Server MS Agent, em outros bancos chamados de EVENT).

### Prática
**Cenário**: Realizar rotina de expurgo que deleta todo registro gravado nos rastreios do Log gerados pelo Sistema Operacional acima do ciclo limite diário aceito de 3 anos todos os domingos para abrir espaço de banco, evitando travar processamento diurno. (Exemplo em rotina nativa Event do estilo MySQL):
```sql
CREATE EVENT evento_manutencao_expurgo
ON SCHEDULE EVERY 1 WEEK
STARTS '2027-01-01 02:00:00'
DO
BEGIN
    -- Limpa registros de mais de 3 anos de log base
    DELETE FROM registro_log_eventos 
    WHERE instante_log < DATE_SUB(NOW(), INTERVAL 3 YEAR);
END;
```
> 🛡️ **Boas Práticas (Tuning e Custos)**: Qualquer Query que utilize a função DELETE processa fortemente memória. Sempre coloque tarefas que gerem travas lógicas intensas (Delete e Update) de rotina agendadas e em Horários que fujam da Janela Principal Diurna dos Operadores e Usuários Ativos.

---

## 3. Segurança e Governança de Roles (GRANT e REVOKE)

### Teoria
Na administração corporativa moderna as credenciais valem ouro e precisam seguir rígidos fluxos pautados pela própria base. Com o comando `GRANT`, distribuímos "PODER" dentro do banco diretamente aos usuários, e o com `REVOKE`, limitamos/subtraimos poderes desses de acordo como mudam de áreas ou demissões. Padrão enterprise usa _Roles_ (Cargos Abstratos) não distribuindo poder por pessoa especificadamente, e sim anexando pessoa no Cargo.

### Prática
**Cenário**: Os auditores querem ler a planilha restrita porem sem perigo para excluírem valores por distração.
```sql
-- Criar uma 'entidade' representacional 
CREATE ROLE auditor_financeiro_view;

-- Apenas garantir Seleções para a Role em cima do schema/estrutura de pagadoras
GRANT SELECT ON financeiro.movimentacao_pagadoras TO auditor_financeiro_view;

-- Dar a permissão de herdar esse cargo sem burocracia do usuário que precisava ler o cenário: carlos_jr
GRANT auditor_financeiro_view TO 'carlos_jr'@'%';

-- Carlos mudou de setor para rh? Revogam a Role apenas e facilmente:
REVOKE auditor_financeiro_view FROM 'carlos_jr'@'%';
```
> 🛡️ **Boas Práticas (Princípio de Menor Privilégio)**: Sendo arquiteto, a sua base da política em grandes projetos será de conceder `APENAS O ESSENCIAL` para as APIs e para a credencial interna. Evite espalhar o comando `GRANT ALL` e crie em produção usuários isolados (App_Usuario, App_API_Pagamento) pois no minuto seguinte em que ocorrer incidentes cibernéticos ou falhas lógicas no Back-end a base inteirinha se estilhaçará.

---

## 🔥 Desafio de Código - Integrador Final: Módulo 4

**O Desafio de Arquitetura**:
As contratações de fim de ano trouxeram uma nova tribo para a equipe: o "Setor de Análise de Preços" da companhia.
Eles preencherão o corpo de desenvolvedores do Data Analytics e precisam interagir via App com a engrenem e consumir suas estruturas sem risco ao resto das divisões sensíveis.

**A Sua Solução (Demonstre o Setup base)**:
1. Comece gerando o arquivo da Stored Procedure com transação encapsulada pra que o setor de análise de preços consiga automatizar suas rotinas diárias e seguras de aumento sobre valores de produto por percentual único (Usando de Parâmetro recebido a "Unidade de Faturamento" pela qual será acionado).
2. Deixe claro o código SQL p/ criar o Usuário `analistas_pricing_time` ou gerencie pela criação de uma `Role` e mostre seu `GRANT` delegando em linha a permissão vital apenas na de visualização/leitura pura no esquema Base do produto.
