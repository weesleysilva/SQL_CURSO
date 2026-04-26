# Módulo 3: Avançado - Estrutura e Performance

## Visão Geral
Engenheiros de Dados sabem rodar código, porém grandes profissionais sabem escrever o código de forma Otimizada, Reutilizável e Estrutural para Banco de Dados complexos que escalam com o volume.

*Cenário de Negócio*: Sistema complexo da "FastDelivery" — Empresa de entregas que manipula milhões de atualizações e rastreios diariamente.

---

## 1. Visões do Banco (Views)

### Teoria
Em muitas situações precisamos disponibilizar dados da tabela filtrados perfeitamente todos os dias para diversas aplicações rodarem, criando confusão. As `VIEWS` não armazenam dados - elas são estruturas lógicas em formato de consulta 'salvas' no banco. Agem como lentes de óculos; facilitando criar recortes de segurança e reuso para terceirizados.

### Prática
**Cenário**: O parceiro terceirizado tem que ter acesso a tela resumida do Status do pacote, porém a nossa tabela original "pacotes" armazena lucro e margem no esquema - e o parceiro jamais pode ver isso.
```sql
CREATE VIEW vw_rastreio_parceiros AS
SELECT 
    codigo_rastreio, 
    cidade_destino, 
    status_atual, 
    data_estimada_entrega
FROM pacotes 
JOIN rotas ON pacotes.id_rota = rotas.id_rota;

-- O sistema de terceiros consome fácil sem conhecer tabelas e dados sensiveis:
SELECT * FROM vw_rastreio_parceiros;
```
> 🛡️ **Boas Práticas (Arquitetura e Tuning)**: Evite aninhar Views (ou seja: criar Views que consultam dentro os dados de dentro de outra e outra View). Isso fará o seu próprio Banco de Dados ficar quase cego (perdendo visibilidade do Query Optimizer), gerando perdas brutais de performance na recuperação e confusão quando for depurar gargalos.

---

## 2. Acelerando por Indexação (Indexes)

### Teoria
Se ler um livro em busca da página sobre a história do autor linha-por-linha leva dezenas de dias, por que seria rápido no banco? "Índices" (ou _Indexes_) no banco de dados agem com a exata lógica do índice/sumário das páginas dos livros. Eles aceleram radicalmente a entrega de dados sacrificando só um pedaço muito pequeno de memória da tabela.

### Prática
**Cenário**: Encontrar o motorista que despachou o pedido pelo ID demorava dezenas de segundos no App dos motoristas gerando perdas e gargalos no App. 
```sql
CREATE INDEX idx_pacotes_codigo_rastreio 
ON pacotes (codigo_rastreio);
```
> 🛡️ **Boas Práticas (Performance)**: *Por que não indexar todas as colunas de uma tabela por default?* Simples: Uma indexação ocupa tamanho em disco, e se TODA coluna for indexada, para cada pequeno evento que o Banco sofra na gravação (Novos Inserte, Updates ou um singelo Delete), todas as chaves vão ter o trabalho extra de serem realocadas simultaneamente ralentando bizarramente as operações transacionais rotineiras do insert/update. Só indexe colunas em tabelas de alto-uso de litura e que estejam sob grandes procuras nas linhas do JOIN, WHERE ou no ORDER BY.

---

## 3. Plano de Execução (Explain Plan e Tuning Básico)

### Teoria
Os Bancos operam por processamento Custo Benefício. O seu comando `EXPLAIN SELECT ...` antes do SQL em si vai desenhar para o usuário visualmente qual caminho que os motores da máquina de banco estão traçado para realizar algo que ele mandou. Vai revelar se ele irá "correr linha por linha" por falta de atalhos (evento nocivo chamado _Table Scan_) e gargalos reais da execução da query.

### Prática
**Cenário**: Entender por qual motivo a extração de dados do painel logístico está fazendo uso de 100% da CPU do seu servidor da AWS.
```sql
EXPLAIN SELECT 
    p.codigo_rastreio, 
    r.motorista 
FROM pacotes p 
JOIN rotas r ON p.id_rota = r.id_rota
WHERE p.status_atual = 'ATIVER_ALERTA_ATRASADO';
-- O retorno será o plano: Type=ALL, ROWS=12959952 (Table Scan indesejado) apontando a correção a ser feita...
```
> 🛡️ **Boas Práticas (Tuning Direto)**: A regra de ouro Universal nos códigos e APIs. JAMAI utilize a chamada coringa de colunas: `SELECT * `. A requisição indiscriminada para processar absolutamente todas as colunas fará não apenas a rede encher pelo tráfego I/O gerado, como ignorará qualquer benefício de índices de ponteiro coberto que a engine pudesse usar. Além disso, evite aplicar funções matemáticas diretamente sobre as colunas num `Where`, pois isso inutilizará um Index local (Index Scan) já que o campo passaria a ser em formato de 'variável dinâmica'. 

---

## 🔥 Desafio de Código - Módulo 3

**Instruções**:
A equipe do painel do centro de manutenções de veículos tem sofrido com a lentidão todos os dias para dar baixa nas planilhas pela manhã. Um Júnior da área entregou a eles este script: `SELECT * FROM veiculos_frota WHERE tipo_veiculo LIKE '%Caminhão%' AND data_prox_manutencao = '2025-01-01'` e causou queda pela Lentidão.

**Sua Tarefa (Análise de Performance)**:
Use seus aprendizados para propor as correções abaixo escrevendo código:
1. Re-estruture primeiramente a Query trocando o comando `*` para algo coeso de relatório (trazendo somente 'placa', 'renavam' e 'tipo'). 
2. Remova o erro clássico de padrão Curinga (`%xxx%`) sobre o texto para que não anule a eficiência de uma consulta limpa.
3. Construa com código o script para Criar no seu banco o Indice na tabela de data de manutenções ('data_prox_manutencao') que é onde o gargalo morava.
