from flask import Flask, jsonify, request
from flask_cors import CORS
import pyodbc

app = Flask(__name__)
CORS(app)

# ─── CONFIGURAÇÃO ─────────────────────────────────────────────────────────────
# Troque os valores abaixo conforme seu SQL Server:
#   SERVER   → nome do servidor (ex: localhost, DESKTOP-XXX\SQLEXPRESS)
#   DATABASE → nome do banco
#   UID/PWD  → usuário e senha (usado apenas se USE_WINDOWS_AUTH = False)

USE_WINDOWS_AUTH = False    # True  = autenticação Windows (mais comum no SSMS)
                            # False = autenticação SQL Server (usuário + senha)

SERVER   = "localhost\\SQLEXPRESS"   # ou só "localhost" se não for Express
DATABASE = "estoque"
UID      = "sa"            # usado apenas se USE_WINDOWS_AUTH = False
PWD      = ""              # usado apenas se USE_WINDOWS_AUTH = False

def get_db():
    if USE_WINDOWS_AUTH:
        conn_str = (
            f"DRIVER={{ODBC Driver 18 for SQL Server}};"
            f"SERVER={SERVER};"
            f"DATABASE={DATABASE};"
            f"Trusted_Connection=yes;"
            f"TrustServerCertificate=yes;"
        )
    else:
        conn_str = (
            f"DRIVER={{ODBC Driver 18 for SQL Server}};"
            f"SERVER={SERVER};"
            f"DATABASE={DATABASE};"
            f"UID={UID};"
            f"PWD={PWD};"
            f"Trusted_Connection=yes;"
            f"TrustServerCertificate=yes;"
        )
    return pyodbc.connect(conn_str)


def rows_to_dicts(cursor):
    """Converte linhas do pyodbc em lista de dicionários."""
    cols = [col[0] for col in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


# ─── PRODUTOS ─────────────────────────────────────────────────────────────────

@app.route("/api/produtos", methods=["GET"])
def listar_produtos():
    db  = get_db()
    cur = db.cursor()
    cur.execute("""
        SELECT p.id_produto, p.nome, p.descricao,
               p.estoque_atual, p.estoque_minimo, p.preco_medio,
               g.nome_grupo
        FROM produto p
        LEFT JOIN grupo_produto g ON p.id_grupo = g.id_grupo
        ORDER BY p.id_produto
    """)
    rows = rows_to_dicts(cur)
    db.close()
    return jsonify(rows)


@app.route("/api/produtos", methods=["POST"])
def criar_produto():
    data = request.json
    db   = get_db()
    cur  = db.cursor()

    # resolve grupo pelo nome — cria se não existir
    cur.execute("SELECT id_grupo FROM grupo_produto WHERE nome_grupo = ?", (data["grupo"],))
    grupo = cur.fetchone()
    if grupo:
        id_grupo = grupo[0]
    else:
        cur.execute("INSERT INTO grupo_produto (nome_grupo) VALUES (?)", (data["grupo"],))
        # SCOPE_IDENTITY() logo após o INSERT na mesma conexão/cursor
        cur.execute("SELECT CAST(SCOPE_IDENTITY() AS INT)")
        id_grupo = cur.fetchone()[0]

    cur.execute("""
        INSERT INTO produto (nome, descricao, id_grupo, estoque_atual, estoque_minimo, preco_medio)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        data["nome"], data.get("descricao", ""), id_grupo,
        data["estoque_atual"], data["estoque_minimo"], data["preco_medio"]
    ))
    cur.execute("SELECT CAST(SCOPE_IDENTITY() AS INT)")
    new_id = cur.fetchone()[0]

    db.commit()
    db.close()
    return jsonify({"id_produto": new_id, "mensagem": "Produto criado com sucesso"}), 201


@app.route("/api/produtos/<int:id_produto>", methods=["PUT"])
def editar_produto(id_produto):
    data = request.json
    db   = get_db()
    cur  = db.cursor()

    cur.execute("SELECT id_grupo FROM grupo_produto WHERE nome_grupo = ?", (data["grupo"],))
    grupo = cur.fetchone()
    if grupo:
        id_grupo = grupo[0]
    else:
        cur.execute("INSERT INTO grupo_produto (nome_grupo) VALUES (?)", (data["grupo"],))
        cur.execute("SELECT CAST(SCOPE_IDENTITY() AS INT)")
        id_grupo = cur.fetchone()[0]

    cur.execute("""
        UPDATE produto
        SET nome           = ?,
            descricao      = ?,
            id_grupo       = ?,
            estoque_atual  = ?,
            estoque_minimo = ?,
            preco_medio    = ?
        WHERE id_produto = ?
    """, (
        data["nome"], data.get("descricao", ""), id_grupo,
        data["estoque_atual"], data["estoque_minimo"], data["preco_medio"],
        id_produto
    ))
    db.commit()
    db.close()
    return jsonify({"mensagem": "Produto atualizado com sucesso"})


@app.route("/api/produtos/<int:id_produto>", methods=["DELETE"])
def deletar_produto(id_produto):
    db  = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM detalhe_compra     WHERE id_produto = ?", (id_produto,))
    cur.execute("DELETE FROM detalhe_consumidor WHERE id_produto = ?", (id_produto,))
    cur.execute("DELETE FROM movimento_estoque  WHERE id_produto = ?", (id_produto,))
    cur.execute("DELETE FROM produto_fornecedor WHERE id_produto = ?", (id_produto,))
    cur.execute("DELETE FROM produto            WHERE id_produto = ?", (id_produto,))
    db.commit()
    db.close()
    return jsonify({"mensagem": "Produto removido com sucesso"})


# ─── GRUPOS ───────────────────────────────────────────────────────────────────

@app.route("/api/grupos", methods=["GET"])
def listar_grupos():
    db  = get_db()
    cur = db.cursor()
    cur.execute("SELECT id_grupo, nome_grupo FROM grupo_produto ORDER BY nome_grupo")
    rows = rows_to_dicts(cur)
    db.close()
    return jsonify(rows)


# ─── MOVIMENTAÇÕES ────────────────────────────────────────────────────────────

@app.route("/api/movimentacoes", methods=["GET"])
def listar_movimentacoes():
    db  = get_db()
    cur = db.cursor()
    cur.execute("""
        SELECT m.id_movimento,
               p.nome AS produto,
               m.tipo_movimento,
               m.quantidade,
               m.referencia,
               FORMAT(m.data, 'dd/MM/yyyy HH:mm') AS data
        FROM movimento_estoque m
        JOIN produto p ON m.id_produto = p.id_produto
        ORDER BY m.id_movimento DESC
    """)
    rows = rows_to_dicts(cur)
    db.close()
    return jsonify(rows)


@app.route("/api/movimentacoes", methods=["POST"])
def registrar_movimentacao():
    data       = request.json
    id_produto = data["id_produto"]
    tipo       = data["tipo_movimento"].upper()   # ENTRADA ou SAIDA
    quantidade = int(data["quantidade"])
    referencia = data.get("referencia", "")

    db  = get_db()
    cur = db.cursor()

    cur.execute("SELECT estoque_atual, nome FROM produto WHERE id_produto = ?", (id_produto,))
    prod = cur.fetchone()

    if not prod:
        db.close()
        return jsonify({"erro": "Produto não encontrado"}), 404

    estoque_atual = prod[0]
    nome_prod     = prod[1]

    if tipo == "SAIDA" and quantidade > estoque_atual:
        db.close()
        return jsonify({"erro": f"Estoque insuficiente. Disponível: {estoque_atual} un."}), 400

    cur.execute("""
        INSERT INTO movimento_estoque (id_produto, data, tipo_movimento, quantidade, referencia)
        VALUES (?, GETDATE(), ?, ?, ?)
    """, (id_produto, tipo, quantidade, referencia))

    if tipo == "ENTRADA":
        cur.execute("""
            UPDATE produto SET estoque_atual = estoque_atual + ?
            WHERE id_produto = ?
        """, (quantidade, id_produto))
    else:
        cur.execute("""
            UPDATE produto SET estoque_atual = estoque_atual - ?
            WHERE id_produto = ?
        """, (quantidade, id_produto))

    db.commit()

    cur.execute("SELECT estoque_atual FROM produto WHERE id_produto = ?", (id_produto,))
    novo_estoque = cur.fetchone()[0]
    db.close()

    return jsonify({
        "mensagem":     f"Estoque de '{nome_prod}' atualizado.",
        "novo_estoque": novo_estoque
    }), 201


# ─── FORNECEDORES ─────────────────────────────────────────────────────────────

@app.route("/api/fornecedores", methods=["GET"])
def listar_fornecedores():
    db  = get_db()
    cur = db.cursor()
    cur.execute("SELECT id_fornecedor, nome_fr, telefone, email FROM fornecedor ORDER BY nome_fr")
    rows = rows_to_dicts(cur)
    db.close()
    return jsonify(rows)


# ─── COMPRAS ──────────────────────────────────────────────────────────────────

@app.route("/api/compras", methods=["GET"])
def listar_compras():
    db  = get_db()
    cur = db.cursor()
    cur.execute("""
        SELECT c.id_compra,
               f.nome_fr AS fornecedor,
               c.numero_nota,
               FORMAT(c.data_c, 'dd/MM/yyyy') AS data_c,
               c.total
        FROM compra c
        JOIN fornecedor f ON c.id_fornecedor = f.id_fornecedor
        ORDER BY c.id_compra DESC
    """)
    rows = rows_to_dicts(cur)
    db.close()
    return jsonify(rows)


# ─── MAIN ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 52)
    print("  Servidor Flask  →  http://localhost:5000")
    print(f"  Banco de dados  →  {DATABASE} @ {SERVER}")
    print("  Pressione CTRL+C para encerrar")
    print("=" * 52)
    app.run(debug=True, port=5000)
