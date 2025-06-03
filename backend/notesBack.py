from fastapi import APIRouter, HTTPException, Path
from pydantic import BaseModel
from supabase import create_client, Client
from typing import Optional, List

SUPABASE_URL = "https://ypprpszogomrmpxgogvy.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class NoteData(BaseModel):
    notename: str
    created_at: str
    notecontents: Optional[str] = ""
    subject_name: str

class NoteUpdateData(BaseModel):
    notecontents: Optional[str] = ""
    subject_name: str

notes_router = APIRouter()

@notes_router.post("/notes")
async def add_note(note_data: NoteData):
    try:
        data, count = supabase.table("notes").insert({
            "notename": note_data.notename,
            "created_at": note_data.created_at,
            "notecontents": note_data.notecontents,
            "subject_name": note_data.subject_name,
        }).execute()

        if data and len(data) > 1 and data[1]:
            return {"message": "Note added successfully", "data": data[1][0]}
        else:
            return {"message": "Note added successfully"}
    except Exception as e:
        if "violates foreign key constraint" in str(e):
            raise HTTPException(status_code=400, detail=f"Subject '{note_data.subject_name}' does not exist. Please add the subject first.")
        print(f"Error adding note: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@notes_router.get("/notes")
async def get_notes(subject_name: Optional[str] = None):
    try:
        query = supabase.table("notes").select("*")
        if subject_name:
            query = query.eq("subject_name", subject_name)

        data, count = query.execute()

        notes = data[1] if data and len(data) > 1 else []

        return notes
    except Exception as e:
        print(f"Error fetching notes: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@notes_router.patch("/notes/{note_title}")
async def update_note_content(
    note_title: str = Path(..., description="The title of the note to update"),
    update_data: NoteUpdateData = ...,
):
    try:
        data, count = supabase.table("notes").update(
            {
                "notecontents": update_data.notecontents,
            }
        ).eq("notename", note_title).eq("subject_name", update_data.subject_name).execute()

        if data and len(data) > 1 and data[1]:
            return {"message": "Note content updated successfully", "data": data[1][0]}
        else:
            if not data[1]:
                raise HTTPException(status_code=404, detail=f"Note '{note_title}' for subject '{update_data.subject_name}' not found or no changes were made.")
            return {"message": "Note content updated successfully (no data returned)"}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Error updating note content for '{note_title}': {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@notes_router.delete("/notes/{note_title}")
async def delete_note(
    note_title: str = Path(..., description="The title of the note to delete"),
    subject_name: str = ...,
):
    try:
        data, count = supabase.table("notes").delete().eq("notename", note_title).eq("subject_name", subject_name).execute()

        if data and len(data) > 1 and data[1]:
            return {"message": "Note deleted successfully", "deleted_note": data[1][0]}
        else:
            raise HTTPException(status_code=404, detail=f"Note '{note_title}' under subject '{subject_name}' not found.")
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Error deleting note '{note_title}': {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e}")