"""Public jobs feed and protected administration, backed by SQLite."""
import json
import os
import secrets
import sqlite3
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from pydantic import BaseModel, Field, HttpUrl, ConfigDict

router = APIRouter()


def connect():
    path = Path(os.getenv('JOBS_DB_PATH', 'data/jobs.sqlite3'))
    path.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(path)
    db.row_factory = sqlite3.Row
    db.execute('CREATE TABLE IF NOT EXISTS jobs (id TEXT PRIMARY KEY, payload TEXT NOT NULL, active INTEGER NOT NULL)')
    return db


class JobInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra='forbid')
    title: str = Field(min_length=1, max_length=200)
    company: str = Field(min_length=1, max_length=200)
    location: str = Field(default='', max_length=200)
    modality: str = Field(default='', max_length=100)
    description: str = Field(default='', max_length=20000)
    requirements: dict[str, Annotated[float, Field(ge=0, le=1, allow_inf_nan=False)]] = Field(default_factory=dict)
    application_url: HttpUrl | None = None
    active: bool = True


def require_admin(x_admin_token: str | None = Header(default=None)):
    expected = os.getenv('JOBS_ADMIN_TOKEN', '')
    if not expected:
        raise HTTPException(503, 'Cadastro desativado: configure JOBS_ADMIN_TOKEN no servidor.')
    if not x_admin_token or not secrets.compare_digest(x_admin_token, expected):
        raise HTTPException(401, 'Token inválido.')


@router.get('/jobs')
def list_jobs(page: int = Query(default=1, ge=1), page_size: int = Query(default=100, ge=1, le=100)):
    db = connect()
    try:
        rows = db.execute('SELECT payload FROM jobs WHERE active=1 ORDER BY id LIMIT ? OFFSET ?',
                          (page_size + 1, (page - 1) * page_size)).fetchall()
        return {'items': [json.loads(row['payload']) for row in rows[:page_size]],
                'has_more': len(rows) > page_size}
    finally:
        db.close()


@router.put('/admin/jobs/{job_id}', dependencies=[Depends(require_admin)])
def put_job(job_id: str, body: JobInput):
    if not job_id.strip() or len(job_id) > 200:
        raise HTTPException(422, 'ID inválido.')
    payload = {'id': job_id, **body.model_dump(mode='json', exclude={'active'})}
    db = connect()
    try:
        with db:
            db.execute('INSERT INTO jobs(id,payload,active) VALUES(?,?,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload, active=excluded.active',
                       (job_id, json.dumps(payload, ensure_ascii=False), int(body.active)))
        return payload
    finally:
        db.close()


@router.delete('/admin/jobs/{job_id}', dependencies=[Depends(require_admin)])
def deactivate_job(job_id: str):
    db = connect()
    try:
        with db:
            changed = db.execute('UPDATE jobs SET active=0 WHERE id=?', (job_id,)).rowcount
        if not changed:
            raise HTTPException(404, 'Vaga não encontrada.')
        return {'ok': True}
    finally:
        db.close()
