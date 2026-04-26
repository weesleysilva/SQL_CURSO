import os
import pyodbc
from dotenv import load_dotenv

# Carrega os segredos do arquivo seguro (.env) para o contexto de memória da aplicação.
load_dotenv()

# Parsing Envs
SERVER = os.getenv('SQL_SERVER', 'localhost')
DATABASE = os.getenv('SQL_DATABASE', 'MeuCursoSQL_DB')
USERNAME = os.getenv('SQL_USER', 'sa')
PASSWORD = os.getenv('SQL_PASSWORD', '')

def executar_scripts():
    print(f"============================================================")
    print(f"🤖 Tentando conectar no servidor SQL Server Host: {SERVER}...")
    print(f"============================================================")
    
    try:
        # String de conexão Genérica utilizando Standard Driver 17+ via TCP (PyODBC config)
        conn_str = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={SERVER};"
            f"DATABASE={DATABASE};"
            f"UID={USERNAME};"
            f"PWD={PASSWORD};"
            f"TrustServerCertificate=yes;"
        )
        # Efetuada transação manual
        conn = pyodbc.connect(conn_str)
        conn.autocommit = True
        cursor = conn.cursor()
        print("✅ Transação aberta e conectada! Lendo arquivos fatiados schema.sql...")

        # Leitura da estrutura gigantesca SQL DDL/DML. Evitamos travar Engine rodando um string gigante "de cara".
        with open('schema.sql', 'r', encoding='utf-8') as file:
            script_full = file.read()
            # Fatiamos por blocos lógicos p/ enviar via batch. Separado nativamente por ';' ou o bloco 'GO'.
            comandos_batch = script_full.split(';') 
            
        print("🚀 Executando plano de Criação das Tabelas corporativas e populando os Registros das aulas...")
        
        qtde = 0
        for comando in comandos_batch:
            if comando.strip():
                try:
                    cursor.execute(comando)
                    qtde += 1
                except pyodbc.Error as py_ex:
                    print(f"⚠️ Aviso ao rodar query menor [ {str(py_ex)[:100]}... ] - Continuando execução...")
        
        print("\n🏆 Finalizado com o suor de Mestre! Engine DataBase SQL preenchida. (Comandos Executados: {})".format(qtde))
        
        cursor.close()
        conn.close()

    except Exception as e:
        print(f"\n❌ ERRO FATAL DE CONEXÃO ESTRUTURAL ❌ :")
        print(str(e))
        print("================================")
        print("DICA 1: Certifique-se que você CRIOU O BANCO 'MeuCursoSQL_DB' ANTES como orientado no Readme.")
        print("DICA 2: Confirme se o arquivo .env tem realmente as variáveis populadas da porta ou servidor SQLEXPRESS.")

if __name__ == '__main__':
    executar_scripts()
