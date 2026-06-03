import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CambiarPasswordPage extends StatefulWidget {
  final int usuarioId;

  const CambiarPasswordPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<CambiarPasswordPage> createState() =>
      _CambiarPasswordPageState();
}

class _CambiarPasswordPageState
    extends State<CambiarPasswordPage> {
  final nuevaController = TextEditingController();
  final confirmarController = TextEditingController();

  String mensaje = "";
  bool cargando = false;

  Future<void> cambiarPassword() async {
    setState(() {
      cargando = true;
      mensaje = "";
    });

    final url = Uri.parse(
      "https://clima-planificador.onrender.com/cambiar-password/${widget.usuarioId}",
    );

    try {
      final respuesta = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nueva": nuevaController.text,
          "confirmar": confirmarController.text,
        }),
      );

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        setState(() {
          mensaje =
              "Contraseña cambiada correctamente";
        });

        await Future.delayed(
          const Duration(seconds: 2),
        );

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
             context,
             "/",
             (route) => false,
          );
        }
      } else {
        setState(() {
          mensaje = datos["error"];
        });
      }
    } catch (e) {
      setState(() {
        mensaje = "Error de conexión";
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar contraseña"),
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
                Icons.lock_reset,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "Cambiar contraseña",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Debes cambiar tu contraseña temporal.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: nuevaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nueva contraseña",
                  prefixIcon:
                      const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmarController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText:
                      "Confirmar contraseña",
                  prefixIcon:
                      const Icon(Icons.lock_outline),
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
                      cargando ? null : cambiarPassword,
                  icon: cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    cargando
                        ? "Guardando..."
                        : "Cambiar contraseña",
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