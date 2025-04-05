import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsccsg/screens/Login.dart';
import 'package:gsccsg/screens/homepage.dart';
import 'package:gsccsg/screens/login_form.dart';
import 'package:gsccsg/screens/splash_screen.dart';
import 'firebase_options.dart';

//Global object for accessing Screen Size
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //To show splash screen to full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //For setting orientation to portrait mode only
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown,DeviceOrientation.portraitUp]).then((value){
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoogleSolutions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen()
    );
  }
}

_initializeFirebase() async{
  return await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
