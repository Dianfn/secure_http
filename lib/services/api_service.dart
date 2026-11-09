import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration defaultTimeout = Duration(seconds: 10);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const ApiException('Email dan password wajib diisi.');
    }

    if (!normalizedEmail.contains('@') || password.length < 6) {
      throw const ApiException(
        'Email atau password tidak valid. Gunakan password minimal 6 karakter.',
      );
    }

    return 'token_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<List<User>> getUsers({Duration timeout = defaultTimeout}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data pengguna (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Format data pengguna tidak valid.');
      }

      return decoded
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw ApiException(
        'Permintaan timeout setelah ${timeout.inSeconds} detik. '
        'Periksa koneksi internet Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const ApiException('Respons server tidak dapat dibaca.');
    }
  }

  Future<List<Post>> getPosts({Duration timeout = defaultTimeout}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts'))
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data postingan (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Format data postingan tidak valid.');
      }

      return decoded
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw ApiException(
        'Permintaan timeout setelah ${timeout.inSeconds} detik. '
        'Periksa koneksi internet Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const ApiException('Respons server tidak dapat dibaca.');
    }
  }
}
