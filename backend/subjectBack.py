from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from supabase import create_client, Client

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class SubjectsData(BaseModel):
    name: str

subjects_router = APIRouter()

@subjects_router.post("/subjects")
async def add_subject(subject_data: SubjectsData):
    try:
        existing_subject_response = supabase.table("subjects").select("name").eq("name", subject_data.name).limit(1).execute()
        existing_subject = existing_subject_response.data
        if existing_subject:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Subject with this name already exists")

        data_response = supabase.table("subjects").insert({"name": subject_data.name}).execute()
        data = data_response.data

        if data:
            return {"message": "Subject added successfully", "data": data[0]}
        else:
            return {"message": "Subject added successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Error adding subject: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")

@subjects_router.get("/subjects")
async def get_subjects():
    try:
        data_response = supabase.table("subjects").select("*").execute()
        subjects = data_response.data

        return subjects if subjects is not None else []
    except Exception as e:
        print(f"Error fetching subjects: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")

@subjects_router.delete("/subjects/{subject_name}")
async def delete_subject(subject_name: str):
    try:
        delete_response = supabase.table("subjects").delete().eq("name", subject_name).execute()
        deleted_data = delete_response.data

        if deleted_data:
            return {"message": f"Subject '{subject_name}' and its associated notes deleted successfully."}
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Subject '{subject_name}' not found.")

    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Error deleting subject '{subject_name}': {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
