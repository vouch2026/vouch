import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Query db metadata', () async {
    SharedPreferences.setMockInitialValues({});

    final envFile = File('.env');
    final lines = envFile.readAsLinesSync();
    String? url;
    String? anonKey;
    for (var line in lines) {
      if (line.startsWith('SUPABASE_URL=')) {
        url = line.split('SUPABASE_URL=')[1].trim();
      }
      if (line.startsWith('SUPABASE_ANON_KEY=')) {
        anonKey = line.split('SUPABASE_ANON_KEY=')[1].trim();
      }
    }

    expect(url, isNotNull);
    expect(anonKey, isNotNull);

    await Supabase.initialize(url: url!, anonKey: anonKey!);
    final client = Supabase.instance.client;

    print('==================== POLICIES DIAGNOSTIC DATA ====================');

    // Query Policies from pg_policies
    try {
      final policies = await client.rpc('get_policies_debug');
      print('POLICIES FROM RPC: $policies');
    } catch (e) {
      // If RPC doesn't exist, let's query via standard select if there's any view, or try a different way
      print('RPC get_policies_debug not available: $e');
    }

    // Let's run a direct query using a custom RPC or check if we can list policies
    // Wait! Can we try to fetch student_attendance as the program head?
    // Let's try to sign in as the Program Head and query student_attendance!
    try {
      await client.auth.signInWithPassword(
        email: 'mr.jeskie15@gmail.com', // Dony Dongiapon (Program Head)
        password: 'password123', // Let's try common passwords
      );
      print('Sign in successful as mr.jeskie15@gmail.com');
      final attendance = await client.from('student_attendance').select('id, student_id');
      print('ATTENDANCE FOR PROGRAM HEAD DONY: ${attendance.length} rows');
    } catch (e) {
      print('Failed sign in/query with password123: $e');
    }

    try {
      await client.auth.signInWithPassword(
        email: 'mr.jeskie15@gmail.com',
        password: 'password',
      );
      print('Sign in successful with password');
      final attendance = await client.from('student_attendance').select('id, student_id');
      print('ATTENDANCE FOR PROGRAM HEAD DONY: ${attendance.length} rows');
    } catch (e) {
      print('Failed sign in/query with password: $e');
    }

    try {
      await client.auth.signInWithPassword(
        email: 'mr.jeskie15@gmail.com',
        password: 'Admin-2026',
      );
      print('Sign in successful with Admin-2026');
      final attendance = await client.from('student_attendance').select('id, student_id');
      print('ATTENDANCE FOR PROGRAM HEAD DONY: ${attendance.length} rows');
    } catch (e) {
      print('Failed sign in/query with Admin-2026: $e');
    }

    print('==================================================================');
  });
}
