import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:naemansan/models/badge.dart';

class BadgePage extends StatefulWidget {
  const BadgePage({Key? key}) : super(key: key);

  @override
  _BadgePageState createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage> {
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

  Widget makeList(AsyncSnapshot<List<BadgeModel>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.data!.isNotEmpty) {
      print(snapshot.data);
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          var badge = snapshot.data![index];
          return ListTile(
            leading: const Icon(
              Icons.stars,
              color: Colors.black,
            ),
            title: Text(
              badge.badgeName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              ' ${badge.getDate}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      );
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Center(child: Text('획득한 뱃지가 없습니다'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<BadgeModel>?> badgeList = apiService.getProfileBadges();

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
          '뱃지',
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
              child: FutureBuilder<List<BadgeModel>?>(
                future: badgeList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<BadgeModel>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return makeList(snapshot);
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
