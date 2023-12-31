import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreenKakao extends StatefulWidget {
  final String loginUrl;

  const WebViewScreenKakao({Key? key, required this.loginUrl})
      : super(key: key);

  @override
  _WebViewScreenKakaoState createState() => _WebViewScreenKakaoState();
}

class _WebViewScreenKakaoState extends State<WebViewScreenKakao> {
  late WebViewController _webViewController;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장

  @override
  void initState() {
    super.initState();
    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');

    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo != null) {
      successLogin();
      // Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false);
    } else {}
  }

  successLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false);
  }

  failedLogin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: const Text('Failed to log in. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakao Login'),
        elevation: 2,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
      ),
      body: WebView(
        initialUrl: widget.loginUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.startsWith(
              'https://ossp.dcs-hyungjoon.com/auth/kakao/callback')) {
            // Callback URL reached, process the token
            String code = Uri.parse(request.url).queryParameters['code'] ?? '';
            // print("2️⃣ CODE는 : $code");

            // Token request
            var response = await http.get(
              Uri.parse(
                  "https://ossp.dcs-hyungjoon.com/auth/kakao/callback?code=$code"),
            );

            var parsedResponse = jsonDecode(response.body);
            // print("2️⃣CODE를 보낸 후 내가 받은 토큰은 : $parsedResponse");

            if (response.statusCode == 200) {
              // API response value
              String accessToken =
                  parsedResponse['data']['jwt']['access_token'];
              String refreshToken =
                  parsedResponse['data']['jwt']['refresh_token'];
              await saveTokens(accessToken, refreshToken);

              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLogged', true);

              await storage.write(
                key: 'login',
                value: accessToken,
              );

              successLogin();
            } else {
              failedLogin();
            }
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}

Future<void> saveTokens(String accessToken, String refreshToken) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'accessToken', value: accessToken);
  await storage.write(key: 'refreshToken', value: refreshToken);
}
