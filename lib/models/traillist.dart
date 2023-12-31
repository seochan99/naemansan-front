//trailmodel.dart
//산책로 목록으로 볼 때 사용하는 모델
class TraillistModel {
  final int id;
  final String title;
  final DateTime createdDate;
  final List<String> tags;
  final String startLocationName;
  final double distance;
  final int likeCount;
  final int userCount;
  final bool isLiked;

  TraillistModel({
    required this.id,
    required this.title,
    required this.createdDate,
    required this.tags,
    required this.startLocationName,
    required this.distance,
    required this.likeCount,
    required this.userCount,
    required this.isLiked,
  });

  factory TraillistModel.fromJson(Map<String, dynamic> json) {
    return TraillistModel(
      id: json['id'],
      title: json['title'],
      createdDate: DateTime.parse(json['created_date']),
      tags: List<String>.from(json['tags'].map((tag) => tag['name'])),
      startLocationName: json['start_location_name'],
      distance: json['distance'].toDouble(),
      likeCount: json['like_cnt'],
      userCount: json['using_unt'],
      isLiked: json['is_like'],
    );
  }
}
