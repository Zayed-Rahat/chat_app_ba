import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationAccessToken {
  static String? _token;

  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      // Get path from .env
      final path = dotenv.env['FIREBASE_SERVICE_ACCOUNT_PATH'];

      if (path == null) {
        return null;
      }

      // Load the JSON file
      final file = File(path);
      final jsonContent = json.decode(await file.readAsString());

      // Create credentials from file
      final credentials = ServiceAccountCredentials.fromJson(jsonContent);

      // Generate client
      final client = await clientViaServiceAccount(credentials, [
        fMessagingScope,
      ]);

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('Error generating access token: $e');
      return null;
    }
  }
}
