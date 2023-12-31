import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:naemansan/models/follow.dart';
import 'package:naemansan/models/badge.dart';
import 'package:naemansan/models/notification.dart';

class ApiService {
  final String baseUrl = 'https://ossp.dcs-hyungjoon.com';

/*           TOKEN           */
  Future<Map<String, String?>> getTokens() async {
    const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final refreshToken = await storage.read(key: 'refreshToken');
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

/*           GET           */
  Future<http.Response> getRequest(String endpoint) async {
    try {
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];
      final refreshToken = tokens['refreshToken'];

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        print('GET 요청 성공');
      } else {
        print('GET 요청 실패 - 상태 코드: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('GET 요청 실패 - $e');
      return http.Response('Error', 500);
    }
  }

/*           POST           */
  Future<http.Response> postRequest(String endpoint, dynamic body) async {
    try {
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('POST 요청 실패 - $e');
      return http.Response('Error', 500);
    }
  }

/*           PUT           */
  Future<http.Response> putRequest(String endpoint, dynamic body) async {
    try {
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];
      final refreshToken = tokens['refreshToken'];

      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('PUT 요청 성공');
      } else {
        print('PUT 요청 실패 - 상태 코드: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('PUT 요청 실패 - $e');
      return http.Response('Error', 500);
    }
  }

  /*           DELETE           */
  Future<http.Response> deleteRequest(String endpoint) async {
    try {
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];
      final refreshToken = tokens['refreshToken'];
      print('accessToken: $accessToken');

      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('DELETE 요청 성공');
      } else {
        print('DELETE 요청 실패 - 상태 코드: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('DELETE 요청 실패 - $e');
      return http.Response('Error', 500);
    }
  }

  /*           유저 정보           */
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final response = await getRequest('user');
      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        // print(parsedResponse['data']);
        return parsedResponse['data'];
      } else {
        print(
            '유저 정보 가져오기 실패 상태코드: ${response.statusCode}, 헤더: ${response.headers}, 바디 : ${response.body}, request: ${response.request} ');
        return null;
      }
    } catch (e) {
      print('유저 정보 가져오기 실패 - $e');
      return null;
    }
  }

  // 상대 프로필 조회 GET 요청
  Future<Map<String, dynamic>?> getOtherUserProfile(int otherUserId) async {
    try {
      final response = await getRequest('user/$otherUserId');
      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        // print(parsedResponse['data']);
        return parsedResponse['data'];
      } else {
        print('유저 정보 가져오기 실패 - ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('유저 정보 가져오기 실패 - $e');
      return null;
    }
  }

  Future<String> getUserProfileImage(var path) async {
    try {
      final response = await getRequest('image/$path');
      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        // print(parsedResponse);
        return parsedResponse['data'];
      } else {
        print('유저 프로필 이미지 가져오기 실패 - ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('유저 프로필 이미지 가져오기 실패 - $e');
      return '';
    }
  }

  Future<http.Response> updateUserInfo(Map<String, dynamic> updatedInfo) async {
    final response = await putRequest('user', updatedInfo);
    return response;
  }

  //회원탈퇴
  Future<http.Response> deleteUserInfo() async {
    final response = await deleteRequest('user');
    print('탈퇴!');
    return response;
  }

  /*           COURSE           */
  Future<List<dynamic>?> getCourseList() async {
    final response = await getRequest('course');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  Future<List<dynamic>?> getTagBasedCourseList(String tagName) async {
    final response = await getRequest('course/list/main/tag?name=$tagName');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 위치 기반 산책로 조회
  Future<List<dynamic>?> getLocationBasedCourseList(
      double? latitude, double? longitude) async {
    final response = await getRequest(
        'course/list/main/location?latitude=$latitude&longitude=$longitude');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  Future<List<dynamic>?> getLocationBasedShapList(
      double? latitude, double? longitude) async {
    final response = await getRequest(
        'shop?page=0&num=10&latitude=$latitude&longitude=$longitude');
    print("??");
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      // print(parsedResponse['data']);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 본인 프로필 뱃지 조회 GET 요청
  Future<List<BadgeModel>?> getProfileBadges() async {
    try {
      final response = await getRequest('user/badge');
      if (response.statusCode == 200) {
        print('본인 프로필 뱃지 조회 GET 요청 성공');
        final responseData = json.decode(response.body);
        final badgeList = responseData['data'] as List<dynamic>;
        final List<BadgeModel> badges = badgeList.map((badgeData) {
          return BadgeModel.fromJson(badgeData);
        }).toList();
        return badges;
      } else {
        print('본인 프로필 뱃지 조회 GET 요청 실패 - 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('본인 프로필 뱃지 조회 GET 요청 실패 - $e');
    }
    return null;
  }

  // 사용자 댓글 조회 GET 요청
  Future<http.Response> getUserComments(int page, int num) async {
    try {
      final response = await getRequest('user/comment?page=$page&num=$num');
      if (response.statusCode == 200) {
        print('사용자 댓글 조회 GET 요청 성공');
      } else {
        print('사용자 댓글 조회 GET 요청 실패 - 상태 코드: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      print('사용자 댓글 조회 GET 요청 실패 - $e');
      return http.Response('Error', 500);
    }
  }

  // 팔로잉 목록 조회 GET 요청
  Future<List<FollowModel>?> getFollowingList(int page, int num) async {
    try {
      final response = await getRequest('user/following?page=$page&num=$num');
      if (response.statusCode == 200) {
        print('팔로잉 목록 조회 GET 요청 성공 ${response.body}');
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];
        List<FollowModel> followingList =
            data.map((item) => FollowModel.fromJson(item)).toList();
        return followingList;
      } else {
        print('팔로잉 목록 조회 GET 요청 실패 - 상태 코드: ${response.statusCode} ');
      }
    } catch (e) {
      print('팔로잉 목록 조회 GET 요청 실패 - $e');
    }
    return null;
  }

  // 팔로워 목록 조회 GET 요청 // !!!
  Future<List<FollowModel>?> getFollowerList(int page, int num) async {
    try {
      final response = await getRequest('user/follower?page=$page&num=$num');
      if (response.statusCode == 200) {
        print('팔로워 목록 조회 GET 요청 성공');
        print({response});
      } else {
        print('팔로워 목록 조회 GET 요청 실패 - 상태 코드: ${response.statusCode}');
      }
      // return response;
    } catch (e) {
      print('팔로워 목록 조회 GET 요청 실패 - $e');
      //return http.Response('Error', 500);
    }
    return null;
  }

// 본인 프로필 수정
  Future<http.Response> updateProfilePicture(File imageFile) async {
    try {
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];
      final uri = Uri.parse('https://ossp.dcs-hyungjoon.com/image/user');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';

      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: 'image.png', //jpg랑 png둘 다 받게 바꾸기
      );

      request.files.add(multipartFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        print('프로필 사진 수정 POST 요청 성공');
      } else {
        print('프로필 사진 수정 POST 요청 실패 - 상태 코드: ${response.statusCode}');
      }

      return http.Response.fromStream(response);
    } catch (e) {
      print('프로필 사진 수정 POST 요청 실패 - $e');
      return http.Response('Error', 0);
    }
  }

  Future<http.Response> getImage(String fileName) async {
    try {
      final accessToken = await getTokens();
      final response = await http.get(
        Uri.parse('image/$fileName'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        print('이미지 조회 GET 요청 성공');
      } else {
        print('이미지 조회 GET 요청 실패 - 상태 코드: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('이미지 조회 GET 요청 실패 - $e');
      return http.Response('Error', 500);
    }
  }

  /* ---------------- TAP 산책로 가져오기 ---------------- */
  // 등록된 전체 산책 코스
  Future<List<dynamic>?> getAllCourses(int page, int num) async {
    try {
      final response = await getRequest('course/list/all?page=$page&num=$num');

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        return parsedResponse['data'];
      } else {
        print('산책로 조회 GET 요청 실패 - 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('산책로 조회 GET 요청 실패 - $e');
      return null;
    }
  }

  // 좋아요수 전체 산책로 조회
  Future<List<dynamic>?> getLikeSortedCourses(int page, int num) async {
    try {
      final response = await getRequest('course/list/like?page=$page&num=$num');

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        return parsedResponse['data'];
      } else {
        print('좋아요순 전체 산책로 조회 GET 요청 실패 - 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('좋아요순 전체 산책로 조회 GET 요청 실패 - $e');
      return null;
    }
  }

  // 산책로 Tap 사용자순 전체 산책로 조회
  Future<List<dynamic>?> getUserSortedCourses(int page, int num) async {
    final response = await getRequest('course/list/using?page=$page&num=$num');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 산책로 Tap 거리순 전체 산책로 조회
  Future<List<dynamic>?> getDistanceSortedCourses(
      int page, int num, double latitude, double longitude) async {
    final response = await getRequest(
        'course/list/location?page=$page&num=$num&latitude=$latitude&longitude=$longitude');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

/* ---------------- TAP 나만의 산책로 가져오기 ---------------- */
  // 나만의 Tap 개인 산책로 조회
  Future<List<dynamic>?> getIndividualBasicCourses(int page, int num) async {
    final response =
        await getRequest('course/list/individual/basic?page=$page&num=$num');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 나만의 Tap 등록한 산책로 조회
  Future<List<dynamic>?> getIndividualEnrollmentCourses(
      int page, int num) async {
    final response = await getRequest(
        'course/list/individual/enrollment?page=$page&num=$num');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 나만의 Tap 좋아요한 산책로 조회
  Future<List<dynamic>?> getIndividualLikedCourses(int page, int num) async {
    final response =
        await getRequest('course/list/individual/like?page=$page&num=$num');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 나만의 Tap 사용한 산책로 조회
  Future<List<dynamic>?> getIndividualUsedCourses(int page, int num) async {
    final response =
        await getRequest('course/list/individual/using?page=$page&num=$num');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 나만의 Tap Tag 기준 산책로 조회
  Future<List<dynamic>?> getIndividualCoursesByTag(
      int page, int num, String tagName) async {
    final encodedTagName = Uri.encodeComponent(tagName);
    final response = await getRequest(
        'course/list/individual/tag?page=$page&num=$num&name=$encodedTagName');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  /* -------- 산책로 디테일 관련 기능 -------- */

  Future<Map<String, dynamic>?> getEnrollmentCourseDetailById(int id) async {
    try {
      final response = await getRequest('course/enrollment/$id');

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        return parsedResponse['data'];
      } else {
        print('GET 요청 실패 - 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('GET 요청 실패 - $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getIndividualmentCourseDetailById(
      int id) async {
    try {
      final response = await getRequest('course/individual/$id');

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        return parsedResponse['data'];
      } else {
        print('GET 요청 실패 - 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('GET 요청 실패 - $e');
      return null;
    }
  }

  /* -------- 개인 산책로 관련 기능 -------- */

  // 개인 산책로 삭제
  Future<bool> deleteIndividualCourse(int id) async {
    final response = await deleteRequest('course/individual/$id');
    return response.statusCode == 200;
  }

  /* -------- 전체 산책로 관련 기능 -------- */

  // 전체 산책로 등록
  Future<bool> enrollCourse(Map<String, dynamic> courseData) async {
    final response = await postRequest('course/enrollment', courseData);
    return response.statusCode == 200;
  }

  // 전체 산책로 조회
  Future<dynamic> getEnrollmentCourse(int id) async {
    final response = await getRequest('course/enrollment/$id');
    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      return parsedResponse['data'];
    } else {
      return null;
    }
  }

  // 전체 산책로 수정
  Future<bool> updateEnrollmentCourse(
      int id, Map<String, dynamic> updatedData) async {
    final response = await putRequest('course/enrollment/$id', updatedData);
    return response.statusCode == 200;
  }

  // 전체 산책로 삭제
  Future<bool> deleteEnrollmentCourse(int id) async {
    final response = await deleteRequest('course/enrollment/$id');
    return response.statusCode == 200;
  }

// 개인 산책로
  Future<bool> deleteIndiviudalCourse(int id) async {
    final response = await deleteRequest('course/individual/$id');
    print(response);
    return response.statusCode == 200;
  }

  /* -------- 사용한 산책로 등록 -------- */

// 사용한 산책로 등록
  Future<bool> registerUsedCourse(
      int id, Map<String, dynamic> courseData) async {
    final response = await postRequest('course/using/$id', courseData);
    return response.statusCode == 200;
  }

// 개인 산책로 등록
  Future<Map<String, dynamic>> registerIndividualCourse(
      Map<String, dynamic> courseData) async {
    final response = await postRequest('course/individual', courseData);
    final responseBody = jsonDecode(response.body);
    return responseBody;
  }

  Future<Map<String, dynamic>> registerErollmentCourse(
      Map<String, dynamic> courseData) async {
    final response = await postRequest('course/enrollment', courseData);
    final responseBody = jsonDecode(response.body);
    return responseBody;
  }

  // 개인 산책로 조회
  Future<dynamic> getIndividualCourse(int id) async {
    final response = await getRequest('course/individual/$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // 개인 태그 조회
  Future<dynamic> getMyTag() async {
    final response = await getRequest('user/tags');
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // 개인태그 POST
  Future<bool> postMyTag(Map<String, dynamic> selectedTags) async {
    print(selectedTags);
    final response = await postRequest('user/tags', selectedTags);
    return response.statusCode == 200;
  }

  Future<bool> putMyTag(Map<String, dynamic> selectedTags) async {
    print("변경되나?????");
    final response = await putRequest('user/tags', selectedTags);
    print("변경 ${response.body}는?");
    return response.statusCode == 200;
  }

  // 태그 리스트 뽑기
  Future<dynamic> getTagList() async {
    final response = await getRequest('course/tags');
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
/* -------- 팔로우 신청 -------- */

// 팔로우 신청
  Future<bool> followUser(int followingId) async {
    final response = await postRequest('follow/$followingId', {});
    return response.statusCode == 200;
  }

// 팔로워 리스트 가져오기
  Future<Map<String, dynamic>> getFollower() async {
    final response = await getRequest('user/following?page=0&num=10');

    // if (response.statusCode == 200) {
    return jsonDecode(response.body);
    // } else {
    // return null;
  }
/* -------- 팔로우 취소 -------- */

// 팔로우 취소
  Future<bool> unfollowUser(int followingId) async {
    final response = await deleteRequest('follow/$followingId');
    return response.statusCode == 200;
  }

// ------------------ 산책로 좋아요
  Future<bool> likeCourse(int courseId) async {
    final response = await postRequest('course/$courseId/like', {});
    return response.statusCode == 200;
  }

  Future<bool> unlikeCourse(int courseId) async {
    final response = await deleteRequest('course/$courseId/like');
    print(response);
    return response.statusCode == 200;
  }

// 로그아웃
  Future<bool> serverLogout() async {
    final response = await getRequest('auth/logout');
    // print("SERVER LOGOUT 결과 : ${response.body}");
    return response.statusCode == 200;
  }

//--------산책로 댓글 ----------------
// 카카오 post
  Future<Map<String, String>?> postKakaoLogin(token) async {
    try {
      //여기
      final response = await postRequest('auth/kakao', token);

      if (response.statusCode == 200) {
        print('카카오 post 성공 ${response.body}');

        // 서버 응답에서 토큰 추출
        final tokenMap = extractTokens(response.body);
        return tokenMap;
      } else {
        print(
            '카카오 post 실패 - 상태 코드: ${response.statusCode} ${response.request}');
        return null;
      }
    } catch (error) {
      print('카카오 post 실패 - 예외 발생: $error');
      return null;
    }
  }

  Map<String, String> extractTokens(String responseBody) {
    final jsonResponse = json.decode(responseBody);
    final jwtData = jsonResponse['data']['jwt'];

    final accessToken = jwtData['access_token'];
    final refreshToken = jwtData['refresh_token'];

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

// 작성한 댓글

  Future<bool> addComment(
      int courseId, Map<String, dynamic> commentData) async {
    print("add 할때 는 $commentData");
    final response = await postRequest('course/$courseId/comment', commentData);
    return response.statusCode == 200;
  }

  Future<void> changeComment(
      int courseId, int commentId, String commentData) async {
    print("수정 할때 는 $commentData");
    final response =
        await putRequest('course/$courseId/comment/$commentId', commentData);
  }

  Future<void> deleteComment(int courseId, int commentId) async {
    final response = await deleteRequest('course/$courseId/comment/$commentId');
  }

  /*알림 관련*/
  // 알림 조회
  Future<List<NotificationModel>?> getNotification(int page, int num) async {
    try {
      final response = await getRequest('notification?page=$page&num=$num');
      if (response.statusCode == 200) {
        print('알림 조회 GET 요청 성공');
        final responseData = json.decode(response.body);
        final notificationList = responseData['data'] as List<dynamic>;
        final List<NotificationModel> notification =
            notificationList.map((notificationdata) {
          return NotificationModel.fromJson(notificationdata);
        }).toList();
        return notification;
      } else {
        print('알림 조회 get 실패 - 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('알림 조회 GET 요청 실패 - $e');
    }
    return null;
  }

  // 알림 상태 수정
  Future<void> readNotification(int notificationId) async {
    final requestData = {
      "is_read_status": true,
    };

    final response = await putRequest(
      'notification/$notificationId',
      requestData,
    );

    if (response.statusCode == 200) {
      print('알림 상태 수정 PUT 요청 성공');
    } else {
      print('알림 상태 수정 PUT 요청 실패 - 상태 코드: ${response.statusCode}');
    }
  }

  // 알림 삭제
  Future<void> deleteNotification(int notificationId) async {
    final response = await deleteRequest('notification/$notificationId');
    if (response.statusCode == 200) {
      print('알림 삭제 Delete 요청 성공');
    } else {
      print('알림 삭제 delete 요청 실패 - 상태 코드: ${response.statusCode}');
    }
  }
}
