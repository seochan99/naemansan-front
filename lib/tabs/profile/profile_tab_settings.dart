import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isNotificationEnabled = true;
  late Future<Map<String, dynamic>?> user;
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    user = apiService.getUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserState();
    });
  }

  Future<void> logout() async {
    ApiService apiService = ApiService();

    // 서버 로그아웃 처리
    await apiService.serverLogout();

    //카카오 로그아웃 처리
    try {
      await UserApi.instance.logout();
    } catch (error) {}

    await storage.delete(key: 'login');
    await deleteTokens();

    goLogin();
  }

  checkUserState() async {
    userInfo = await storage.read(key: 'login');
    if (userInfo == null) {
      print('로그인 페이지로 이동');
      goLogin();
    } else {
      print('로그인 중');
    }
  }

  goLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  premium() {
    Navigator.pushNamed(context, '/premium');
  }

  @override
  Widget build(BuildContext context) {
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
          '설정',
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  // 스토어 연결
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '버전 정보',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '1.0.0', // 현재 버전 표시
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: InkWell(
                onTap: () {
                  // 고객센터 문의하기
                },
                child: Row(
                  children: const [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '문의하기',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: InkWell(
                onTap: () {
                  logout();
                },
                child: Row(
                  children: const [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '로그아웃',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: InkWell(
                onTap: () => _showDialog(context),
                child: Row(
                  children: const [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '내만산 탈퇴하기',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteTokens() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    print("삭제 진행함?");

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogged', false);
  }

  void _showDialog(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('탈퇴 시 모든 정보가 삭제됩니다.\n정말 탈퇴하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              '탈퇴',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              '취소',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await apiService.deleteUserInfo();
      Navigator.pushNamed(context, '/login');
    }
  }
}
