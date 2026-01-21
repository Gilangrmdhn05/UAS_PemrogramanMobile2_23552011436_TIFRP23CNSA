import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warungku_mobile/utils/constants.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _userAddress;
  String? _userImageUrl;


  bool get isAuthenticated => _token != null;
  String? get token => _token;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String? get userAddress => _userAddress;
  String? get userImageUrl => _userImageUrl;

  Future<bool> _authenticate(String endpoint, Map<String, String> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message']);
      }
      
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        _token = data['token'];
        
        final userData = data['user'] ?? data;

        _userId = int.tryParse(userData['id']?.toString() ?? userData['user_id']?.toString() ?? '0');
        _userName = userData['nama'];
        _userEmail = userData['email'];
        _userPhone = userData['no_hp'];
        _userAddress = userData['alamat'];
        _userImageUrl = userData['profile_image_url'];

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) prefs.setString('token', _token!);
        if (_userId != null) prefs.setInt('userId', _userId!);
        if (_userName != null) prefs.setString('userName', _userName!);
        if (_userEmail != null) prefs.setString('userEmail', _userEmail!);
        if (_userPhone != null) prefs.setString('userPhone', _userPhone!);
        if (_userAddress != null) prefs.setString('userAddress', _userAddress!);
        if (_userImageUrl != null) prefs.setString('userImageUrl', _userImageUrl!);
        notifyListeners();
      }
      return true;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) {
    return _authenticate(
      'auth.php?action=login',
      {'email': email, 'password': password},
    );
  }

  Future<void> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
  }) {
    return _authenticate(
      'auth.php?action=register',
      {
        'nama': nama,
        'email': email,
        'password': password,
        'no_hp': noHp,
        'alamat': alamat,
      },
    );
  }

  Future<void> updateUserProfile({required String phone, required String address, String? imageUrl}) async {
    // Simulate API call to update profile
    _userPhone = phone;
    _userAddress = address;
    if (imageUrl != null) {
      _userImageUrl = imageUrl;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userPhone', _userPhone!);
    prefs.setString('userAddress', _userAddress!);
    if (imageUrl != null) {
      prefs.setString('userImageUrl', _userImageUrl!);
    }
    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    _userImageUrl = imageUrl;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userImageUrl', _userImageUrl!);
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }

    _token = prefs.getString('token');
    _userId = prefs.getInt('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userPhone = prefs.getString('userPhone');
    _userAddress = prefs.getString('userAddress');
    _userImageUrl = prefs.getString('userImageUrl');
    
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userAddress = null;
    _userImageUrl = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all data
    
    notifyListeners();
  }
}
