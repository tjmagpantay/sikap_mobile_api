import 'package:flutter/material.dart';
import 'package:sikap/utils/colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sikap/widgets/navigation_helper.dart';
import 'package:sikap/services/api_service.dart';
import 'package:sikap/services/user_session.dart';
import 'package:sikap/pages/home_screen.dart';
import 'package:sikap/pages/welcome_screen.dart'; // ADD THIS IMPORT

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userSession = UserSession.instance;

    print("=== PROFILE LOADING DEBUG ===");
    print("Is logged in: ${userSession.isLoggedIn}");
    print("User ID: ${userSession.userId}");

    if (userSession.isLoggedIn && userSession.userData != null) {
      // First, use session data as base
      setState(() {
        _userProfile = userSession.userData;
        _isLoading = true; // Keep loading while we fetch complete data
      });

      // Then fetch complete profile data from API
      try {
        print("Fetching complete profile data from API...");
        final result = await ApiService.getUserProfile(userSession.userId!);

        print("=== API RESPONSE ===");
        print("Full API Response: $result");

        if (result['success']) {
          setState(() {
            _userProfile = result['user']; // Use complete API data
            _isLoading = false;
          });

          print('✅ Complete profile loaded from API');
          print(
            'Education count: ${_userProfile?['profile']?['education']?.length ?? 0}',
          );
          print(
            'Skills count: ${_userProfile?['profile']?['skills']?.length ?? 0}',
          );
          print(
            'Work experience count: ${_userProfile?['profile']?['work_experience']?.length ?? 0}',
          );
        } else {
          // Fallback to session data if API fails
          setState(() {
            _userProfile = userSession.userData;
            _isLoading = false;
          });
          print('⚠️ API failed, using session data: ${result['message']}');
        }
      } catch (e) {
        // Fallback to session data if API call fails
        setState(() {
          _userProfile = userSession.userData;
          _isLoading = false;
        });
        print('❌ API call failed, using session data: $e');
      }
    } else {
      print("❌ User not logged in or no session data");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFullName() {
    if (_userProfile?['profile'] != null) {
      final profile = _userProfile!['profile'];
      final firstName = profile['first_name'] ?? '';
      final middleName = profile['middle_name'] ?? '';
      final lastName = profile['last_name'] ?? '';
      final suffix = profile['suffix'] ?? '';

      String fullName = '$firstName';
      if (middleName.isNotEmpty && middleName != 'N/A') {
        fullName += ' $middleName';
      }
      fullName += ' $lastName';
      if (suffix.isNotEmpty && suffix != 'N/A') {
        fullName += ' $suffix';
      }

      return fullName.trim();
    }
    return 'No Name Available';
  }

  String _getEmail() {
    return _userProfile?['email'] ?? 'No email available';
  }

  String _getPhoneNumber() {
    final contactNo = _userProfile?['profile']?['contact_no'];
    if (contactNo != null && contactNo.isNotEmpty && contactNo != 'N/A') {
      return contactNo;
    }
    return 'No phone number available';
  }

  String _getProfileImageUrl() {
    final imagePath = _userProfile?['profile']?['profile_picture'];
    return ApiService.getImageUrl(imagePath);
  }

  String _getAge() {
    final dob = _userProfile?['profile']?['date_of_birth'];
    if (dob != null && dob.isNotEmpty) {
      try {
        final birthDate = DateTime.parse(dob);
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        return '$age years old';
      } catch (e) {
        return 'Age not available';
      }
    }
    return 'Age not available';
  }

  String _getAddress() {
    final address = _userProfile?['profile']?['address'];
    if (address != null && address.isNotEmpty && address != 'N/A') {
      return address;
    }
    return 'Address not provided';
  }

  double _getProfileCompletion() {
    final completion = _userProfile?['profile']?['profile_completion'];
    if (completion == 1) return 1.0;

    // Calculate completion based on available data
    int filledFields = 0;
    int totalFields = 8;

    final profile = _userProfile?['profile'];
    if (profile != null) {
      if (profile['first_name'] != null &&
          profile['first_name'].isNotEmpty &&
          profile['first_name'] != 'N/A')
        filledFields++;
      if (profile['last_name'] != null &&
          profile['last_name'].isNotEmpty &&
          profile['last_name'] != 'N/A')
        filledFields++;
      if (profile['date_of_birth'] != null &&
          profile['date_of_birth'].isNotEmpty)
        filledFields++;
      if (profile['sex'] != null && profile['sex'].isNotEmpty) filledFields++;
      if (profile['address'] != null &&
          profile['address'].isNotEmpty &&
          profile['address'] != 'N/A')
        filledFields++;
      if (profile['contact_no'] != null &&
          profile['contact_no'].isNotEmpty &&
          profile['contact_no'] != 'N/A')
        filledFields++;
      if (profile['profile_picture'] != null &&
          profile['profile_picture'].isNotEmpty)
        filledFields++;
      if (_userProfile?['email'] != null && _userProfile!['email'].isNotEmpty)
        filledFields++;
    }

    return filledFields / totalFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Header with Gradient Background
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Back Button
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      // Title
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: const Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Edit Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            // Handle edit action
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Below Header
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 150, 20, 20),
                        child: Column(
                          children: [
                            // Personal Information Card
                            _buildPersonalInfoCard(),

                            const SizedBox(height: 24),

                            // Profile Completion Card
                            _buildProfileCompletionCard(),

                            const SizedBox(height: 24),

                            // Education Section
                            _buildEducationSection(),

                            const SizedBox(height: 24),

                            // Skills Section
                            _buildSkillsSection(),

                            const SizedBox(height: 24),

                            // Work Experience Section
                            _buildWorkExperienceSection(),

                            const SizedBox(height: 24),

                            // Contact Section
                            _buildContactSection(),

                            const SizedBox(height: 32),

                            // Sign Out Button - NEW ADDITION
                            _buildSignOutButton(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // Fixed Header Section - Profile Image + Name + Gradient Overlay
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 130,
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Text(
                        _getFullName(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                IgnorePointer(
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(1.0),
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile Image
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _getProfileImageUrl().isNotEmpty
                      ? Image.network(
                          _getProfileImageUrl(),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationHelper.createBottomNavBar(context, 3),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Age', _getAge()),
          _buildInfoRow(
            'Gender',
            _userProfile?['profile']?['sex']?.toString().toUpperCase() ??
                'Not specified',
          ),
          _buildInfoRow('Address', _getAddress()),
          _buildInfoRow(
            'Date of Birth',
            _formatDate(_userProfile?['profile']?['date_of_birth']),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    final completion = _getProfileCompletion();
    final percentage = (completion * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: completion >= 0.8
                          ? AppColors.primary
                          : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: completion >= 0.8
                          ? AppColors.primary
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completion,
              child: Container(
                decoration: BoxDecoration(
                  color: completion >= 0.8 ? AppColors.primary : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    final education =
        _userProfile?['profile']?['education'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Educational Background',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Icon(Icons.edit, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (education.isEmpty)
            Text(
              'No education information added yet.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            ...education.map((edu) => _buildEducationItem(edu)).toList(),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> education) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            education['school_name'] ?? 'School Name Not Available',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Duration',
            _formatEducationDuration(
              education['start_date'],
              education['end_date'],
            ),
          ),
          _buildInfoRow(
            'Degree/Program',
            education['education_level'] ?? 'Not specified',
          ),
          _buildInfoRow(
            'Field of Study',
            education['field_of_study'] ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = _userProfile?['profile']?['skills'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skills & Expertise',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Icon(Icons.edit, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (skills.isEmpty)
            Text(
              'No skills added yet.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: skills.map((skill) => _buildSkillChip(skill)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(Map<String, dynamic> skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill['skill_name'] ?? 'Skill',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          if (skill['proficiency_level'] != null)
            Text(
              '(${skill['proficiency_level']})',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkExperienceSection() {
    final experience =
        _userProfile?['profile']?['work_experience'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Work Experience',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Icon(Icons.edit, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (experience.isEmpty)
            Text(
              'No work experience added yet.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            ...experience.map((exp) => _buildExperienceItem(exp)).toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> experience) {
    final jobTitle = experience['job_title'];
    final companyName = experience['company_name'];

    // Skip if both are N/A or empty
    if ((jobTitle == null || jobTitle == 'N/A' || jobTitle.isEmpty) &&
        (companyName == null || companyName == 'N/A' || companyName.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jobTitle ?? 'Position Not Specified',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            companyName ?? 'Company Not Specified',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Duration',
            _formatWorkDuration(
              experience['start_date'],
              experience['end_date'],
              experience['currently_working'],
            ),
          ),
          if (experience['employment_type'] != null)
            _buildInfoRow('Type', experience['employment_type']),
          if (experience['responsibilities'] != null &&
              experience['responsibilities'] != 'N/A')
            _buildInfoRow('Responsibilities', experience['responsibilities']),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),

        // Email Contact
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _getEmail(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Phone Contact
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.phone_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _getPhoneNumber(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not provided';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatEducationDuration(String? startDate, String? endDate) {
    if (startDate == null || startDate.isEmpty) return 'Not specified';

    try {
      final start = DateTime.parse(startDate);
      String duration = '${start.year}';

      if (endDate != null && endDate.isNotEmpty) {
        final end = DateTime.parse(endDate);
        duration += ' - ${end.year}';
      } else {
        duration += ' - Present';
      }

      return duration;
    } catch (e) {
      return 'Not specified';
    }
  }

  String _formatWorkDuration(
    String? startDate,
    String? endDate,
    dynamic currentlyWorking,
  ) {
    if (startDate == null || startDate.isEmpty) return 'Not specified';

    try {
      final start = DateTime.parse(startDate);
      String duration = '${start.month}/${start.year}';

      if (currentlyWorking == 1 || currentlyWorking == true) {
        duration += ' - Present';
      } else if (endDate != null && endDate.isNotEmpty) {
        final end = DateTime.parse(endDate);
        duration += ' - ${end.month}/${end.year}';
      } else {
        duration += ' - Not specified';
      }

      return duration;
    } catch (e) {
      return 'Not specified';
    }
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _showSignOutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _signOut() {
    // Clear user session
    UserSession.instance.clearUserData();

    // Navigate to welcome screen and clear all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }
}
