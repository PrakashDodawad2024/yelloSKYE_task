import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      Get.snackbar('Upload Failed',
          e.message ?? 'An unknown error occurred during upload.',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      Get.snackbar('Success', 'File deleted from storage.',
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseException catch (e) {
      Get.snackbar('Delete Failed',
          e.message ?? 'An unknown error occurred during deletion.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> downloadFile(String fileUrl, String fileName) async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Denied',
            'Storage permission is required to download files.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final Directory? appExternalDir = await getExternalStorageDirectory();
      if (appExternalDir == null) {
        Get.snackbar('Error', 'Could not find external storage directory.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final String savePath = '${appExternalDir.path}/Download/$fileName';
      final File file = File(savePath);

      Reference ref = _storage.refFromURL(fileUrl);
      await ref.writeToFile(file);

      Get.snackbar(
        'Download Complete',
        'File saved to: $savePath',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () async {
            if (await canLaunchUrl(Uri.file(savePath))) {
              await launchUrl(Uri.file(savePath));
            } else {
              Get.snackbar('Error', 'Could not open file.',
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: const Text('OPEN'),
        ),
      );
    } on FirebaseException catch (e) {
      Get.snackbar('Download Failed',
          e.message ?? 'An unknown error occurred during download.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
