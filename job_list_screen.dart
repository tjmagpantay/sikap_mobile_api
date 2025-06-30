import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sikap/utils/colors.dart';
import 'package:sikap/widgets/navigation_helper.dart';
import 'package:sikap/pages/job_detail_screen.dart';

class JobList extends StatelessWidget {
  const JobList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: StickySearchDelegate(),
            ),

            // Job Cards List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final jobs = [
                      {
                        'companyName': 'Atlassian',
                        'jobTitle': 'Product Designer',
                        'location': 'Manila, Philippines',
                        'jobTypes': ['Freelance', 'Full-time'],
                        'isGradient': false,
                      },
                      {
                        'companyName': 'Atlassian',
                        'jobTitle': 'Product Designer',
                        'location': 'Manila, Philippines',
                        'jobTypes': ['Freelance', 'Full-time'],
                        'isGradient': false,
                      },
                      {
                        'companyName': 'Atlassian',
                        'jobTitle': 'Product Designer',
                        'location': 'Manila, Philippines',
                        'jobTypes': ['Freelance', 'Full-time'],
                        'isGradient': false,
                      },
                      {
                        'companyName': 'Atlassian',
                        'jobTitle': 'Product Designer',
                        'location': 'Manila, Philippines',
                        'jobTypes': ['Freelance', 'Full-time'],
                        'isGradient': false,
                      },
                      {
                        'companyName': 'Atlassian',
                        'jobTitle': 'Product Designer',
                        'location': 'Manila, Philippines',
                        'jobTypes': ['Freelance', 'Full-time'],
                        'isGradient': false,
                      },
                    ];

                    if (index >= jobs.length) return null;

                    final job = jobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildJobCard(
                        context: context,
                        companyName: job['companyName'] as String,
                        jobTitle: job['jobTitle'] as String,
                        location: job['location'] as String,
                        jobTypes: job['jobTypes'] as List<String>,
                        isGradient: job['isGradient'] as bool,
                      ),
                    );
                  },
                  childCount: 5,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Extra space for bottom navbar
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationHelper.createBottomNavBar(context, 1),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required String companyName,
    required String jobTitle,
    required String location,
    required List<String> jobTypes,
    required bool isGradient,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to job detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JobDetailScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBFF), // Light blue background
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with company info and bookmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFF0052CC), // Atlassian blue
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Company Name and Job Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.placeholderBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Product Designer',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bookmark Icon
                Icon(
                  Icons.bookmark,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.placeholderBlue,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.placeholderBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Job Types
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Freelance',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Full-time',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom delegate for sticky search bar
class StickySearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 100.0;

  @override
  double get maxExtent => 100.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 100.0,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        height: 64.0,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Search job or company...',
            hintStyle: const TextStyle(
              color: AppColors.placeholderBlue,
              fontFamily: 'Inter',
              fontSize: 16,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.placeholderBlue,
                  BlendMode.srcIn,
                ),
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.search,
                    color: AppColors.placeholderBlue,
                    size: 20,
                  );
                },
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 20,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
