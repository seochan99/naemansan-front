// 이 파일 안 쓰는 건가?

class KeyWordBoxModel {
  final String tags;

  KeyWordBoxModel({
    required this.tags,
  });

  factory KeyWordBoxModel.fromJson(Map<String, dynamic> json) {
    return KeyWordBoxModel(
      tags: json['name'],
    );
  }
}
