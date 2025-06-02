import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:latlong2/latlong.dart';
import 'package:yelloskye_task/controllers/map_controller.dart';
import 'package:yelloskye_task/models/project.dart';

class MapScreen extends StatelessWidget {
  final MapController mapController = Get.find<MapController>();

  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Locations'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (mapController.isLoading.value) {
          return const Center(
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                )),
          );
        }
        if (mapController.projects.isEmpty) {
          return const Center(
            child: Text(
              'No projects with location data found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        double avgLat = mapController.projects
                .map((p) => p.latitude)
                .reduce((a, b) => a + b) /
            mapController.projects.length;
        double avgLon = mapController.projects
                .map((p) => p.longitude)
                .reduce((a, b) => a + b) /
            mapController.projects.length;

        return FlutterMap(
          options: MapOptions(
            center: LatLng(avgLat, avgLon),
            zoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flexfilms',
            ),
            MarkerLayer(
              markers: mapController.projects.map((project) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(project.latitude, project.longitude),
                  builder: (ctx) => GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        project.name,
                        project.description,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 5),
                        mainButton: TextButton(
                          onPressed: () {
                            Get.back();
                            mapController.navigateToProjectDetail(project);
                          },
                          child: const Text('VIEW DETAILS'),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red[700],
                          size: 40.0,
                        ),
                        Flexible(
                          child: Text(
                            project.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }),
    );
  }
}
