from fastapi import APIRouter, HTTPException, Path
from pydantic import BaseModel
from supabase import create_client, Client

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM" 
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class userUpdate(BaseModel):
    email: str
    password: str

forgot_router = APIRouter()

@forgot_router.post("/forgotpassword")
async def forgot(forgot_data: userUpdate):
    try:
        data, count = supabase.table("users").update({"password": forgot_data.password}).eq("email", forgot_data.email).execute()
        if count == 0:
            raise HTTPException(status_code=404, detail="User not found.") 
        return {"message": "Password updated successfully."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@forgot_router.get("/users")
async def get_users():
    data, count = supabase.table("users").select("*").execute()
    return data[1] 

@forgot_router.delete("/users/{email}")
async def delete_user(email: str):
    data, count = supabase.table("users").delete().eq("email", email).execute()
    if count == 0:
        raise HTTPException(status_code=404, detail="User not found.")
    return {"message": "User deleted successfully."}

@forgot_router.get("/")
async def root():
    return {"message": "FastAPI server is running!"}
