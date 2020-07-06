import 'package:discussion_app/models/allUser_model.dart';
import 'package:discussion_app/providers/auth_provider.dart';
import 'package:discussion_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:discussion_app/utils/exceptions.dart';

class AdminProvider with ChangeNotifier {
  bool isLoading = false;

  // VARIABEL HASIL
  var allKey;
  List<Datum> allUser = List<Datum>();
  //List<Datum> allUser = List<Datum>();

  //PAGINATION
  int pageAllUser = 1;
  String nextPageUser;
  bool isLoadingMore;

  ApiService apiService;
  AuthProvider authProvider;

  AdminProvider(AuthProvider authProvider) {
    this.apiService = ApiService(authProvider);
    this.authProvider = authProvider;
  }

  //* ADMIN PANEL

  Future<bool> getAllUser(String token) async {
    try {
      pageAllUser = 1;
      //Jika tidak ada exceptions thrown dari API service
      notifyListeners();
      final data = await apiService.getAllUser(token, pageAllUser);
      print('data : ${data.user.data.length}');
      List<Datum> _listUser = data.user.data;
      allUser = _listUser;
      nextPageUser = data.user.nextPageUrl;
      notifyListeners();
      return true;
    } on AuthException {
      //Token expired, redirect login

      notifyListeners();
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      notifyListeners();
      print(exception);
      return false;
    }
  }

  Future<bool> getAllUserMore(String token) async {
    try {
      //Jika tidak ada exceptions thrown dari API service
      //pageAllUser++;
      String _url = nextPageUser;
      if (_url != null) {
        isLoadingMore = true;
        final data = await apiService.getAllUserMore(_url, token);

        print('data : ${data.user.data.length}');

        List<Datum> _listUser = data.user.data;
        List<Datum> _userSekarang = allUser;

        nextPageUser = data.user.nextPageUrl;

        List<Datum> _allUserNew = [..._userSekarang, ..._listUser];
        allUser = _allUserNew;
        notifyListeners();
        print('sukses tambah allUser more');
      }else{
        print('sudah habis gan');
      }

      isLoadingMore = false;
      notifyListeners();
      return true;
    } on AuthException {
      //Token expired, redirect login
      isLoadingMore = false;
      notifyListeners();
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      isLoadingMore = false;
      notifyListeners();
      print(exception);
      return false;
    }
  }

  Future<bool> getAllKey(String token) async {
    try {
      //Jika tidak ada exceptions thrown dari API service
      isLoading = true;
      notifyListeners();
      final data = await apiService.getAllKey(token);
      allKey = data.key;
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException {
      //Token expired, redirect login
      isLoading = false;
      notifyListeners();
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      isLoading = false;
      notifyListeners();
      print(exception);
      return false;
    }
  }

  Future<bool> generateKey(String token) async {
    try {
      //Jika tidak ada exceptions thrown dari API service
      isLoading = true;
      notifyListeners();
      await apiService.getGenerateKey(token);
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException {
      //Token expired, redirect login
      isLoading = false;
      notifyListeners();
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      isLoading = false;
      notifyListeners();
      print(exception);
      return false;
    }
  }
}