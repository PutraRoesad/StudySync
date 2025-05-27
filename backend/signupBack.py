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

class SignupData(BaseModel):
    first_name: str
    last_name: str
    email: str
    dob: str
    password: str

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co" 
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM" 

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.post("/signup")
async def signup(signup_data: SignupData):
    try:
        dob = datetime.strptime(signup_data.dob, "%Y-%m-%d").date() 
        data, count = supabase.table("users").insert({
            "first_name": signup_data.first_name,
            "last_name": signup_data.last_name,
            "email": signup_data.email,
            "dob": dob.isoformat(), 
            "password": signup_data.password,
        }).execute()
        return {"message": "Signup successful"}
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