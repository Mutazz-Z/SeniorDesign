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

cred = credentials.Certificate("scripts/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def mark_all_present():
    now = datetime.now()
    date_str = now.strftime("%Y-%m-%d")

    print(f"🚀 Simulating {COUNT} students marking PRESENT for {date_str}...")

    # create a list of all uids and shuffle them randomly
    uids = [str(START_ID + i) for i in range(COUNT)]
    random.shuffle(uids)

    # loop through the randomized list using enumerate to track the index
    for index, uid in enumerate(uids):
        doc_id = f"{CLASS_ID}_{uid}_{date_str}"
        att_ref = db.collection('attendance').document(doc_id)
        
        att_data = {
            'classId': CLASS_ID,
            'studentUid': uid,
            'date': date_str,
            'status': 'present',
            'timestamp': firestore.SERVER_TIMESTAMP
        }
        
        # Write directly to Firestore instead of batching
        att_ref.set(att_data)
        print(f"   👤 Student {uid} checked in.")

        # Add a random "human" delay between 0.5 and 1.5 seconds
        if index < COUNT - 1: # Skip delay after the last student
            delay = random.uniform(0.2, 1.5)
            time.sleep(delay)

    print("✅ Success! Everyone is marked PRESENT.")

if __name__ == "__main__":
    mark_all_present()