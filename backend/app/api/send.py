from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List

from app.twilio_client import send_sms

router = APIRouter()


class SendRequest(BaseModel):
    message: str = Field(..., max_length=1600)
    recipients: List[str]


@router.post("/send")
async def send_message(req: SendRequest):
    if not req.recipients:
        raise HTTPException(status_code=400, detail="recipients required")

    results = []
    for to in req.recipients:
        res = send_sms(to, req.message)
        results.append(res)

    return {"sent": len(results), "results": results}
