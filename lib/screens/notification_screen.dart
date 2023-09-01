import 'package:flutter/material.dart';

import 'package:naemansan/models/notification.dart';
import 'package:naemansan/services/login_api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  Widget makeList(AsyncSnapshot<List<NotificationModel>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.data!.isNotEmpty) {
      return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var notification = snapshot.data![index];
            return ListTile(
              tileColor: notification.is_read_status
                  ? null
                  : const Color.fromARGB(133, 63, 174, 3),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    notification.title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 1,
                  ),
                  Text(
                    notification.content,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  Text(
                    '${notification.create_date}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                apiService.readNotification(notification.id);
                setState(() {});
                // 알림 읽기 ...
              },
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (BuildContext) => AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  await apiService
                                      .deleteNotification(notification.id);
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: const Center(
                                  child: Text('알림 삭제',
                                      style: TextStyle(color: Colors.black87)),
                                ))
                          ],
                        ));
              },
            );
          });
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            children: const [
              SizedBox(height: 170),
              Icon(Icons.notifications_none_rounded,
                  size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                '받은 알림이 없습니다',
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<NotificationModel>?> notificationList =
        apiService.getNotification(1, 100);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        title: const Text('알림'),
      ),
      body: Center(
          child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<NotificationModel>?>(
              future: notificationList,
              builder: (BuildContext context,
                  AsyncSnapshot<List<NotificationModel>?> snapshot) {
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
      )),
    );
  }
}
