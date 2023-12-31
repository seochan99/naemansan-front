import 'package:flutter/material.dart';
import 'package:naemansan/screens/screen_index.dart';
import 'package:naemansan/screens/widgets/trail_public.dart';
import 'package:naemansan/models/traillist.dart';
//import 'package:naemansan/models/traildetailmodel.dart';
import 'package:naemansan/services/courses_api.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> _getCurrentLocation() async {
  LocationPermission permission;
  // 위치 권한 요청
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    // 권한이 거부되었을 때 또는 영구적으로 거부되었을 때
    throw Exception('위치 권한이 필요합니다.');
  }

  // 현재 위치 가져오기
  Position position = await Geolocator.getCurrentPosition();

  return position;
}

class Trail extends StatefulWidget {
  const Trail({Key? key}) : super(key: key);

  @override
  _TrailState createState() => _TrailState();
}

class _TrailState extends State<Trail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TrailApiService TrailapiService; // ApiService 인스턴스 변수 추가
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    TrailapiService = TrailApiService();

    _getCurrentLocation().then((position) {
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ListView makeList(AsyncSnapshot<List<TraillistModel>?> snapshot) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data!.length,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      itemBuilder: (context, index) {
        var trail = snapshot.data![index];

        return TrailWidget(
          id: trail.id,
          title: trail.title,
          startpoint: trail.startLocationName,
          distance: trail.distance / 1000,
          CourseKeyWord: trail.tags,
          likeCnt: trail.likeCount,
          userCnt: trail.userCount,
          isLiked: trail.isLiked,
          created_date: trail.createdDate.toString(),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 위도와 경도 값 가져오기

    const int page = 0;
    const int num = 10000000;
    final Future<List<TraillistModel>?> RecommendTrail =
        TrailapiService.getRecommendedCourses(page, num);
    final Future<List<TraillistModel>?> NearestTrail =
        TrailapiService.getNearestCourses(
            page, num, _latitude, _longitude); //위도 경도 불러와야함
    final Future<List<TraillistModel>?> MostLikedTrail =
        TrailapiService.getMostLikedTrail(page, num);
    final Future<List<TraillistModel>?> MostUsedTrail =
        TrailapiService.getMostUsedTrail(page, num);
    final Future<List<TraillistModel>?> NewTrail =
        TrailapiService.getAllCourses(page, num);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined, //산책로 추가 시 버튼으로 사용
            color: Colors.black,
          ),
          onPressed: () {
            //arrow 아이콘 클릭 시 홈 화면으로 이동 (홈 화면에 화살표 생김)
            false;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => const IndexScreen(index: 0),
              ),
            );
          },
        ),
        titleSpacing: 0,
        title: const Text(
          '모두의 산책로',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),

        //오른쪽 여백 넣기
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black, //선택된 항목 나타내기
          tabs: const [
            Tab(
              child: Text('추천',
                  style: TextStyle(color: Colors.black, fontSize: 12.5)),
            ),
            Tab(
              child: Text('거리순',
                  style: TextStyle(color: Colors.black, fontSize: 12.5)),
            ),
            Tab(
              child: Text('인기순', // = 좋아요순
                  style: TextStyle(color: Colors.black, fontSize: 12.5)),
            ),
            Tab(
              child: Text('이용순',
                  style: TextStyle(color: Colors.black, fontSize: 12.5)),
            ),
            Tab(
              child: Text('최신순',
                  style: TextStyle(color: Colors.black, fontSize: 12.5)),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FutureBuilder(
              future: RecommendTrail,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Row(
                    children: [Expanded(child: makeList(snapshot))],
                  );
                }
                return const Center(
                  child: Text('추천 산책로가 없습니다'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FutureBuilder(
              future: NearestTrail,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [Expanded(child: makeList(snapshot))],
                  );
                }
                return const Center(
                  child: Text('가까운 위치에 산책로가 없습니다'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FutureBuilder(
              future: MostLikedTrail,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [Expanded(child: makeList(snapshot))],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FutureBuilder(
              future: MostUsedTrail,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [Expanded(child: makeList(snapshot))],
                  );
                }
                return const Center(
                  child: Text('사용된 산책로 정보가 없습니다'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FutureBuilder(
              future: NewTrail,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [Expanded(child: makeList(snapshot))],
                  );
                }
                return const Center(
                  child: Text('최근 등록된 산책로가 없습니다'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
