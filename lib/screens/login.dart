import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsccsg/screens/homepage.dart';
import 'package:gsccsg/api/apis.dart';
import 'package:gsccsg/helper/dialogs.dart';
import 'package:gsccsg/screens/login_form.dart';
import 'dart:math' as math;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  AnimationController? _bubbleController;
  bool _isInitialized = false;


  @override
  void dispose() {
    _controller.dispose();
    _bubbleController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Bubble controller for animated bubbles
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Single controller for fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // mark as ready
    setState(() {
      _isInitialized = true;
    });
  }


  _handleGoogleButtonClick() {
    Dialogs.showProgressLoader(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomePage()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const UserFormPage()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('Error: $e');
      Dialogs.showSnackbar(
          context, 'No internet connection! Please check and try again...');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const SizedBox();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            // Use Positioned.fill to define bounds
            Positioned.fill(
              child: Stack(
                children: [
                  // Bubbles
                  _animatedBubble(
                    animation: _bubbleController!,
                    offsetY: 80,
                    offsetX: 30,
                    size: 60,
                    color: Colors.purple.withOpacity(0.2),
                  ),
                  _animatedBubble(
                    animation: _bubbleController!,
                    offsetY: 200,
                    offsetX: MediaQuery.of(context).size.width - 90,
                    size: 40,
                    color: Colors.lightBlue.withOpacity(0.2),
                  ),
                  _animatedBubble(
                    animation: _bubbleController!,
                    offsetY: MediaQuery.of(context).size.height - 200,
                    offsetX: 60,
                    size: 70,
                    color: Colors.pinkAccent.withOpacity(0.15),
                  ),
                  _animatedBubble(
                    animation: _bubbleController!,
                    offsetY: MediaQuery.of(context).size.height - 120,
                    offsetX: MediaQuery.of(context).size.width - 90,
                    size: 50,
                    color: Colors.orangeAccent.withOpacity(0.15),
                  ),
                ],
              ),
            ),

            // Main content overlaid on top
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  ScaleTransition(
                    scale: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
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
                  const SizedBox(height: 20,),
                  const Spacer(),
                  GestureDetector(
                    onTap: _handleGoogleButtonClick,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.lightBlueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                              color: Colors.deepPurpleAccent.withOpacity(0.3),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/images/google.svg',
                                height: 20, width: 20),
                            const SizedBox(width: 30),
                            const Text(
                              "Sign in with Google",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedBubble({
    required Animation<double> animation,
    required double offsetY,
    required double offsetX,
    required double size,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double floatY = offsetY + 10 * math.sin(animation.value * 2 * math.pi);
        return Positioned(
          top: floatY,
          left: offsetX,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
    );
  }


}
