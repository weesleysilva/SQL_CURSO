# Módulo 4: Expert - Programação Interna e Automação Master

## Visão Geral
Arquitetos de software precisam delegar tarefas crônicas para rodarem "abaixo" de suas próprias APIs e Sistemas por questão de segurança de red de Tráfego pesado. Dominar este módulo lhe permite engatilhar tarefas sem que o painel e servidor HTTP principal precisem realizar suor ativamente.

*Cenário de Negócio*: ERP para Controle de Operacional RH e Frotas de uma corporação nacional "MegaMarket".

---

## 1. Lógica Procedural no Banco (Stored Procedures)

### Teoria
As famigeradas `Stored Procedures` (SPs). É onde a mágica dos bancos toma as vezes nas noites bancárias. Um objeto gigante empacotado possuindo código Transacional (Ifs/Elses, Loops lógicos, Parâmetros e Rollbacks preventivos) sem que dependa de programar em C# ou Python o lado da nuvem.

### Prática
**Cenário**: Fechamento do caixa da unidade impedindo valores picados gerarem problemas com rollback.
```sql
CREATE PROCEDURE prc_fechar_diaria_banco (
    @p_numero_agencia INT
)
AS
BEGIN
    BEGIN TRANSACTION; -- "Salva aqui, e se tudo baixo falhar, desfaz e volta pra cá"
    
    UPDATE contas SET status_conta = 'Bloqueado Financeiro' WHERE id_agencia = @p_numero_agencia;
    
    INSERT INTO tabela_log_fechamentos (data, agente) VALUES (GETDATE(), SYSTEM_USER);
    
    COMMIT; -- "Deu tudo certo! Dispara o gravador universal!"
END;

-- App rodando a API na noite:
EXECUTE prc_fechar_diaria_banco 50;
```
> 🛡️ **Boas Práticas (ACID)**: Qualquer transação base de update que não está cercado no pacote Transaction corre forte risco de anomalias no ar.

---

## 2. Gatilhos Autônomos em Fundo (Triggers)

### Teoria
Bancos executando _Event-Driven Architecture_ puramente passiva. Assim entramos os `Triggers` (Gatilhos): Stored Procedures zumbis atreladas a eventos fixos em colunas que disparam 100% de forma passiva (quando se tentar deletar registros da empresa, se acorda a "Trigger de Delete" copiando aquele registro num DB de logs).

### Prática
**Cenário**: Toda tentativa de EXCLUIR (`DELETE`) perigosa a Tabela dos Clientes tem de gerar um alerta na Auditoria secreta salvando a imagem em `log_demitidos`.
```sql
CREATE TRIGGER tgr_alerta_secreto_delete
ON clientes
AFTER DELETE
AS
BEGIN
    -- 'deleted' é uma tabela mágica instantânea q possui as colunas da remoção original que sofreu tentativa do hit
    INSERT INTO rh_logs_deletados (id_morto, evento_em)
    SELECT id_cliente, GETDATE() FROM deleted;
END;
```
> 🛡️ **Trigger Hell Avoidance**: Use extremamento como sal na cozinha. Engatilhar gatilho A que explode o Gatilho B e faz hit no Gatilho C, resultará em seu Servidor caindo por "Table Deadlocks".

---

## 3. Automação Agendada Pura (Jobs / SQLServer Agent)

### Teoria
No Server Agent ou PGCron, robôs internos não precisam de gatilhos pontuais (em updates) mas trabalham nos "schedules" via calendário disparando processos agendados baseados e purgas (rotinas "Batch").

### Prática
*(Exemplo visual de Script Padrão - A sintaxe pode variar do Engine)*
```sql
-- Criando Job que Executa Purga de Tabelas Mensalmente (Base Event Nativa):
CREATE EVENT evento_manutencao_expurgo_total
ON SCHEDULE EVERY 1 MONTH STARTS '2026-01-01 03:00:00'
DO
BEGIN
    DELETE FROM registro_log_eventos WHERE instante < DATE_SUB(NOW(), INTERVAL 3 YEAR);
END;
```

---

## 4. Governança Segura Tática (GRANT, REVOKE e ROLES)

### Teoria
Usuários na base não são donos do mundo. Aplique sempre Políticas rígidas. No modelo do Azure ou corporativo o DBA cria um "Grupo Abstrato de Cargo" (`ROLE`), deposita as permissões do cargo em cima dele, e atribui as pessos físicas entrando e saindo da firma somente àquele papel sem se embaralhar.
* `GRANT`: Concede liberação
* `REVOKE`: Retira

### Prática
```sql
-- Criar uma Entidade "Perfis/Cargo/Grupo"
CREATE ROLE leitor_financeiro;

-- O Grupo Leitor Financeiro da companhia só poderá rodar Query View e Selecionar as tabelas. Nada mais.
GRANT SELECT ON contas TO leitor_financeiro;

-- Promova usuários sem estresse vinculando o papel.
ALTER ROLE leitor_financeiro ADD MEMBER analista_joao;
```

---

## 🔥 O Desafio Operacional Final de Engenheiro de Dados

**O Arquitetamento Final:**
Você acabou de montar uma área inteira com o sistema Python base nas rotinas iniciais.
Seja Mestre.
1. Crie uma Stored Procedure completa `Exec_AumentarSaldosBase`. Nela amarre usando Transaction p/ atualizar a tabela de `contas`, inflando em +R$50 reais fixos no saldo de contas do nosso Mock (Onde as agências delas forem "Abaixo do limiar X").
2. Gere um Script em sequencia elaborando uma Role focada em "Seguro Auditory" onde o DBA concede puramente a Leitura (`SELECT`) à base para o estagiário fiscal que lerá este script validado.
