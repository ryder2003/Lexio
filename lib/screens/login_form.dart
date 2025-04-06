import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/apis.dart';
import 'homepage.dart'; // Import HomePage for navigation

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? name, disorderType, gender, studentClass;
  int? age;

  final List<String> disorderTypes = ["ADHD", "Dyslexia", "Dyscalculia"];
  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> classes = ["Preschool", "Primary School", "Middle School", "High School", "Undergrad", "Postgraduate"];

  late AnimationController _controller;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _buttonScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onButtonPress() async {
    _controller.forward().then((_) => _controller.reverse());

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Update user object while preserving existing values
        APIs.me.name = name?.isNotEmpty == true ? name! : APIs.me.name;
        APIs.me.disorder = disorderType?.isNotEmpty == true ? disorderType! : APIs.me.disorder;
        APIs.me.age = age != null ? age.toString() : APIs.me.age;
        APIs.me.gender = gender?.isNotEmpty == true ? gender! : APIs.me.gender;
        APIs.me.classType = studentClass?.isNotEmpty == true ? studentClass! : APIs.me.classType;

        // Save the updated info
        await APIs.updateUserInfo();

        // Navigate to HomePage after successful update
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        }
      } catch (e) {
        print("Error updating user info: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 90,
        title: Text(
          "Add Information",
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildGlassTextField("Full Name", Icons.person, (value) => name = value),
                      const SizedBox(height: 20),
                      _buildGlassDropdown("Select Disorder Type", disorderTypes, Icons.healing, (value) => disorderType = value),
                      const SizedBox(height: 20),
                      _buildGlassTextField("Age", Icons.calendar_today, (value) => age = int.tryParse(value!), keyboardType: TextInputType.number),
                      const SizedBox(height: 20),
                      _buildGlassDropdown("Select Gender", genders, Icons.wc, (value) => gender = value),
                      const SizedBox(height: 20),
                      _buildGlassDropdown("Select Class", classes, Icons.school, (value) => studentClass = value),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _buttonScale,
                child: GestureDetector(
                  onTap: _onButtonPress,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.deepPurpleAccent, Colors.purple]),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
                    ),
                    child: Center(
                      child: Text("Submit", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(String label, IconData icon, Function(String?) onSave, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
      onSaved: onSave,
    );
  }

  Widget _buildGlassDropdown(String label, List<String> items, IconData icon, Function(String?) onSave) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey.shade900,
      decoration: _inputDecoration(label, icon),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)))).toList(),
      validator: (value) => value == null ? "Select $label" : null,
      onSaved: onSave,
      onChanged: (value) {},
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
