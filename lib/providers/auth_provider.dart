import 'package:discussion_app/models/auth_model.dart';
import 'package:discussion_app/models/signin_model.dart';
import 'package:discussion_app/widgets/notification_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated, Relogin }

class AuthProvider with ChangeNotifier {
  Status _status = Status.Uninitialized;
  String _email;
  String _token;
  String _name;
  int _idUser;
  String _angkatan;
  int _role;
  String _profil;
  String _nrp;
  String _password;
  String _roleName;
  int _nomer;
  NotificationText _notification;

  int get idUser => _idUser;
  String get nrp => _nrp;
  Status get status => _status;
  String get token => _token;
  String get name => _name;
  String get profil => _profil;
  int get role => _role;
  String get roleName => _roleName;
  String get angkatan => _angkatan;
  int get nomer => _nomer;

  NotificationText get notification => _notification;

  //* ROLE
  List fixRole = ['Guest', 'Mahasiswa Aktif', 'Fungsionaris', 'Alumni', 'Dosen', 'Admin', 'Developer'];

  // URL ENDPOINT API USER
  //* LOCAL HOST
  //final String api = "http://192.168.43.47/api/v1/user";
  //* AZURE VPS
  final String api = 'http://138.91.32.37/api/v1/user';

  initAuthProvider() async {
    String email = await getEmail();
    String nrp = await getNrp();
    String password = await getPassword();
    String token = await getToken();
    String name = await getName();
    String profil = await getProfil();
    int role = await getRole();
    String roleName = await getRoleName();
    String angkatan = await getAngkatan();
    int idUser = await getIdUser();
    int nomer = await getNomer();
    if (token != null) {
      _email = email;
      _idUser = idUser;
      _nrp = nrp;
      _password = password;
      _token = token;
      _name = name;
      _profil = profil;
      _role = role;
      _angkatan = angkatan;
      _roleName = roleName;
      _nomer = nomer;
      signin(_email, _password);
      _status = Status.Authenticated;
    } else {
      _status = Status.Unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signin(String email, String password) async {
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();
    final url = "$api/signin";
    print('url login : $url');

    Map<String, String> body = {
      'email': email,
      'password': password,
    };

    Map<String, String> headers = {'Accept': 'application/json'};
    print(_status);
    try {
      final response = await http.post(url, body: body, headers: headers);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var apiResponse = loginFromJson(response.body);
        _status = Status.Authenticated;
        _email = apiResponse.user.email;
        _token = apiResponse.token;
        _name = apiResponse.user.name;
        _profil = apiResponse.user.image;
        _role = apiResponse.user.role;
        _angkatan = apiResponse.user.angkatan;
        _idUser = apiResponse.user.id;
        _nomer = apiResponse.user.nomer;
        _roleName = fixRole[apiResponse.user.role];
        await storeUserData(apiResponse, email, password);
        notifyListeners();
        print('login sukses');
        print(_token);
        return true;
      }

      if (response.statusCode == 404) {
        _status = Status.Unauthenticated;
        _notification = NotificationText('Email atau password salah');
        notifyListeners();
        return false;
      }

      _status = Status.Unauthenticated;
      _notification = NotificationText('Server sedang bermasalah.');
      notifyListeners();
      return false;
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      _notification = NotificationText('Internet tidak dapat terhubung keserver.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({@required String email, String password, String nomer, String angkatan, String nama}) async {
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();
    final url = "$api/register";

    Map<String, String> body = {'email': email, 'password': password, 'angkatan': angkatan, 'nomer': nomer, 'name': nama};

    Map<String, String> headers = {'Accept': 'application/json'};
    print(_status);
    try {
      final response = await http.post(url, body: body, headers: headers);
      print(response.body);
      if (response.statusCode == 201) {
        await signin(email, password);
        notifyListeners();
        print('login sukses');
        return true;
      }

      if (response.statusCode == 404) {
        _status = Status.Unauthenticated;
        _notification = NotificationText('Email sudah ada');
        notifyListeners();
        return false;
      }

      _status = Status.Unauthenticated;
      _notification = NotificationText('Server sedang bermasalah.');
      notifyListeners();
      return false;
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      _notification = NotificationText('Internet tidak dapat terhubung keserver.');
      notifyListeners();
      return false;
    }
  }

  storeUserData(apiResponse, email, password) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setInt('id', apiResponse.user.id);
    await storage.setString('email', email);
    await storage.setString('nrp', apiResponse.user.nrp);
    await storage.setString('password', password);
    await storage.setString('token', apiResponse.token);
    await storage.setString('name', apiResponse.user.name);
    await storage.setString('profil', apiResponse.user.image);
    await storage.setString('angkatan', apiResponse.user.angkatan);
    await storage.setInt('nomer', apiResponse.user.nomer);
    await storage.setInt('role', apiResponse.user.role);
    await storage.setString('roleName', fixRole[apiResponse.user.role]);
  }

  Future<int> getNomer() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    int nomer = storage.getInt('nomer');
    return nomer;
  }

  Future<int> getIdUser() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    int idUser = storage.getInt('id');
    return idUser;
  }

  Future<String> getEmail() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String email = storage.getString('email');
    return email;
  }

  Future<String> getNrp() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String nrp = storage.getString('nrp');
    return nrp;
  }

  Future<String> getPassword() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String password = storage.getString('password');
    return password;
  }

  Future<String> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token');
    return token;
  }

  Future<String> getName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String name = storage.getString('name');
    return name;
  }

  Future<String> getProfil() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String profil = storage.getString('profil');
    return profil;
  }

  Future<int> getRole() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    int role = storage.getInt('role');
    return role;
  }

  Future<String> getRoleName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String role = storage.getString('roleName');
    return role;
  }

  Future<String> getAngkatan() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String angkatan = storage.getString('angkatan');
    return angkatan;
  }

  logOut([bool tokenExpired = false]) async {
    if (tokenExpired == true) {
      await reLogin();
      _notification = NotificationText('Waktu sesi habis. Harap masuk lagi.', type: 'info');
    } else {
      _status = Status.Unauthenticated;
      SharedPreferences storage = await SharedPreferences.getInstance();
      await storage.clear();
      _token = null;
      print('logout token : $token');
      notifyListeners();
    }
  }

  Future updateData(String namaBaru, String angkatanBaru) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('name', namaBaru);
    await storage.setString('angkatan', angkatanBaru);
    _name = namaBaru;
    _angkatan = angkatanBaru;
    notifyListeners();
  }

  Future reLogin() async {
    _status = Status.Relogin;
    notifyListeners();
    String _emailRelog = await getEmail();
    String _passwordRelog = await getPassword();
    print('relogin');
    final url = "$api/signin";

    Map<String, String> body = {
      'email': _emailRelog,
      'password': _passwordRelog,
    };

    Map<String, String> headers = {'Accept': 'application/json'};
    print(_status);

    final response = await http.post(url, body: body, headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var apiResponse = loginFromJson(response.body);
      _status = Status.Authenticated;
      _email = apiResponse.user.email;
      _token = apiResponse.token;
      _name = apiResponse.user.name;
      _profil = apiResponse.user.image;
      _role = apiResponse.user.role;
      _angkatan = apiResponse.user.angkatan;
      _idUser = apiResponse.user.id;
      _nomer = apiResponse.user.nomer;
      _roleName = fixRole[apiResponse.user.role];
      await storeUserData(apiResponse, _emailRelog, _passwordRelog);
      print(_token);
      notifyListeners();
      print('login sukses');
    }
  }
}
