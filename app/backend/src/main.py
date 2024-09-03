from fastapi import FastAPI

app = FastAPI()

VERSION = "0.0.1"

@app.get("/")
async def root():
    return {"message": f"Hello World! This is version {VERSION}"}


@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}
