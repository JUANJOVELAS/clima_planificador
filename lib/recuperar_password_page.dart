import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() =>
      _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState
    extends State<RecuperarPasswordPage> {
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
        headers: {
          "Content-Type": "application/json",
        },
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
        mensaje = "Error de conexión";
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
      ),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: esOscuro
                ? const Color(0xFF1E293B)
                : Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.email,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "Recuperar contraseña",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ingresa tu correo registrado.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: "Correo",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      cargando ? null : recuperar,
                  icon: cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    cargando
                        ? "Enviando..."
                        : "Enviar contraseña temporal",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                mensaje,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}