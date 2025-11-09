## SlideSMS — Project Plan for a Group SMS Webapp

Last updated: 2025-11-08

This document is a beginner-friendly, step-by-step project plan to build a scalable group-SMS web application (MVP -> production). It includes recommended tech stacks, service vendor choices (2–3 options per category with considerations), an architecture overview, an actionable build plan, and training resources.

If you prefer short, actionable tasks, follow the numbered "Development Roadmap" section. Read the vendor recommendations when you're ready to purchase services.

## Concrete ordered setup checklist (dependency order)

Follow these steps in order. Each step depends on the previous so do them sequentially. I included quick commands where useful.

1) Install Docker locally (Windows)
   - Why: you will build the backend container image and push to Docker Hub before creating Container Apps.
   - Install: download Docker Desktop for Windows from https://www.docker.com/products/docker-desktop and run the installer.
   - Verify in PowerShell:
     ```powershell
     docker --version
     ```

2) Create a Docker Hub account & repository
   - Create an account at https://hub.docker.com and a repository (e.g., `youruser/slidesms-backend`).

3) Build & push backend image (local quick test)
   - From repo root (PowerShell):
     ```powershell
     docker build -t youruser/slidesms-backend:latest -f backend/Dockerfile ./backend
     docker login --username youruser
     docker push youruser/slidesms-backend:latest
     ```
   - This gives you the image that Azure Container Apps will pull.

4) (Optional) Add CI to build & push images
   - Add a GitHub Actions workflow to build and push images to Docker Hub on push to `main` (recommended for automation).

5) Provision Azure infra (same region; EastUS2 recommended)
   - Create a Resource Group (e.g., `slideSMS-rg`) and a Log Analytics workspace.
   - Create a Container Apps environment (requires Log Analytics workspace).
   - Create the Container App for the API using your Docker Hub image (ingress=external, target port=8000). Keep `api` DNS-only in Cloudflare.
   - Create background worker as a Container App job or an Azure Function app (Python 3.10/3.11) for queue processing.

   Example az CLI (edit placeholders):
   ```powershell
   az group create --name slideSMS-rg --location eastus2
   az monitor log-analytics workspace create --resource-group slideSMS-rg --workspace-name slideSMS-law
   # create environment and app as previously discussed
   ```

6) Obtain the Container App FQDN(s)
   - After creation, get the backend FQDN (example: `my-api.***.azurecontainerapps.io`) — you'll use that as Cloudflare CNAME target.

7) Configure Cloudflare DNS (only after you have the FQDN)
   - Add CNAME: `api` -> `<your-containerapp-fqdn>` (Proxy: DNS only / grey cloud)
   - Add CNAME: `www` -> `<frontend-host>` (Proxy: Proxied / orange cloud)
   - Add apex (slidesms.app) as CNAME (flattening) to frontend host or A record per host instructions.

8) Add custom domains in Azure (validate ownership)
   - In App Service/Container Apps, add `api.slidesms.app` and `www.slidesms.app`; Azure will show verification TXT/CNAME values — add those in Cloudflare DNS and validate.

9) Enable TLS
   - In Cloudflare: SSL/TLS -> set to Full (strict) if origin cert valid; enable Always Use HTTPS.

10) Update local and CI config
   - Copy `.env.example` → `.env` and set APP_DOMAIN and FRONTEND_BASE_URL.
   - Add GitHub repository secrets: DOCKERHUB_TOKEN, DOCKERHUB_USERNAME, TWILIO_*, APP_DOMAIN.

11) Test end-to-end
   - Visit `https://slidesms.app` and `https://api.slidesms.app/health`.
   - Test sending an SMS from the deployed app and verify delivery receipts and inbound messages (Twilio webhooks).

Notes & gotchas:
- DNS cannot be completed until you have the hostnames from Azure (step 6). Cloudflare nameservers can remain configured now.
- Keep `api.slidesms.app` as DNS-only (grey cloud) to avoid Twilio webhook complications.
- If you need to test webhooks before DNS is ready, use Cloudflare Tunnel or ngrok to expose your local service.


### Decisions (confirmed)
- Frontend: React (SPA, recommended with Vite)
- Backend: Python + FastAPI
- Background processing: Azure Functions (serverless) for job processing
- Container registry: Docker Hub
- Database: Azure Database for PostgreSQL
- SMS provider: Twilio Programmable SMS
 - Domain: slidesms.app (registered) — update DNS to point to hosting and enable Cloudflare (recommended) for TLS/WAF/CDN.

## Goals (what the app should do)
- Allow users to create groups and add phone numbers.
- Send SMS messages (one-off and scheduled) to groups.
- Track delivery status and basic analytics (sent, delivered, failed).
- Scale from a small user base (MVP) to many messages/users.

## Minimum Viable Product (MVP) feature list
- User registration and login (email + password, or social login later).
- Create groups (name, description) and add/remove phone numbers.
- Compose and send SMS to a group.
- Message queueing and retry for undelivered messages.
- Basic message history and delivery status UI.
- Simple admin dashboard for usage and billing metrics.

## High-level architecture (conceptual)
- Client (single page app) — React (recommended) for a modern, fast frontend with wide ecosystem (Vite, Create React App, or Next.js later for SSR/ISR).
- API server — Python + FastAPI containerized with Docker. FastAPI is modern, async-friendly, and provides automatic OpenAPI docs which shortens development time and reduces complexity.
- Background processing — Azure Functions (serverless) to process send-jobs, retries and webhook handling; this reduces operational overhead compared to self-hosted workers.
- Queueing — Azure Queue Storage or Azure Service Bus (used by Functions) for decoupling send requests from processing.
- Database — Azure Database for PostgreSQL (managed Postgres) for app data (users, groups, messages).
- SMS provider API — Twilio Programmable SMS for sending and receiving messages; Twilio webhooks provide delivery receipts and inbound messages.
- CI/CD pipeline — GitHub Actions to build, test, push Docker images to Docker Hub, and deploy to Azure App Service / ACI / Functions as needed.
- Hosting — Azure App Service for the API (or ACI) and Azure Functions for background jobs; optionally AKS later for advanced orchestration.
- Monitoring & logging — Azure Monitor / Application Insights + Sentry for error tracking.
- Secrets — Azure Key Vault for API keys and DB credentials.

## Tech stack recommendation (beginner-friendly, scalable)
Primary recommendation: React (frontend) + Python + FastAPI (backend) + Docker + GitHub Actions + Azure hosting

- Why Python? You're comfortable with it. Python has many libraries, good community support, and is easy for rapid development.
- Why FastAPI? Modern, fast, built for async I/O, automatically generates docs (OpenAPI), and scales well for APIs. FastAPI is the recommended choice over Flask because it requires fewer decisions around async handling, gives built-in validation with Pydantic, and tends to reduce boilerplate for APIs.
- Frontend: React is recommended — it separates concerns from the backend, has excellent ecosystem (component libraries, routing, form handling), and pairs well with a FastAPI backend exposing JSON APIs. Use Vite for a fast dev server and build experience.
- Background processing: Azure Functions (serverless) is recommended for your background jobs; Functions integrate with Azure Queues/Service Bus and reduce the operational burden of maintaining worker hosts. If you later need advanced scheduling or custom workers, you can adopt Celery with Redis.
- Database: Azure Database for PostgreSQL (managed Postgres) for easier Python integration (`psycopg2`) and strong ecosystem support.
- Container registry: Docker Hub (selected) for storing your container images; Azure Container Registry remains an alternative if tighter Azure integration is desired.
- ORMs: SQLAlchemy (works well with Postgres). Use Alembic for migrations.

Tradeoffs and notes:
- Azure Functions reduces operational complexity but has cold-start considerations for rarely used functions and different scaling semantics than long-running workers. It's a good modern choice for many background jobs and webhook handling.
- Azure Database for PostgreSQL simplifies Python setup compared to Azure SQL because drivers and libraries are native to Python.

If you later prefer .NET: Azure + .NET is also excellent and well-integrated. For a beginner with Python preference, Python + FastAPI is the simplest path to a working and scalable MVP.

## Core service vendor categories & recommended vendors
For each category, I list top picks and why.

1) Domain registrar & DNS
- Cloudflare — domain registrar + best-in-class DNS + free CDN & DDoS protection. Very developer-friendly. Considerations: If you already use Cloudflare, it's easiest to centralize domain, DNS, SSL, and CDN there.
- Google Domains — simple UI, reliable. Good for those who prefer Google ecosystem.
- GoDaddy — widely used, sometimes cheaper promos; beware upsells and UI complexity.

2) CDN / Edge DNS / WAF
- Cloudflare — excellent CDN, DNS, performance, and WAF in one. Great for static assets and protecting the app.
- Azure Front Door — integrates tightly with Azure, global load balancing, WAF.
- AWS CloudFront — if you plan to use AWS for hosting; otherwise Cloudflare is simpler cross-cloud.

3) Hosting / Compute (where your Docker containers run)
- Azure App Service (Web App for Containers) — easiest path on Azure to deploy containerized web apps with built-in scaling and managed platform features.
- Azure Container Instances (ACI) — for small-to-medium workloads, simple and serverless container execution.
- Azure Kubernetes Service (AKS) — for long-term, large-scale orchestration with advanced traffic control — more operational overhead.
- Simpler alternatives (non-Azure): Render, DigitalOcean App Platform — cheaper and simpler for hobby/early-stage apps.

4) Container registry
- Docker Hub — easy and common; selected for this project. Good cross-cloud portability and simple integration with GitHub Actions.
- Azure Container Registry (ACR) — private registry integrated with Azure; alternative if you prefer fully managed, private images inside Azure.

5) CI/CD
- GitHub Actions — directly integrates with your GitHub repo; powerful and free minutes for public repos.
- Azure DevOps Pipelines — deeper Azure integration and enterprise features.

6) Database
- Azure SQL Database — you know it; enterprise-grade and fully managed. Works well with .NET and with Python via ODBC drivers.
- Azure Database for PostgreSQL — managed Postgres, great Python integration and open-source ecosystem.


7) SMS provider (critical) — APIs, deliverability, number management
Primary recommendation (selected):
- Twilio — selected for this project. Twilio Programmable SMS is the API/platform you'll use for sending/receiving SMS, managing phone numbers, and receiving delivery receipts via webhooks. Twilio has excellent Python SDKs and tutorials to get started quickly.
- Bandwidth — a carrier that offers API-based SMS with competitive pricing and better control over phone numbers (sometimes cheaper for high volume). Consider later if you scale very large.
- RingCentral — offers messaging APIs for SMS and MMS; consider only if you already use RingCentral for telephony.
- Alternatives: Vonage (Nexmo), MessageBird — solid international options.

SMS provider considerations:
- Throughput and throttling (how many messages per second/minute).
- Short codes vs long codes vs toll-free numbers (short codes are faster and better for mass messaging but require approval and cost more).
- Two-way messaging support and callbacks/webhooks for delivery receipts and inbound messages.
- Compliance (TCPA in the U.S. and local laws) and opt-in/opt-out management.
- Pricing: per-message costs, monthly number fees, short-code leasing.

Can I "piggyback" off Twilio Programmable SMS?

Short answer: Yes — you build your app on top of Twilio. Twilio is a programmable communications platform (APIs + services). It is not a ready-made group-SMS user-facing app; instead, it provides the building blocks (send/receive SMS, phone number management, webhooks for delivery receipts and inbound messages, tools for scaling and compliance). In practice:

- You will use Twilio's API/SDK from your FastAPI backend (or from Azure Functions) to send messages and to receive delivery/inbound webhooks.
- Twilio handles carrier connectivity, regional routing, and many deliverability details for you — this is the main value.
- You still need to build the group management UI, user auth, opt-in flows, message queuing, retry logic (or let Functions handle retries), logging, and compliance workflows.

When to rely on Twilio vs build custom:
- Start with Twilio for MVP — it's fast to integrate, well-documented, and reliable for small to medium volumes.
- If you grow to very large volume and want lower cost or direct carrier relationships, consider switching/augmenting with a carrier like Bandwidth or direct aggregator contracts. But most apps piggyback on Twilio (or similar) for a long time because of the development speed and operational simplicity.

Practical next steps for Twilio integration:
1. Create a Twilio account and get a trial number to test sending/receiving SMS.
2. Implement a small send endpoint in FastAPI that enqueues an Azure Function job or calls Twilio directly for testing.
3. Configure Twilio webhooks to an HTTP endpoint (FastAPI or Azure Function) to receive delivery receipts and inbound messages; persist those to `message_recipients`.


8) Queueing & background jobs
- Redis + Celery — mature, full-featured, supports retries, scheduling.
- Azure Storage Queues or Azure Service Bus + Azure Functions — serverless approach with tight Azure integration.

9) Secrets & key management
- Azure Key Vault — store API keys, DB credentials, and secrets securely.
- HashiCorp Vault — advanced, multi-cloud secret management.

10) Monitoring, logging & error reporting
- Azure Monitor & Application Insights — integrated with Azure, great telemetry for app performance.
- Sentry — excellent error tracking for Python; easy to integrate.

## Competitors & market landscape (group SMS / mass texting)
Key competitors and services to study:
- Twilio Programmable SMS (platform enabling many products) — not a consumer app but the underlying platform.
- SimpleTexting — focused on easy mass texting and campaigns.
- EZ Texting — SMS marketing and group messaging.
- Textedly — SMS marketing & group messaging.
- Trumpia — enterprise mass messaging.
- Remind — education-focused group messaging (classroom / school to parent messaging).
- GroupMe (Microsoft) — group chat app (uses data messaging more than carrier SMS).

Typical user reviews and common challenges across these services:
- Deliverability problems: messages being marked as spam or blocked by carriers.
- Cost: per-message fees can grow quickly with volume.
- Compliance complexity: ensuring opt-ins and handling unsubscribes to follow rules like TCPA.
- Limited two-way support: some platforms handle replies poorly or inconsistently.
- UX limitations: many services trade off advanced features for simplicity.

Use these competitor pain points as design goals: make deliverability visible, simplify compliance, provide transparent pricing, and support clear two-way flows.

## Step-by-step Development Roadmap (detailed, beginner-friendly)
Phase 0 — prep (1–2 days)
1. Create a GitHub repo (private/public).
2. Pick a domain and DNS provider (register `slideSMS.app` or a variant): Cloudflare recommended.
3. Create an Azure account (if not already) and enable resource groups, subscription, and billing.

Phase 1 — initial prototype (MVP) (1–2 weeks)
1. Scaffold the API
   - Create a Python project with virtualenv/Poetry.
   - Install FastAPI, Uvicorn, SQLAlchemy, alembic, and a DB driver (pyodbc or psycopg2).
2. Basic models and endpoints
   - User (id, email, hashed_password)
   - Group (id, name, owner_id)
   - GroupMember (group_id, phone_number)
   - Message (id, group_id, content, status, created_at)
3. Implement user auth (simple email/password + JWT tokens).
4. Implement Create Group / Add members endpoints and a simple UI (or Postman to test).
5. Add sending flow
   - Create a background job queue (Redis + RQ or Celery).
   - Implement a worker that takes a message job and calls the SMS provider API.
6. Hook Twilio (or chosen provider) sandbox to send test SMS.

Phase 2 — Docker, CI/CD, deployments (1 week)
1. Write a Dockerfile for the API and one for the worker (or one image with different commands).
2. Configure GitHub Actions:
   - Build Docker image, run unit tests, push image to ACR (or Docker Hub).
   - Deploy to Azure App Service for Containers or ACI.
3. Set up Azure resources: App Service, Redis Cache (Azure Cache for Redis) or use Azure Queue Service.

Phase 3 — production readiness (2–4 weeks)
1. Move secrets to Azure Key Vault.
2. Add Application Insights and Sentry for observability.
3. Add rate limiting, retry policies, and exponential backoff.
4. Set up monitoring and alerting (thresholds for failed sends, worker queue length).
5. Implement billing/usage tracking and basic admin reporting.
6. Implement compliance features: opt-in capture, unsubscribe keywords, and retention policy.

Phase 4 — scale & optimization (ongoing)
1. Review SMS throughput with provider and consider short codes/toll-free numbers for high volume.
2. Consider AKS or multiple worker instances behind autoscaling rules.
3. Use a regional DB read-replica strategy if needed.

## Example DB schema (simplified)
- users: id, email, password_hash, created_at
- groups: id, owner_id (FK users), name, created_at
- members: id, group_id (FK groups), phone_number, added_by, created_at
- messages: id, group_id (FK), content, status, scheduled_at, created_at
- message_recipients: id, message_id (FK), phone_number, status, provider_message_id, delivered_at

Notes: store provider_message_id so you can reconcile delivery reports from the SMS provider.

## Key implementation notes & gotchas
- SMS compliance is mandatory (store opt-ins, provide a clear unsubscribe flow).
- Test with low volumes first. Carriers sometimes block large volumes from new accounts.
- Use webhooks to get delivery receipts and inbound replies; store them in `message_recipients`.
- Monitor costs: SMS costs add up and differ by destination country and number type.
- For Azure SQL with Python: you'll need ODBC drivers and `pyodbc` configuration — be ready for some setup time. PostgreSQL (`psycopg2`) often requires fewer platform-specific steps.

## CI/CD and deployment checklist (GitHub + Azure example)
1. Protect `main` branch; use pull requests and code reviews.
2. GitHub Actions pipeline:
   - Build & test python unit tests.
   - Build Docker image and push to ACR.
   - Deploy to Azure App Service (slot-based deployments recommended).
3. Use deployment slots for zero-downtime deploys.

## Cost & procurement checklist (what you'll likely need to purchase)
- Domain registration (annual): Cloudflare / Google Domains / GoDaddy.
- SMS provider costs: per-message + phone number fees. Start with Twilio trial and upgrade as needed.
- Azure costs: App Service, Azure SQL / PostgreSQL, Redis or Azure Queue, ACR storage, Application Insights. Use Azure cost estimator to forecast.
- Optional: Short code for high-volume messaging (expensive, application process required).

Additional note:
- Domain `slidesms.app` — registered on 2025-11-08. Next steps: add the registrar's nameservers to Cloudflare (if using Cloudflare), create DNS records (A/CNAME) pointing to your host, enable TLS/HTTPS (Cloudflare or Azure-managed certificates), and add any verification records required by Twilio for webhooks.

## Learning resources (recommended, many beginner-friendly)
- FastAPI docs (official) — concise, excellent examples: https://fastapi.tiangolo.com
- Docker for beginners — Docker Desktop tutorial and official docs.
- GitHub Actions docs — start with simple build-and-deploy actions.
- Twilio Quickstart for Python — how to send SMS with Twilio using Python.
- Azure Fundamentals + Azure App Service + Azure SQL tutorials on Microsoft Learn.

Udemy course suggestions (if you have access via your company):
- "FastAPI - The Complete Guide" — covers building modern Python APIs with async endpoints.
- "Docker and Kubernetes: The Complete Guide" — good if you plan to learn container orchestration (AKS later).
- "The Complete Python Web Developer 202X" — an overview including REST APIs, Docker, and deployment.

Free resources and guided tracks:
- Microsoft Learn: Azure Fundamentals and App Service quickstarts.
- RealPython articles (many free) for Python web development and SQLAlchemy.

## Security & compliance quick checklist
- Use HTTPS everywhere (Cloudflare + TLS, or Azure Managed Certificates).
- Store secrets in Key Vault, not in source control.
- Implement rate limits and abuse detection for message sending.
- Keep logs for delivery reports and opt-ins for compliance reasons.

## Success criteria for MVP
- Can register users, create groups, and send SMS to small groups (5–50 numbers).
- Messages are queued and retried on transient failures.
- Delivery receipts are stored and viewable in the admin dashboard.

## Next steps (immediate, first week)
1. Confirm domain name variant you want (I can check availability if you want).
2. Decide whether to use Azure SQL or PostgreSQL for the first MVP (I recommend PostgreSQL for easier Python integration unless Azure SQL is required).
3. I will create a minimal repo scaffold (FastAPI + Dockerfile + simple endpoints) if you want — say the word and I will add starter code.

---

If you'd like, I can now:
- scaffold a starter repo with FastAPI, Dockerfile, a simple Send SMS endpoint (wired to Twilio sandbox), and GitHub Actions workflow;
- or generate detailed Terraform/ARM templates for Azure resources.

Which would you like me to do next? If you want the starter repo, tell me whether you want `Azure SQL` or `PostgreSQL` for the MVP database and whether to wire Twilio as the initial SMS provider.
