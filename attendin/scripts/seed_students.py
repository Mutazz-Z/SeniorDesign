import firebase_admin
from firebase_admin import credentials, firestore

# --- CONFIGURATION ---

PROFILE_PICTURES = [
    "https://images.pexels.com/photos/18699972/pexels-photo-18699972.jpeg",
    "https://images.pexels.com/photos/13314726/pexels-photo-13314726.jpeg",
    "https://images.pexels.com/photos/5450982/pexels-photo-5450982.jpeg",
    "https://images.pexels.com/photos/12871451/pexels-photo-12871451.jpeg",
    "https://images.pexels.com/photos/32083359/pexels-photo-32083359.jpeg",
    "https://images.pexels.com/photos/769772/pexels-photo-769772.jpeg",
    "https://images.pexels.com/photos/5871970/pexels-photo-5871970.jpeg",
    "https://images.pexels.com/photos/17059392/pexels-photo-17059392.jpeg",
    "https://images.pexels.com/photos/6256103/pexels-photo-6256103.jpeg",
    "https://images.pexels.com/photos/12154467/pexels-photo-12154467.jpeg",
]

NAMES = [
    "Maximus Iquina",
    "James Buehler",
    "Jake Koetter",
    "Connor Fitts",
    "Logan Brown",
    "John Jones",
    "Evan Smith",
    "Noah Sherrard",
    "Therese Bell",
    "Kai Dages"
]

# PASTE YOUR ACTUAL CLASS ID HERE!
CLASS_ID = "cs_senior_design_001" 
START_ID = 100
COUNT = 10
# ---------------------

cred = credentials.Certificate("scripts/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def seed_database():
    batch = db.batch()
    print(f"🌱 Seeding {COUNT} students into class: {CLASS_ID}...")

    for i in range(COUNT):
        # We use string IDs "100", "101"...
        uid = str(START_ID + i) 

        profile_pic = PROFILE_PICTURES[i % len(PROFILE_PICTURES)]
        name = NAMES[i % len(NAMES)]
        
        # 1. Create User (Matches user_data_provider.dart)
        user_ref = db.collection('users').document(uid)
        user_data = {
            'name': name, 
            'email': f"student{uid}@demo.com",
            'role': 'student',
            'schoolId': f"{uid}",
            'profilePicture': profile_pic,
        }
        batch.set(user_ref, user_data)

        enrollment_ref = db.collection('enrollment').document(f"{CLASS_ID}_{uid}")
        enrollment_data = {
            'classId': CLASS_ID,
            'studentUid': uid,
        }
        batch.set(enrollment_ref, enrollment_data)

    batch.commit()
    print("✅ Success! Students 100-129 created and enrolled.")

if __name__ == "__main__":
    seed_database()