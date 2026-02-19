import firebase_admin
from firebase_admin import credentials, firestore

# --- CONFIGURATION ---
# PASTE YOUR ACTUAL CLASS ID HERE!
CLASS_ID = "cs_senior_design_001" 
START_ID = 100
COUNT = 30
# ---------------------

cred = credentials.Certificate("/../../Code_Blooded/attendin/scripts/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def seed_database():
    batch = db.batch()
    print(f"🌱 Seeding {COUNT} students into class: {CLASS_ID}...")

    for i in range(COUNT):
        # We use string IDs "100", "101"...
        uid = str(START_ID + i) 
        
        # 1. Create User (Matches user_data_provider.dart)
        user_ref = db.collection('users').document(uid)
        user_data = {
            'name': f"Student {i+1}", 
            'email': f"student{uid}@demo.com",
            'role': 'student',
            'schoolId': f"{uid}",
            'profilePicture': "",
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