import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';
import '../model/adhd_image.dart';
import '../model/locals.dart';
import '../model/my_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  //For getting current user from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(){
    return firestore.collection('users').where('id',isEqualTo: user?.uid).snapshots();
  }

  //For getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    return firestore.collection('users').where('id',isNotEqualTo: user?.uid).snapshots();
  }

  // Initialize with a default user object to prevent errors
  static MyUser me = MyUser(
    image: '',
    name: '',
    disorder: '',
    id: '',
    email: '',
    age: '',
    gender: '',
    classType: '',
  );

  static User? get user => auth.currentUser;

  /// Check if user exists in Firestore
  static Future<bool> userExists() async {
    if (user == null) return false;
    return (await firestore.collection('users').doc(user!.uid).get()).exists;
  }

  /// Fetch current user info or create a new user if not found
  static Future<void> getSelfInfo() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        me = MyUser.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        await createUser();
        await getSelfInfo(); // Fetch again after creation
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  /// Create a new user document in Firestore
  static Future<void> createUser() async {
    if (user == null) return;

    final newUser = MyUser(
      image: user!.photoURL ?? '',
      name: user!.displayName ?? "Unknown",
      disorder: '',
      id: user!.uid,
      email: user!.email ?? '',
      age: '',
      gender: '',
      classType: '',
    );

    await firestore.collection('users').doc(user!.uid).set(newUser.toJson());

    // Assign `me` immediately after user creation
    me = newUser;
  }

  /// Update existing user information
  static Future<void> updateUserInfo() async {
    if (user == null) return;

    try {
      await firestore.collection('users').doc(user!.uid).update(me.toJson());
    } catch (e) {
      print("Error updating user info: $e");
    }
  }

  //For image generation for adhd people
  static Future<List<AdhdImage>> getAdhdImage(String lessonContent, String subject) async {
    final cachedImages = await PreferencesHelper.getCachedAdhdImage(lessonContent);
    if (cachedImages != null) return cachedImages;

    APIs.getSelfInfo();
    const uuid = Uuid();
    String randomId = uuid.v4();
    final response = await post(
      Uri.parse('https://gsc-backend-959284675740.asia-south1.run.app/story-mode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": me.id,
        "lessonId": randomId,
        "prompt": lessonContent,
        "subject": subject,
        "level": me.classType
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = (data['response'] as List)
          .map((item) => AdhdImage.fromJson(item))
          .toList();

      await PreferencesHelper.cacheAdhdImage(
        lessonContent: lessonContent,
        images: images,
      );
      return images;
    }
    throw Exception('Failed to generate ADHD images');
  }
}