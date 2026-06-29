import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Logger _logger = Logger();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> init() async {
    // Background messages and topics are not supported identically on Web without service workers.
    // Wrap them in kIsWeb checks to prevent blank page crashes.
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('User granted permission');
    } else {
      _logger.w('User declined or has not accepted permission');
    }

    if (!kIsWeb) {
      // Subscribe to all users topic
      await _firebaseMessaging.subscribeToTopic('company_invoices');
      _logger.i('Subscribed to topic: company_invoices');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Got a message whilst in the foreground!');
      _logger.i('Message data: ${message.data}');

      if (message.notification != null) {
        _logger.i('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('A new onMessageOpenedApp event was published!');
      _handleInteraction(message);
    });

    // Check if app was opened via notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleInteraction(initialMessage);
    }
  }

  void _handleInteraction(RemoteMessage message) {
    if (message.data['type'] == 'invoice') {
      final invoiceId = message.data['invoiceId'];
      if (invoiceId != null) {
        // Navigate to Invoice Detail Screen
        navigatorKey.currentState?.pushNamed(
          '/invoice-detail',
          arguments: invoiceId,
        );
      }
    }
  }

  // Client-side generic broadcast (Requires setting up HTTP v1 API OAuth, which is complex client side)
  // For simplicity without a backend, we can trigger this if we have a legacy server key, 
  // but HTTP v1 requires Service Account tokens.
  // We will assume a cloud function handles this, or we just rely on Firestore triggers.
  // For demonstration, here's a placeholder for how you'd call a backend endpoint to broadcast.
  Future<void> broadcastNewInvoice(String invoiceId, String invoiceNumber) async {
    // In a real app, send a POST request to YOUR server (Cloud Function)
    // which then uses the Firebase Admin SDK to send the FCM to topic 'company_invoices'
    _logger.i('Broadcasting new invoice $invoiceId to topic company_invoices via backend...');
    
    // Example HTTP call (pseudo-code):
    // await http.post(
    //   Uri.parse('https://us-central1-YOUR_PROJECT.cloudfunctions.net/sendPushNotification'),
    //   body: jsonEncode({
    //     'topic': 'company_invoices',
    //     'title': 'New Bill Generated',
    //     'body': 'Invoice $invoiceNumber has been created.',
    //     'data': {'type': 'invoice', 'invoiceId': invoiceId}
    //   })
    // );
  }
}
