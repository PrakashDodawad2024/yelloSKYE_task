import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String userId;
  final DateTime timestamp;
  final String status;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.timestamp,
    this.status = 'Planning',
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Planning',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? userId,
    DateTime? timestamp,
    String? status,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
