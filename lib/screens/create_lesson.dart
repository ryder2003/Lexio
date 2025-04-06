// lessons.dart (updated)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gsccsg/api/apis.dart';
import 'package:gsccsg/model/my_user.dart';
import 'package:gsccsg/screens/results_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import '../model/locals.dart';

class CreateLessonPage extends StatefulWidget {
  final MyUser user;
  const CreateLessonPage({super.key, required this.user});

  @override
  _CreateLessonPageState createState() => _CreateLessonPageState();
}

class _CreateLessonPageState extends State<CreateLessonPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  Future<String> _uploadFileAndGetResponse(
      String title, String subject) async {
    if (_selectedFile == null) throw Exception("No file selected");

    setState(() => _isUploading = true);

    try {
      // First API call to upload file and get initial response
      var uri = Uri.parse("https://gsc-backend-959284675740.asia-south1.run.app/image-summary");
      var request = http.MultipartRequest("POST", uri);

      request.files.add(await http.MultipartFile.fromPath("image", _selectedFile!.path));
      request.fields["lesson_title"] = title;
      request.fields["subject"] = subject;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String initialResponse = responseData['summary'].toString();

        // Second API call to process the initial response
        String finalResponse = await _processInitialResponse(initialResponse, title, subject);

        await PreferencesHelper.saveLessonDetails(
          userId: widget.user.id,
          title: title,
          subject: subject,
          uploadResponse: finalResponse,
          filePath: _selectedFile!.path,
        );

        return finalResponse;
      } else {
        throw Exception("Upload failed: ${response.body}");
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<String> _processInitialResponse(String initialResponse, String title, String subject) async {
    try {
      final response = await post(
        Uri.parse('https://gsc-backend-959284675740.asia-south1.run.app/prompt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "prompt": "Generate an explaination for a student in ${APIs.me.classType} based on the following summary:" + initialResponse,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['response'].toString();
      } else {
        throw Exception("Processing failed: ${response.body}");
      }
    } catch (e) {
      // If second API fails, return the initial response
      return initialResponse;
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'docx','jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back, color: Colors.white,)),
        title: Text("Create Lesson", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: _selectedFile == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_present, size: 40, color: Colors.white70),
                      const SizedBox(height: 5),
                      Text("Tap to select a file", style: GoogleFonts.poppins(color: Colors.white70)),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 40, color: Colors.green),
                      const SizedBox(height: 5),
                      Text("Selected: $_fileName", style: GoogleFonts.poppins(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Lesson Title"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration("Subject"),
            ),

            const SizedBox(height: 90),
            ElevatedButton(
              onPressed: () async {
                if (_selectedFile != null) {
                  final responseFuture = _uploadFileAndGetResponse(
                    _titleController.text,
                    _subjectController.text,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsPage(
                        user: APIs.me,
                        subject: _subjectController.text,
                        futureFileSummary: responseFuture,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a file first")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Upload File", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}