# Assignment 1 - Test Plan: Attendin

## Part I. Description of Overall Test Plan

The testing strategy for AttendIn is mainly grounded in **Test Driven Development (TDD)**, ensuring that individual components, such as data models and utility functions, are validated via automated unit tests before integration. Currently, system validation is conducted using device simulators and physical devices with mocked location data to verify geofencing boundaries without requiring on-site field testing.

We utilize Unit Testing to enforce logic constraints and Widget Testing to ensure UI consistency across different device states. Integration Testing is performed by using mocked GPS coordinates into the application to simulate "in-range" and "out-of-range" scenarios. This approach allows us to test the attendance logic and boundary conditions in a controlled environment before moving to live field deployment.

## Part II. Test Case Descriptions

#### 1. Student Login - Valid Credentials
* Purpose: Verify a student can successfully authenticate and access the home screen.
* Description: Enter valid email and password into the login screen and tap "Login".
* Inputs: `student@uc.edu`, `password`
* Expected Outputs: User is redirected to home screen.
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on real device, verify the student was able to get past the login screen with valid credentials.
* Result: Pass, Student was able to login.

#### 2. Student Login - Invalid Credentials
* Purpose: Verify a student will not access the home screen on incorrect login.
* Description: Enter valid email and invalid password into the login screen and tap "Login".
* Inputs: `student@uc.edu`, `wrong_password`
* Expected Outputs: User stays on login screen, text shows up.
* Categories: Abnormal / Blackbox / Functional / Integration
* Excecution: Ran on real device, verify the student was NOT able to get past the login screen with invalid credentials.
* Result: Pass, Student was not able to login, pop up showed showing incorrect login.

#### 3. Forgot Password Navigation
* Purpose: Verify a student can access forgot password screen.
* Description: Click "Forgot Password" text on the Login screen and tap "Login".
* Inputs: User tap.
* Expected Outputs: Screen changes to the forgot password screen.
* Categories: Normal / Blackbox / Functional / Unit
* Excecution: Ran on real device, click on forgot password.
* Result: Pass, the forgot password screen appears.

#### 4. Student Tab Navigation
* Purpose: Verify navigation between main app screens works correctly.
* Description: Tap the bottom navigation bars and verify the screen changes correctly.
* Inputs: User tap on navigation bar.
* Expected Outputs: User is brought to correct screen.
* Categories: Normal / Blackbox / Functional / Unit
* Excecution: Ran on real device, Navigate between screens smoothly.
* Result: Pass, screen navigation worked correctly.

#### 5. Home Screen - Current Day
* Purpose: Verify the home screen shows current day classes only.
* Description: Load home screen on monday and verify tuesday classes are hidden.
* Inputs: Mock System date and data.
* Expected Outputs: Only class on monday is shown.
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on real device, Verify looking at the current schedule can see classes for today.
* Result: Pass, All classes showed up for current day.

#### 6. Mark Attendance - In Range
* Purpose: Verify attendance is marked when user in range.
* Description: User presses Mark Attendance while simulator is in range of a class.
* Inputs: Mock device to be in class.
* Expected Outputs: Button changes to Attended Class and animation plays.
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on simulator, verify that while in range of the geofence, attendance was marked correctly.
* Result: Pass, Student was able to mark attendance.

#### 7. Mark Attendance - Out of Range
* Purpose: Verify attendance cannot be marked while out of range.
* Description: User presses Mark Attendance while simulator is out of range of class.
* Inputs: Mock device to be out of range of class.
* Expected Outputs: Button changes to out of range.
* Categories: Abnormal / Blackbox / Functional / Integration
* Excecution: Ran on simulator, verify that while out of range of the geofence, attendance was not able to be marked.
* Result: Pass, Student was shown "Out of Location", while not in range of the geofence.

#### 8. Double Attendance
* Purpose: Ensure a student can only submit attendance once per class session.
* Description: Attempt to tap the "Mark Attendance" button immediately after a success.
* Inputs: User taps twice.
* Expected Outputs: Button is only clickable the first time.
* Categories: Boundary / Blackbox / Functional / Integration
* Excecution: Ran on simulator, verify that after "Mark Attendance" is pressed, the button changes to attended class and cannot be pressed again.
* Result: Pass, Student was not able to click button again after attendance has been taken.

#### 9. Toggle Theme
* Purpose: Verify toggling between dark and light theme correctly updates the color schemes.
* Description: Navigate to Settings and toggle the "Dark Mode" switch.
* Inputs: Tap toggle switch.
* Expected Outputs: Background color changes accordingly.
* Categories: Normal / Whitebox / Functional / Unit
* Excecution: Ran on simulator, verify that toggling light and dark mode change colors correctly.
* Result: Pass, toggling the theme changed the colors of the entire app.

#### 10. Profile Image Missing
* Purpose: Verify a missing or broken profile picture shows initials
* Description: Load a user profile that has an invalid image URL.
* Inputs: Mock User Name and missing Image
* Expected Outputs: Widget displays circle with initials instead of a broken image
* Categories: Normal / Whitebox / Functional / Unit
* Excecution: Ran on simulator, Verify student without a profile picture shows correctly
* Result: Pass, Profile picture shown as first initial, last initial.

#### 11. Admin Login - Success
* Purpose: Verify faculty can access the web dashboard.
* Description: Enter valid credentials into the login page
* Inputs: `admin@uc.edu`, `password`
* Expected Outputs: Navigates to the main dashboard page.
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web, Verify admin can login with valid credentials
* Result: Pass, Admin was able to login

#### 12. Admin Sidebar Navigation
* Purpose: Verify the web dashboard navigates correctly.
* Description: Click the navigation items in the left sidebar.
* Inputs: Click navigation bar.
* Expected Outputs: Navigates to the current screen correctly and smoothly.
* Categories: Normal / Blackbox / Functional / Unit
* Excecution: Ran on web, verify admin can click between screens
* Result: Pass, Admin was able to navigate screens smoothly

#### 13. View Active Class Status
* Purpose: Verify Admin can see the live class details.
* Description: View currently active class from the main dashboard.
* Inputs: View data on the home menu, Mock student data.
* Expected Outputs: Screen has correct list of students with current status.
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web. While a class is in session, verify you can view the live class details.
* Result: Pass, Active class status shows up on the main dashboard

#### 14. Start Attendance Session
* Purpose: Verify Admin can manually start a class session
* Description: Click the manual attendance toggle for a specific class.
* Inputs: User click.
* Expected Outputs: Attendance has been started, students can mark themselves as attended class
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web and real device. Verify admin can toggle the attendance window open, and students can check in.
* Result: Pass, Admin toggling the attendance window opens the window, students can instantly check in after this.

#### 15. View Class History
* Purpose: Verify Admin can view the class history.
* Description: Navigate to Classes and view any date.
* Inputs: Select any class date
* Expected Outputs: Can view the attendance records for a specific date
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web. Clicking on a specific class from the classes screen, verify you can view attendance history
* Result: Pass, Clicking on any student shows the attendance history for that student, can download CSV for attendance records for every student

#### 16. Edit Class Settings
* Purpose: Verify Admin can edit any class settings.
* Description: Navigate to Classes and then select settings on a class.
* Inputs: Edit any item from class settings
* Expected Outputs: The related settings update correctly
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web. Edit the class and verify it shows up in other places around the app
* Result: Pass, Edited class time/name/dates and it shows on the admin web app as well as the student mobile app.

#### 17. Add Student to Class
* Purpose: Verify admin can manage roster of each class.
* Description: Type in the name of a student and press the plus button
* Inputs: Manually input student, and click plus
* Expected Outputs: The student is correctly added to class
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web and real device. Add a student to class, verify on the student mobile app they are now able to see that class
* Result: Pass, Adding a student adds them on the admin side, when the student opens the mobile app they can now see this class they were added to.

#### 18. Download CSV File
* Purpose: Verify admin can download the CSV of a class
* Description: Click "Export CSV" on the Classes page
* Inputs: User click.
* Expected Outputs: The CSV is correctly downloaded with the class data
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on web. Navigate to any class with attendance history, verify we are able to download the CSV.
* Result: Pass, CSV was correctly downloaded and showed all attendancy history of every student

#### 19. Manual Attendance
* Purpose: Verify admin can drag and drop students for manual attendance
* Description: Admin drags a student card from absent to present
* Inputs: User drag.
* Expected Outputs: Student status updates to "Present"
* Categories: Normal / Blackbox / Functional / Unit
* Excecution: Ran on web. While class is in session, verify you can drag and drop students between present and absent.
* Result: Pass, Dragging and dropping students updates their attendance records, visible on both the admin and student apps.

#### 20. Location Permissions
* Purpose: Verify student mobile apps asks for location permissions to access location.
* Description: Attempt to mark attendance, verify location is asked for.
* Inputs: Click a button.
* Expected Outputs: The popup comes up asking for access to location
* Categories: Normal / Blackbox / Functional / Integration
* Excecution: Ran on real device. Verify that clicking "Mark Attendance" askes for location permission if not already granted.
* Result: Pass, the popup appears asking to access location when attendance is attempted to be marked.


## Part III. Test Case Matrix

| ID | Normal/Abnormal | BlackBox/WhiteBox | Functional/Performance | Unit/Integration |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Normal | Blackbox | Functional | Integration |
| 2 | Abnormal | Blackbox | Functional | Integration |
| 3 | Normal | Blackbox | Functional | Unit |
| 4 | Normal | Blackbox | Functional | Unit |
| 5 | Normal | Blackbox | Functional | Integration |
| 6 | Normal | Blackbox | Functional | Integration |
| 7 | Abnormal | Blackbox | Functional | Integration |
| 8 | Boundary | Blackbox | Functional | Integration |
| 9 | Normal | Whitebox | Functional | Unit |
| 10 | Normal | Whitebox | Functional | Unit |
| 11 | Normal | Blackbox | Functional | Integration |
| 12 | Normal | Blackbox | Functional | Unit |
| 13 | Normal | Blackbox | Functional | Integration |
| 14 | Normal | Blackbox | Functional | Integration |
| 15 | Normal | Blackbox | Functional | Integration |
| 16 | Normal | Blackbox | Functional | Integration |
| 17 | Normal | Blackbox | Functional | Integration |
| 18 | Normal | Blackbox | Functional | Integration |
| 19 | Normal | Blackbox | Functional | Unit |
| 20 | Normal | Blackbox | Functional | Integration |