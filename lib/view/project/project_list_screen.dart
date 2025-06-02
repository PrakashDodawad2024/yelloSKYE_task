import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/controllers/auth_controller.dart';
import 'package:yelloskye_task/controllers/project_controller.dart';
import 'package:yelloskye_task/models/project.dart';
import 'package:yelloskye_task/utils/colors.dart';

class ProjectListScreen extends StatelessWidget {
  final ProjectController projectController = Get.find<ProjectController>();
  final AuthController authController = Get.find<AuthController>();

  ProjectListScreen({super.key});

  void _showProjectDialog({Project? project}) {
    final TextEditingController nameController =
        TextEditingController(text: project?.name ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: project?.description ?? '');
    final TextEditingController latitudeController =
        TextEditingController(text: project?.latitude.toString() ?? '12.9716');
    final TextEditingController longitudeController =
        TextEditingController(text: project?.longitude.toString() ?? '77.5946');

    Get.dialog(
      AlertDialog(
        title: Text(project == null ? 'Add New Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: latitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: longitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                Get.snackbar('Error', 'Name and Description cannot be empty.',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              final double? lat = double.tryParse(latitudeController.text);
              final double? lon = double.tryParse(longitudeController.text);

              if (lat == null || lon == null) {
                Get.snackbar(
                    'Error', 'Please enter valid latitude and longitude.',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              if (project == null) {
                projectController.addProject(
                  nameController.text,
                  descriptionController.text,
                  lat,
                  lon,
                );
              } else {
                projectController.updateProject(
                  project.copyWith(
                    name: nameController.text,
                    description: descriptionController.text,
                    latitude: lat,
                    longitude: lon,
                  ),
                );
              }
              Get.back();
            },
            child: Text(project == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Project project) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
            'Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              projectController.deleteProject(project.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            onTap: () {
              projectController.onInit();
            },
            child: const Text('My Projects')),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Get.toNamed('/map'),
            tooltip: 'View on Map',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Get.toNamed('/charts'),
            tooltip: 'View Charts',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: projectController.searchController,
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (projectController.isLoading.value) {
                return const Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: mainColor,
                      )),
                );
              }
              if (projectController.filteredProjects.isEmpty) {
                return const Center(
                  child: Text(
                    'No projects found. Add a new project!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: projectController.filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = projectController.filteredProjects[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        project.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          project.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: mainColor),
                            onPressed: () =>
                                _showProjectDialog(project: project),
                            tooltip: 'Edit Project',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(project),
                            tooltip: 'Delete Project',
                          ),
                        ],
                      ),
                      onTap: () {
                        Get.toNamed('/project_detail', arguments: project);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(),
        label: const Text('Add Project'),
        icon: const Icon(Icons.add),
        backgroundColor: mainColor,
      ),
    );
  }
}
