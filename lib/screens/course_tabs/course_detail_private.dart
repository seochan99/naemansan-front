// 개인 산책로 조회 - 내가 등록한 (나만의) 산책로 /course/individual/{id}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naemansan/models/traildetail_private.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:naemansan/screens/widgets/detail_map.dart';

class IndivCourseDetail extends StatefulWidget {
  final int id;

  const IndivCourseDetail({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _IndivCourseDetailState createState() => _IndivCourseDetailState();
}

class _IndivCourseDetailState extends State<IndivCourseDetail> {
  IndivTraildetailModel? trailDetail;

  String imageUrl = "";
  String userName = "";

  //void addComment(String comment) {
  //  setState(() {});
  //}

  @override
  void initState() {
    super.initState();
    fetchTrailDetail();
    fetchUserInfo();
  }

// 산책로 공개하기
  void erollmentCourse() async {
    ApiService apiService = ApiService();
    // 서버에 POST 요청을 보내는 로직을 추가해야 합니다.
    // selectedTags 리스트를 서버에 전송
  }

  //산책로 Delete
  Future<void> deleteTrail() async {
    ApiService apiService = ApiService();

    apiService.deleteIndiviudalCourse(widget.id);
  }

  Future<void> fetchTrailDetail() async {
    ApiService apiService = ApiService();
    Map<String, dynamic>? data;

    data = await apiService.getIndividualmentCourseDetailById(widget.id);

    if (data != null) {
      if (mounted) {
        setState(() {
          trailDetail = IndivTraildetailModel.fromJson(data!);
        });
      }
    }
  }

  Future<void> fetchUserInfo() async {
    ApiService apiService = ApiService();
    Map<String, dynamic>? userData = await apiService.getUserInfo();
    if (userData != null) {
      String filename = userData['image_path'];
      if (mounted) {
        setState(() {
          imageUrl = 'https://ossp.dcs-hyungjoon.com/image?uuid=$filename';
          userName = userData['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (trailDetail == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    }

    final double lengthInKm = trailDetail!.distance / 1000;
    final formattedDate = DateFormat("MM/dd").format(trailDetail!.createdDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(trailDetail!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPopupMenu(context);
            },
          ),
        ],
        elevation: 2,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              DetailMap(locations: trailDetail!.locations), //지도 표시
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trailDetail!.title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    children: const [],
                  ),
                ],
              ),
              Text(
                '생성 날짜: ${DateFormat('yy.MM.dd').format(trailDetail!.createdDate)}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '길이: ${lengthInKm.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 150),
              Row(
                children: [
                  const SizedBox(width: 30),
                  ElevatedButton(
                    // button white
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(300, 50),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/erollmentCourse',
                          arguments: {
                            "id": widget.id,
                            "title": trailDetail!.title,
                          });
                    },
                    child: const Text("공개하기",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  //삭제
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
                deleteTrail();
                goMyTab();
              },
            ),
          ],
        );
      },
    );
  }

  goMyTab() async {
    Navigator.pushNamed(context, '/mytab');
  }
}
