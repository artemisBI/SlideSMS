import logging
import azure.functions as func
from azure.storage.queue import QueueClient
from azure.core.exceptions import ResourceNotFoundError
import json
import sys
import os

def validate_queue_exists(connection_string: str, queue_name: str) -> bool:
    """
    Validate that the required queue exists.
    Returns True if queue exists, False otherwise.
    """
    try:
        queue_client = QueueClient.from_connection_string(
            connection_string,
            queue_name
        )
        # Try to get queue properties to check if it exists
        queue_client.get_queue_properties()
        return True
    except ResourceNotFoundError:
        logging.error(f"Queue '{queue_name}' not found. Process will exit.")
        return False
    except Exception as e:
        logging.error(f"Error checking queue existence: {str(e)}")
        return False

def main(msg: func.QueueMessage) -> None:
    try:
        # Get connection string from environment
        connection_string = os.environ.get('AzureWebJobsStorage')
        queue_name = 'slidesms-send-queue'

        # Validate queue exists on startup
        if not validate_queue_exists(connection_string, queue_name):
            logging.error("Required queue not found. Stopping process.")
            sys.exit(1)  # Exit with error code

        # Process the message
        message_data = msg.get_body().decode('utf-8')
        logging.info(f"Processing message: {message_data}")

        try:
            # Parse message data
            message_json = json.loads(message_data)
            logging.info(f"Message successfully parsed: {message_json}")
            
            # Add your message processing logic here
            
        except json.JSONDecodeError as e:
            logging.error(f"Invalid JSON format in message: {str(e)}")
            # Don't raise here - we want to remove invalid messages from queue
            return

    except Exception as e:
        logging.error(f"Critical error in message processing: {str(e)}")
        # Re-raise to let Azure Functions handle retry policy
        raise