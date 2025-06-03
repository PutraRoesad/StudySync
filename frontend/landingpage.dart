import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://ypprpszogomrmpxgogvy.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM",
  );

  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Landingpage());
  }
}

class Landingpage extends StatelessWidget {
  const Landingpage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.5,
              width: screenWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E4),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: SizedBox(
                      child: Image.asset('assets/image/logo1.png'),
                    ),
                  ),
                  SizedBox(child: Image.asset('assets/image/logo2.png')),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: screenHeight * 0.08),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.08),
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Your #1 AI-powered scheduler app ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.05,
                                  letterSpacing: screenWidth * 0.05 * 0.10,
                                  fontFamily: 'custom',
                                ),
                              ),
                              TextSpan(
                                text:
                                    'designed to help university students manage their academic work.',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  letterSpacing: screenWidth * 0.05 * 0.10,
                                  fontFamily: 'custom',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        print('Test');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.12,
                          vertical: screenHeight * 0.03,
                        ),
                        backgroundColor: const Color(0x99FFB20F),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                          fontFamily: 'custom',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
