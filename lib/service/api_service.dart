import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/character.dart';
import '../model/episode.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class PagedResult<T> {
  final List<T> items;
  final bool hasNext;
  const PagedResult(this.items, this.hasNext);
}

class ApiService {
  static const String _host = 'rickandmortyapi.com';
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>?> _getJson(
    Uri uri, {
    bool notFoundIsEmpty = false,
  }) async {
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      // API mengembalikan 404 jika filter/pencarian tidak punya hasil
      if (response.statusCode == 404 && notFoundIsEmpty) return null;
      throw ApiException('Server bermasalah (kode ${response.statusCode}).');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Silakan coba lagi.');
    } catch (_) {
      throw ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet kamu.',
      );
    }
  }

  /// GET /character, /character?status=alive, /character?name=rick
  Future<PagedResult<Character>> fetchCharacters({
    int page = 1,
    String status = '',
    String name = '',
  }) async {
    final uri = Uri.https(_host, '/api/character', {
      'page': '$page',
      if (status.isNotEmpty) 'status': status,
      if (name.isNotEmpty) 'name': name,
    });

    final json = await _getJson(uri, notFoundIsEmpty: true);
    if (json == null) return PagedResult<Character>(<Character>[], false);

    final results = (json['results'] as List)
        .map((e) => Character.fromJson(e as Map<String, dynamic>))
        .toList();
    final hasNext = (json['info'] as Map)['next'] != null;
    return PagedResult<Character>(results, hasNext);
  }

  /// GET /character/{id}
  Future<Character> fetchCharacter(int id) async {
    final json = await _getJson(Uri.https(_host, '/api/character/$id'));
    return Character.fromJson(json!);
  }

  /// GET /episode?page=
  Future<PagedResult<Episode>> fetchEpisodes({int page = 1}) async {
    final uri = Uri.https(_host, '/api/episode', {'page': '$page'});
    final json = await _getJson(uri);

    final results = (json!['results'] as List)
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();
    final hasNext = (json['info'] as Map)['next'] != null;
    return PagedResult<Episode>(results, hasNext);
  }
}
