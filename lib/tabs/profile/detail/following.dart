import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:naemansan/models/follow.dart';

class Following extends StatefulWidget {
  const Following({Key? key}) : super(key: key);

  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  bool isNotificationEnabled = true;
  late Future<Map<String, dynamic>?> user;
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    user = apiService.getUserInfo();
  }

  ListView makeList(AsyncSnapshot<List<FollowModel>?> snapshot) {
    List<String> userNames =
        snapshot.data!.map((people) => people.user_name).toList();
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: userNames.length,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      itemBuilder: (context, index) {
        var people = snapshot.data![index];
        return Row(children: [Text(people.user_name)]);
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<FollowModel>?> FollowingList =
        apiService.getFollowingList(0, 1000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 2,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          '팔로잉',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<FollowModel>?>(
                future: FollowingList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<FollowModel>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return makeList(snapshot);
                  } else {
                    return const Text('팔로우가 없습니다');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
