import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { image, video }

class MediaItem {
  final String id;
  final String projectId;
  final String userId;
  final String url;
  final MediaType type;
  final String fileName;
  final DateTime uploadDate;

  MediaItem({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.url,
    required this.type,
    required this.fileName,
    required this.uploadDate,
  });

  factory MediaItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MediaItem(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
      url: data['url'] ?? '',
      type: (data['type'] == 'image') ? MediaType.image : MediaType.video,
      fileName: data['fileName'] ?? '',
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'url': url,
      'type': type == MediaType.image ? 'image' : 'video',
      'fileName': fileName,
      'uploadDate': Timestamp.fromDate(uploadDate),
    };
  }
}
