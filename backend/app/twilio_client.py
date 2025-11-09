import os
import logging
from typing import Dict

TWILIO_SID = os.getenv("TWILIO_ACCOUNT_SID")
TWILIO_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_FROM = os.getenv("TWILIO_FROM_NUMBER")

logger = logging.getLogger("twilio_client")


def send_sms(to: str, body: str) -> Dict:
    """Send SMS via Twilio if configured; otherwise return a mock response.

    This wrapper keeps the rest of the app simple for local development.
    """
    if TWILIO_SID and TWILIO_TOKEN and TWILIO_FROM:
        try:
            from twilio.rest import Client

            client = Client(TWILIO_SID, TWILIO_TOKEN)
            message = client.messages.create(body=body, from_=TWILIO_FROM, to=to)
            logger.info(f"Sent message to {to}: {message.sid}")
            return {"to": to, "status": "queued", "provider_id": message.sid}
        except Exception as e:
            logger.exception("Twilio send failed")
            return {"to": to, "status": "error", "error": str(e)}

    # Mock response for local development
    logger.info(f"(mock) send to {to}: {body}")
    return {"to": to, "status": "mocked", "provider_id": None}
