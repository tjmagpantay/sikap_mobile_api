# SIKAP Job Portal API - Flutter Integration Guide

This API provides endpoints for the SIKAP job portal Flutter app to connect with the MariaDB database.

## 🚀 Quick Setup

### 1. Database Configuration

1. Make sure XAMPP is running (Apache + MySQL)
2. Your database `sikap_db` should already be set up
3. Update `/config/.env` with your database credentials:

```
DB_HOST=localhost
DB_NAME=sikap_db
DB_USER=root
DB_PASS=
```

### 2. Test Your Setup

Visit: `http://localhost/sikap_api/php/test_connection.php`

- You should see a success message with database connection info

### 3. Flutter Integration

#### Step 1: Add HTTP Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

#### Step 2: Copy API Service Files

Copy these files to your Flutter project:

- `lib/services/api_service.dart`
- `lib/services/user_session.dart`

#### Step 3: Update Your Login Page

Your login page should call the API and handle the response:

```dart
// In your login button onPressed:
final result = await ApiService.login(email, password);
if (result['success']) {
  UserSession.instance.setUserData(result['user']);
  Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => const HomePage())
  );
}
```

## 📱 Available APIs

### Authentication

- **POST** `/login.php` - User login
- **POST** `/register.php` - User registration

### Job Posts

- **GET** `/get_jobpost.php` - Get all job posts
- **GET** `/get_job_details.php?job_id={id}` - Get specific job details

### User Profile

- **GET** `/get_user_profile.php?user_id={id}` - Get user profile

### Saved Jobs

- **GET** `/get_saved_jobpost.php?jobseeker_id={id}` - Get user's applications

### Utilities

- **GET** `/get_categories.php` - Get job categories
- **GET** `/test_connection.php` - Test database connection

## 🔧 Integration Steps for Your Flutter App

### 1. Update Login Screen

Replace the hardcoded navigation with API call:

```dart
// Replace this:
Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));

// With this:
await _handleLogin(); // Your new login method
```

### 2. Update Home Screen

Make it dynamic to show real user data and job posts:

```dart
class HomePage extends StatefulWidget {
  // Load user data from UserSession
  // Load job posts from API
  // Display dynamic content
}
```

### 3. Test with Real Data

Use existing test accounts:

- **Jobseeker**: `jobseeker@test.com` / password from your database
- **Employer**: `employer@test.com` / password from your database

## 📋 Next Steps

1. **Test Database Connection**: Visit the test connection URL
2. **Add HTTP Package**: Update your Flutter pubspec.yaml
3. **Copy Service Files**: Add the API service files to your Flutter project
4. **Update Login**: Integrate real login functionality
5. **Update Home**: Make home screen dynamic
6. **Test Login**: Try logging in with test accounts

## 🛠 Troubleshooting

### Database Connection Issues

- Check XAMPP is running
- Verify database name in `.env` file
- Test connection using the test endpoint

### Flutter HTTP Issues

- Ensure `http` package is added to pubspec.yaml
- Check your Android emulator can reach `10.0.2.2`
- For physical device, replace with your computer's IP address

### API Response Issues

- Check browser network tab for actual API responses
- Verify JSON structure matches your Flutter code expectations

## 📝 Example Usage

### Login Flow

```dart
// 1. User enters credentials
// 2. Call ApiService.login(email, password)
// 3. If successful, store in UserSession
// 4. Navigate to HomePage
// 5. HomePage loads user data and job posts
```

### Home Screen Flow

```dart
// 1. Get user name from UserSession
// 2. Load job posts from API
// 3. Display dynamic greeting and job cards
// 4. Handle loading states
```

Your Flutter app is now ready to connect with your MariaDB database through these PHP APIs! 🎉
