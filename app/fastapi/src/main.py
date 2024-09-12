from fastapi import FastAPI
from os import getenv

app = FastAPI()

VERSION = "0.1.0"

ENV = getenv("ENV")

@app.get("/")
async def root():
    return {"message": f"Hello World from FastAPI! This is version {VERSION} in environment {ENV}"}
