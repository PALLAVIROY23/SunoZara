import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sunozara/api/storage.dart';

class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCVD1XqzHffLunH4cL0Cxh1Os55b0_o0Lk",
            appId: "1:960542920574:android:4d3bf3211f4c061ee76d2f",
            messagingSenderId: "960542920574",
            projectId: "sunozara-user-application",
            storageBucket: "sunozara-user-application.appspot.com"
        ));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in
    }

    return firebaseApp;
  }

  static Future<User?> signInWithFacebook({
    required BuildContext context,
  }) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
        return userCredential.user;
      } else if (loginResult.status == LoginStatus.cancelled) {
        Fluttertoast.showToast(msg: 'Login cancelled by user.');
      } else {
        Fluttertoast.showToast(msg: 'Login failed.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }

    return null;
  }

  static Future<User?> signInWithGoogle({
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(GoogleAuthProvider());

        user = userCredential.user;
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      try {
        final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          final UserCredential userCredential =
          await auth.signInWithCredential(credential);

          user = userCredential.user;
        } else {
          Fluttertoast.showToast(msg: 'Google sign-in was cancelled.');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content:
              'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content:
              'Error occurred while accessing credentials. Try again.',
            ),
          );
        } else if (e.code == 'network-request-failed') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'Network error. Please check your connection.',
            ),
          );
        } else {
          // Log any other errors for debugging
          print('FirebaseAuthException: ${e.code}, ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'Error occurred during sign-in: ${e.message}',
            ),
          );
        }
      } catch (e) {
        print("error");
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
    }

    return user;
  }


  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(content: 'Error signing out. Try again.'),
      );
    }
  }

}
