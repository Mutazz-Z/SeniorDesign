# Front End (Mobile) - Requirements

- **[Figma Design](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-1384&t=vbIXcwVWdasWdGVu-1)**

## Theming

- **Font Family:** League Spartan
- **[Color Palette](https://coolors.co/081564-16c2b8-65743a-fde74c-c3423f)**


### Splash Screen

- Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=2-16&m=dev

A splash screen is the screen that appears on bootup of the app. This screen is only shown briefly before a user is shown the login page or home page depending on their login status.

This screen should feature our logo, accompanied by our brand text below.

---

### Welcome Screen

- Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=4-12&m=dev

This is the inital screen a user is presented upon downloading. Features two buttons.

- **Log in**: Should navigate to the login screen
- **Sign up:** Should navigate to the sign up screen

---
### Sign up Screen

- Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-117&m=dev

**Takes in 3 Fields**
- Name
- Email
- Password

The password field should hide the password by default unless the `eye` icon is pressed.

**Contains 2 buttons**
- `Sign up` - Continue with sign up; Navigate to `Home Page` Screen
- `Log in` - Navigate to `Log in` Screen

---

### Log in Screen

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=4-12&m=dev

**Takes in 2 fields:**
- `Email`
- `Password`

The password field should hide the password by default unless the `eye` icon is pressed.

**Contains 4 buttons:**
- `Log in` - Attempts to login
- `Forgot Password` - Navigates to `forgot password` screen to reset
- `Sign up` - Navigates to `sign up` screen
- `Log in with biometrics` - Prompt biometrics

---

### Forgot Password Screen

- Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-164&m=dev

Takes in 2 fields:
- Password
- Confirm Password

Both of these fields must match.
The password field should hide the password by default unless the `eye` icon is pressed.

Contains 1 button:
- `Create New Password` - Navigates to Log in screen upon sucess. Otherwise, prompt failure.

---

### Home Screen

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-262&m=dev

#### Calendar Widget:
Features days of the week, Mon-Sat. 

- Dark Blue: ![Dark Blue](https://i.imgur.com/cTv0tMs.png) Represents a day where a user has class(es) scheduled
- Light Blue: ![LightBlue](https://i.imgur.com/JFs5J69.png) Represents the current day of the week.
- White: Repesents a day when class is not held for the user.

Beneath the days of the week should be a quick hourly view displaying the time for the held class(es) in the current hour.

#### Attendance Widget

This widget should change dynamically based on what class is currently being held for the user.

- Features the current subject and location in a bounded box.
- Big button widget to mark attendance.
    - Should use geolocation to verify student is present to click. Otherwise show the [out of location card](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-668&m=dev).
    - Similar behavior for other scenarios. 
        - [Attended Class](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-596&m=dev) - Shown upon click to confirm attendance
        - [Missed Class](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-740&m=dev) - Shown when a student misses the attendance window

#### Bottom Bar

Features 3 selectable menus.
- Profile (Left) - Navigate to [Profile Screen](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-812&m=dev)
- Home (Middle) - Navigate to [Home Screen](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-262&m=dev)
- Schedule (Right) - Navigate to [Schedule Screen](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-1197&m=dev)

Bottom bar should be shared globally accross all the screens it navigates to.

Current selected Screen should be highlighted in Yellow: ![Yellow](https://I.imgur.com/UA2yAhY.png) 

---

### Schedule Screen

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-1197&m=dev

First screen features a list of cards with each class a student is taking. Clicking on a card navigates to a custom view displaying the info for the selected class.
This info view features:
- **Title Card** The class name, location, meeting dates. (Reusing our class card)
- **Missed Classes** Displays how many times a student has missed the given class.
- **Calendar** Displays an expanded calendar:
    - Red: Missed Class
    - Dark Blue ![Dark Blue](https://i.imgur.com/cTv0tMs.png): Meeting Date
    - Light Blue ![LightBlue](https://i.imgur.com/JFs5J69.png): Current Date

---

### Profile Screen

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-812&m=dev

Features *Settings* & *Logout*

#### Settings:
- Navigates to a [settings page](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-872&m=dev) allowing you to customize theming and changing your password.

#### Logout:
- Pops up a [modal](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=8-1114&m=dev) asking you if you want to log out. Should navigate back to the `Login Screen`

