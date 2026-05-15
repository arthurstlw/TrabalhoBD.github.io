from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# ─── CONFIGURAÇÃO ─────────────────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "user":     "root",
    "password": "Trabalho1456@",          # ← coloque sua senha do MySQL aqui (se tiver)
    "database": "estoque"
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG)


# ─── PRODUTOS ────────────────────────────────────────────────────────────────

@app.route("/api/produtos", methods=["GET"])
def listar_produtos():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT p.id_produto, p.nome, p.descricao,
               p.estoque_atual, p.estoque_minimo, p.preco_medio,
               g.nome_grupo
        FROM produto p
        LEFT JOIN grupo_produto g ON p.id_grupo = g.id_grupo
        ORDER BY p.id_produto
    """)
    rows = cur.fetchall()
    db.close()
    return jsonify(rows)


@app.route("/api/produtos", methods=["POST"])
def criar_produto():
    data = request.json
    db = get_db()
    cur = db.cursor()

    # resolve grupo pelo nome
    cur.execute("SELECT id_grupo FROM grupo_produto WHERE nome_grupo = %s", (data["grupo"],))
    grupo = cur.fetchone()
    if grupo:
        id_grupo = grupo[0]
    else:
        cur.execute("INSERT INTO grupo_produto (nome_grupo) VALUES (%s)", (data["grupo"],))
        db.commit()
        id_grupo = cur.lastrowid

    cur.execute("""
        INSERT INTO produto (nome, descricao, id_grupo, estoque_atual, estoque_minimo, preco_medio)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        data["nome"], data.get("descricao", ""), id_grupo,
        data["estoque_atual"], data["estoque_minimo"], data["preco_medio"]
    ))
    db.commit()
    new_id = cur.lastrowid
    db.close()
    return jsonify({"id_produto": new_id, "mensagem": "Produto criado com sucesso"}), 201


@app.route("/api/produtos/<int:id_produto>", methods=["PUT"])
def editar_produto(id_produto):
    data = request.json
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT id_grupo FROM grupo_produto WHERE nome_grupo = %s", (data["grupo"],))
    grupo = cur.fetchone()
    if grupo:
        id_grupo = grupo[0]
    else:
        cur.execute("INSERT INTO grupo_produto (nome_grupo) VALUES (%s)", (data["grupo"],))
        db.commit()
        id_grupo = cur.lastrowid

    cur.execute("""
        UPDATE produto
        SET nome=%s, descricao=%s, id_grupo=%s,
            estoque_atual=%s, estoque_minimo=%s, preco_medio=%s
        WHERE id_produto=%s
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
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM detalhe_compra     WHERE id_produto=%s", (id_produto,))
    cur.execute("DELETE FROM detalhe_consumidor WHERE id_produto=%s", (id_produto,))
    cur.execute("DELETE FROM movimento_estoque  WHERE id_produto=%s", (id_produto,))
    cur.execute("DELETE FROM produto_fornecedor WHERE id_produto=%s", (id_produto,))
    cur.execute("DELETE FROM produto            WHERE id_produto=%s", (id_produto,))
    db.commit()
    db.close()
    return jsonify({"mensagem": "Produto removido com sucesso"})


# ─── GRUPOS ───────────────────────────────────────────────────────────────────

@app.route("/api/grupos", methods=["GET"])
def listar_grupos():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT id_grupo, nome_grupo FROM grupo_produto ORDER BY nome_grupo")
    rows = cur.fetchall()
    db.close()
    return jsonify(rows)


# ─── MOVIMENTAÇÕES ────────────────────────────────────────────────────────────

@app.route("/api/movimentacoes", methods=["GET"])
def listar_movimentacoes():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT m.id_movimento, p.nome AS produto, m.tipo_movimento,
               m.quantidade, m.referencia,
               DATE_FORMAT(m.data, '%d/%m/%Y %H:%i') AS data
        FROM movimento_estoque m
        JOIN produto p ON m.id_produto = p.id_produto
        ORDER BY m.id_movimento DESC
    """)
    rows = cur.fetchall()
    db.close()
    return jsonify(rows)


@app.route("/api/movimentacoes", methods=["POST"])
def registrar_movimentacao():
    data       = request.json
    id_produto = data["id_produto"]
    tipo       = data["tipo_movimento"].upper()   # ENTRADA ou SAIDA
    quantidade = int(data["quantidade"])
    referencia = data.get("referencia", "")

    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT estoque_atual, nome FROM produto WHERE id_produto=%s", (id_produto,))
    prod = cur.fetchone()

    if not prod:
        db.close()
        return jsonify({"erro": "Produto não encontrado"}), 404

    if tipo == "SAIDA" and quantidade > prod["estoque_atual"]:
        db.close()
        return jsonify({"erro": f"Estoque insuficiente. Disponível: {prod['estoque_atual']} un."}), 400

    cur2 = db.cursor()
    cur2.execute("""
        INSERT INTO movimento_estoque (id_produto, data, tipo_movimento, quantidade, referencia)
        VALUES (%s, NOW(), %s, %s, %s)
    """, (id_produto, tipo, quantidade, referencia))

    if tipo == "ENTRADA":
        cur2.execute("UPDATE produto SET estoque_atual = estoque_atual + %s WHERE id_produto=%s",
                     (quantidade, id_produto))
    else:
        cur2.execute("UPDATE produto SET estoque_atual = estoque_atual - %s WHERE id_produto=%s",
                     (quantidade, id_produto))

    db.commit()

    # busca novo estoque para retornar ao front
    cur2.execute("SELECT estoque_atual FROM produto WHERE id_produto=%s", (id_produto,))
    novo = cur2.fetchone()
    db.close()
    return jsonify({
        "mensagem": f"Estoque de '{prod['nome']}' atualizado.",
        "novo_estoque": novo[0] if novo else None
    }), 201


# ─── FORNECEDORES ─────────────────────────────────────────────────────────────

@app.route("/api/fornecedores", methods=["GET"])
def listar_fornecedores():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT id_fornecedor, nome_fr, telefone, email FROM fornecedor ORDER BY nome_fr")
    rows = cur.fetchall()
    db.close()
    return jsonify(rows)


# ─── COMPRAS ──────────────────────────────────────────────────────────────────

@app.route("/api/compras", methods=["GET"])
def listar_compras():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT c.id_compra, f.nome_fr AS fornecedor, c.numero_nota,
               DATE_FORMAT(c.data_c, '%d/%m/%Y') AS data_c, c.total
        FROM compra c
        JOIN fornecedor f ON c.id_fornecedor = f.id_fornecedor
        ORDER BY c.id_compra DESC
    """)
    rows = cur.fetchall()
    db.close()
    return jsonify(rows)


# ─── MAIN ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 52)
    print("  Servidor Flask  →  http://localhost:5000")
    print("  Banco de dados  →  estoque @ localhost")
    print("  Pressione CTRL+C para encerrar")
    print("=" * 52)
    app.run(debug=True, port=5000)
