import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> testSupabaseConnection() async {
  try {
    print('Testing direct HTTP connection to Supabase...');
    
    final url = Uri.parse('https://aswuxjtiufcgifmfqzyo.supabase.co/rest/v1/');
    final response = await http.get(
      url,
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzd3V4anRpdWZjZ2lmbWZxenlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwMzg5MzAsImV4cCI6MjA3MzYxNDkzMH0.T9gXh7LEe06LISA6uHxidSCquRQi1fejpjSDEs4-kfw',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzd3V4anRpdWZjZ2lmbWZxenlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwMzg5MzAsImV4cCI6MjA3MzYxNDkzMH0.T9gXh7LEe06LISA6uHxidSCquRQi1fejpjSDEs4-kfw',
      },
    );
    
    print('HTTP Response Status: ${response.statusCode}');
    print('HTTP Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      print('✅ Supabase connection successful!');
    } else {
      print('❌ Supabase connection failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ HTTP connection error: $e');
  }
}
