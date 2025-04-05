// lessons.dart (updated)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gsccsg/api/apis.dart';
import 'package:gsccsg/screens/results_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../model/locals.dart';

class CreateLessonPage extends StatefulWidget {
  @override
  _CreateLessonPageState createState() => _CreateLessonPageState();
}

class _CreateLessonPageState extends State<CreateLessonPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? _selectedDifficulty;
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  Future<String> _uploadFileAndGetResponse(
      String title, String description, String category, String? difficulty) async {
    if (_selectedFile == null) throw Exception("No file selected");

    setState(() => _isUploading = true);

    try {
      var uri = Uri.parse("https://gsc-backend-959284675740.asia-south1.run.app/image-summary");
      var request = http.MultipartRequest("POST", uri);

      request.files.add(await http.MultipartFile.fromPath("image", _selectedFile!.path));
      request.fields["lesson_title"] = title;
      request.fields["description"] = description;
      request.fields["category"] = category;
      request.fields["difficulty"] = difficulty ?? "Beginner";

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String responseString = responseData.toString();

        await PreferencesHelper.saveLessonDetails(
          title: title,
          description: description,
          category: category,
          difficulty: difficulty ?? "Beginner",
          uploadResponse: responseString,
          filePath: _selectedFile!.path,
        );

        return responseString;
      } else {
        throw Exception("Upload failed: ${response.body}");
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'docx'],
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
        title: Text("Create Lesson", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                      Icon(Icons.file_present, size: 40, color: Colors.white70),
                      SizedBox(height: 5),
                      Text("Tap to select a file", style: GoogleFonts.poppins(color: Colors.white70)),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 40, color: Colors.green),
                      SizedBox(height: 5),
                      Text("Selected: $_fileName", style: GoogleFonts.poppins(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("Lesson Title"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration("Description"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _categoryController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("Category"),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.black,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: _inputDecoration("Select Difficulty Level"),
              items: ["Beginner", "Intermediate", "Advanced"]
                  .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value;
                });
              },
              hint: Text("Select Difficulty Level", style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_selectedFile != null) {
                  final responseFuture = _uploadFileAndGetResponse(
                    _titleController.text,
                    _descriptionController.text,
                    _categoryController.text,
                    _selectedDifficulty,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsPage(
                        user: APIs.me,
                        futureFileSummary: responseFuture,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a file first")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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