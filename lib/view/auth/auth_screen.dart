import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/utils/colors.dart';
import 'package:yelloskye_task/view/auth/login_screen.dart';
import 'package:yelloskye_task/view/auth/signup_screen.dart';
import 'package:yelloskye_task/controllers/auth_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: Image(
                      width: 250,
                      height: 250,
                      image: AssetImage('assets/projecticon.png'))),
              const SizedBox(height: 40),
              const Text(
                'Project Manager App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Get.to(() => SignupScreen());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: mainColor,
                  side: const BorderSide(color: mainColor),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
