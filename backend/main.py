from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from subjectBack import subjects_router
from notesBack import notes_router
from addtaskBack import addtask_router
from forgotBack import forgot_router
from signupBack import signup_router
from loginBack import login_router


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(subjects_router)
app.include_router(notes_router)
app.include_router(addtask_router)
app.include_router(forgot_router)
app.include_router(signup_router)
app.include_router(login_router)

@app.get("/")
async def root():
    return {"message": "Welcome to the unified Notes and Subjects API!"}