import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:naemansan/screens/Login/webview_apple_screen.dart';
import 'package:naemansan/screens/Login/webview_google_screen.dart';
import 'package:naemansan/screens/Login/webview_kakao_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:http/http.dart' as http;

class LoginBtn extends StatelessWidget {
  final String whatsLogin;
  final String logo;
  final BuildContext routeContext;

  const LoginBtn(
      {super.key,
      required this.whatsLogin,
      required this.logo,
      required this.routeContext});

// 서버에 토큰 보내주고 user profile가져오기

  @override
  Widget build(BuildContext context) {
    void kakaoLogin(String loginUrl) {
      Navigator.push(
        routeContext, // 네비게이션을 위한 BuildContext
        MaterialPageRoute(
          builder: (context) => WebViewScreenKakao(
              loginUrl: loginUrl), // loginUrl 값을 전달하여 WebViewScreenKakao를 생성
        ),
      );
    }

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


    kakaoLoginUseSDK() async {
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
