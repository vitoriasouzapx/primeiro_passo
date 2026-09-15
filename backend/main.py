import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from jobs_api import router
from pydantic import BaseModel
from openai import OpenAI

app=FastAPI(title='Primeiro Passo AI Backend')
app.include_router(router)
app.add_middleware(CORSMiddleware,
    allow_origins=[v.strip() for v in os.getenv('CORS_ORIGINS', 'http://localhost:5300').split(',') if v.strip()],
    allow_methods=['GET', 'POST'], allow_headers=['Content-Type'])
class ChatIn(BaseModel):
    message:str
    profile:dict

@app.get('/health')
def health(): return {'ok':True}

@app.post('/chat')
def chat(body:ChatIn):
    if not os.getenv('OPENAI_API_KEY'):
        raise HTTPException(503, 'IA não configurada; o app utiliza a resposta local.')
    client = OpenAI(api_key=os.environ['OPENAI_API_KEY'])
    system='''Você é o assistente educacional de carreira do app Primeiro Passo. Use o perfil fornecido para orientar próximos passos de empregabilidade, capacitação, adaptação e reflexão sobre o ser humano no trabalho. Não faça diagnóstico psicológico. Diferencie fatos, hipóteses e expectativas. Seja acolhedor, prático e conciso.'''
    prompt=f"PERFIL:\n{body.profile}\n\nMENSAGEM:\n{body.message}"
    r=client.responses.create(model=os.getenv('OPENAI_MODEL','gpt-5.6-luna'),input=[{'role':'system','content':system},{'role':'user','content':prompt}])
    return {'answer':r.output_text}

