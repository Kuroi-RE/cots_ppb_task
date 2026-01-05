import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Supabase configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // API endpoints
  static const String tasksEndpoint = '/rest/v1/tasks';

  // Full URLs
  static String get tasksUrl => '$supabaseUrl$tasksEndpoint';

  // Headers
  static Map<String, String> get headers => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };

  static Map<String, String> get headersWithContentType => {
    ...headers,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };
}
