import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificacionService {
  static Future<void> inicializar() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'clima_channel',
          channelName: 'Clima Notifications',
          channelDescription: 'Notificaciones del clima',
          defaultColor: const Color(0xFF2563EB),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
    );
  }

  static Future<void> mostrarNotificacion({
    required String titulo,
    required String mensaje,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'clima_channel',
        title: titulo,
        body: mensaje,
      ),
    );
  }
}