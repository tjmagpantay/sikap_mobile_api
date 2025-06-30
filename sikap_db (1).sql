-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 30, 2025 at 03:28 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sikap_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `accreditation`
--

CREATE TABLE `accreditation` (
  `accreditation_id` int(11) NOT NULL,
  `employer_id` int(11) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `accreditation`
--

INSERT INTO `accreditation` (`accreditation_id`, `employer_id`, `status`, `reviewed_by`, `reviewed_at`, `notes`, `created_at`, `updated_at`) VALUES
(1, 2, 'approved', 1, '2025-06-16 02:12:45', '', '2025-06-15 17:53:42', '2025-06-15 18:12:45'),
(2, 3, 'approved', 1, '2025-06-30 20:40:48', '', '2025-06-30 12:30:44', '2025-06-30 12:40:48');

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `admin_name` varchar(100) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `user_id`, `admin_name`, `createdAt`, `updatedAt`) VALUES
(1, 1, 'Admin Test', '2025-06-12 03:56:22', '2025-06-12 03:56:22');

-- --------------------------------------------------------

--
-- Table structure for table `application_attachments`
--

CREATE TABLE `application_attachments` (
  `attachment_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` enum('CV','Resume','Portfolio','Certificate','Transcript','Others') DEFAULT 'Others',
  `uploaded_at` datetime DEFAULT current_timestamp(),
  `profile_document_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `application_attachments`
--

INSERT INTO `application_attachments` (`attachment_id`, `application_id`, `file_path`, `file_type`, `uploaded_at`, `profile_document_id`) VALUES
(2, 1, 'uploads/documents/1_cv_1749719198.pdf', 'CV', '2025-06-19 19:54:20', 3),
(3, 2, 'uploads/documents/1_resume_1750366062.pdf', 'Resume', '2025-06-26 23:43:07', 4),
(4, 2, 'uploads/documents/1_cv_1749719198.pdf', 'CV', '2025-06-26 23:43:07', 3);

-- --------------------------------------------------------

--
-- Table structure for table `employer`
--

CREATE TABLE `employer` (
  `employer_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `contact_no` varchar(20) DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `company_name` varchar(100) DEFAULT NULL,
  `about_us` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `profile_completed` tinyint(1) DEFAULT 0,
  `status` enum('incomplete','pending_verification','verified','rejected','suspended') DEFAULT 'incomplete'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employer`
--

INSERT INTO `employer` (`employer_id`, `user_id`, `first_name`, `middle_name`, `last_name`, `position`, `contact_no`, `profile_picture`, `company_name`, `about_us`, `created_at`, `updated_at`, `profile_completed`, `status`) VALUES
(2, 3, 'Maria', 'Angela', 'Perez', 'Recruitment Lead', '09171234567', NULL, 'Google Philippines', 'Google is a global technology leader focused on improving the ways people connect with information. In the Philippines, Google supports a growing community of professionals and innovators by delivering tools and platforms that empower businesses, developers, and users.', '2025-06-12 21:46:45', '2025-06-30 21:02:11', 1, 'pending_verification'),
(3, 5, 'Ana', 'Reyes', 'Cruz', 'Recruitment Lead', '+639178901234', NULL, 'Atlassian', 'Atlassian is a leading provider of collaboration and productivity software for teams. Our mission is to unleash the potential of every team through tools like Jira, Confluence, Trello, and Bitbucket. Headquartered in Sydney, Australia, Atlassian empowers agile teams worldwide.', '2025-06-30 20:13:38', '2025-06-30 20:40:48', 1, 'verified');

-- --------------------------------------------------------

--
-- Table structure for table `employers_business`
--

CREATE TABLE `employers_business` (
  `business_id` int(11) NOT NULL,
  `employer_id` int(11) NOT NULL,
  `banner_image` text DEFAULT NULL,
  `business_name` varchar(100) DEFAULT NULL,
  `business_logo` text DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `business_type` enum('Corporation','Partnership','Sole Proprietorship','Non-Profit') NOT NULL,
  `business_size` enum('micro','small','medium','large') DEFAULT NULL,
  `business_desc` text DEFAULT NULL,
  `business_email` varchar(100) DEFAULT NULL,
  `business_contact` varchar(20) DEFAULT NULL,
  `business_industry` varchar(100) DEFAULT NULL,
  `business_team_size` varchar(50) DEFAULT NULL,
  `business_established_year` date DEFAULT NULL,
  `business_website` varchar(255) DEFAULT NULL,
  `business_socials` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`business_socials`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employers_business`
--

INSERT INTO `employers_business` (`business_id`, `employer_id`, `banner_image`, `business_name`, `business_logo`, `business_address`, `business_type`, `business_size`, `business_desc`, `business_email`, `business_contact`, `business_industry`, `business_team_size`, `business_established_year`, `business_website`, `business_socials`, `created_at`, `updated_at`) VALUES
(1, 2, 'uploads/profile_pictures/business_banner_3_1751288392.jpg', 'Google Philippines Inc.', 'uploads/profile_pictures/business_logo_3_1751288392.jpg', '8th Floor, Net Park Building, 5th Ave, BGC, Taguig, Metro Manila', 'Corporation', '', 'Google Philippines Inc. operates as part of Google\'s Asia Pacific network, promoting the use of digital tools and supporting the local digital economy through outreach, education, and innovation.', 'philippines@google.com', '(02) 1234 5678', 'Technology', NULL, '2025-11-01', 'https://www.google.com.ph', '{\"facebook\":\"https:\\/\\/www.facebook.com\\/Google\",\"twitter\":\"https:\\/\\/twitter.com\\/google\"}', '2025-06-12 22:09:18', '2025-06-30 21:00:56'),
(2, 3, 'uploads/profile_pictures/business_banner_5_1751286469.jpg', 'Atlassian', 'uploads/profile_pictures/business_logo_5_1751286469.png', '34th Street, Bonifacio Global City, Taguig, Metro Manila', 'Corporation', '', 'Atlassian builds tools that help teams work smarter and faster. We are passionate about technology, transparency, and empowering teams to collaborate globally.', 'careers@atlassian.com', '0288123456', 'Technology', NULL, '2002-01-01', 'https://www.atlassian.com', '{\"facebook\":\"https:\\/\\/www.facebook.com\\/Atlassian\"}', '2025-06-30 20:27:49', '2025-06-30 20:29:22');

-- --------------------------------------------------------

--
-- Table structure for table `employer_documents`
--

CREATE TABLE `employer_documents` (
  `req_doc_id` int(11) NOT NULL,
  `employer_id` int(11) NOT NULL,
  `letter_of_intent` varchar(100) DEFAULT NULL,
  `company_profile` varchar(100) DEFAULT NULL,
  `business_permit` varchar(100) DEFAULT NULL,
  `cert_of_no_pending_case` varchar(100) DEFAULT NULL,
  `dole_registration` varchar(100) DEFAULT NULL,
  `cert_no_objection` varchar(100) DEFAULT NULL,
  `poea_reg` varchar(100) DEFAULT NULL,
  `job_vaccancies_qual` varchar(100) DEFAULT NULL,
  `phil_jobnet_reg` varchar(100) DEFAULT NULL,
  `upload_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employer_documents`
--

INSERT INTO `employer_documents` (`req_doc_id`, `employer_id`, `letter_of_intent`, `company_profile`, `business_permit`, `cert_of_no_pending_case`, `dole_registration`, `cert_no_objection`, `poea_reg`, `job_vaccancies_qual`, `phil_jobnet_reg`, `upload_date`) VALUES
(1, 2, 'uploads/documents/letter_of_intent_3_1751288526.pdf', 'uploads/documents/company_profile_3_1751288526.pdf', 'uploads/documents/business_permit_3_1751288526.pdf', 'uploads/documents/cert_of_no_pending_case_3_1751288526.pdf', 'uploads/documents/dole_registration_3_1751288526.pdf', 'uploads/documents/cert_no_objection_3_1751288526.pdf', 'uploads/documents/poea_reg_3_1751288526.pdf', 'uploads/documents/job_vaccancies_qual_3_1751288526.pdf', 'uploads/documents/phil_jobnet_reg_3_1751288527.pdf', '2025-06-30 13:02:07'),
(2, 3, 'uploads/documents/letter_of_intent_5_1751286639.pdf', 'uploads/documents/company_profile_5_1751286639.pdf', 'uploads/documents/business_permit_5_1751286639.pdf', 'uploads/documents/cert_of_no_pending_case_5_1751286639.pdf', 'uploads/documents/dole_registration_5_1751286639.pdf', 'uploads/documents/cert_no_objection_5_1751286639.pdf', 'uploads/documents/poea_reg_5_1751286639.pdf', 'uploads/documents/job_vaccancies_qual_5_1751286639.pdf', 'uploads/documents/phil_jobnet_reg_5_1751286639.pdf', '2025-06-30 12:30:39');

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker`
--

CREATE TABLE `jobseeker` (
  `jobseeker_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) NOT NULL,
  `suffix` varchar(50) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `sex` enum('male','female','other') DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `contact_no` varchar(20) DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `profile_completion` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `profile_completed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobseeker`
--

INSERT INTO `jobseeker` (`jobseeker_id`, `user_id`, `first_name`, `middle_name`, `last_name`, `suffix`, `date_of_birth`, `sex`, `address`, `contact_no`, `profile_picture`, `profile_completion`, `created_at`, `updated_at`, `profile_completed`) VALUES
(1, 2, 'Alex ', 'Ansusinha', 'Albon', '', '1996-03-23', 'male', 'Rosario San Jose', '09192083485', 'uploads/profile_pictures/profile_2_1751289891.png', 1, '2025-06-12 17:06:38', '2025-06-30 21:24:51', 1),
(2, 4, 'N/A', '', 'N/A', '', '2025-06-11', 'female', ' ', 'N/A', NULL, 1, '2025-06-13 18:44:13', '2025-06-13 18:50:34', 1);

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker_certificates`
--

CREATE TABLE `jobseeker_certificates` (
  `certificate_id` int(11) NOT NULL,
  `jobseeker_id` int(11) DEFAULT NULL,
  `certificate_title` varchar(255) DEFAULT NULL,
  `issuing_organization` varchar(255) DEFAULT NULL,
  `date_issued` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobseeker_certificates`
--

INSERT INTO `jobseeker_certificates` (`certificate_id`, `jobseeker_id`, `certificate_title`, `issuing_organization`, `date_issued`) VALUES
(1, 1, '', '', '0000-00-00'),
(2, 1, '', '', '0000-00-00'),
(3, 2, '', '', '0000-00-00'),
(4, 1, '', '', '0000-00-00');

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker_documents`
--

CREATE TABLE `jobseeker_documents` (
  `document_id` int(11) NOT NULL,
  `jobseeker_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` enum('resume','cv','certificate','other') NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobseeker_documents`
--

INSERT INTO `jobseeker_documents` (`document_id`, `jobseeker_id`, `file_name`, `file_path`, `file_type`, `uploaded_at`) VALUES
(3, 1, 'jobseeker_cv.pdf', 'uploads/documents/1_cv_1749719198.pdf', 'cv', '2025-06-12 17:06:38'),
(4, 1, 'jobseeker_resume - Copy.pdf', 'uploads/documents/1_resume_1750366062.pdf', 'resume', '2025-06-20 04:47:42');

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker_education`
--

CREATE TABLE `jobseeker_education` (
  `education_id` int(11) NOT NULL,
  `jobseeker_id` int(11) NOT NULL,
  `school_name` varchar(255) NOT NULL,
  `education_level` enum('High School','Vocational','Associate','Bachelor','Master','Doctorate') NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `field_of_study` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobseeker_education`
--

INSERT INTO `jobseeker_education` (`education_id`, `jobseeker_id`, `school_name`, `education_level`, `start_date`, `end_date`, `field_of_study`) VALUES
(1, 1, 'BSU', 'Bachelor', '2021-01-01', '2025-12-31', 'Information Technology'),
(2, 2, '', '', NULL, NULL, ''),
(3, 1, '', '', NULL, NULL, ''),
(4, 1, 'BSU', 'Bachelor', '2010-01-01', '2016-12-31', 'Information Technology');

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker_preferences`
--

CREATE TABLE `jobseeker_preferences` (
  `preference_id` int(11) NOT NULL,
  `jobseeker_id` int(11) NOT NULL,
  `preference_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker_skills`
--

CREATE TABLE `jobseeker_skills` (
  `skill_id` int(11) NOT NULL,
  `jobseeker_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `proficiency_level` enum('Beginner','Intermediate','Advanced','Expert') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobseeker_skills`
--

INSERT INTO `jobseeker_skills` (`skill_id`, `jobseeker_id`, `skill_name`, `proficiency_level`) VALUES
(1, 1, 'Coding', 'Intermediate'),
(2, 1, 'Driving Skills', 'Expert');

-- --------------------------------------------------------

--
-- Table structure for table `jobseeker_work_experience`
--

CREATE TABLE `jobseeker_work_experience` (
  `experience_id` int(11) NOT NULL,
  `jobseeker_id` int(11) NOT NULL,
  `job_title` varchar(100) NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `responsibilities` text DEFAULT NULL,
  `achievements` text DEFAULT NULL,
  `employment_type` enum('Full-Time','Part-Time','Contract','Freelance','Internship') DEFAULT NULL,
  `currently_working` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobseeker_work_experience`
--

INSERT INTO `jobseeker_work_experience` (`experience_id`, `jobseeker_id`, `job_title`, `company_name`, `start_date`, `end_date`, `responsibilities`, `achievements`, `employment_type`, `currently_working`) VALUES
(1, 1, 'N/A', 'N/A', '2025-06-01', '2025-06-10', 'N/A', NULL, 'Internship', 0),
(2, 1, 'N/A', 'N/A', NULL, NULL, 'N/A', NULL, '', 0),
(3, 1, 'N/A', 'N/A', '2025-06-01', '2025-06-10', 'N/A', NULL, '', 0),
(4, 2, '', '', '0000-00-00', '0000-00-00', 'N/A', NULL, '', 0),
(5, 2, '', '', NULL, NULL, '', NULL, '', 0),
(6, 1, 'N/A', 'N/A', '2025-06-01', '2025-06-10', 'N/A', NULL, '', 0),
(7, 1, '', '', NULL, NULL, '', NULL, '', 0),
(8, 1, 'F1 Driver', 'Williams Racing', '2025-06-01', '2029-12-10', 'N/A', NULL, 'Full-Time', 0),
(9, 1, 'Professional Driver', 'Williams Racing', '2019-01-01', '2025-12-31', 'Driver', NULL, '', 0);

-- --------------------------------------------------------

--
-- Table structure for table `job_application`
--

CREATE TABLE `job_application` (
  `application_id` int(11) NOT NULL,
  `jobseeker_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `application_status` enum('pending','reviewed','shortlisted','rejected','hired') DEFAULT 'pending',
  `applied_at` datetime DEFAULT current_timestamp(),
  `reviewed_at` datetime DEFAULT NULL,
  `is_finalized` tinyint(1) DEFAULT 0,
  `current_step` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_application`
--

INSERT INTO `job_application` (`application_id`, `jobseeker_id`, `job_id`, `application_status`, `applied_at`, `reviewed_at`, `is_finalized`, `current_step`) VALUES
(1, 1, 3, 'pending', '2025-06-19 13:54:45', NULL, 1, 4),
(2, 1, 5, 'pending', '2025-06-26 17:43:32', NULL, 1, 4);

-- --------------------------------------------------------

--
-- Table structure for table `job_application_answers`
--

CREATE TABLE `job_application_answers` (
  `answer_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_application_eligibility`
--

CREATE TABLE `job_application_eligibility` (
  `eligibility_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `interested_program` enum('None','SPES','TUPAD','GIP') DEFAULT 'None',
  `priority_sector` enum('None','PWD','4Ps','Solo Parent','Senior Citizen','Youth') DEFAULT 'None'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_application_eligibility`
--

INSERT INTO `job_application_eligibility` (`eligibility_id`, `application_id`, `interested_program`, `priority_sector`) VALUES
(1, 1, 'None', 'None'),
(2, 2, 'None', 'None');

-- --------------------------------------------------------

--
-- Table structure for table `job_application_status_logs`
--

CREATE TABLE `job_application_status_logs` (
  `log_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `status` enum('pending','reviewed','shortlisted','rejected','hired') DEFAULT NULL,
  `changed_by_role` enum('jobseeker','employer','admin') DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_application_status_logs`
--

INSERT INTO `job_application_status_logs` (`log_id`, `application_id`, `status`, `changed_by_role`, `changed_at`, `remarks`) VALUES
(1, 1, 'pending', 'jobseeker', '2025-06-19 19:54:45', 'Application submitted'),
(2, 2, 'pending', 'jobseeker', '2025-06-26 23:43:32', 'Application submitted');

-- --------------------------------------------------------

--
-- Table structure for table `job_category`
--

CREATE TABLE `job_category` (
  `job_category_id` int(11) NOT NULL,
  `category_name` enum('IT','Healthcare','Education','Engineering','Finance','Marketing','Construction','Others') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_category`
--

INSERT INTO `job_category` (`job_category_id`, `category_name`) VALUES
(1, 'IT'),
(2, 'Healthcare'),
(3, 'Education'),
(4, 'Engineering'),
(5, 'Finance'),
(6, 'Marketing'),
(7, 'Construction'),
(8, 'Others');

-- --------------------------------------------------------

--
-- Table structure for table `job_post`
--

CREATE TABLE `job_post` (
  `job_id` int(11) NOT NULL,
  `employer_id` int(11) NOT NULL,
  `posted_by_role` enum('employer','admin') NOT NULL,
  `job_title` varchar(100) NOT NULL,
  `job_category_id` int(11) NOT NULL,
  `job_status` enum('open','closed','draft','paused') DEFAULT 'open',
  `job_type` enum('full-time','part-time','contract','internship','freelance') NOT NULL,
  `salary` decimal(10,2) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `workplace_option` enum('onsite','remote','hybrid') DEFAULT 'onsite',
  `pay_type` enum('monthly','hourly','weekly','project-based') DEFAULT NULL,
  `pay_range` varchar(100) DEFAULT NULL,
  `show_pay` tinyint(1) DEFAULT 1,
  `job_summary` text DEFAULT NULL,
  `full_description` text DEFAULT NULL,
  `application_start` datetime DEFAULT NULL,
  `application_deadline` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_post`
--

INSERT INTO `job_post` (`job_id`, `employer_id`, `posted_by_role`, `job_title`, `job_category_id`, `job_status`, `job_type`, `salary`, `location`, `workplace_option`, `pay_type`, `pay_range`, `show_pay`, `job_summary`, `full_description`, `application_start`, `application_deadline`, `created_at`, `updated_at`) VALUES
(3, 2, 'employer', 'Data Analyst Intern', 1, 'open', 'full-time', NULL, 'Manila', 'onsite', 'monthly', '20,000 - 40,000', 1, 'Google’s internship program offers students the opportunity to gain hands-on experience working with large datasets and real-time insights.', 'As a Data Analyst Intern, you\'ll assist the data science team in analyzing user behavior and helping improve product performance using tools like SQL, Python, and Google Data Studio.', '2025-06-17 02:45:00', '2025-12-31 23:59:59', '2025-06-17 08:45:59', '2025-06-30 13:09:11'),
(5, 2, 'employer', 'Front-End Developer', 1, 'open', 'full-time', NULL, 'Taguig, Metro Manila', 'hybrid', 'monthly', '70,000 - 90,000', 1, 'Google Philippines is looking for a talented front-end developer to join our product engineering team to help improve user experiences across our web platforms.', 'You will be responsible for building user-friendly web interfaces using React, TypeScript, and modern front-end frameworks. Collaborate with cross-functional teams, ensure accessibility, and write scalable, maintainable code.', '2025-06-26 17:41:00', '2025-12-31 23:59:59', '2025-06-26 23:42:14', '2025-06-30 13:08:05'),
(6, 3, 'employer', 'Junior Backend Developer', 1, 'open', 'full-time', NULL, 'Makati City', 'hybrid', 'monthly', '20,000 - 40,000', 1, 'Join our team to develop and maintain backend services for our web platform.', 'We are looking for a passionate Junior Backend Developer with knowledge in PHP, Laravel, and SQL. You will help build robust APIs, troubleshoot system issues, and collaborate closely with front-end developers and designers.', '2025-06-30 14:42:00', '2025-11-25 08:46:00', '2025-06-30 20:46:31', '2025-06-30 12:48:49'),
(7, 3, 'employer', 'Marketing Assistant (Entry-Level)', 6, 'open', 'full-time', NULL, 'Quezon City', 'onsite', NULL, NULL, 1, 'Support the marketing team with campaign coordination, content planning, and customer engagement.\'', 'We’re seeking an energetic entry-level Marketing Assistant to help execute marketing campaigns and create content for social media platforms. Must be creative, detail-oriented, and eager to learn digital marketing tools.', '2025-06-30 14:49:00', '2025-12-30 20:50:00', '2025-06-30 20:51:05', '2025-06-30 12:51:43');

-- --------------------------------------------------------

--
-- Table structure for table `job_post_application_settings`
--

CREATE TABLE `job_post_application_settings` (
  `setting_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `resume_required` tinyint(1) DEFAULT 1,
  `allow_cover_letter` tinyint(1) DEFAULT 1,
  `screening_questions_enabled` tinyint(1) DEFAULT 1,
  `max_applicants` int(11) DEFAULT NULL,
  `notify_on_new_application` tinyint(1) DEFAULT 1,
  `is_highlighted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_post_application_settings`
--

INSERT INTO `job_post_application_settings` (`setting_id`, `job_id`, `resume_required`, `allow_cover_letter`, `screening_questions_enabled`, `max_applicants`, `notify_on_new_application`, `is_highlighted`) VALUES
(1, 3, 1, 1, 0, NULL, 1, 0),
(3, 5, 1, 1, 0, NULL, 1, 0),
(4, 6, 1, 1, 0, NULL, 1, 0),
(5, 7, 1, 1, 0, NULL, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `job_post_attachments`
--

CREATE TABLE `job_post_attachments` (
  `attachment_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_post_attachments`
--

INSERT INTO `job_post_attachments` (`attachment_id`, `job_id`, `file_path`) VALUES
(2, 6, 'uploads/job_attachments/6862875199920_1751287633.pdf'),
(3, 7, 'uploads/job_attachments/6862884195315_1751287873.pdf'),
(4, 5, 'uploads/job_attachments/68628c1c7b61b_1751288860.pdf');

-- --------------------------------------------------------

--
-- Table structure for table `job_post_questions`
--

CREATE TABLE `job_post_questions` (
  `question_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('text','radio','checkbox','dropdown') NOT NULL,
  `question_option` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_post_questions`
--

INSERT INTO `job_post_questions` (`question_id`, `job_id`, `question_text`, `question_type`, `question_option`) VALUES
(3, 6, 'Do you have experience with Laravel?', 'dropdown', 'Yes, No'),
(4, 6, 'Which back-end technologies have you worked with?', 'checkbox', 'PHP,Node.js,Python,Java'),
(5, 6, 'What is your expected monthly salary?', 'text', NULL),
(6, 7, 'Have you managed a social media page before?', 'radio', 'Yes,No'),
(7, 5, 'What front-end frameworks are you experienced in?', 'text', NULL),
(8, 5, 'Can you provide a link to a portfolio or GitHub repo?', 'text', NULL),
(9, 3, 'What statistical tools or languages are you familiar with?', 'text', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `job_post_skills`
--

CREATE TABLE `job_post_skills` (
  `job_skill_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job_post_skills`
--

INSERT INTO `job_post_skills` (`job_skill_id`, `job_id`, `skill_name`) VALUES
(7, 6, 'Javascript'),
(8, 6, 'React and Angular'),
(9, 7, 'Social Media Marketing'),
(10, 7, 'Content Writing'),
(11, 7, 'Google Analytics'),
(12, 7, 'Communication'),
(13, 5, 'React'),
(14, 5, 'JavaScript'),
(15, 5, 'TypeScript'),
(16, 5, 'HTML/CSS'),
(17, 5, 'Responsive Design'),
(18, 5, 'Git'),
(19, 3, 'SQL'),
(20, 3, 'Python'),
(21, 3, 'Data Visualization'),
(22, 3, 'Google Sheets'),
(23, 3, 'Analytical Thinking');

-- --------------------------------------------------------

--
-- Table structure for table `req_document`
--

CREATE TABLE `req_document` (
  `req_doc_id` int(11) NOT NULL,
  `employer_id` int(11) NOT NULL,
  `letter_of_intent` varchar(100) DEFAULT NULL,
  `company_profile` varchar(100) DEFAULT NULL,
  `business_permit` varchar(100) DEFAULT NULL,
  `cert_of_no_pending_case` varchar(100) DEFAULT NULL,
  `dole_registration` varchar(100) DEFAULT NULL,
  `cert_no_objection` varchar(100) DEFAULT NULL,
  `poea_reg` varchar(100) DEFAULT NULL,
  `job_vaccancies_qual` varchar(100) DEFAULT NULL,
  `phil_jobnet_reg` varchar(100) DEFAULT NULL,
  `upload_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`) VALUES
(1, 'admin'),
(2, 'employer'),
(3, 'jobseeker');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` enum('active','inactive','pending') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `password`, `status`, `created_at`) VALUES
(1, 'admin@test.com', '$2y$10$m5quIMOO7EbLihE6kIrl1eDHW4HVS/77nPL/DfneeJGS8v1yCYuHa', 'active', '2025-06-12 03:56:22'),
(2, 'jobseeker@test.com', '$2y$10$Gq29w0FRqUM7D7NOtjk0TeZMaRNYOIpBX4lXnyvKU0/93zIqGcutW', 'active', '2025-06-12 03:57:02'),
(3, 'employer@test.com', '$2y$10$Rr5tmGgT17cGjeUU0Kn4zuT2aAXDVYXdGcz51od9xX97HSweIquGu', 'pending', '2025-06-12 03:57:51'),
(4, 'jobseeker@test2.com', '$2y$10$HxSwKsPjptytHgg66XWG6ud4fjGDHRJ.XP50d.8cedeRjspNlq.je', 'active', '2025-06-12 12:18:07'),
(5, 'ana@gmail.com', '$2y$10$cGxnv0T/yXXs9OCcVPTbBewJWHfSDN/zcgXARyCPjr7wDRQY2Z9Gy', 'pending', '2025-06-30 12:03:18');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_role_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_role_id`, `user_id`, `role_id`) VALUES
(1, 1, 1),
(2, 2, 3),
(3, 3, 2),
(4, 4, 3),
(5, 5, 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accreditation`
--
ALTER TABLE `accreditation`
  ADD PRIMARY KEY (`accreditation_id`),
  ADD KEY `employer_id` (`employer_id`),
  ADD KEY `reviewed_by` (`reviewed_by`);

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `application_attachments`
--
ALTER TABLE `application_attachments`
  ADD PRIMARY KEY (`attachment_id`),
  ADD KEY `application_id` (`application_id`),
  ADD KEY `application_attachments_ibfk_2` (`profile_document_id`);

--
-- Indexes for table `employer`
--
ALTER TABLE `employer`
  ADD PRIMARY KEY (`employer_id`),
  ADD KEY `fk_user_id` (`user_id`);

--
-- Indexes for table `employers_business`
--
ALTER TABLE `employers_business`
  ADD PRIMARY KEY (`business_id`),
  ADD KEY `fk_employer_id` (`employer_id`);

--
-- Indexes for table `employer_documents`
--
ALTER TABLE `employer_documents`
  ADD PRIMARY KEY (`req_doc_id`),
  ADD KEY `fk_employers_document_employer` (`employer_id`);

--
-- Indexes for table `jobseeker`
--
ALTER TABLE `jobseeker`
  ADD PRIMARY KEY (`jobseeker_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `jobseeker_certificates`
--
ALTER TABLE `jobseeker_certificates`
  ADD PRIMARY KEY (`certificate_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`);

--
-- Indexes for table `jobseeker_documents`
--
ALTER TABLE `jobseeker_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`);

--
-- Indexes for table `jobseeker_education`
--
ALTER TABLE `jobseeker_education`
  ADD PRIMARY KEY (`education_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`);

--
-- Indexes for table `jobseeker_preferences`
--
ALTER TABLE `jobseeker_preferences`
  ADD PRIMARY KEY (`preference_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`);

--
-- Indexes for table `jobseeker_skills`
--
ALTER TABLE `jobseeker_skills`
  ADD PRIMARY KEY (`skill_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`);

--
-- Indexes for table `jobseeker_work_experience`
--
ALTER TABLE `jobseeker_work_experience`
  ADD PRIMARY KEY (`experience_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`);

--
-- Indexes for table `job_application`
--
ALTER TABLE `job_application`
  ADD PRIMARY KEY (`application_id`),
  ADD KEY `jobseeker_id` (`jobseeker_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `job_application_answers`
--
ALTER TABLE `job_application_answers`
  ADD PRIMARY KEY (`answer_id`),
  ADD KEY `application_id` (`application_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `job_application_eligibility`
--
ALTER TABLE `job_application_eligibility`
  ADD PRIMARY KEY (`eligibility_id`),
  ADD KEY `application_id` (`application_id`);

--
-- Indexes for table `job_application_status_logs`
--
ALTER TABLE `job_application_status_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `application_id` (`application_id`);

--
-- Indexes for table `job_category`
--
ALTER TABLE `job_category`
  ADD PRIMARY KEY (`job_category_id`);

--
-- Indexes for table `job_post`
--
ALTER TABLE `job_post`
  ADD PRIMARY KEY (`job_id`),
  ADD KEY `employer_id` (`employer_id`),
  ADD KEY `job_category_id` (`job_category_id`);

--
-- Indexes for table `job_post_application_settings`
--
ALTER TABLE `job_post_application_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `job_post_attachments`
--
ALTER TABLE `job_post_attachments`
  ADD PRIMARY KEY (`attachment_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `job_post_questions`
--
ALTER TABLE `job_post_questions`
  ADD PRIMARY KEY (`question_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `job_post_skills`
--
ALTER TABLE `job_post_skills`
  ADD PRIMARY KEY (`job_skill_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `req_document`
--
ALTER TABLE `req_document`
  ADD PRIMARY KEY (`req_doc_id`),
  ADD KEY `fk_req_employer` (`employer_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_role_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `role_id` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accreditation`
--
ALTER TABLE `accreditation`
  MODIFY `accreditation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `application_attachments`
--
ALTER TABLE `application_attachments`
  MODIFY `attachment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `employer`
--
ALTER TABLE `employer`
  MODIFY `employer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `employers_business`
--
ALTER TABLE `employers_business`
  MODIFY `business_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `employer_documents`
--
ALTER TABLE `employer_documents`
  MODIFY `req_doc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobseeker`
--
ALTER TABLE `jobseeker`
  MODIFY `jobseeker_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobseeker_certificates`
--
ALTER TABLE `jobseeker_certificates`
  MODIFY `certificate_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobseeker_documents`
--
ALTER TABLE `jobseeker_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobseeker_education`
--
ALTER TABLE `jobseeker_education`
  MODIFY `education_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobseeker_preferences`
--
ALTER TABLE `jobseeker_preferences`
  MODIFY `preference_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobseeker_skills`
--
ALTER TABLE `jobseeker_skills`
  MODIFY `skill_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobseeker_work_experience`
--
ALTER TABLE `jobseeker_work_experience`
  MODIFY `experience_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `job_application`
--
ALTER TABLE `job_application`
  MODIFY `application_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `job_application_answers`
--
ALTER TABLE `job_application_answers`
  MODIFY `answer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job_application_eligibility`
--
ALTER TABLE `job_application_eligibility`
  MODIFY `eligibility_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `job_application_status_logs`
--
ALTER TABLE `job_application_status_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `job_category`
--
ALTER TABLE `job_category`
  MODIFY `job_category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `job_post`
--
ALTER TABLE `job_post`
  MODIFY `job_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `job_post_application_settings`
--
ALTER TABLE `job_post_application_settings`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `job_post_attachments`
--
ALTER TABLE `job_post_attachments`
  MODIFY `attachment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `job_post_questions`
--
ALTER TABLE `job_post_questions`
  MODIFY `question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `job_post_skills`
--
ALTER TABLE `job_post_skills`
  MODIFY `job_skill_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `req_document`
--
ALTER TABLE `req_document`
  MODIFY `req_doc_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `user_role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `accreditation`
--
ALTER TABLE `accreditation`
  ADD CONSTRAINT `accreditation_ibfk_1` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `accreditation_ibfk_2` FOREIGN KEY (`reviewed_by`) REFERENCES `admin` (`admin_id`) ON DELETE SET NULL;

--
-- Constraints for table `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `application_attachments`
--
ALTER TABLE `application_attachments`
  ADD CONSTRAINT `application_attachments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_application` (`application_id`),
  ADD CONSTRAINT `application_attachments_ibfk_2` FOREIGN KEY (`profile_document_id`) REFERENCES `jobseeker_documents` (`document_id`) ON DELETE CASCADE;

--
-- Constraints for table `employer`
--
ALTER TABLE `employer`
  ADD CONSTRAINT `employer_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `employers_business`
--
ALTER TABLE `employers_business`
  ADD CONSTRAINT `employers_business_ibfk_1` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_employer_id` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`) ON DELETE CASCADE;

--
-- Constraints for table `employer_documents`
--
ALTER TABLE `employer_documents`
  ADD CONSTRAINT `fk_employers_document_employer` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`) ON DELETE CASCADE;

--
-- Constraints for table `jobseeker`
--
ALTER TABLE `jobseeker`
  ADD CONSTRAINT `jobseeker_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `jobseeker_certificates`
--
ALTER TABLE `jobseeker_certificates`
  ADD CONSTRAINT `jobseeker_certificates_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`);

--
-- Constraints for table `jobseeker_documents`
--
ALTER TABLE `jobseeker_documents`
  ADD CONSTRAINT `jobseeker_documents_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`);

--
-- Constraints for table `jobseeker_education`
--
ALTER TABLE `jobseeker_education`
  ADD CONSTRAINT `jobseeker_education_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`) ON DELETE CASCADE;

--
-- Constraints for table `jobseeker_preferences`
--
ALTER TABLE `jobseeker_preferences`
  ADD CONSTRAINT `jobseeker_preferences_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`) ON DELETE CASCADE;

--
-- Constraints for table `jobseeker_skills`
--
ALTER TABLE `jobseeker_skills`
  ADD CONSTRAINT `jobseeker_skills_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`) ON DELETE CASCADE;

--
-- Constraints for table `jobseeker_work_experience`
--
ALTER TABLE `jobseeker_work_experience`
  ADD CONSTRAINT `jobseeker_work_experience_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`) ON DELETE CASCADE;

--
-- Constraints for table `job_application`
--
ALTER TABLE `job_application`
  ADD CONSTRAINT `job_application_ibfk_1` FOREIGN KEY (`jobseeker_id`) REFERENCES `jobseeker` (`jobseeker_id`),
  ADD CONSTRAINT `job_application_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `job_post` (`job_id`);

--
-- Constraints for table `job_application_answers`
--
ALTER TABLE `job_application_answers`
  ADD CONSTRAINT `job_application_answers_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_application` (`application_id`),
  ADD CONSTRAINT `job_application_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `job_post_questions` (`question_id`);

--
-- Constraints for table `job_application_eligibility`
--
ALTER TABLE `job_application_eligibility`
  ADD CONSTRAINT `job_application_eligibility_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_application` (`application_id`);

--
-- Constraints for table `job_application_status_logs`
--
ALTER TABLE `job_application_status_logs`
  ADD CONSTRAINT `job_application_status_logs_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_application` (`application_id`);

--
-- Constraints for table `job_post`
--
ALTER TABLE `job_post`
  ADD CONSTRAINT `job_post_ibfk_1` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`),
  ADD CONSTRAINT `job_post_ibfk_2` FOREIGN KEY (`job_category_id`) REFERENCES `job_category` (`job_category_id`);

--
-- Constraints for table `job_post_application_settings`
--
ALTER TABLE `job_post_application_settings`
  ADD CONSTRAINT `job_post_application_settings_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job_post` (`job_id`);

--
-- Constraints for table `job_post_attachments`
--
ALTER TABLE `job_post_attachments`
  ADD CONSTRAINT `job_post_attachments_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job_post` (`job_id`);

--
-- Constraints for table `job_post_questions`
--
ALTER TABLE `job_post_questions`
  ADD CONSTRAINT `job_post_questions_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job_post` (`job_id`);

--
-- Constraints for table `job_post_skills`
--
ALTER TABLE `job_post_skills`
  ADD CONSTRAINT `job_post_skills_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job_post` (`job_id`);

--
-- Constraints for table `req_document`
--
ALTER TABLE `req_document`
  ADD CONSTRAINT `fk_req_employer` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
