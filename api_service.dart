import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  static const baseUrl = 'http://192.168.1.4/sikap_api/php';

  // Auto-retry with token refresh
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    // Try refreshing token before request
    await UserSession.instance.refreshTokenIfNeeded();

    var response = await request();

    // If unauthorized, try to refresh token and retry once
    if (response.statusCode == 401) {
      print('🔄 401 received, attempting token refresh...');

      final refreshed = await UserSession.instance.refreshTokenIfNeeded();
      if (refreshed) {
        response = await request(); // Retry with new token
      }
    }

    return response;
  }

  // Authentication APIs
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // Store token and user data if login successful
        if (result['success'] && result['token'] != null) {
          await UserSession.instance.setUserData(
            result['user'],
            result['token'],
          );
        }

        return result;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // Store token and user data if registration successful
        if (result['success'] && result['token'] != null) {
          await UserSession.instance.setUserData(
            result['user'],
            result['token'],
          );
        }

        return result;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    await UserSession.instance.clearUserData();
  }

  // Helper method to make authenticated requests with auto-retry
  static Future<http.Response> _makeAuthenticatedRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return await _makeRequest(() async {
      final headers = UserSession.instance.authHeaders;

      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(Uri.parse(url), headers: headers);
        case 'POST':
          return await http.post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PUT':
          return await http.put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          return await http.delete(Uri.parse(url), headers: headers);
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    });
  }

  // Job Post APIs (public, no auth required)
  static Future<Map<String, dynamic>> getJobPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_jobpost.php'));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getJobDetails(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_job_details.php?job_id=$jobId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Protected APIs (require authentication) - Updated with auto-retry
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'GET',
        '$baseUrl/get_user_profile.php?user_id=$userId',
      );

      if (response.statusCode == 401) {
        await logout(); // Token expired, logout user
        return {
          'success': false,
          'message': 'Session expired, please login again',
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> saveJob(
    int jobseekerId,
    int jobId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'POST',
        '$baseUrl/save_job.php',
        body: {'jobseeker_id': jobseekerId, 'job_id': jobId},
      );

      if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Session expired, please login again',
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSavedJobs(int jobseekerId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'GET',
        '$baseUrl/get_saved_jobpost.php?jobseeker_id=$jobseekerId',
      );

      if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Session expired, please login again',
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> unsaveJob(
    int jobseekerId,
    int jobId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'POST',
        '$baseUrl/unsave_job.php',
        body: {'jobseeker_id': jobseekerId, 'job_id': jobId},
      );

      if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Session expired, please login again',
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // New method to get job documents
  static Future<Map<String, dynamic>> getJobDocuments(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_job_documents.php?job_id=$jobId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Utility method to get image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://192.168.1.4/sikap_api/$imagePath';
  }
}
