import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naemansan/models/otheruser.dart';
import 'package:naemansan/models/traildetail_public.dart';
import 'package:naemansan/screens/map/using_course_screen.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:naemansan/screens/widgets/detail_map.dart';
import 'package:naemansan/tabs/profile/overview/view_profile.dart';
import 'package:naemansan/screens/course_tabs/course_edit.dart';
import 'package:naemansan/models/comment.dart';
import 'package:naemansan/services/courses_api.dart';
import 'package:naemansan/screens/widgets/comment.dart';

class CourseDetail extends StatefulWidget {
  final int id;

  const CourseDetail({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _CourseDetailState createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  List<String> comments = [];
  TraildetailModel? trailDetail;
  OtherUserModel? otherUser;
  String imageUrl = "";
  bool isLikeNow = false;
  int likeCnt = 0;
  bool isWriter = false;
  final _commentController = TextEditingController();
  late TrailApiService TrailapiService;

  void addComment(String comment) {
    //산책로 댓글 등록
    if (mounted) {
      setState(() {
        comments.add(comment);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTrailDetail();
    TrailapiService = TrailApiService();
  }

  Future<void> fetchTrailDetail() async {
    ApiService apiService = ApiService();
    Map<String, dynamic>? data;

    data = await apiService
        .getEnrollmentCourseDetailById(widget.id); //등록한 (enrolled) 산책로

    if (data != null) {
      if (mounted) {
        setState(() {
          trailDetail = TraildetailModel.fromJson(data!);
          isLikeNow = trailDetail!.isLiked;
        });
        fetchWriterProfile();
      }
    }
  }

  // 상대프로필 조회
  Future<void> fetchWriterProfile() async {
    ApiService apiService = ApiService();
    Map<String, dynamic>? data, myData;
    myData = await apiService.getUserInfo();
    data = await apiService.getOtherUserProfile(trailDetail!.userid);

    if (mounted) {
      setState(() {
        myData!['name'] == data!['name'] ? isWriter = true : isWriter = false;
        otherUser = OtherUserModel.fromJson(data);
        imageUrl =
            'https://ossp.dcs-hyungjoon.com/image?uuid=${otherUser!.imagePath}';
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  ListView makeList(AsyncSnapshot<List<CommentModel>?> snapshot) {
    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data!.length,
      // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      itemBuilder: (context, index) {
        var trail = snapshot.data![index];

        return CommentWidget(
          created_date: trail.created_date,
          content: trail.content,
          user_id: trail.user_id, //댓글 작성자의 user id
          course_id: trail.course_id,
          id: trail.id,
          user_name: trail.user_name,
        ); //댓글 아이디
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 20),
    );
  }

  //댓글 관련
  //댓글 작성  comment POST보내기
  Future<void> postComment() async {
    ApiService apiService = ApiService();
    final comment = _commentController.text;

    bool data;
    Map<String, dynamic> commentData = {
      "content": comment,
    };

    data = await apiService.addComment(widget.id, commentData);

    if (data) {
      if (mounted) {
        setState(() {
          isWriter == true;
          // isLikeNow = true;
          // trailDetail!.likeCnt++;
        });
      }
    }
  }

  //댓글 수정  - 댓글 선택시 댓글 id
  //댓글 삭제

  // 좋아요 POST보내기
  Future<void> postLike() async {
    // print("POST");
    ApiService apiService = ApiService();
    bool data;

    data = await apiService.likeCourse(widget.id);
    if (data) {
      // print("좋아요 성공");
      if (mounted) {
        setState(() {
          isLikeNow = true;
          trailDetail!.likeCnt++;
        });
      }
    }
  }

  // 좋아요 Delete 보내기
  Future<void> deleteLike() async {
    ApiService apiService = ApiService();
    bool data;

    data = await apiService.unlikeCourse(widget.id);
    if (data) {
      if (mounted) {
        setState(() {
          isLikeNow = false;
          trailDetail!.likeCnt--;
        });
      }
    }
  }

  //산책로 Delete
  Future<void> deleteTrail() async {
    ApiService apiService = ApiService();

    apiService.deleteEnrollmentCourse(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<CommentModel>?> commentlist =
        TrailapiService.viewComment(widget.id, 0, 1000);
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
//!! 여기서부터 화면 !!!!!!!!!!!!!!!
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(trailDetail!.title),
        actions: isWriter // !! 버튼 부분
            ? [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showPopupMenu(context);
                  },
                ),
              ]
            : [],
        elevation: 2,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 상대방 프로필로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            //-------------------------------------------------------------------------------------------------------------
                            builder: (context) => ViewProfile(
                              userId: trailDetail!.userid,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(trailDetail!.username,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DetailMap(locations: trailDetail!.locations),
                ],
              ),

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
                    children: [
                      IconButton(
                        icon: Icon(
                          isLikeNow ? Icons.favorite : Icons.favorite_border,
                          color: isLikeNow ? Colors.red : null,
                        ),
                        onPressed: () => {
                          // 좋아요 POST보내기
                          isLikeNow ? deleteLike() : postLike(),
                        },
                      ),
                      Text(
                        '${trailDetail!.likeCnt}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
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

              const SizedBox(height: 16),
              Text(
                '시작위치: ${trailDetail!.startLocationName}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '길이: ${lengthInKm.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trailDetail!.introduction,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                '🎯 키워드',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: trailDetail!.tags.map((keyword) {
                  return Chip(
                    label: Text(
                      keyword,
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              // Row(
              //   children: [
              //     const SizedBox(width: 30),
              //     ElevatedButton(
              //       // button white
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.white,
              //         foregroundColor: Colors.black,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         minimumSize: const Size(300, 50),
              //       ),
              //       onPressed: () {},
              //       child: const Text("이용하기",
              //           style: TextStyle(
              //               fontSize: 15, fontWeight: FontWeight.w600)),
              //     ),
              //   ],
              // ),

              //작성된 댓글 get //댓글 클릭시 수정, 삭제 가능하게 (id전달)
              const SizedBox(height: 24),
              const Text(
                '댓글',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder(
                //!! 스크롤 문제
                future: commentlist,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Column(
                        children: const [
                          SizedBox(
                            height: 10,
                          ),
                          Text('작성된 댓글이 없습니다') //이용한 - 한강한바퀴
                        ],
                      );
                    }
                    return Row(
                      children: [Expanded(child: makeList(snapshot))],
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('댓글을 불러오는 중 오류가 발생했습니다'),
                    );
                  }
                  return const Center(
                    child: Text(
                      '작성된 댓글이 없습니다',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // Add your content here
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: '댓글',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      postComment();
                      _commentController.clear();
                      //addComment('New comment');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsingCourseScreen(
                locations: trailDetail!.locations,
              ),
            ),
          );
        },
        label: const Text(
          "이용하기",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                title: const Text('수정'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseEditpage(
                        id: trailDetail!.id,
                        title: trailDetail!.title,
                        introduction: trailDetail!.introduction,
                        keywords: trailDetail!.tags,
                      ),
                    ),
                  );
                  // 수정 페이지로 이동
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
