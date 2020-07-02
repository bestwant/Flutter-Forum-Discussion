import 'dart:io';

import 'package:discussion_app/providers/auth_provider.dart';
import 'package:discussion_app/services/api.dart';
import 'package:discussion_app/utils/exceptions.dart';
import 'package:flutter/material.dart';

class PostProvider with ChangeNotifier {
  bool _initialized = false;

  AuthProvider authProvider;

  // VARIABEL HASIL
  var allPost;
  var idPost;
  var filterPost;
  var searchPost;
  var detailProfil;

  String statusCreate = 'menunggu';
  String statusDelete = 'menunggu';
  String statusKomentar = 'menunggu';
  String statusEditProfil = 'menunggu';

  bool get initialized => _initialized;

  ApiService apiService;

  PostProvider(AuthProvider authProvider) {
    this.apiService = ApiService(authProvider);
    this.authProvider = authProvider;
  }

  Future<void> getAllPost() async {
    try {
      //Jika tidak ada exceptions thrown dari API service
      final data = await apiService.getAllPost();
      allPost = data.posts;
      print('sukses get all post');
      notifyListeners();
    } on AuthException {
      //Token expired, redirect login
      await authProvider.logOut(true);
    } catch (exception) {
      print(exception);
    }
  }

  Future<bool> getIdPost(int id) async {
    try {
      idPost = null;
      notifyListeners();
      final data = await apiService.getIdPost(id);
      idPost = data;
      print('sukses get id post');
      notifyListeners();
      return true;
    } on AuthException {
      //Token expired, redirect login
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> createPost(
      String title, String description, String kategori, File image) async {
    try {
      statusCreate = 'loading';
      notifyListeners();
      final data =
          await apiService.createPost(title, description, kategori, image);
      if (data) {
        statusCreate = 'sukses';
      }
      statusCreate = 'menunggu';

      print('sukses create post');
      notifyListeners();
      return true;
    } on AuthException {
      statusCreate = 'menunggu';
      notifyListeners();
      //Token expired, redirect login
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      statusCreate = 'menunggu';
      notifyListeners();
      print(exception);
      return false;
    }
  }

  Future<void> deletePost(int id) async {
    try {
      statusDelete = 'loading';
      notifyListeners();
      final data = await apiService.deletePost(id);
      if (data) {
        statusDelete = 'sukses';
      }
      notifyListeners();
    } on AuthException {
      statusCreate = 'gagal';
      //Token expired, redirect login
      await authProvider.logOut(true);
    } catch (exception) {
      statusCreate = 'gagal';
      print(exception);
    }
  }

  Future<void> getFilterPost(String kategori) async {
    try {
      filterPost = null;
      notifyListeners();
      final data = await apiService.filterPost(kategori);
      filterPost = data.posts;

      print('sukses filter post');
      notifyListeners();
    } on AuthException {
      await authProvider.logOut(true);
    } catch (exception) {
      print(exception);
    }
  }

  Future<void> getSearchPost(String title) async {
    try {
      searchPost = null;
      notifyListeners();
      final data = await apiService.searchPost(title);
      searchPost = data;
      print('sukses get search post');
      notifyListeners();
    } on AuthException {
      await authProvider.logOut(true);
    } catch (exception) {
      print(exception);
    }
  }

  Future<bool> createKomentar(String postId, String komentar) async {
    try {
      statusKomentar = 'loading';
      notifyListeners();
      final data = await apiService.createKomentar(postId, komentar);
      if (data) {
        statusKomentar = 'sukses';
      } else {
        statusKomentar = 'menunggu';
        notifyListeners();
      }
      return true;
    } on AuthException {
      statusKomentar = 'menunggu';
      notifyListeners();
      //Token expired, redirect login
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      statusKomentar = 'menunggu';
      notifyListeners();
      print(exception);
      return false;
    }
  }

  // PROFIL PROVIDER
  Future<void> getDetailProfil() async {
    try {
      //Jika tidak ada exceptions thrown dari API service
      final data = await apiService.getDetailProfil();
      detailProfil = data;
      print('sukses get detail post');
      notifyListeners();
    } on AuthException {
      //Token expired, redirect login
      await authProvider.logOut(true);
    } catch (exception) {
      print(exception);
    }
  }

  Future<bool> editProfil(String nama, String angkatan, File image) async {
    try {
      statusEditProfil = 'loading';
      notifyListeners();
      final data = await apiService.editProfil(nama, angkatan, image);
      if (data) {
        statusEditProfil = 'sukses';
      }
      statusEditProfil = 'menunggu';
      notifyListeners();
      return true;
    } on AuthException {
      statusEditProfil = 'menunggu';
      notifyListeners();
      //Token expired, redirect login
      await authProvider.logOut(true);
      return false;
    } catch (exception) {
      statusEditProfil = 'menunggu';
      notifyListeners();
      print(exception);
      return false;
    }
  }
}
