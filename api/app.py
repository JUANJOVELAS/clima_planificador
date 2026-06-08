from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import mysql.connector
from dotenv import load_dotenv
import os
import random
import string
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import date, time, timedelta, datetime
import requests
import statistics

load_dotenv()

app = Flask(__name__)

CORS(
    app,
    resources={r"/*": {"origins": "*"}},
    supports_credentials=False
)


def obtener_conexion():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT")),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME"),
        ssl_disabled=False
    )

def convertir_fechas(objeto):
    for key, value in objeto.items():
        if isinstance(value, (date, time, timedelta, datetime)):
            objeto[key] = str(value)
    return objeto


@app.route("/")
def inicio():
    return jsonify({"mensaje": "API funcionando correctamente"})


@app.route("/registro", methods=["POST"])
def registro():
    datos = request.get_json()
    nombre = datos.get("nombre")
    correo = datos.get("correo")
    password = datos.get("password")

    if not nombre or not correo or not password:
        return jsonify({"error": "Todos los campos son obligatorios"}), 400

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            INSERT INTO usuarios (nombre, correo, password, password_temporal)
            VALUES (%s, %s, %s, FALSE)
            """,
            (nombre, correo, generate_password_hash(password))
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Usuario registrado correctamente"}), 201

    except mysql.connector.IntegrityError:
        return jsonify({"error": "El correo ya está registrado"}), 409

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/login", methods=["POST"])
def login():
    datos = request.get_json()
    correo = datos.get("correo")
    password = datos.get("password")

    if not correo or not password:
        return jsonify({"error": "Correo y contraseña son obligatorios"}), 400

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute("SELECT * FROM usuarios WHERE correo = %s", (correo,))
    usuario = cursor.fetchone()

    cursor.close()
    conexion.close()

    if usuario and check_password_hash(usuario["password"], password):
        return jsonify({
            "mensaje": "Login correcto",
            "usuario": {
                "id": usuario["id"],
                "nombre": usuario["nombre"],
                "correo": usuario["correo"],
                "password_temporal": usuario["password_temporal"]
            }
        }), 200

    return jsonify({"error": "Credenciales incorrectas"}), 401


@app.route("/perfil/<int:usuario_id>", methods=["GET"])
def obtener_perfil(usuario_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT id, nombre, correo, foto_perfil
            FROM usuarios
            WHERE id = %s
            """,
            (usuario_id,)
        )

        usuario = cursor.fetchone()

        cursor.close()
        conexion.close()

        return jsonify(usuario), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/perfil/<int:usuario_id>", methods=["PUT"])
def editar_perfil(usuario_id):
    datos = request.get_json()
    nombre = datos.get("nombre")
    correo = datos.get("correo")
    foto_perfil = datos.get("foto_perfil")

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        if foto_perfil is None:
            cursor.execute(
                """
                UPDATE usuarios
                SET nombre = %s, correo = %s
                WHERE id = %s
                """,
                (nombre, correo, usuario_id)
            )
        else:
            cursor.execute(
                """
                UPDATE usuarios
                SET nombre = %s, correo = %s, foto_perfil = %s
                WHERE id = %s
                """,
                (nombre, correo, foto_perfil, usuario_id)
            )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Perfil actualizado"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/recuperar-password", methods=["POST", "OPTIONS"])
def recuperar_password():
    if request.method == "OPTIONS":
        return jsonify({"ok": True}), 200

    datos = request.get_json()
    correo = datos.get("correo")

    caracteres = string.ascii_letters + string.digits
    password_temporal = "".join(random.choice(caracteres) for _ in range(8))

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            UPDATE usuarios
            SET password = %s, password_temporal = TRUE
            WHERE correo = %s
            """,
            (generate_password_hash(password_temporal), correo)
        )

        conexion.commit()

        if cursor.rowcount == 0:
            cursor.close()
            conexion.close()
            return jsonify({"error": "Correo no registrado"}), 404

        cursor.close()
        conexion.close()

        api_key = os.getenv("RESEND_API_KEY")

        respuesta_resend = requests.post(
            "https://api.resend.com/emails",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json={
                "from": "onboarding@resend.dev",
                "to": correo,
                "subject": "Recuperación de contraseña",
                "html": f"""
                <h2>Recuperación de contraseña</h2>
                <p>Tu contraseña temporal es:</p>
                <h1>{password_temporal}</h1>
                <p>Debes cambiarla al iniciar sesión.</p>
                """,
            },
        )

        if respuesta_resend.status_code not in [200, 201]:
            return jsonify({
                "error": "No se pudo enviar el correo",
                "detalle": respuesta_resend.text
            }), 500

        return jsonify({"mensaje": "Correo enviado correctamente"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
        
@app.route("/cambiar-password/<int:usuario_id>", methods=["PUT"])
def cambiar_password(usuario_id):
    datos = request.get_json()
    nueva = datos.get("nueva")
    confirmar = datos.get("confirmar")

    if nueva != confirmar:
        return jsonify({"error": "Las contraseñas no coinciden"}), 400

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            UPDATE usuarios
            SET password = %s, password_temporal = FALSE
            WHERE id = %s
            """,
            (generate_password_hash(nueva), usuario_id)
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Contraseña actualizada"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/ubicaciones", methods=["POST"])
def crear_ubicacion():
    datos = request.get_json()

    usuario_id = datos.get("usuario_id")
    nombre = datos.get("nombre")
    descripcion = datos.get("descripcion")
    latitud = datos.get("latitud")
    longitud = datos.get("longitud")

    if not usuario_id or not nombre or latitud is None or longitud is None:
        return jsonify({"error": "Faltan datos obligatorios"}), 400

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            INSERT INTO ubicaciones
            (usuario_id, nombre, descripcion, latitud, longitud)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (usuario_id, nombre, descripcion, latitud, longitud)
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Ubicación guardada correctamente"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/ubicaciones/<int:usuario_id>", methods=["GET"])
def listar_ubicaciones(usuario_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor(dictionary=True)

        cursor.execute(
            "SELECT * FROM ubicaciones WHERE usuario_id = %s",
            (usuario_id,)
        )

        ubicaciones = cursor.fetchall()

        cursor.close()
        conexion.close()

        return jsonify(ubicaciones), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500



@app.route("/ubicaciones/<int:id>", methods=["DELETE"])
def eliminar_ubicacion(id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            "DELETE FROM ubicaciones WHERE id = %s",
            (id,)
        )

        conexion.commit()

        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Ubicación eliminada"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/actividades", methods=["POST"])
def crear_actividad():
    datos = request.get_json()

    usuario_id = datos.get("usuario_id")
    ubicacion_id = datos.get("ubicacion_id")
    titulo = datos.get("titulo")
    descripcion = datos.get("descripcion")
    fecha = datos.get("fecha")
    hora = datos.get("hora")
    tipo = datos.get("tipo")

    if not usuario_id or not ubicacion_id or not titulo or not fecha or not hora or not tipo:
        return jsonify({"error": "Faltan datos obligatorios"}), 400

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            SELECT id
            FROM actividades
            WHERE usuario_id = %s
            AND fecha = %s
            AND hora = %s
            """
            ,
            (usuario_id, fecha, hora)
        )

        actividad_existente = cursor.fetchone()

        if actividad_existente:
            cursor.close()
            conexion.close()

            return jsonify({
                "error": "Ya existe una actividad programada en esa fecha y hora"
            }), 400

        cursor.execute(
            """
            INSERT INTO actividades
            (usuario_id, ubicacion_id, titulo, descripcion, fecha, hora, tipo)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                usuario_id,
                ubicacion_id,
                titulo,
                descripcion,
                fecha,
                hora,
                tipo
            )
        )

        conexion.commit()

        cursor.close()
        conexion.close()

        return jsonify({
            "mensaje": "Actividad creada correctamente"
        }), 201

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500

    


@app.route("/actividades/<int:usuario_id>", methods=["GET"])
def listar_actividades(usuario_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT actividades.*, ubicaciones.nombre AS nombre_ubicacion
            FROM actividades
            INNER JOIN ubicaciones ON actividades.ubicacion_id = ubicaciones.id
            WHERE actividades.usuario_id = %s
            ORDER BY actividades.fecha ASC, actividades.hora ASC
            """,
            (usuario_id,)
        )

        actividades = cursor.fetchall()
        actividades = [convertir_fechas(act) for act in actividades]

        cursor.close()
        conexion.close()

        return jsonify(actividades), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/actividades/<int:actividad_id>/completar", methods=["PUT"])
def completar_actividad(actividad_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            "UPDATE actividades SET estado = 'Completada' WHERE id = %s",
            (actividad_id,)
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Actividad completada"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/actividades/<int:actividad_id>", methods=["PUT"])
def editar_actividad(actividad_id):
    datos = request.get_json()

    titulo = datos.get("titulo")
    descripcion = datos.get("descripcion")
    fecha = datos.get("fecha")
    hora = datos.get("hora")
    tipo = datos.get("tipo")

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            UPDATE actividades
            SET titulo = %s,
                descripcion = %s,
                fecha = %s,
                hora = %s,
                tipo = %s
            WHERE id = %s
            """,
            (titulo, descripcion, fecha, hora, tipo, actividad_id)
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Actividad actualizada"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/actividades/<int:actividad_id>", methods=["DELETE"])
def eliminar_actividad(actividad_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            "DELETE FROM actividades WHERE id = %s",
            (actividad_id,)
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Actividad eliminada"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/temperaturas", methods=["POST"])
def guardar_temperatura():
    datos = request.get_json()

    usuario_id = datos.get("usuario_id")
    temperatura = datos.get("temperatura")

    if not usuario_id or temperatura is None:
        return jsonify({"error": "Faltan datos"}), 400

    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            INSERT INTO temperaturas (usuario_id, temperatura)
            VALUES (%s, %s)
            """,
            (usuario_id, temperatura)
        )

        conexion.commit()
        cursor.close()
        conexion.close()

        return jsonify({"mensaje": "Temperatura guardada"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/estadisticas/<int:usuario_id>", methods=["GET"])
def estadisticas(usuario_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor()

        cursor.execute(
            """
            SELECT temperatura
            FROM temperaturas
            WHERE usuario_id = %s
            ORDER BY fecha ASC
            """,
            (usuario_id,)
        )

        registros = cursor.fetchall()

        cursor.close()
        conexion.close()

        temperaturas = [float(t[0]) for t in registros]

        if len(temperaturas) == 0:
            return jsonify({
                "promedio": 0,
                "maxima": 0,
                "minima": 0,
                "mediana": 0,
                "moda": 0,
                "pendiente": 0,
                "tendencia": "Sin datos",
                "probabilidad_realizacion": 0
            })

        promedio = round(sum(temperaturas) / len(temperaturas), 2)
        maxima = max(temperaturas)
        minima = min(temperaturas)

        mediana = round(statistics.median(temperaturas), 2)

        try:
            moda = round(statistics.mode(temperaturas), 2)
        except:
            moda = "Sin moda"

        n = len(temperaturas)

        x = list(range(1, n + 1))
        y = temperaturas

        suma_x = sum(x)
        suma_y = sum(y)

        suma_xy = sum(xi * yi for xi, yi in zip(x, y))
        suma_x2 = sum(xi ** 2 for xi in x)

        denominador = (n * suma_x2) - (suma_x ** 2)

        if denominador != 0:
            m = ((n * suma_xy) - (suma_x * suma_y)) / denominador
        else:
            m = 0

        m = round(m, 3)

        if m > 0:
            tendencia = "Calentamiento"
        elif m < 0:
            tendencia = "Enfriamiento"
        else:
            tendencia = "Estable"

        p_lluvia = 0.50
        p_alerta_dada_lluvia = 0.70

        probabilidad_lluvia = p_lluvia * p_alerta_dada_lluvia
        probabilidad_realizacion = round(
            (1 - probabilidad_lluvia) * 100,
            2
        )

        return jsonify({
            "promedio": promedio,
            "maxima": maxima,
            "minima": minima,
            "mediana": mediana,
            "moda": moda,
            "pendiente": m,
            "tendencia": tendencia,
            "probabilidad_realizacion": probabilidad_realizacion
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/temperaturas/<int:usuario_id>", methods=["GET"])
def listar_temperaturas(usuario_id):
    try:
        conexion = obtener_conexion()
        cursor = conexion.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT id, temperatura, fecha
            FROM temperaturas
            WHERE usuario_id = %s
            ORDER BY fecha ASC
            """,
            (usuario_id,)
        )

        temperaturas = cursor.fetchall()
        temperaturas = [convertir_fechas(temp) for temp in temperaturas]

        cursor.close()
        conexion.close()

        return jsonify(temperaturas), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)