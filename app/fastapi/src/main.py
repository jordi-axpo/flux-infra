from fastapi import FastAPI

app = FastAPI()

VERSION = "0.0.7"

@app.get("/")
async def root():
    return {"message": f"Hello World from FastAPI! This is version {VERSION}"}
