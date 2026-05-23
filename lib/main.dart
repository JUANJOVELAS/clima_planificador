import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'ubicaciones_page.dart';
import 'actividades_page.dart';
import 'dashboard_page.dart';
import 'pendientes_page.dart';
import 'pronostico_page.dart';
import 'perfil_page.dart';
import 'recuperar_password_page.dart';
import 'cambiar_password_page.dart';
import 'registro_page.dart';
import 'mapa_page.dart';
import 'calendario_page.dart';
import 'notificacion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService.inicializar();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool modoOscuro = false;

  void cambiarTema(bool valor) {
    setState(() {
      modoOscuro = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Clima Planificador",
      themeMode: modoOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: LoginPage(
        modoOscuro: modoOscuro,
        cambiarTema: cambiarTema,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final bool modoOscuro;
  final Function(bool) cambiarTema;

  const LoginPage({
    super.key,
    required this.modoOscuro,
    required this.cambiarTema,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarPassword = true;
  String mensaje = "";

  Future<void> login() async {
    final url = Uri.parse("https://clima-planificador.onrender.com/login");

    final respuesta = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correoController.text,
        "password": passwordController.text,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200) {
      if (datos["usuario"]["password_temporal"] == 1 ||
          datos["usuario"]["password_temporal"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CambiarPasswordPage(
              usuarioId: datos["usuario"]["id"],
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              nombre: datos["usuario"]["nombre"],
              usuarioId: datos["usuario"]["id"],
              modoOscuro: widget.modoOscuro,
              cambiarTema: widget.cambiarTema,
            ),
          ),
        );
      }
    } else {
      setState(() {
        mensaje = datos["error"];
      });
    }
  }

  InputDecoration inputDecoracion(String texto, IconData icono) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: texto,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: esOscuro ? const Color(0xFF1E293B) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: esOscuro
                ? [
                    const Color(0xFF020617),
                    const Color(0xFF0F172A),
                    const Color(0xFF1E3A8A),
                  ]
                : [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF2563EB),
                    const Color(0xFF38BDF8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 430,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: esOscuro
                    ? const Color(0xFF111827).withOpacity(0.96)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_queue,
                      size: 70,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Clima Planificador",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Organiza tus actividades según el clima",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: esOscuro ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextField(
                    controller: correoController,
                    decoration: inputDecoracion("Correo", Icons.email),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: passwordController,
                    obscureText: ocultarPassword == true,
                    decoration: inputDecoracion(
                      "Contraseña",
                      Icons.lock,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          ocultarPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            ocultarPassword = !ocultarPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Iniciar Sesión",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroPage(),
                        ),
                      );
                    },
                    child: const Text("¿No tienes cuenta? Regístrate"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RecuperarPasswordPage(),
                        ),
                      );
                    },
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: widget.modoOscuro,
                      onChanged: widget.cambiarTema,
                      title: const Text("Modo oscuro"),
                      secondary: const Icon(Icons.dark_mode),
                    ),
                  ),
                  if (mensaje.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String nombre;
  final int usuarioId;
  final bool modoOscuro;
  final Function(bool) cambiarTema;

  const HomePage({
    super.key,
    required this.nombre,
    required this.usuarioId,
    required this.modoOscuro,
    required this.cambiarTema,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String ubicacion = "Sin ubicación";
  String clima = "";
  String temperatura = "";
  String recomendacion = "";
  String climaEstado = "normal";

  double? latitud;
  double? longitud;

  Future<void> obtenerUbicacion() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();

    if (!servicioActivo) {
      setState(() {
        ubicacion = "Activá la ubicación";
      });
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied) {
      setState(() {
        ubicacion = "Permiso denegado";
      });
      return;
    }

    Position posicion = await Geolocator.getCurrentPosition();

    latitud = posicion.latitude;
    longitud = posicion.longitude;

    setState(() {
      ubicacion = "Latitud: $latitud\nLongitud: $longitud";
    });
  }

  Future<void> guardarUbicacion() async {
    if (latitud == null || longitud == null) {
      return;
    }

    final url = Uri.parse("https://clima-planificador.onrender.com/ubicaciones");

    final respuesta = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "usuario_id": widget.usuarioId,
        "nombre": "Mi ubicación",
        "descripcion": "Ubicación guardada desde Flutter",
        "latitud": latitud,
        "longitud": longitud,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(datos["mensaje"])),
    );
  }

  Future<void> guardarTemperatura() async {
    if (temperatura.isEmpty) {
      return;
    }

    double temp = double.parse(temperatura.replaceAll(" °C", ""));

    final url = Uri.parse("https://clima-planificador.onrender.com/temperaturas");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "usuario_id": widget.usuarioId,
        "temperatura": temp,
      }),
    );
  }

  Future<void> obtenerClima() async {
    if (latitud == null || longitud == null) {
      setState(() {
        clima = "Primero obtené la ubicación";
      });
      return;
    }

    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?latitude=$latitud&longitude=$longitud&current_weather=true",
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      setState(() {
        double temp = datos["current_weather"]["temperature"];
        double viento = datos["current_weather"]["windspeed"];
        int codigoClima = datos["current_weather"]["weathercode"];

        temperatura = "$temp °C";
        clima = "Viento: $viento km/h";

        if (codigoClima >= 61 && codigoClima <= 67) {
          recomendacion = "🌧️ Lluvia detectada.\nLleva paraguas.";
          climaEstado = "lluvia";
        } else if (temp <= 8) {
          recomendacion =
              "🥶 Mucho frío.\nIdeal para actividades interiores.";
          climaEstado = "frio";
        } else if (temp <= 15) {
          recomendacion = "🧥 Hace fresco.\nLleva abrigo si sales.";
          climaEstado = "frio";
        } else if (temp >= 30) {
          recomendacion = "☀️ Temperatura alta.\nMantente hidratado.";
          climaEstado = "soleado";
        } else if (viento >= 20) {
          recomendacion =
              "🌪️ Mucho viento.\nEvita actividades al aire libre.";
          climaEstado = "viento";
        } else {
          recomendacion = "✅ Excelente clima.\nBuen día para actividades.";
          climaEstado = "normal";
        }
      });

      guardarTemperatura();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recomendacion),
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          modoOscuro: widget.modoOscuro,
          cambiarTema: widget.cambiarTema,
        ),
      ),
    );
  }

  Widget menuItem(IconData icono, String texto, VoidCallback accion) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(texto),
      onTap: accion,
    );
  }

  Widget cardAccion(
    IconData icono,
    String titulo,
    String subtitulo,
    VoidCallback accion,
  ) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      color: esOscuro ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.15),
          child: Icon(icono, color: Colors.blue),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: accion,
      ),
    );
  }

  LinearGradient fondoClima() {
    if (climaEstado == "lluvia") {
      return const LinearGradient(
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E3A8A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (climaEstado == "frio") {
      return const LinearGradient(
        colors: [
          Color(0xFF1E40AF),
          Color(0xFF60A5FA),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (climaEstado == "soleado") {
      return const LinearGradient(
        colors: [
          Color(0xFFF59E0B),
          Color(0xFFF97316),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (climaEstado == "viento") {
      return const LinearGradient(
        colors: [
          Color(0xFF64748B),
          Color(0xFF38BDF8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [
        Color(0xFF2563EB),
        Color(0xFF38BDF8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData iconoEstadoClima() {
    if (climaEstado == "lluvia") {
      return Icons.water_drop;
    }

    if (climaEstado == "frio") {
      return Icons.ac_unit;
    }

    if (climaEstado == "soleado") {
      return Icons.wb_sunny;
    }

    if (climaEstado == "viento") {
      return Icons.air;
    }

    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF38BDF8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud, color: Colors.white, size: 50),
                  const SizedBox(height: 12),
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Clima Planificador",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: SwitchListTile(
                value: widget.modoOscuro,
                onChanged: widget.cambiarTema,
                title: const Text("Modo oscuro"),
                secondary: const Icon(
                  Icons.dark_mode,
                  color: Colors.blue,
                ),
              ),
            ),
            const Divider(),
            menuItem(Icons.person, "Perfil", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilPage(
                    usuarioId: widget.usuarioId,
                  ),
                ),
              );
            }),
            menuItem(Icons.location_on, "Ubicaciones", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UbicacionesPage(
                    usuarioId: widget.usuarioId,
                  ),
                ),
              );
            }),
            menuItem(Icons.map, "Mapa Real", () {
              if (latitud != null && longitud != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapaPage(
                      latitud: latitud!,
                      longitud: longitud!,
                    ),
                  ),
                );
              }
            }),
            menuItem(Icons.event, "Actividades", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActividadesPage(
                    usuarioId: widget.usuarioId,
                  ),
                ),
              );
            }),
            menuItem(Icons.calendar_today, "Calendario Visual", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarioPage(
                    usuarioId: widget.usuarioId,
                  ),
                ),
              );
            }),
            menuItem(Icons.bar_chart, "Dashboard Estadístico", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(
                    usuarioId: widget.usuarioId,
                  ),
                ),
              );
            }),
            menuItem(Icons.calendar_month, "Pronóstico 7 días", () {
              if (latitud != null && longitud != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PronosticoPage(
                      latitud: latitud!,
                      longitud: longitud!,
                    ),
                  ),
                );
              }
            }),
            menuItem(Icons.cloud, "Actividades Pendientes", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendientesPage(
                    usuarioId: widget.usuarioId,
                  ),
                ),
              );
            }),
            const Divider(),
            menuItem(Icons.logout, "Cerrar sesión", cerrarSesion),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Clima Planificador"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: fondoClima(),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    iconoEstadoClima(),
                    color: Colors.white,
                    size: 52,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Hola, ${widget.nombre}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Planifica tus actividades según el clima actual.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            cardAccion(
              Icons.my_location,
              "Obtener ubicación",
              ubicacion,
              obtenerUbicacion,
            ),
            cardAccion(
              Icons.save,
              "Guardar ubicación",
              "Guarda tus coordenadas actuales en MySQL",
              guardarUbicacion,
            ),
            cardAccion(
              Icons.cloud_queue,
              "Obtener clima",
              "Consulta temperatura y viento en tiempo real",
              obtenerClima,
            ),
            const SizedBox(height: 20),
            if (temperatura.isNotEmpty || clima.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: fondoClima(),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      iconoEstadoClima(),
                      size: 55,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Temperatura: $temperatura",
                      style: const TextStyle(
                        fontSize: 21,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Clima: $clima",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      recomendacion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}