import 'package:flutter/material.dart';
import 'package:sikap/pages/splash_screen.dart';
import 'package:sikap/pages/home_screen.dart';
import 'package:sikap/pages/job_list_screen.dart';
import 'package:sikap/pages/saved_jobs.dart';
import 'package:sikap/pages/profile_screen.dart';
import 'try.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sikap',
      theme: ThemeData(fontFamily: 'Inter'),
      home: const Try(), // Temporarily use Try page for testing
      routes: {
        '/home': (context) => const HomePage(),
        '/jobs': (context) => const JobList(),
        '/saved': (context) => const SavedJobs(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}