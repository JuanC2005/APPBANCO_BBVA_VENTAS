import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    return 'http://10.0.2.2:8000/api/v1';
  }
  static const Duration timeout = Duration(seconds: 30);
}
