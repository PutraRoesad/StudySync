from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
from supabase import create_client, Client

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class assignmentsData(BaseModel):
    subject: str
    description: str
    due_date: str
    collaborators: str

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.post("/assignments")
async def create_assignment(assignments_data: assignmentsData):
    try:
        due_date_obj = datetime.strptime(assignments_data.due_date, "%Y-%m-%d").date()

        data, count = supabase.table("assignments").insert({
            "subject": assignments_data.subject,
            "description": assignments_data.description,
            "due_date": due_date_obj.isoformat(),
            "collaborators": assignments_data.collaborators,
        }).execute()

        return {"message": "Assignment added successfully"}
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Please use YYYY-MM-DD.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.get("/users")
async def get_users():
    data, count = supabase.table("users").select("*").execute()
    return data[1]

@app.delete("/users/{email}")
async def delete_user(email: str):
    data, count = supabase.table("users").delete().eq("email", email).execute()

    if count == 0:
        raise HTTPException(status_code=404, detail="User not found.")

    return {"message": "User deleted successfully."}

@app.get("/")
async def root():
    return {"message": "FastAPI server is running!"}