import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# --- CONFIGURATION ---
CLASS_ID = "cs_senior_design_001" 
START_ID = 100
COUNT = 10
# ---------------------

# Prevent re-initializing if running in a shared environment
if not firebase_admin._apps:
    cred = credentials.Certificate("scripts/serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
db = firestore.client()

def mark_all_absent():
    batch = db.batch()
    now = datetime.now()
    date_str = now.strftime("%Y-%m-%d")

    print(f"🚫 Instantly marking {COUNT} students ABSENT for {date_str}...")

    for i in range(COUNT):
        uid = str(START_ID + i)
        doc_id = f"{CLASS_ID}_{uid}_{date_str}"
        att_ref = db.collection('attendance').document(doc_id)
        
        att_data = {
            'classId': CLASS_ID,
            'studentUid': uid,
            'date': date_str,
            'status': 'absent',
            'timestamp': firestore.SERVER_TIMESTAMP
        }
        
        # Add to the batch instead of writing immediately
        batch.set(att_ref, att_data)

    # Commit all changes at once
    batch.commit()
    print("✅ Success! Everyone has been marked ABSENT instantly.")

if __name__ == "__main__":
    mark_all_absent()