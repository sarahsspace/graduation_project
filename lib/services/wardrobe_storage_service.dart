import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/wardrobe_image_model.dart';

class WardrobeStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a single image file to Firebase Storage & save metadata in Firestore
  Future<void> uploadWardrobeImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = _storage.ref().child('wardrobe_images/${user.uid}/$fileName.jpg');

    // Upload image
    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();

    // Create model
    final imageModel = WardrobeImageModel(
      imageUrl: downloadUrl,
      userId: user.uid,
      uploadedAt: DateTime.now(),
    );

    // Save metadata in Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe')
        .add(imageModel.toMap());
  }

  /// Fetch user's wardrobe image metadata
  Future<List<WardrobeImageModel>> fetchWardrobeImages() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe')
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WardrobeImageModel.fromMap(doc.data()))
        .toList();
  }
}
