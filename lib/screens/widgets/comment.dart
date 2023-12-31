import 'package:flutter/material.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:naemansan/screens/comment_edit.dart';
import 'package:naemansan/models/otheruser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 산책로 디테일 페이지에서 댓글 볼 때 사용
class CommentWidget extends StatefulWidget {
  final String content;
  final int user_id; //(댓글사용자 아이디
  final int course_id; //코스 아이디
  final int id; // 댓글 아이디
  final String user_name;
  final DateTime created_date;

  const CommentWidget({
    Key? key,
    required this.created_date,
    required this.id,
    required this.course_id,
    required this.content,
    required this.user_id,
    required this.user_name,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late Future<Map<String, dynamic>?> user;
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  late bool isWriter; // 댓글 작성자와 현재 사용자를 비교한 결과를 저장할 변수
  OtherUserModel? otherUser;
  late String imagePath;

// Fetch user info
  Future<void> fetchUserInfo() async {
    ApiService apiService = ApiService();
    Map<String, dynamic>? data, myData;

    myData = await apiService.getUserInfo();
    data = await apiService.getOtherUserProfile(widget.user_id);

    if (mounted) {
      setState(() {
        myData!['name'] == data!['name'] ? isWriter = true : isWriter = false;
        //otherUser = OtherUserModel.fromJson(data);
        //imagePath =
        //  'https://ossp.dcs-hyungjoon.com/image?uuid=${otherUser!.imagePath}';
        if (isWriter == true) {
          imagePath = myData['image_path'];
        } else {
          imagePath =
              'https://ossp.dcs-hyungjoon.com/image?uuid=${data['image_path']}';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    isWriter = false; // 초기값으로 false 설정
    imagePath = ''; //초기값
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
// 이미지 불러오기 (높이, 넓이 40 40 )
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(imagePath), // 이미지 표시
                    ),

                    const SizedBox(width: 10),
                    Text(
                      widget.user_name,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.content,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.created_date.toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isWriter)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showPopupMenu(context);
              },
            ),
        ],
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 현재 사용자인 경우에만 수정 옵션 표시
              ListTile(
                title: const Text('수정'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentEditpage(
                        id: widget.id,
                        content: widget.content,
                        course_id: widget.course_id,
                        user_id: widget.user_id,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('삭제'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                deleteComment();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteComment() async {
    ApiService apiService = ApiService();
    apiService.deleteComment(widget.course_id, widget.id);
  }
}
