import 'dart:developer';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await _initializeFirebase();

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat BA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 19,
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // var result = await FlutterNotificationChannel().registerNotificationChannel(
  //   description: 'For Showing Message Notification',
  //   id: 'chats',
  //   importance: NotificationImportance.IMPORTANCE_HIGH,
  //   name: 'Chats',
  // );

  if (Platform.isAndroid) {
    try {
      var result = await FlutterNotificationChannel()
          .registerNotificationChannel(
            description: 'For Showing Message Notification',
            id: 'chats',
            importance: NotificationImportance.IMPORTANCE_HIGH,
            name: 'Chats',
          );
      log('\nNotification Channel Result: $result');
    } catch (e) {
      log('Error registering notification channel: $e');
    }
  } else {
    log('Skipping notification channel setup — not running on Android.');
  }

  // log('\nNotification Channel Result: $result');
}
