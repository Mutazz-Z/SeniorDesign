import firebase_admin
from firebase_admin import credentials, firestore

# --- CONFIGURATION (MUST MATCH YOUR SEED SCRIPT) ---
CLASS_ID = "cs_senior_design_001" 
START_ID = 100
COUNT = 30
# ---------------------------------------------------

cred = credentials.Certificate("/../../Code_Blooded/attendin/scripts/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def clean_up():
    print(f"⚠️  WARNING: Deleting fake students {START_ID} to {START_ID + COUNT - 1}...")
    
    batch = db.batch()
    deleted_count = 0

    for i in range(COUNT):
        # We target the exact same IDs we created
        uid = str(START_ID + i)

        # 1. Delete User Document
        # Path: users/100
        user_ref = db.collection('users').document(uid)
        batch.delete(user_ref)
        
        # 2. Delete Enrollment Document
        # Path: enrollment/cs_senior_design_001_100
        # (Matches the logic in your seed_students.py)
        enrollment_ref = db.collection('enrollment').document(f"{CLASS_ID}_{uid}")
        batch.delete(enrollment_ref)
        
        deleted_count += 1

    # 3. (Optional) Delete Attendance Records
    # If you ran the attendance script, those records are still there. 
    # Let's clean them up too so your dashboard goes back to "0 Present".
    print("   Scanning for attendance records to delete...")
    
    # We look for any attendance doc where the studentUid matches our fake range
    # Note: This might take a second if you have thousands of records, but for a demo it's fast.
    attendance_query = db.collection('attendance')\
        .where(field_path='studentUid', op_string='>=', value=str(START_ID))\
        .where(field_path='studentUid', op_string='<=', value=str(START_ID + COUNT))\
        .stream()

    for doc in attendance_query:
        batch.delete(doc.reference)

    # Commit the mass delete
    batch.commit()
    print(f"🗑️  Nuked {deleted_count} users, enrollments, and their attendance records.")
    print("✨ Database is clean.")

if __name__ == "__main__":
    clean_up()