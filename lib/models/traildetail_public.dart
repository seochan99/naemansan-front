class TraildetailModel {
  final int id;
  final int userid;
  final String username;
  final String title;
  final DateTime createdDate;
  final String introduction;
  final List<String> tags;
  final String startLocationName;
  final List<Map<String, dynamic>> locations;
  final double distance;
  // final int likeCnt;
  //final int userCount;
  final bool isLiked;

  int _likeCnt;

  int get likeCnt => _likeCnt;

  set likeCnt(int value) {
    _likeCnt = value;
  }

  TraildetailModel({
    required this.id,
    required this.userid,
    required this.username,
    required this.title,
    required this.createdDate,
    required this.introduction,
    required this.tags,
    required this.startLocationName,
    required this.locations,
    required this.distance,
    required int likeCnt,

    //required this.userCount,
    required this.isLiked,
  }) : _likeCnt = likeCnt;

  factory TraildetailModel.fromJson(Map<String, dynamic> json) {
    return TraildetailModel(
      id: json['id'],
      userid: json['user_id'],
      username: json['user_name'],
      title: json['title'],
      createdDate: DateTime.parse(json['created_date']),
      introduction: json['introduction'],
      tags: List<String>.from(json['tags'].map((tag) => tag['name'])),
      startLocationName: json['start_location_name'],
      likeCnt: json['like_cnt'],
      //userCount: json['using_unt'],

      locations:
          List<Map<String, dynamic>>.from(json['locations'].map((location) {
        return {
          'latitude': location['latitude'],
          'longitude': location['longitude']
        };
      })),
      distance: json['distance'].toDouble(),
      isLiked: json['is_like'],
    );
  }
}

/*
course/enrollment/{id}s
*/