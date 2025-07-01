import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator
  // static const baseUrl = 'http://10.0.2.2/sikap_api/php';
  static const baseUrl = 'http://192.168.1.2/sikap_api/php';


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
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  
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
          'message': 'Server error: ${response.statusCode}'
        };
      }
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
  
  // Get user's job applications (saved jobs)
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

  // Get all users (for testing)
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_users.php'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
  // Method to get full image URL
    static String getImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return '';
      
      // If it's already a full URL, return as is
      if (imagePath.startsWith('http')) return imagePath;
      
      // Now points to your sikap_api project (which has the uploads folder)
      return 'http://192.168.1.2/sikap_api/$imagePath';
    }

    static Future<Map<String, dynamic>> getSavedJobs(int jobseekerId) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/get_saved_jobpost.php?jobseeker_id=$jobseekerId'),
        );
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}'
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Network error: $e'
        };
      }
    }

    static Future<Map<String, dynamic>> saveJob(int jobseekerId, int jobId) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/save_job.php'),
          body: {
            'jobseeker_id': jobseekerId.toString(),
            'job_id': jobId.toString(),
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

    static Future<Map<String, dynamic>> unsaveJob(int jobseekerId, int jobId) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/unsave_job.php'),
          body: {
            'jobseeker_id': jobseekerId.toString(),
            'job_id': jobId.toString(),
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
}
