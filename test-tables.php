<?php
// filepath: c:\xampp\htdocs\sikap_api\test_api_direct.php
header('Content-Type: application/json');
require_once 'config/cors-headers.php';
require_once 'config/db_config.php';

$test_user_id = 2; // Alex's user_id

echo "<h2>Direct API Test for User ID: $test_user_id</h2>";

try {
    // Test direct database query
    $user_stmt = $conn->prepare("
        SELECT u.user_id, u.email, u.status, r.role_name 
        FROM users u
        JOIN user_roles ur ON u.user_id = ur.user_id
        JOIN roles r ON ur.role_id = r.role_id
        WHERE u.user_id = ?
    ");
    $user_stmt->bind_param("i", $test_user_id);
    $user_stmt->execute();
    $user_result = $user_stmt->get_result();

    if ($user_result->num_rows > 0) {
        $user_data = $user_result->fetch_assoc();
        echo "<h3>✅ User Data:</h3>";
        echo "<pre>" . print_r($user_data, true) . "</pre>";

        if ($user_data['role_name'] === 'jobseeker') {
            // Get jobseeker profile
            $profile_stmt = $conn->prepare("SELECT * FROM jobseeker WHERE user_id = ?");
            $profile_stmt->bind_param("i", $test_user_id);
            $profile_stmt->execute();
            $profile_result = $profile_stmt->get_result();

            if ($profile_result->num_rows > 0) {
                $profile_data = $profile_result->fetch_assoc();
                $jobseeker_id = $profile_data['jobseeker_id'];
                
                echo "<h3>✅ Jobseeker Profile:</h3>";
                echo "<pre>" . print_r($profile_data, true) . "</pre>";

                // Test education query
                $education = [];
                $education_stmt = $conn->prepare("SELECT * FROM jobseeker_education WHERE jobseeker_id = ?");
                $education_stmt->bind_param("i", $jobseeker_id);
                $education_stmt->execute();
                $education_result = $education_stmt->get_result();
                
                while ($row = $education_result->fetch_assoc()) {
                    $education[] = $row;
                }

                // Test skills query
                $skills = [];
                $skills_stmt = $conn->prepare("SELECT * FROM jobseeker_skills WHERE jobseeker_id = ?");
                $skills_stmt->bind_param("i", $jobseeker_id);
                $skills_stmt->execute();
                $skills_result = $skills_stmt->get_result();
                
                while ($row = $skills_result->fetch_assoc()) {
                    $skills[] = $row;
                }

                // Test work experience query
                $work_experience = [];
                $work_experience_stmt = $conn->prepare("SELECT * FROM jobseeker_work_experience WHERE jobseeker_id = ?");
                $work_experience_stmt->bind_param("i", $jobseeker_id);
                $work_experience_stmt->execute();
                $work_experience_result = $work_experience_stmt->get_result();
                
                while ($row = $work_experience_result->fetch_assoc()) {
                    $work_experience[] = $row;
                }

                // Add arrays to profile data
                $profile_data['education'] = $education;
                $profile_data['skills'] = $skills;
                $profile_data['work_experience'] = $work_experience;

                // Create final API response
                $api_response = [
                    'success' => true,
                    'user' => [
                        'user_id' => (int)$user_data['user_id'],
                        'email' => $user_data['email'],
                        'role' => $user_data['role_name'],
                        'profile' => $profile_data
                    ]
                ];

                echo "<h3>✅ Complete API Response:</h3>";
                echo "<pre>" . json_encode($api_response, JSON_PRETTY_PRINT) . "</pre>";

                echo "<h3>📊 Data Counts:</h3>";
                echo "Education records: " . count($education) . "<br>";
                echo "Skills records: " . count($skills) . "<br>";
                echo "Work experience records: " . count($work_experience) . "<br>";

            } else {
                echo "<h3>❌ No jobseeker profile found</h3>";
            }
        }
    } else {
        echo "<h3>❌ No user found</h3>";
    }

} catch (Exception $e) {
    echo "<h3>❌ Error: " . $e->getMessage() . "</h3>";
}
?>