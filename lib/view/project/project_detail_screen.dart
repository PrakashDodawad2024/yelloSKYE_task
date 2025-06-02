import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/models/project.dart';
import 'package:yelloskye_task/controllers/media_controller.dart';
import 'package:yelloskye_task/view/project/image_section.dart';
import 'package:yelloskye_task/view/project/video_section.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late Project project;
  late TabController _tabController;
  final MediaController mediaController = Get.find<MediaController>();

  @override
  void initState() {
    super.initState();

    project = Get.arguments as Project;
    _tabController = TabController(length: 2, vsync: this);

    mediaController.loadMediaForProject(project.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Images', icon: Icon(Icons.image)),
            Tab(text: 'Videos', icon: Icon(Icons.video_collection)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ImageSection(projectId: project.id),
          VideoSection(projectId: project.id),
        ],
      ),
    );
  }
}
