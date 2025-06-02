import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/utils/colors.dart';
import 'package:yelloskye_task/view/auth/auth_screen.dart';
import 'package:yelloskye_task/view/common_widgets/charts_screen.dart';
import 'package:yelloskye_task/view/common_widgets/map_screen.dart';
import 'package:yelloskye_task/view/common_widgets/splash_screen.dart';
import 'package:yelloskye_task/view/project/project_list_screen.dart';
import 'package:yelloskye_task/view/project/project_detail_screen.dart';
import 'package:yelloskye_task/services/auth_service.dart';
import 'package:yelloskye_task/services/firestore_service.dart';
import 'package:yelloskye_task/services/storage_service.dart';
import 'package:yelloskye_task/controllers/auth_controller.dart';
import 'package:yelloskye_task/controllers/project_controller.dart';
import 'package:yelloskye_task/controllers/media_controller.dart';
import 'package:yelloskye_task/controllers/root_controller.dart';
import 'package:yelloskye_task/controllers/map_controller.dart';
import 'package:yelloskye_task/controllers/charts_controller.dart';
import 'package:yelloskye_task/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  Get.put<AuthService>(AuthService());
  Get.put<FirestoreService>(FirestoreService());
  Get.put<StorageService>(StorageService());
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'Project Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: mainColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          buttonColor: mainColor,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/auth', page: () => const AuthScreen()),
        GetPage(
            name: '/projects',
            page: () => ProjectListScreen(),
            binding: ProjectBinding()),
        GetPage(name: '/map', page: () => MapScreen(), binding: MapBinding()),
        GetPage(
            name: '/charts',
            page: () => ChartsScreen(),
            binding: ChartsBinding()),
        GetPage(
            name: '/project_detail',
            page: () => ProjectDetailScreen(),
            binding: MediaBinding()),
      ],
    );
  }
}

//
class ProjectBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectController>(() => ProjectController());
  }
}

class MediaBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaController>(() => MediaController());
  }
}

class MapBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapController>(() => MapController());
  }
}

class ChartsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChartsController>(() => ChartsController());
  }
}
