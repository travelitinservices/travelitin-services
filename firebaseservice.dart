import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<String?> getUserFirstName(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('intel')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs[0]['firstName'] : null;
  }

  Future<void> reportScam({
    required String location,
    required String content,
    required String userEmail,
  }) async {
    await FirebaseFirestore.instance.collection('scams').add({
      'location': location,
      'content': content,
      'userEmail': userEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}