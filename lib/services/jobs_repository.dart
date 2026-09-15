import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/catalog.dart';

/// The app consumes this contract; database credentials stay on the server.
class JobsRepository {
  final String baseUrl;
  JobsRepository({this.baseUrl = const String.fromEnvironment('JOBS_API_URL')});
  bool get isDemo => baseUrl.trim().isEmpty;

  Future<List<JobItem>> load() async {
    if (isDemo) return List.of(jobs);
    final base = Uri.parse(baseUrl);
    if (!['http', 'https'].contains(base.scheme) || base.host.isEmpty) {
      throw const FormatException('URL da API inválida.');
    }
    final result = <JobItem>[];
    final ids = <String>{};
    // Bounded pagination also prevents endless requests from a broken API.
    for (var page = 1; page <= 100; page++) {
      final uri = Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/jobs')
          .replace(queryParameters: {'page': '$page', 'page_size': '100'});
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200)
        throw StateError('API: ${response.statusCode}');
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map || data['items'] is! List || data['has_more'] is! bool) {
        throw const FormatException('Resposta de vagas inválida.');
      }
      for (final item in data['items']) {
        final job = JobItem.fromMap(Map<String, dynamic>.from(item));
        if (!ids.add(job.id))
          throw const FormatException('ID de vaga duplicado.');
        result.add(job);
      }
      if (data['has_more'] == false) return result;
    }
    throw StateError('Limite de paginação excedido.');
  }
}
