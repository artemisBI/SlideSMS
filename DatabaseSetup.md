# Database Setup Guide for SlideSMS

## Prerequisites Check
1. Docker Desktop is installed and running
2. Python virtual environment is set up
3. Azure Storage account and Queue are configured

## Step-by-Step Database Setup

### Phase 1: Local Development Database

1. **Update Docker Compose Configuration**
   ```yaml
   version: '3.8'
   services:
     postgres:
       image: postgres:15
       environment:
         POSTGRES_DB: slidesms
         POSTGRES_USER: slidesms_user
         POSTGRES_PASSWORD: local_dev_password_only
       ports:
         - "5432:5432"
       volumes:
         - postgres_data:/var/lib/postgresql/data
     
     pgadmin:
       image: dpage/pgadmin4
       environment:
         PGADMIN_DEFAULT_EMAIL: admin@slidesms.app
         PGADMIN_DEFAULT_PASSWORD: pgadmin_local_only
       ports:
         - "5050:80"
       depends_on:
         - postgres

   volumes:
     postgres_data:
   ```

2. **Install Required Python Packages**
   Add to functions/requirements.txt:
   ```
   sqlalchemy>=2.0.0
   psycopg2-binary>=2.9.9
   alembic>=1.12.1
   ```

3. **Create Database Models**
   Create new file: functions/app/models.py
   ```python
   from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Enum
   from sqlalchemy.ext.declarative import declarative_base
   from sqlalchemy.orm import relationship
   from datetime import datetime
   import enum

   Base = declarative_base()

   class MessageStatus(enum.Enum):
       QUEUED = "queued"
       SENDING = "sending"
       SENT = "sent"
       DELIVERED = "delivered"
       FAILED = "failed"

   class Group(Base):
       __tablename__ = 'groups'
       id = Column(Integer, primary_key=True)
       name = Column(String(100), nullable=False)
       created_at = Column(DateTime, default=datetime.utcnow)
       contacts = relationship("Contact", back_populates="group")
       messages = relationship("Message", back_populates="group")

   class Contact(Base):
       __tablename__ = 'contacts'
       id = Column(Integer, primary_key=True)
       phone_number = Column(String(20), nullable=False)
       name = Column(String(100))
       group_id = Column(Integer, ForeignKey('groups.id'))
       created_at = Column(DateTime, default=datetime.utcnow)
       group = relationship("Group", back_populates="contacts")
       message_recipients = relationship("MessageRecipient", back_populates="contact")

   class Message(Base):
       __tablename__ = 'messages'
       id = Column(Integer, primary_key=True)
       content = Column(Text, nullable=False)
       group_id = Column(Integer, ForeignKey('groups.id'))
       status = Column(Enum(MessageStatus), default=MessageStatus.QUEUED)
       created_at = Column(DateTime, default=datetime.utcnow)
       scheduled_for = Column(DateTime, nullable=True)
       group = relationship("Group", back_populates="messages")
       recipients = relationship("MessageRecipient", back_populates="message")

   class MessageRecipient(Base):
       __tablename__ = 'message_recipients'
       id = Column(Integer, primary_key=True)
       message_id = Column(Integer, ForeignKey('messages.id'))
       contact_id = Column(Integer, ForeignKey('contacts.id'))
       status = Column(Enum(MessageStatus), default=MessageStatus.QUEUED)
       provider_message_id = Column(String(100))  # Twilio message ID
       error_message = Column(Text, nullable=True)
       sent_at = Column(DateTime, nullable=True)
       delivered_at = Column(DateTime, nullable=True)
       message = relationship("Message", back_populates="recipients")
       contact = relationship("Contact", back_populates="message_recipients")
   ```

4. **Database Connection Configuration**
   Create new file: functions/app/database.py
   ```python
   from sqlalchemy import create_engine
   from sqlalchemy.orm import sessionmaker
   import os

   # Get connection string from environment variable
   DATABASE_URL = os.getenv('DATABASE_URL')

   # Create engine
   engine = create_engine(DATABASE_URL)

   # Create session factory
   SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

   def get_db():
       db = SessionLocal()
       try:
           yield db
       finally:
           db.close()
   ```

5. **Database Migration Setup**
   Create new file: functions/alembic.ini and functions/migrations/env.py
   (Will provide full configuration in next steps)

### Phase 2: Azure Database Setup

1. **Create Azure PostgreSQL Flexible Server**
   - Region: Same as Function App
   - Networking: Allow Azure services
   - Configure firewall rules for development

2. **Configure Connection Strings**
   Update local.settings.json:
   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "...",
       "FUNCTIONS_WORKER_RUNTIME": "python",
       "DATABASE_URL": "postgresql://user:password@localhost:5432/slidesms"
     }
   }
   ```

3. **Update Azure Function App Settings**
   - Add DATABASE_URL configuration
   - Configure managed identity for database access

### Phase 3: Database Schema Management

1. **Initialize Alembic Migrations**
   ```bash
   alembic init migrations
   ```

2. **Create Initial Migration**
   ```bash
   alembic revision --autogenerate -m "initial_schema"
   ```

3. **Apply Migrations**
   ```bash
   alembic upgrade head
   ```

### Phase 4: Function App Integration

1. **Update Queue Processing Function**
   Update ProcessQueueMessage/__init__.py to use database session

2. **Add Database Health Check**
   Create new function for database connectivity monitoring

### Phase 5: Testing and Validation

1. **Create Test Data Script**
   Script to populate test groups and contacts

2. **Verify Connections**
   Test scripts for both local and Azure databases

## Dependencies Tree

```
Base Requirements:
└── Docker Desktop
    └── PostgreSQL Container
        └── Database Schema
            └── Alembic Migrations
                └── Function App Database Integration
                    └── Twilio Integration (Future)

Development Tools:
└── Python 3.11
    └── Virtual Environment
        ├── SQLAlchemy
        ├── Alembic
        └── psycopg2-binary

Azure Services:
└── Azure Account
    ├── Resource Group
    ├── Storage Account
    │   └── Queue Storage
    └── PostgreSQL Flexible Server
        └── Function App Configuration
```

## Completion Criteria

Before proceeding to Twilio integration, verify:
1. Local PostgreSQL container runs and is accessible
2. Database migrations run successfully
3. Function app can connect to database
4. Basic CRUD operations work
5. Connection pooling and error handling are in place

## Next Steps After Database Setup

1. Twilio integration
2. Message status tracking
3. Webhook handling
4. Group management API