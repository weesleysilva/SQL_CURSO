# Ambiente de Setup Local: SQL Server Automatizado

Esta pasta contém o script para garantir que você tenha 100% de dados práticos populados na sua máquina local ou em sua VPS, focando na eliminação total de bloqueios durante a jornada de práticas manuais do curso.

## O Que Está Preparado Aqui
- **schema.sql**: Um "Dumptão" pesado contendo as "Constraints de PK/FK" da modelagem corporativa gerando tabelas em padrão Enterprise, e mais de inúmeras linhas já inseridas.
- **popular_banco.py**: App leve Python focado na camada de Data Engineering usando bibliotecas robustas para conectar à sua Engine do MS SQL Server abstraindo complexidades.
- **.env.example**: Espaço seguro para guardar suas chaves do SQL (sem subir na nuvem vazadas). 

## Passos para População do Banco

1. **Garanta que o Database Exista:**
Antes de automatizar, abra seu SQL Management Studio ou DBeaver e rode simples:
`CREATE DATABASE MeuCursoSQL_DB;`

2. **Configure suas Credenciais Secretas**:
Mude o nome do arquivo `.env.example` para `.env` estrito (Isso garante ignorar no GIT), e aplique informações ali (Sua Senha Mestre do seu SQLEXPRESS).

3. **Crie seu Ecossistema Estudo**:
Utilizando Python ou Virtual Env (recomendado usar a `pip`), baixe os dois conectores primordiais propostos. Abra seu Terminal Integrado Bash ou Cmdlet:
```bash
pip install pyodbc python-dotenv
```
*Obs:* Caso usando Windows nativo com instâncias de SqlServer rodando em C:, o drive local odbc padrão vem incluso em sistema base. 

4. **Start e Disparo**
Apenas execute pelo terminal!
```bash
python popular_banco.py
```
O console exibirá tabelas nascendo e os inputs de inserts voando para sua infraestrutura. 
A área de testes está liberada. Siga para o **Módulo 1**!
