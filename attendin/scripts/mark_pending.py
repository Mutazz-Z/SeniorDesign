import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import time
import random

# --- CONFIGURATION ---
CLASS_ID = "cs_senior_design_001" 
START_ID = 100
COUNT = 10
# ---------------------

# Prevent re-initializing if running in a shared environment, though standard for standalone scripts
if not firebase_admin._apps:
    cred = credentials.Certificate("scripts/serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
db = firestore.client()

def mark_all_pending():
    now = datetime.now()
    date_str = now.strftime("%Y-%m-%d")

    print(f"⏳ Simulating {COUNT} students remaining PENDING for {date_str}...")

    for i in range(COUNT):
        uid = str(START_ID + i)
        doc_id = f"{CLASS_ID}_{uid}_{date_str}"
        att_ref = db.collection('attendance').document(doc_id)
        
        att_data = {
            'classId': CLASS_ID,
            'studentUid': uid,
            'date': date_str,
            'status': 'pending',
            'timestamp': firestore.SERVER_TIMESTAMP
        }
        
        att_ref.set(att_data)
        print(f"   🕒 Student {uid} set to pending.")

        # Add a random "human" delay between 0.5 and 2.5 seconds
        if i < COUNT - 1:
            delay = random.uniform(0.5, 1.0)
            time.sleep(delay)

    print("✅ Success! Everyone is marked PENDING.")

if __name__ == "__main__":
    mark_all_pending()