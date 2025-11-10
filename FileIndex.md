# SlideSMS Project File Index

## Project Documentation
- `ProjectPlan.md` - Main project planning document with architecture, vendor decisions, and implementation steps
- `ProjectSummary.md` - Overview of the project goals and requirements
- `CONTRIBUTING.md` - Guidelines for contributing to the project
- `LICENSE` - Project license information
- `README.md` - Project overview and setup instructions
- `SAVEPOINT.md` - Development progress tracking
- `tiersAndPackages.txt` - Service tier and package definitions
- `numberScoring.txt` - Phone number scoring system documentation
- `sampleMessages.txt` - Sample SMS message templates

## Backend Service (Python FastAPI)
- `backend/`
  - `Dockerfile` - Container definition for the backend API service
  - `requirements.txt` - Python package dependencies for the backend
  - `alembic.ini` - Database migration configuration
  - `migrations/` - Database migration files
    - `env.py` - Alembic environment configuration
    - `versions/` - Migration version files
      - `001_initial.py` - Initial database schema migration
  - `app/`
    - `main.py` - FastAPI application entry point
    - `models.py` - SQLAlchemy database models and schemas
    - `database.py` - Database connection and session management
    - `twilio_client.py` - Twilio SMS service integration
    - `api/`
      - `health.py` - Health check endpoints
      - `send.py` - SMS sending endpoints

## Frontend Application (React)
- `frontend/`
  - `Dockerfile` - Container definition for the frontend service
  - `index.html` - Entry HTML file
  - `package.json` - Node.js dependencies and scripts
  - `src/`
    - `App.jsx` - Main React application component
    - `main.jsx` - Application entry point
    - `styles.css` - Global styles

## Azure Functions
- `functions/`
  - `host.json` - Azure Functions host configuration
  - `local.settings.json` - Local development settings
  - `requirements.txt` - Python package dependencies for Functions
  - `QueueProcessorFunction/`
    - `__init__.py` - Queue message processing function
    - `function.json` - Function trigger and binding configuration
  - `TwilioWebhookFunction/`
    - `__init__.py` - Twilio webhook handling function
    - `function.json` - Function trigger and binding configuration
  - `create_queue.py` - Utility script to create Azure Storage Queue

## Development Scripts
- `scripts/`
  - `run_local.ps1` - PowerShell script for local development setup

## Docker Configuration
- `docker-compose.yml` - Docker Compose configuration for local development

## Purpose and Interactions

### Backend Service
- Provides REST API endpoints for the frontend
- Handles user authentication and authorization
- Manages group and contact operations
- Queues SMS messages for processing

### Frontend Application
- User interface for the SMS platform
- Interacts with backend API
- Manages user sessions and input
- Displays message status and history

### Azure Functions
- **QueueProcessorFunction**: 
  - Processes queued SMS messages
  - Handles retries and error cases
  - Monitors queue status
  - Validates queue existence
- **TwilioWebhookFunction**: 
  - Handles Twilio webhook callbacks
  - Updates message delivery status
  - Processes incoming messages

### Development and Infrastructure
- Docker configurations enable consistent development and deployment environments
- PowerShell scripts automate common development tasks
- Documentation files provide project guidance and tracking