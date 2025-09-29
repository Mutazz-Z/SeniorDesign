# Back End - Requirements

#### Firebase Setup

Firebase works well with Flutter and will be our go do for database management. They have a free tier `Spark` that'll be sufficient enough for our purposes. Follow the documentation steps below to set up firebase in our application.

**Documentation:** https://firebase.google.com/docs/flutter/setup?platform=ios

---

#### User Management (FirebaseUI Auth)

We need a way to manage user accounts. `FirebaseUI Auth` looks like a good solution for us. Recommend using the `Drop-in solution` as we (probably) don't need any custom user management features. 

Documentation: https://firebase.google.com/docs/auth/where-to-start

---

#### User Data (Class information, etc)

A key feature of this app is taking attendance meaning each user will need to store a custom 'schedule' of their classes. To do this, will need to harness `Cloud Firestore`.

Documentation: https://firebase.google.com/docs/database