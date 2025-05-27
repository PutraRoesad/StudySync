from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from supabase import create_client, Client 

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)

class SubjectsData(BaseModel):
    name: str

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co" 
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM" 

# Create a Supabase client instance
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.post("/subjects")
async def add_subject(subject_data: SubjectsData):
    try:
        data, count = supabase.table("subjects").insert({
            "name": subject_data.name,
        }).execute()
        
        return {"message": "Subject added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.get("/subjects")
async def get_subjects():
    try:
        data, count = supabase.table("subjects").select("*").execute()
        
        subjects = data[1] if data and len(data) > 1 else []
        
        return subjects
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")


@app.get("/")
async def root():
    return {"message": "FastAPI server is running!"}