import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Base URL đã bao gồm path chung của auth routes
  /// - 10.0.2.2: localhost của máy dev khi chạy trên Android Emulator
  /// - Cổng 3000 và prefix /api/auth là theo cấu hình trên server Node.js
  static const String baseUrl = 'http://10.0.2.2:3000/api/auth';

  /// Đăng nhập người dùng
  /// Trả về null nếu thành công (và lưu token),
  /// ngược lại trả về message lỗi để hiển thị.
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('🔷 [AuthService.login] STATUS: ${response.statusCode}');
      print('🔷 [AuthService.login] BODY:   ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String;

        // Lưu token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        print('✅ Đăng nhập thành công, token=$token');
        return null;
      } else {
        final msg = json.decode(response.body)['message'] as String?;
        return msg ?? 'Đăng nhập thất bại';
      }
    } catch (e) {
      print('❌ [AuthService.login] Lỗi kết nối: $e');
      return 'Lỗi kết nối tới máy chủ';
    }
  }

  /// Đăng ký người dùng mới
  /// Trả về null nếu thành công (và lưu token),
  /// ngược lại trả về message lỗi để hiển thị.
  static Future<String?> register(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('🔷 [AuthService.register] STATUS: ${response.statusCode}');
      print('🔷 [AuthService.register] BODY:   ${response.body}');

      // Server có thể trả 201 (Created) hoặc 200
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String;

        // Lưu token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        print('✅ Đăng ký thành công, token=$token');
        return null;
      } else {
        final msg = json.decode(response.body)['message'] as String?;
        return msg ?? 'Đăng ký thất bại';
      }
    } catch (e) {
      print('❌ [AuthService.register] Lỗi kết nối: $e');
      return 'Lỗi kết nối tới máy chủ';
    }
  }

  /// Lấy token đã lưu (nếu cần dùng để gọi các API khác)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Xóa token khi đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
