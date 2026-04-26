# Curso Completo de SQL: Do Iniciante ao Expert 🚀

Bem-vindo ao Curso de SQL, projetado para transformar você em um especialista em manipulação, modelagem, otimização e gerência de bancos de dados.

## Metodologia e Design Instrucional

O material está organizado em uma progressão de conhecimento fluída:
1. **Teoria Rápida e Direta**: Conceitos limpos para garantir uma base técnica sólida sem enrolação.
2. **Casos em Cenários Reais**: Em vez de exemplos clássicos genéricos, mergulhamos em E-commerce, Bancos Digitais e Logística. 
3. **Boas Práticas e Performance**: O mercado exige não só "quem sabe rodar o código", mas "quem sabe escrever código eficiente, seguro e legível" (como abordado nos tópicos de Tuning).
4. **Desafio de Código (Hands-on)**: Nada supera a prática. O final de cada módulo convida à ação para provar a fixação das habilidades.

## Organização de Módulos (Pastas)

Navegue pelas pastas do projeto de acordo com o seu mapa de aprendizagem:

- 📂 [**Setup_SQL_Server/**](./Setup_SQL_Server) *(Comece por aqui)*
  - Ambiente e scripts de Instalação. Contém o arquivo `.env` para segurança com credenciais, e um Script construído em Python para consumir o `schema.sql` que criará *todas* as tabelas fictícias e populará os dados do curso quebrando barreiras iniciais.
- 📂 [**Modulo_1_Iniciante/**](./Modulo_1_Iniciante)
  - Modelagem de Entidades Base (`PK/FK`) e as Consultas fundamentais da liguagem de banco. Como perguntar o básico com filtros `WHERE` e limitações de informação.
- 📂 [**Modulo_2_Intermediario/**](./Modulo_2_Intermediario)
  - Inteligência relacional profunda. Dominando junções complexas com multíplas formas de `JOIN`, empilhamento de consultas `UNION`, escopo de `Subqueries`, além do domínio sobre agregações verticais com Agrupamentos estatísticos (GROUP BY e HAVING).
- 📂 [**Modulo_3_Avancado/**](./Modulo_3_Avancado)
  - Virando a chave para o universo de Arquitetura de Dados de alta performance. Entendendo encapsulamento seguro via `Views`, `CTE's` (Common Table Expressions), Funções de janela / `RANK`, finalizando com o segredo da performance com Indexação, Explain Plan e as principais rotinas táticas de Tuning.
- 📂 [**Modulo_4_Expert/**](./Modulo_4_Expert)
  - Automações potentes e administração profissional de instâncias DB. Como criar rotinas e Scripts dinâmicos (`Stored Procedures`), engatilhar gatilhos implícitos no banco (`Triggers`), agendamento no próprio motor do banco (`Jobs/Automations`) e Governança/Auditoria de permissões de acesso (`GRANT/REVOKE` e `Roles`).

---

**Instrutor / Especialista em Dados**: Antigravity
> *Bons estudos! E lembre-se: sempre teste o seu "WHERE" com muito rigor em um SELECT paralelo, antes de executar um UPDATE ou DELETE em produção!*
