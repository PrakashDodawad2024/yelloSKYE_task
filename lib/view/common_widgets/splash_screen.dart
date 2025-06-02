import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/controllers/auth_controller.dart';
import 'package:yelloskye_task/controllers/root_controller.dart';
import 'package:yelloskye_task/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Get.put(RootController());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(15),
                width: 450,
                height: 450,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Spacer(),
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: Image(
                            width: 250,
                            image: AssetImage("assets/projecticon.png"))),
                    SizedBox(height: 20),
                    Text(
                      "Project Manager App",
                      style: TextStyle(
                          fontSize: 24,
                          color: appbarcolor,
                          fontWeight: FontWeight.bold),
                    ),
                    Spacer()
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
