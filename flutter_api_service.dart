// Updated Flutter API Service for SIKAP Job Portal
// Save this as lib/services/api_service.dart in your Flutter project

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator
  static const baseUrl = 'http://10.0.2.2/sikap_api/php';
  
  // Authentication APIs
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'jobseeker'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
        },
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  // Job Post APIs
  static Future<Map<String, dynamic>> getJobPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_jobpost.php'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  static Future<Map<String, dynamic>> getJobDetails(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_job_details.php?job_id=$jobId'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  // User Profile APIs
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_user_profile.php?user_id=$userId'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  // Job Application APIs
  static Future<Map<String, dynamic>> applyForJob({
    required int jobseekerId,
    required int jobId,
    String interestedProgram = 'None',
    String prioritySector = 'None'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/apply_job.php'),
        body: {
          'jobseeker_id': jobseekerId.toString(),
          'job_id': jobId.toString(),
          'interested_program': interestedProgram,
          'priority_sector': prioritySector,
        },
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  static Future<Map<String, dynamic>> getUserApplications(int jobseekerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_saved_jobpost.php?jobseeker_id=$jobseekerId'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
  // Utility APIs
  static Future<Map<String, dynamic>> getJobCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_categories.php'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
}

// Example usage in your Flutter app:
/*

// Login example
void loginUser() async {
  final result = await ApiService.login('user@test.com', 'password123');
  
  if (result['success']) {
    print('Login successful');
    print('User: ${result['user']}');
    // Navigate to home screen
  } else {
    print('Login failed: ${result['message']}');
    // Show error message
  }
}

// Get job posts example
void loadJobPosts() async {
  final result = await ApiService.getJobPosts();
  
  if (result['success']) {
    List jobs = result['data'];
    print('Found ${jobs.length} job posts');
    // Update UI with job posts
  } else {
    print('Failed to load jobs: ${result['message']}');
  }
}

// Apply for job example
void applyForJob(int jobseekerId, int jobId) async {
  final result = await ApiService.applyForJob(
    jobseekerId: jobseekerId,
    jobId: jobId,
  );
  
  if (result['success']) {
    print('Application submitted successfully');
    // Show success message
  } else {
    print('Application failed: ${result['message']}');
  }
}

*/
