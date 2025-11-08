import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Замените эти значения на свои из Supabase!
  static const String supabaseUrl = 'https://cologevaazjipdpxjtmz.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvbG9nZXZhYXpqaXBkcHhqdG16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1OTAwMDIsImV4cCI6MjA3ODE2NjAwMn0.EzfjFzLf7_HU6D4paO4uxDUltpJmytS40hcrzOhsBjE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}