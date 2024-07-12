import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<Map<String, dynamic>> _messageStream =
      StreamController.broadcast();

  static Stream<Map<String, dynamic>> get messageStream =>
      _messageStream.stream;

  //app en primer plano
  static Future _onMessageHandler(RemoteMessage message) async {
    print('==== 🔔 NOTIFICACION PRIMER PLANO ====');
    final data = message.data;
    _messageStream.add(data);

  }

  //Segundo Plano
  static Future _backgroundHandler(RemoteMessage message) async {
    print('====  🔔 NOTIFICACION SEGUNDO PLANO ====');

    final data = message.data;
    _messageStream.add(data);

   
  }

  //app Cerrada
  static Future _onMessageOpenApp(RemoteMessage message) async {
    print('==== 🔔 NOTIFICACION APP CERRADA ====');

    final data = message.data;
    _messageStream.add(data);

    
  }

  static Future initializeApp() async {
    //push Notifications
    await Firebase.initializeApp();
    await requestPermission();

    token = await FirebaseMessaging.instance.getToken();
    print('==  TOKEN NOTIFICATIONS: $token ===');
    // prefs.idDevice = token ?? '';
    //Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }

  static closeStreams() {
    _messageStream.close();
  }

  static requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    print('User push notification status ${settings.authorizationStatus}');
  }
}
