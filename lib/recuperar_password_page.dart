import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final correoController = TextEditingController();
  String mensaje = "";
  bool cargando = false;

  Future<void> recuperar() async {
    setState(() {
      cargando = true;
      mensaje = "";
    });

    final url = Uri.parse(
      "https://clima-planificador.onrender.com/recuperar-password",
    );

    try {
      final respuesta = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": correoController.text.trim(),
        }),
      );

      final datos = jsonDecode(respuesta.body);

      setState(() {
        if (respuesta.statusCode == 200) {
          mensaje = datos["mensaje"];
        } else {
          mensaje = datos["error"];
        }
      });
    } catch (e) {
      setState(() {
        mensaje = "Error de conexión con el servidor";
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 430,
          margin: const EdgeInsets.all(22),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_read,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 18),
              const Text(
                "Recuperar contraseña",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ingresa tu correo registrado y recibirás una contraseña temporal.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: "Correo registrado",
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: esOscuro ? const Color(0xFF0F172A) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: cargando ? null : recuperar,
                  icon: cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    cargando ? "Enviando..." : "Enviar contraseña temporal",
                  ),
                ),
              ),
              if (mensaje.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}