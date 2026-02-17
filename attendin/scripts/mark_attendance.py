import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# --- CONFIGURATION (MUST MATCH YOUR SEED SCRIPT) ---
CLASS_ID = "cs_senior_design_001" 
START_ID = 100
COUNT = 30
# ---------------------------------------------------

cred = credentials.Certificate("/../../Code_Blooded/attendin/scripts/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def mark_all_present():
    batch = db.batch()
    
    # Get today's date in YYYY-MM-DD format (matches attendance_data_provider.dart)
    now = datetime.now()
    date_str = now.strftime("%Y-%m-%d")

    print(f"🚀 Marking {COUNT} students PRESENT for {date_str}...")

    for i in range(COUNT):
        uid = str(START_ID + i)
        
        # 1. Construct the Document ID exactly how the app expects it
        # Format: classId_studentUid_date
        doc_id = f"{CLASS_ID}_{uid}_{date_str}"
        
        att_ref = db.collection('attendance').document(doc_id)
        
        # 2. Set Status to 'present'
        att_data = {
            'classId': CLASS_ID,
            'studentUid': uid,
            'date': date_str,
            'status': 'present',
            'timestamp': firestore.SERVER_TIMESTAMP
        }
        batch.set(att_ref, att_data)

    batch.commit()
    print("✅ Success! Everyone is marked PRESENT.")

if __name__ == "__main__":
    mark_all_present()