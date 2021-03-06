import 'dart:io';

import 'package:discussion_app/models/bug_model.dart';
import 'package:discussion_app/models/filterUser_model.dart';
import 'package:discussion_app/models/formVerif_model.dart';
import 'package:discussion_app/models/notif_model.dart';
import 'package:discussion_app/models/searchUser_model.dart';
import 'package:discussion_app/models/AllPosts_model.dart';
import 'package:discussion_app/models/allKey_model.dart';
import 'package:discussion_app/models/allUser_model.dart';
import 'package:discussion_app/models/feedback_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discussion_app/models/allPost_model.dart';
import 'package:discussion_app/models/detailProfil_model.dart';
import 'package:discussion_app/models/filterPost_model.dart';
import 'package:discussion_app/models/idPost_model.dart';
import 'package:discussion_app/models/searchPost_model.dart';
import 'package:discussion_app/providers/auth_provider.dart';
import 'package:discussion_app/utils/exceptions.dart';
import 'package:http/http.dart' as http;

class ApiService {
  AuthProvider authProvider;
  String token;
  String storageToken;
  String storageNama;

  ApiService(AuthProvider authProvider) {
    this.authProvider = authProvider;
    this.token = authProvider.token;
    _init();
  }

  Future _init() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storageToken = storage.getString('token');
    storageNama = storage.getString('name');
  }

  //* LOCAL HOST
  //final String api = 'http://192.168.43.47/api/v1';

  //* AZURE VPS
  final String api = 'http://138.91.32.37/api/v1';

  void validateResponseStatus(int status, int validStatus) {
    if (status == 401) {
      throw new AuthException("401", "Unauthorized");
    }

    if (status != validStatus) {
      throw new ApiException(status.toString(), 'Server down');
    }
  }

  //* NOTIFIKASI

  Future<Notif> getAllNotif() async {
    final url = "$api/notifall";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all notif');
    return notifFromJson(response.body);
  }

  Future<Notif> getAllNotifMore(String url) async {
    print(url);

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return notifFromJson(response.body);
  }

  Future<AllPost> getAllPost() async {
    final url = "$api/post";
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    print('token api : $token');
    print('token storage : $storageToken');

    return allPostFromJson(response.body);
  }

  Future<AllPosts> getAllPosts() async {
    final url = "$api/post";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all posts');
    return allPostsFromJson(response.body);
  }

  Future<AllPosts> getAllPostsMore(String url) async {
    print(url);

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return allPostsFromJson(response.body);
  }

  Future<IdPost> getIdPost(int id, String tokenProvider) async {
    final url = "$api/post/$id";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenProvider'};

    final response = await http.get(url, headers: headers);
    print(response.body);
    validateResponseStatus(response.statusCode, 200);
    print('sukses get id post');
    return idPostFromJson(response.body);
  }

  Future<bool> createPost(String title, String description, String kategori, File image, String tokenProvider) async {
    final url = '$api/post';
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['kategori'] = kategori;

    if (image != null) {
      var pic = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(pic);
    } else {}
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $tokenProvider';

    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
    validateResponseStatus(response.statusCode, 201);

    return true;
  }

  Future<bool> editPost(int id, String title, String description, String kategori, File image, String tokenProvider) async {
    final url = '$api/post/$id';
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['_method'] = 'PATCH';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['kategori'] = kategori;

    if (image != null) {
      var pic = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(pic);
    } else {}
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $tokenProvider';

    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
    print('token edit $tokenProvider');
    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  Future<bool> deletePost(int id, String tokenNew) async {
    final url = '$api/post/$id';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    Map<String, String> body = {'_method': 'DELETE'};

    final response = await http.post(url, headers: headers, body: body);

    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  Future<AllPosts> filterPost(String kategori) async {
    final url = '$api/post/filter';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    Map<String, String> body = {
      'kategori': '$kategori',
    };

    final response = await http.post(url, headers: headers, body: body);

    validateResponseStatus(response.statusCode, 200);

    return allPostsFromJson(response.body);
  }

  Future<AllPosts> getAllFilterPostsMore(String url, String kategori) async {
    print(url);

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    Map<String, String> body = {
      'kategori': '$kategori',
    };
    final response = await http.post(url, headers: headers, body: body);

    validateResponseStatus(response.statusCode, 200);

    return allPostsFromJson(response.body);
  }

  Future<SearchPost> searchPost(String title, String tokenNew) async {
    final url = '$api/post/search';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    Map<String, String> body = {
      'title': '$title',
    };

    final response = await http.post(url, headers: headers, body: body);

    validateResponseStatus(response.statusCode, 200);

    return searchPostFromJson(response.body);
  }

  //* KOMENTAR

  Future<bool> createKomentar(String postId, String komentar, String tokenProvider) async {
    final url = '$api/komentar';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenProvider'};

    Map<String, String> body = {
      'post_id': postId,
      'komentar': komentar,
    };

    final response = await http.post(url, headers: headers, body: body);

    validateResponseStatus(response.statusCode, 201);
    print('token api komentar : $tokenProvider');
    return true;
  }

  Future<bool> deleteKomentar(int id, String tokenNew, int role) async {
    final url = '$api/komentar/$id';
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    Map<String, String> body = {'_method': 'DELETE', 'role': '$role'};

    final response = await http.post(url, headers: headers, body: body);
    print(response.body);
    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  //* PROFIL

  Future<UserDetail> getDetailProfil() async {
    final url = "$api/user/detail";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    print('token api detail profil : $token');

    return userDetailFromJson(response.body);
  }

  Future<UserDetail> getDetailProfilId(int id, String tokenNew) async {
    final url = "$api/user/detail/$id";
    print(id);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);
    print(response.body);
    validateResponseStatus(response.statusCode, 200);

    return userDetailFromJson(response.body);
  }

  Future<bool> editProfil(String nama, String angkatan, File image, String nomer, String tokenNew) async {
    final url = '$api/user/profil';
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['name'] = nama;
    request.fields['angkatan'] = angkatan;
    request.fields['nomer'] = nomer;

    if (image != null) {
      var pic = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(pic);
    } else {}

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $tokenNew';

    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  Future<bool> logout() async {
    final url = "$api/user/logout";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    print('token api detail profil : $token');

    return true;
  }

  //* VERIFIKASI
  Future<int> cekVerifikasi(String key) async {
    final url = '$api/user/verifikasi/cek';

    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    Map<String, String> body = {
      'key': '$key',
    };

    final response = await http.post(url, headers: headers, body: body);
    print(response.body);
    return response.statusCode;
  }

  Future<int> verifikasi(String key, int role, String nrp, String tokenNew) async {
    final url = '$api/user/verifikasi';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    Map<String, String> body = {
      'role': '$role',
      'nrp': '$nrp',
      'key': '$key',
    };

    final response = await http.post(url, headers: headers, body: body);
    print(response.statusCode);
    return response.statusCode;
  }

  //* ADMIN API

  Future<AllKey> getAllKey(String tokenNew) async {
    final url = "$api/user/key/all";
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return allKeyFromJson(response.body);
  }

  Future<bool> getGenerateKey(String tokenNew) async {
    final url = "$api/user/key";
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  Future<AllUser> getAllUser(String tokenNew) async {
    final url = "$api/user";
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all user');
    return allUserFromJson(response.body);
  }

  Future<AllUser> getAllUserMore(String url, String tokenNew) async {
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all user more');
    return allUserFromJson(response.body);
  }

  Future<bool> deleteUser(int id, String tokenNew) async {
    final url = '$api/user/$id';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.post(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  Future<bool> editAdminRole(int id, int role, String tokenNew) async {
    final url = '$api/user/admin/role';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    Map<String, String> body = {
      'id': '$id',
      'role': '$role',
    };

    final response = await http.post(url, body: body, headers: headers);
    print(response.body);
    validateResponseStatus(response.statusCode, 200);

    return true;
  }

  //* FEEDBACK

  Future<Feedback> getAllFeedback(String tokenNew) async {
    final url = "$api/user/admin/feedback";
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all feedback');
    return feedbackFromJson(response.body);
  }

  Future<Feedback> getAllFeedbackMore(String url, String tokenNew) async {
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all feedback more');
    return feedbackFromJson(response.body);
  }

  Future<bool> createFeedback(String deskripsi, String tokenProvider) async {
    final url = '$api/user/admin/feedback';

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenProvider'};

    Map<String, String> body = {
      'deskripsi': deskripsi,
    };

    final response = await http.post(url, headers: headers, body: body);

    validateResponseStatus(response.statusCode, 201);
    print('sukses create feedback');
    return true;
  }

  //* FILTER USER

  Future<FilterUser> filterUser(int role, String tokenNew) async {
    final url = '$api/user/admin/role?role=$role';
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return filterUserFromJson(response.body);
  }

  Future<FilterUser> getAllFilterUserMore(int role, String url, String tokenNew) async {
    String _url = url + '&role=$role';
    print(_url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(_url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all user more');
    return filterUserFromJson(response.body);
  }

  //* SEARCH USER

  Future<SearchUser> searchUser(String param, String tokenNew) async {
    final url = '$api/user/admin/search?search=$param';
    print(url);
    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);
    print(response.body);
    validateResponseStatus(response.statusCode, 200);

    return searchUserFromJson(response.body);
  }

  //* Bug

  Future<bool> createBug(String deskripsi, File image, String tokenProvider) async {
    final url = '$api/user/admin/bug';

    //* BODY
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['deskripsi'] = deskripsi;

    if (image != null) {
      var pic = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(pic);
    } else {}

    //* HEADER
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $tokenProvider';

    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
    validateResponseStatus(response.statusCode, 201);

    return true;
  }

  Future<Bug> getAllBug(String tokenNew) async {
    final url = "$api/user/admin/bug";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return bugFromJson(response.body);
  }

  Future<Bug> getAllBugMore(String url, String tokenNew) async {
    print(url);

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all bug more');
    return bugFromJson(response.body);
  }

  Future<bool> createForm(String nrp, File image, String tokenProvider) async {
    final url = '$api/user/admin/form';

    //* BODY
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['nrp'] = nrp;

    if (image != null) {
      var pic = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(pic);
    } else {}

    //* HEADER
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $tokenProvider';

    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
    validateResponseStatus(response.statusCode, 201);

    return true;
  }

  Future<Form> getAllForm(String tokenNew) async {
    final url = "$api/user/admin/form";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    return formFromJson(response.body);
  }

  Future<Form> getAllFormMore(String url, String tokenNew) async {
    print(url);

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $tokenNew'};

    final response = await http.get(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);
    print('sukses get all form more');
    return formFromJson(response.body);
  }

  Future<bool> getReadNotif(int id) async {
     final url = "$api/notif/$id";

    Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.post(url, headers: headers);

    validateResponseStatus(response.statusCode, 200);

    print('sukses read');

    return true;
  }
}
