import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup/services/token_service.dart';

class ChecklistService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8383/api/checklist';
    }
    return 'http://10.0.2.2:8383/api/checklist';
  }

  // ── Headers con JWT ──────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Obtener checklist completo del usuario ───────────────────────
  static Future<Map<String, dynamic>> obtenerChecklist() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/mi-checklist'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'items': data};
      } else if (response.statusCode == 404) {
        return {'success': false, 'noChecklist': true, 'error': 'Checklist no inicializado'};
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // ── Obtener resumen del checklist ────────────────────────────────
  static Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/mi-checklist/resumen'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true, 'resumen': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // ── Inicializar checklist con datos del negocio ──────────────────
  static Future<Map<String, dynamic>> inicializarChecklist({
    required String nombreNegocio,
    required String tipoNegocio,
    required String ciudad,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
        Uri.parse('$baseUrl/mi-checklist/inicializar'),
        headers: headers,
        body: jsonEncode({
          'nombreNegocio': nombreNegocio,
          'tipoNegocio': tipoNegocio,
          'ciudad': ciudad,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'mensaje': data['mensaje']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Error al inicializar'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // ── Marcar / desmarcar ítem ──────────────────────────────────────
  static Future<Map<String, dynamic>> actualizarItem({
    required String itemId,
    required bool completado,
    String? notaPersonal,
    bool omitido = false,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .patch(
        Uri.parse('$baseUrl/mi-checklist/items/$itemId'),
        headers: headers,
        body: jsonEncode({
          'completado': completado,
          'notaPersonal': notaPersonal ?? '',
          'omitido': omitido,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'porcentajeAvance': data['porcentajeAvance'],
          'etapaActual': data['etapaActual'],
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Error al actualizar'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // ── Resetear progreso ────────────────────────────────────────────
  static Future<Map<String, dynamic>> resetearProgreso() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(Uri.parse('$baseUrl/mi-checklist/reset'), headers: headers)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'mensaje': data['mensaje']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Error al resetear'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // ── Etiquetas legibles por etapa ─────────────────────────────────
  static String etapaLabel(String etapa) {
    const map = {
      'ETAPA_1_JURIDICA': 'Jurídica',
      'ETAPA_2_TRIBUTARIA': 'Tributaria',
      'ETAPA_3_SANITARIA': 'Sanitaria',
      'ETAPA_4_LABORAL': 'Laboral',
      'ETAPA_5_FINANCIERA': 'Financiera',
    };
    return map[etapa] ?? etapa;
  }

  // ── Color por etapa ──────────────────────────────────────────────
  static int etapaColor(String etapa) {
    const map = {
      'ETAPA_1_JURIDICA': 0xff1565C0,
      'ETAPA_2_TRIBUTARIA': 0xffE65100,
      'ETAPA_3_SANITARIA': 0xff2E7D32,
      'ETAPA_4_LABORAL': 0xff6A1B9A,
      'ETAPA_5_FINANCIERA': 0xff00838F,
    };
    return map[etapa] ?? 0xff757575;
  }
}