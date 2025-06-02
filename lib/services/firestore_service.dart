import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/models/project.dart';
import 'package:yelloskye_task/models/media_item.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Project>> getProjects(String userId) {
    return _db
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList());
  }

  Future<void> addProject(Project project) async {
    try {
      await _db.collection('projects').add(project.toFirestore());
      Get.snackbar('Success', 'Project added successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add project: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _db
          .collection('projects')
          .doc(project.id)
          .update(project.toFirestore());
      Get.snackbar('Success', 'Project updated successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update project: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final mediaSnapshot = await _db
          .collection('media')
          .where('projectId', isEqualTo: projectId)
          .get();
      for (var doc in mediaSnapshot.docs) {
        await doc.reference.delete();
      }

      await _db.collection('projects').doc(projectId).delete();
      Get.snackbar('Success', 'Project deleted successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete project: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addMediaItem(MediaItem mediaItem) async {
    try {
      await _db.collection('media').add(mediaItem.toFirestore());
      Get.snackbar('Success', 'Media uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add media item: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Stream<List<MediaItem>> getMediaItemsForProject(
      String projectId, String userId) {
    return _db
        .collection('media')
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: userId)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MediaItem.fromFirestore(doc)).toList());
  }

  Future<void> deleteMediaItem(String mediaId) async {
    try {
      await _db.collection('media').doc(mediaId).delete();
      Get.snackbar('Success', 'Media deleted successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete media item: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> preloadSampleProjects(String userId) async {
    final projectsCollection = _db.collection('projects');
    final existingProjects = await projectsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingProjects.docs.isEmpty) {
      List<Project> sampleProjects = [
        Project(
          id: '',
          name: 'Building A - Phase 1',
          description: 'Residential complex construction, foundation work.',
          latitude: 12.9716,
          longitude: 77.5946,
          userId: userId,
          timestamp: DateTime.now(),
        ),
        Project(
          id: '',
          name: 'Bridge Repair - Section C',
          description:
              'Maintenance and structural repair of old bridge section.',
          latitude: 13.0000,
          longitude: 77.6500,
          userId: userId,
          timestamp: DateTime.now(),
        ),
        Project(
          id: '',
          name: 'Park Renovation - Green Oasis',
          description: 'Landscaping and new playground installation.',
          latitude: 12.9165,
          longitude: 77.6101,
          userId: userId,
          timestamp: DateTime.now(),
        ),
      ];

      for (var project in sampleProjects) {
        await projectsCollection.add(project.toFirestore());
      }
    }
  }
}
