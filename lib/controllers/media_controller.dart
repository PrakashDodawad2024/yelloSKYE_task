import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yelloskye_task/models/media_item.dart';
import 'package:yelloskye_task/services/firestore_service.dart';
import 'package:yelloskye_task/services/storage_service.dart';
import 'package:yelloskye_task/services/auth_service.dart';

class MediaController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final StorageService _storageService = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();

  RxList<MediaItem> images = <MediaItem>[].obs;
  RxList<MediaItem> videos = <MediaItem>[].obs;
  var isLoadingMedia = true.obs;

  final ImagePicker _picker = ImagePicker();
  String? _currentProjectId;

  void loadMediaForProject(String projectId) {
    _currentProjectId = projectId;
    isLoadingMedia.value = true;
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.',
          snackPosition: SnackPosition.BOTTOM);
      isLoadingMedia.value = false;
      return;
    }

    _firestoreService.getMediaItemsForProject(projectId, userId).listen(
        (mediaList) {
      images.value =
          mediaList.where((item) => item.type == MediaType.image).toList();
      videos.value =
          mediaList.where((item) => item.type == MediaType.video).toList();
      isLoadingMedia.value = false;
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to load media: $error',
          snackPosition: SnackPosition.BOTTOM);
      isLoadingMedia.value = false;
    });
  }

  Future<void> pickAndUploadImage() async {
    if (_currentProjectId == null) {
      Get.snackbar('Error', 'No project selected.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Get.snackbar('Uploading', 'Uploading image...',
          showProgressIndicator: true, snackPosition: SnackPosition.BOTTOM);
      File file = File(pickedFile.path);
      String fileName = pickedFile.name;
      String path =
          'project_media/$userId/${_currentProjectId}/images/$fileName';

      String? downloadUrl = await _storageService.uploadFile(file, path);
      Get.back();

      if (downloadUrl != null) {
        final mediaItem = MediaItem(
          id: '',
          projectId: _currentProjectId!,
          userId: userId,
          url: downloadUrl,
          type: MediaType.image,
          fileName: fileName,
          uploadDate: DateTime.now(),
        );
        await _firestoreService.addMediaItem(mediaItem);
      }
    }
  }

  Future<void> pickAndUploadVideo() async {
    if (_currentProjectId == null) {
      Get.snackbar('Error', 'No project selected.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      Get.snackbar('Uploading', 'Uploading video...',
          showProgressIndicator: true, snackPosition: SnackPosition.BOTTOM);
      File file = File(pickedFile.path);
      String fileName = pickedFile.name;
      String path =
          'project_media/$userId/${_currentProjectId}/videos/$fileName';

      String? downloadUrl = await _storageService.uploadFile(file, path);
      Get.back();

      if (downloadUrl != null) {
        final mediaItem = MediaItem(
          id: '',
          projectId: _currentProjectId!,
          userId: userId,
          url: downloadUrl,
          type: MediaType.video,
          fileName: fileName,
          uploadDate: DateTime.now(),
        );
        await _firestoreService.addMediaItem(mediaItem);
      }
    }
  }

  Future<void> downloadMedia(MediaItem mediaItem) async {
    await _storageService.downloadFile(mediaItem.url, mediaItem.fileName);
  }

  Future<void> deleteMedia(MediaItem mediaItem) async {
    await _storageService.deleteFile(mediaItem.url);
    await _firestoreService.deleteMediaItem(mediaItem.id);
  }
}
