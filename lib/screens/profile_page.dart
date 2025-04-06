import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gsccsg/screens/Login.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../model/my_user.dart';

class ProfilePage extends StatefulWidget {
  final MyUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int totalLessons = 15;
  final int completedLessons = 10;

  final List<String> achievements = [
    "Completed First Lesson",
    "Reached 50% Progress",
    "Mastered Writing Basics"
  ];

  Color getAccentColor() {
    switch (widget.user.disorder) {
      case "ADHD":
        return Colors.deepPurpleAccent;
      case "Dyslexia":
        return Colors.lightBlueAccent;
      case "Dyscalculia":
        return Colors.greenAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  double getFontSize() {
    switch (widget.user.disorder) {
      case "ADHD":
        return 24;
      case "Dyslexia":
        return 26;
      case "Dyscalculia":
        return 22;
      default:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back, color: Colors.white,)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: getAccentColor(), width: 4),
                boxShadow: [
                  BoxShadow(color: getAccentColor().withOpacity(0.5), blurRadius: 10, spreadRadius: 3),
                ],
              ),
              child: ClipOval(
                child: Image.network(widget.user.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Hello, ${widget.user.name}",
              style: GoogleFonts.poppins(fontSize: getFontSize(), fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Condition: ${widget.user.disorder}",
              style: GoogleFonts.poppins(fontSize: 18, color: getAccentColor()),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  Text("Lessons Completed: $completedLessons/$totalLessons",
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: completedLessons / totalLessons,
                    backgroundColor: Colors.white30,
                    color: getAccentColor(),
                    minHeight: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("Achievements", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      achievements[index],
                      style: GoogleFonts.poppins(fontSize: 16, color: getAccentColor()),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    Dialogs.showProgressLoader(context);
                    //sign out from the app
                    // await APIs.auth.signOut().then((value) async{
                    //   await GoogleSignIn().signOut().then((value){
                    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const Login()));
                    //
                    //   });
                    // });
                    // Sign out from Firebase Auth
                    await APIs.auth.signOut();

                    // Sign out from Google
                    await GoogleSignIn().signOut();

                    // Wait briefly to ensure auth state updates completely
                    await Future.delayed(const Duration(milliseconds: 500));

                    if (!mounted) return;

                    // Navigate to login screen with clear stack
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()));

                  }, // Empty functionality for now
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getAccentColor(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
