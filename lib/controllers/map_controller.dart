import 'package:get/get.dart';
import 'package:yelloskye_task/models/project.dart';
import 'package:yelloskye_task/services/firestore_service.dart';
import 'package:yelloskye_task/services/auth_service.dart';

class MapController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  RxList<Project> projects = <Project>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _firestoreService.getProjects(user.uid).listen((projectList) {
          projects.value = projectList;
          isLoading.value = false;
        }, onError: (error) {
          Get.snackbar('Error', 'Failed to load projects for map: $error',
              snackPosition: SnackPosition.BOTTOM);
          isLoading.value = false;
        });
      } else {
        projects.value = [];
        isLoading.value = false;
      }
    });
  }

  void navigateToProjectDetail(Project project) {
    Get.toNamed('/project_detail', arguments: project);
  }
}
