import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from jobs_api import router as jobs_router
from discovery_api import router as discovery_router

app = FastAPI(title='Primeiro Passo Backend')
app.include_router(jobs_router)
app.include_router(discovery_router)
app.add_middleware(CORSMiddleware,
    allow_origins=[v.strip() for v in os.getenv('CORS_ORIGINS', 'http://localhost:5300').split(',') if v.strip()],
    allow_methods=['GET', 'POST', 'PUT', 'DELETE'],
    allow_headers=['Content-Type', 'Authorization', 'X-Admin-Token'])

@app.get('/health')
def health():
    return {'ok': True}
