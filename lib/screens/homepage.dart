import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsccsg/model/locals.dart';
import 'package:gsccsg/screens/create_lesson.dart';
import 'package:gsccsg/screens/profile_page.dart';
import 'package:gsccsg/screens/results_page.dart';
import '../api/apis.dart';
import '../model/my_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _currentUserId;
  StreamSubscription? _userSubscription;

  double overallProgress = 0.0;
  List<Map<String, dynamic>> lessons = [];
  bool _isLoading = true;

  Future<void> _loadLessons(String userID) async {
    setState(() => _isLoading = true);
    try {
      var lessonList = await PreferencesHelper.getLessonList(APIs.me.id);
      setState(() {
        lessons = lessonList.map((lesson) => {
          "title": lesson["title"],
          "subject": lesson["subject"],
          "response": lesson["uploadResponse"],
          "progress": 0.0,
          "buttonText": "Continue"
        }).toList();

        if (lessons.isNotEmpty) {
          overallProgress = lessons.map((l) => l["progress"] as double).reduce((a, b) => a + b) / lessons.length;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    _userSubscription = APIs.getUserInfo().listen((userSnapshot) {
      if (userSnapshot.docs.isNotEmpty) {
        final user = MyUser.fromJson(userSnapshot.docs.first.data());
        if (user.id != _currentUserId) {
          setState(() => _currentUserId = user.id);
          _loadLessons(APIs.me.id); // Load lessons for this user
        }
      }
    });
    _loadLessons(APIs.me.id);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateLessonPage(user: APIs.me,)))
              .then((_) => _loadLessons(APIs.me.id));
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Text(
                      "Your Progress",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProgressBar(overallProgress),
                    const SizedBox(height: 24),
                    Text(
                      "Your Lessons",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : lessons.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "No lessons yet. Create your first lesson!",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                        : SizedBox(
                        height: 400,
                        child: SingleChildScrollView(child: _buildLessonCards(lessons))),
                    const SizedBox(height: 24),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder(
      stream: APIs.getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome Back,", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                  Text("Loading...", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const CircleAvatar(radius: 25, backgroundColor: Colors.grey),
            ],
          );
        }

        final data = snapshot.data?.docs;
        if (data == null || data.isEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome Back,", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                  Text("Guest", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const CircleAvatar(radius: 25, backgroundColor: Colors.grey),
            ],
          );
        }

        MyUser user = MyUser.fromJson(data.first.data());

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back,",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(user: APIs.me)));
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(user.image),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        minHeight: 12,
        value: value,
        backgroundColor: Colors.grey.shade300,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
      ),
    );
  }

  Widget _buildLessonCards(List<Map<String, dynamic>> lessons) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lesson["title"] ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              if (lesson["subject"] != null && lesson["subject"].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    lesson["subject"] ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: lesson["progress"],
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultsPage(
                          user: APIs.me,
                          file: lesson["response"],
                          subject: lesson["subject"],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    lesson["buttonText"] ?? "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}