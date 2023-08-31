import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:naemansan/screens/Login/webview_apple_screen.dart';
import 'package:naemansan/screens/Login/webview_google_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:naemansan/screens/screen_index.dart';
import 'package:flutter/services.dart';

class LoginBtn extends StatelessWidget {
  final String whatsLogin;
  final String logo;
  final BuildContext routeContext;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  late var userInfo;
  ApiService apiService = ApiService();
  bool isLogged = false;

  LoginBtn(
      {super.key,
      required this.whatsLogin,
      required this.logo,
      required this.routeContext});

// 서버에 토큰 보내주고 user profile가져오기

  @override
  Widget build(BuildContext context) {
    //기기에 토큰 저장

    Future<void> saveTokens(String accessToken, String refreshToken) async {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);
      print('save Access Token: $accessToken');
      print('save Refresh Token: $refreshToken');
    }

    //로그인 성공 시
    /*
    successLogin() {
      Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false);
    }*/

    //유저 정보 확인

    Future<bool> getLoginStatus() async {
      userInfo = await storage.read(key: 'login');
      userInfo == null ? isLogged = false : isLogged = true;
      print("userInfo 가 있냐고 $userInfo");

      return userInfo != null;
    }

    // 저장된 토큰이 있는지 여부를 체크하는 함수
    /*    Future<bool> checkStoredTokens() async {
      const storage = FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'accessToken');
      String? refreshToken = await storage.read(key: 'refreshToken');
      print('stored Access Token: $accessToken');
      print('stored Refresh Token: $refreshToken');
      return accessToken != null && refreshToken != null;
    }
*/
    //구글 로그인
    void googleLogin(String loginUrl) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WebViewGoogle(loginUrl: loginUrl), // Pass the loginUrl value
        ),
      );
    }

    void appleLogin(String loginUrl) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WebViewApple(loginUrl: loginUrl), // Pass the loginUrl value
        ),
      );
    }

    //카카오 로그인 (로그인 버튼 -> 앱 진입)
    Future<void> kakaoLogin(OAuthToken token) async {
      //앞 부분 코드 수정 필요!
      String accessToken = token.accessToken;
      String refreshToken = token.refreshToken!;
      print('카카오 토큰 받은것 {$accessToken, $refreshToken}');
      await saveTokens(accessToken, refreshToken);

      final tokenMap = await apiService.postKakaoLogin(token); // post 요청 보내기
      print('tokenMap: $tokenMap');
      if (tokenMap != null) {
        // 서버에서 받은 토큰을 secureStorage에 저장
        await storage.write(key: 'accessToken', value: tokenMap['accessToken']);
        await storage.write(
            key: 'refreshToken', value: tokenMap['refreshToken']);

        // SharedPreferences를 사용하여 로그인 상태 저장
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLogged', true);

        // 페이지 이동
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const IndexScreen(
              index: 0,
            ),
          ),
        );
      } else {
        // 토큰을 받아오지 못한 경우 처리
        // 예: 에러 메시지를 표시하거나 다른 동작 수행
      }
    }

    //카카오 로그인 (로그인 화면 -> 로그인 버튼)
    Future<void> kakaoLoginUseSDK() async {
      late OAuthToken kakaotoken;
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          // 카카오톡으로 로그인 성공 처리
        } catch (error) {
          // 카카오톡으로 로그인 실패 처리

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount();
            // 카카오계정으로 로그인 성공 처리
          } catch (error) {
            // 카카오계정으로 로그인 실패 처리
          }
        }
      } else {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          // 카카오계정으로 로그인 성공 처리
          print("Token : ${token.accessToken}");
        } catch (error) {
          // 카카오계정으로 로그인 실패 처리
        }
      }
    }

    // login function
    void login(logo) async {
      var response = await http.get(
        Uri.parse("http://ossp.dcs-hyungjoon.com/auth/$logo"),
      );
      // print(response.body);
      var parsedResponse = jsonDecode(response.body);

      // print("1️⃣ login_button.dart 에서 response.body : $parsedResponse");

      String loginUrl = parsedResponse['data']['url'];
      // print("1️⃣ loginURL : $loginUrl");
      if (logo == 'kakao') {
        // kakaoLogin(loginUrl);
        kakaoLoginUseSDK();
      } else if (logo == 'google') {
        googleLogin(loginUrl);
      } else if (logo == 'apple') {
        print("apple login Parse Responds : $loginUrl");
        appleLogin(loginUrl);
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5F5F5),
        fixedSize: const Size(307, 50), // 버튼 크기
      ),
      onPressed: () {
        login(logo);
      },
      // 로고와 텍스트를 가로로 나열
      child: Row(
        // 로고와 텍스트를 가운데 정렬
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo/$logo.png',
            width: 18,
          ),
          const SizedBox(width: 10),
          Text(
            whatsLogin,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF49454F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
