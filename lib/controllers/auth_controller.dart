import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      User? user = await _authService.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null) {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      User? user = await _authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null) {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email to reset password.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(emailController.text.trim());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
