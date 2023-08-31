import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:naemansan/providers/location.dart';
import 'package:naemansan/screens/Home/select_tag_screen.dart';
import 'package:naemansan/screens/course_tabs/course_create_enrollment.dart';
import 'package:naemansan/screens/login_screen.dart';
import 'package:naemansan/screens/map/create_title_map.dart';
import 'package:naemansan/screens/screen_index.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:naemansan/services/login_api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  await dotenv.load(fileName: 'assets/config/.env');

  // firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // spalsh 시간 조절하기
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 로그인 여부 확인
  //final isLoggedin = prefs.getBool('isLoggedIn') ?? false;
  KakaoSdk.init(nativeAppKey: "05bf0ff2954bc573bba42b538554c4b5");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLogged = false;
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  late ApiService apiService = ApiService();

  @override
  void initState() {
    getLoginStatus();
    super.initState();
  }

  Future<void> getLoginStatus() async {
    userInfo = await storage.read(key: 'login');
    userInfo == null ? isLogged = false : isLogged = true;
    setState(() {});
  }

  Future<bool> isUserLoggedIn() async {
    const storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');
    String? deviceToken = await getDeviceToken();
    bool isIos = Theme.of(context).platform == TargetPlatform.iOS;

    if (deviceToken != null) {
      print('isUserLoggedIn - deviceToken!=null');
      await sendDeviceToken(deviceToken, isIos);
    }
    //return accessToken != null;
    return accessToken != null && refreshToken != null;
  }

  Future getDeviceToken() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await firebaseMessage.getToken();

    print("deviceToken: $deviceToken");
    return (deviceToken == null) ? "" : deviceToken;
  }

  Future<void> sendDeviceToken(String deviceToken, bool isIos) async {
    try {
      Map<String, dynamic> requestBody = {
        'device_token': deviceToken,
        'is_ios': isIos
      };

      final response =
          await apiService.putRequest('user/notification', requestBody);

      if (response.statusCode == 200) {
        print('sendDeviceToken - Success');
      } else {
        print('sendDeviceToken - Failure: ${response.statusCode}');
      }
    } catch (error) {
      print('sendDeviceToken - Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return MaterialApp(
            title: '내가 만든 산책로',
            home: const IndexScreen(index: 0), //islogged 당분간 체크 안하겠습니다

            routes: {
              '/index': (context) => const IndexScreen(index: 0),
              '/login': (context) => const LoginScreen(),
              '/allCourse': (context) => const IndexScreen(index: 1),
              "/createTitle": (context) => const CreateTitleScreen(),
              "/mytab": (context) => const IndexScreen(index: 2),
              "/erollmentCourse": (context) =>
                  const CreateErollmentCourseScreen(),
              "/tagSelect": (context, {arguments}) => const SelectTagScreen(
                    isEdit: false,
                  ),
            },
          );
        }
      },
    );
  }
}
