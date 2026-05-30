import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news.dart';

class NewsService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  NewsService({
    String? baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  })  : baseUrl = baseUrl ?? 'http://localhost:8383',
        _client = client ?? http.Client();

  Future<List<News>> getLatestNews() async {
    final uri = Uri.parse('$baseUrl/api/news/latest');

    try {
      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode != 200) {
        throw NewsServiceException(
          _messageFromBody(
                response.body,
                defaultMessage: 'Error al obtener noticias (${response.statusCode})',
              ) ??
              'Error al obtener noticias (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const NewsServiceException('Formato inválido de respuesta del servidor.');
      }

      return decoded
          .whereType<Map>()
          .map((item) => News.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } on TimeoutException {
      throw const NewsServiceException('La solicitud a noticias tardó demasiado en responder.');
    } on FormatException {
      throw const NewsServiceException('La respuesta de noticias no tiene un JSON válido.');
    } on http.ClientException catch (e) {
      throw NewsServiceException('No fue posible conectar con el servidor de noticias: ${e.message}');
    } catch (e) {
      if (e is NewsServiceException) {
        rethrow;
      }
      throw NewsServiceException('Error inesperado al obtener noticias: $e');
    }
  }

  String? _messageFromBody(String body, {String? defaultMessage}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error.trim();
        }
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Return the provided fallback below.
    }
    return defaultMessage;
  }
}

class NewsServiceException implements Exception {
  final String message;

  const NewsServiceException(this.message);

  @override
  String toString() => message;
}

