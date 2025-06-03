from fastapi import APIRouter, HTTPException, Path
from pydantic import BaseModel
from datetime import datetime
from supabase import create_client, Client
import os
import json # Import the json module

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


class AssignmentsData(BaseModel):
    subject: str
    description: str
    due_date: str
    collaborators: str # Still receive as string, but process it

    
addtask_router = APIRouter()

@addtask_router.post("/assignments")
async def create_assignment(assignments_data: AssignmentsData):
    try:
        due_datetime_obj = datetime.fromisoformat(assignments_data.due_date)

        # Process collaborators:
        # If the collaborators string is not empty, split by comma and strip whitespace.
        # Otherwise, make it an empty list.
        # This creates a Python list, which Supabase will store as a JSON array.
        collaborators_list = [c.strip() for c in assignments_data.collaborators.split(',')] if assignments_data.collaborators else []

        data, count = supabase.table("assignments").insert({
            "subject": assignments_data.subject,
            "description": assignments_data.description,
            "due_date": due_datetime_obj.isoformat(),
            "collaborators": collaborators_list, # Pass the Python list here
        }).execute()

        return {"message": "Assignment added successfully"}
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date/time format. Please use YYYY-MM-DDTHH:MM:SS.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@addtask_router.get("/")
async def root():
    return {"message": "FastAPI server is running!"}