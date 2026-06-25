import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parkcheck/widgets/auth_gate.dart';
import 'package:parkcheck/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    
    if (!kIsWeb) {
      try {
        Stripe.publishableKey = 'pk_test_51SZtQM6TqOz44N4yRz4j6AiysVbnL3NjnCgm2zXtNSTlKYVaGkChUWPixVGmrKpEwNR5rG6A7S1GVnrd7O6boe5B004IwZL1aW';
        print('Stripe publishable key set successfully');
      } catch (e) {
        print('Failed to initialize Stripe: $e');
      }
    } else {
      print('Running on Web - Stripe initialization skipped to prevent crashes');
    }

    runApp(const MainApp());
  } catch (e) {
    print('Failed to initialize app: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize: $e', 
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkCheck Klient',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
      
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200], 
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450, 
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
