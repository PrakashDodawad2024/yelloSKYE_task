import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/services/auth_service.dart';
import 'package:yelloskye_task/services/firestore_service.dart';

class RootController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  @override
  void onInit() {
    super.onInit();
    _checkInitialAuthState();

    _authService.authStateChanges.listen((User? user) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAuthStateChanged(user);
      });
    });
  }

  Future<void> _checkInitialAuthState() async {
    try {
      final User? initialUser = _authService.currentUser;

      if (initialUser != null) {
        _firestoreService.preloadSampleProjects(initialUser.uid);
        Get.offAllNamed('/projects');
      } else {
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print("Error during initial auth check: $e");
      Get.offAllNamed('/auth');
    } finally {
      print("Initial auth check complete.");
    }
  }

  void _handleAuthStateChanged(User? user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        if (Get.currentRoute != '/auth') {
          Get.offAllNamed('/auth');
        } else {}
      } else {
        if (Get.currentRoute != '/projects') {
          _firestoreService.preloadSampleProjects(user.uid);
          Get.offAllNamed('/projects');
        } else {}
      }
    });
  }
}
