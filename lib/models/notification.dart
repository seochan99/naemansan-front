class NotificationModel {
  final int id;
  final String title;
  final String content;
  final DateTime create_date;
  final bool is_read_status;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.create_date,
    required this.is_read_status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        create_date: json['create_date'],
        is_read_status: json['is_read_status']);
  }
}

/*
            "id": Integer,
            "title": String
            "content": String,
            "create_date": TimeStamp,
            "is_read_status": Boolean
 */