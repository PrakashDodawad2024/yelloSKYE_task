import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/models/project.dart';
import 'package:yelloskye_task/services/firestore_service.dart';
import 'package:yelloskye_task/services/auth_service.dart';

class ProjectController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  RxList<Project> projects = <Project>[].obs;

  RxList<Project> filteredProjects = <Project>[].obs;

  var isLoading = true.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _firestoreService.getProjects(user.uid).listen((projectList) {
          projects.value = projectList;
          filterProjects(searchController.text);
          isLoading.value = false;
        }, onError: (error) {
          Get.snackbar('Error', 'Failed to load projects: $error',
              snackPosition: SnackPosition.BOTTOM);
          isLoading.value = false;
        });
      } else {
        projects.value = [];
        filteredProjects.value = [];
        isLoading.value = false;
      }
    });

    searchController.addListener(() {
      filterProjects(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void filterProjects(String query) {
    if (query.isEmpty) {
      filteredProjects.value = List.from(projects);
    } else {
      filteredProjects.value = projects
          .where((project) =>
              project.name.toLowerCase().contains(query.toLowerCase()) ||
              project.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> addProject(String name, String description, double latitude,
      double longitude) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final newProject = Project(
      id: '',
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      timestamp: DateTime.now(),
      status: 'Planning',
    );
    await _firestoreService.addProject(newProject);
  }

  Future<void> updateProject(Project project) async {
    await _firestoreService.updateProject(project);
  }

  Future<void> deleteProject(String projectId) async {
    await _firestoreService.deleteProject(projectId);
  }
}
