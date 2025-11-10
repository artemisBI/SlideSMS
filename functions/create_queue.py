from azure.storage.queue import QueueClient
import os
import json

def create_queue_and_send_message():
    # Get connection string from local.settings.json
    with open('local.settings.json') as f:
        settings = json.load(f)
        connection_string = settings['Values']['AzureWebJobsStorage']

    # Create the queue
    queue_name = "slidesms-send-queue"
    queue_client = QueueClient.from_connection_string(
        connection_string, 
        queue_name
    )
    
    print(f"Creating queue: {queue_name}...")
    queue_client.create_queue()
    print("Queue created successfully!")
    
    # Send a test message
    message = {
        "phoneNumber": "+1234567890",
        "message": "Test message from SlideSMS"
    }
    
    print("Sending test message...")
    queue_client.send_message(json.dumps(message))
    print("Test message sent successfully!")

if __name__ == "__main__":
    create_queue_and_send_message()