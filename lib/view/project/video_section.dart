import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yelloskye_task/controllers/media_controller.dart';
import 'package:yelloskye_task/models/media_item.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:yelloskye_task/utils/colors.dart';

class VideoSection extends StatelessWidget {
  final String projectId;
  final MediaController mediaController = Get.find<MediaController>();

  VideoSection({super.key, required this.projectId});

  void _showVideoPlayer(String videoUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: _VideoPlayerWidget(videoUrl: videoUrl),
      ),
      barrierDismissible: true,
    );
  }

  void _showMediaOptions(MediaItem mediaItem) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download Video'),
              onTap: () {
                Get.back();
                mediaController.downloadMedia(mediaItem);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Video',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmationDialog(mediaItem);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(MediaItem mediaItem) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Video'),
        content:
            Text('Are you sure you want to delete "${mediaItem.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              mediaController.deleteMedia(mediaItem);
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
    return Obx(() {
      if (mediaController.isLoadingMedia.value) {
        return const Center(
          child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
              )),
        );
      }
      if (mediaController.videos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No videos uploaded for this project.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: mediaController.pickAndUploadVideo,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Video'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      }
      return Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: mediaController.videos.length,
            itemBuilder: (context, index) {
              final videoItem = mediaController.videos[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill,
                      size: 40, color: mainColor),
                  title: Text(
                    videoItem.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      'Uploaded: ${videoItem.uploadDate.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showVideoPlayer(videoItem.url),
                  onLongPress: () => _showMediaOptions(videoItem),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: mediaController.pickAndUploadVideo,
              heroTag: 'uploadVideoFab',
              child: const Icon(Icons.video_call),
            ),
          ),
        ],
      );
    });
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: Chewie(
              controller: _chewieController!,
            ),
          )
        : const Center(
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                )),
          );
  }
}
