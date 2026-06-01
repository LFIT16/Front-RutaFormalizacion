class News {
  final String title;
  final String summary;
  final String source;
  final String category;
  final String? imageUrl;
  final String? articleUrl;
  final DateTime? publishedAt;

  const News({
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    this.imageUrl,
    this.articleUrl,
    this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: (json['title'] as String?)?.trim() ?? '',
      summary: (json['summary'] as String?)?.trim() ?? '',
      source: (json['source'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? '',
      imageUrl: _asTrimmedString(json['imageUrl']),
      articleUrl: _asTrimmedString(json['articleUrl']),
      publishedAt: _parseDate(json['publishedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'source': source,
      'category': category,
      'imageUrl': imageUrl,
      'articleUrl': articleUrl,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  static String? _asTrimmedString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}