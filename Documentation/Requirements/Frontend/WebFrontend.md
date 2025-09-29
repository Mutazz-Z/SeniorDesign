# Front End (Web) - Requirements

- **[Figma Design](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=165-200&p=f&t=BOadSLPnSi4Tj78F-0)**

## Theming

- **Font Family:** League Spartan
- **[Color Palette](https://coolors.co/081564-16c2b8-65743a-fde74c-c3423f)**

## Welcome/Login Screen

- Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=165-882&m=dev

This is the inital screen a user is presented. Features three (required) buttons and one (optional) button.

#### Required
- **Log in**: Should navigate to the login screen
- **Forgot Password:** Should navigate to the sign up screen (contact an admin screen)
- **Keep Me Logged In Check** Self explanatory

#### Optional
- **Dark/Light Mode** Changes the UI Theme


## Forgot Password Screen

- Link to Figma: TBA

Should show a `Contact workspace admin` modal with an "_Okay_" button for confirmation.


## Main Components

Each screen past the login features two main components:
- `Navigation` - on the left side
- `Main Content` - On the right side



## Dashboard

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=165-1162&m=dev


### Main Content:

Shows title and current date under.
Given the current date/time, the class being hosted should appear along with live monitoring of the attendance. 


#### Right Content:

The right side of the screen features a quick glance schedule for faculty showing them the classes they are hosting for today and the next date. Each of the classes on this panel is broken down to 3 components:
- `Averaged Attendance` - Circle showing the average attendance rate of each class. >70% should feature a green circle, between 50-70% should be a yellow circle, and <50% should be a red circle.
- `Class Name` - Should display the name of the class
- `Description` - Should show the time and location it is held in

## Classes Screen

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=167-408&m=dev

First page should feature two sections. Active & Inactive classes. The cards under these should be reusing our `class_card.dart` widget. 

Pressing the **green plus icon** should open a [modal](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=168-963&m=dev) where you can create a new class.

Clicking each class should navigate to the [next screen](https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=168-597&m=dev). This screen allows faculty to override student attendance by selecting the student and selecting the date (reusing our `expanded_calendar_widget.dart`) to override. Here, a faculty member can also use the search bar to both search for an existing student in their class and/or to add a new student into their class (using the green plus button next to the search).

At the bottom, a button is present which downloads all the attendance records for the given class as a CSV file.

Clicking the **yellow settings cog** should navigate to the class settings screen.

## Profile Screen

Link to Figma: https://www.figma.com/design/mFoy1hrhLCk290uLqfwqWI/Attendin?node-id=168-1111&m=dev

- Reusing our password manager in our password manager screen from our mobile view.
- Log out button

