from fastapi import APIRouter, HTTPException, Path
from pydantic import BaseModel
from supabase import create_client, Client

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co" 
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM" 
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class LoginData(BaseModel):
    email: str
    password: str

login_router = APIRouter()

@login_router.post("/login")
async def login(login_data: LoginData):
    try:
        data, count = supabase.table("users").select("*").eq("email", login_data.email).execute()
        if not data[1]:  
            raise HTTPException(status_code=401, detail="Invalid email or password.")

        user = data[1][0] 
        if user["password"] == login_data.password:
            return {"message": "Login successful"}
        else:
            raise HTTPException(status_code=401, detail="Invalid email or password.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@login_router.get("/users")
async def get_users():
    data, count = supabase.table("users").select("*").execute()
    return data[1] 

@login_router.delete("/users/{email}")
async def delete_user(email: str):
    data, count = supabase.table("users").delete().eq("email", email).execute()
    if count == 0:
        raise HTTPException(status_code=404, detail="User not found.")
    return {"message": "User deleted successfully."}

@login_router.get("/")
async def root():
    return {"message": "FastAPI server is running!"}