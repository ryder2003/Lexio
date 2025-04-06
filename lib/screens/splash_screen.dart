import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../main.dart';
import 'Login.dart';
import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );

      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint('\nUser: ${APIs.auth.currentUser}\n');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Static Bubbles
          Positioned(
            left: mq.width * 0.1,
            top: mq.height * 0.1,
            child: _buildBubble(60, Colors.purple.withOpacity(0.2)),
          ),
          Positioned(
            right: mq.width * 0.1,
            top: mq.height * 0.2,
            child: _buildBubble(40, Colors.lightBlue.withOpacity(0.2)),
          ),
          Positioned(
            left: mq.width * 0.2,
            bottom: mq.height * 0.2,
            child: _buildBubble(70, Colors.pinkAccent.withOpacity(0.15)),
          ),
          Positioned(
            right: mq.width * 0.1,
            bottom: mq.height * 0.1,
            child: _buildBubble(50, Colors.orangeAccent.withOpacity(0.15)),
          ),

          // App content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Lexio',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Making reading easier for all",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Designed with accessibility in mind",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    letterSpacing: 1.1,
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ This was the missing method!
  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
