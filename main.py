from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import os

app = FastAPI(title="DevOps Python API")

# Setup Monitoring (Prometheus)
Instrumentator().instrument(app).expose(app)

@app.get("/")
def read_root():
    return {"status": "Online", "environment": os.getenv("ENV", "Local")}

@app.get("/health")
def health_check():
    return {"status": "Healthy"}