# Project Plan: slideSMS.app

> Converted from a LaTeX source into GitHub-flavored Markdown for easy uploading to a GitHub Wiki or repository documentation. See the short "How to upload" notes at the bottom.

## 1. Project Vision

To create a scalable, user-friendly group SMS messaging web application named **slideSMS.app**. The service allows administrators ("orchestrators") to manage recipient lists and send scheduled, optimized text message campaigns to US domestic phone numbers.

## 2. Technology & Architecture

- **Backend Language:** Python
- **Deployment:** Docker-based, utilizing modern DevOps practices for scalability.
- **Environment:** Support for local development and testing before production deployment.
- **Target Market:** US domestic phone numbers only.

## 3. Core Features & User Flows

### 3.1 Admin Authentication

- **Login:** Admins log in using their phone number and an organization name.
- **Security:** Implement modern authentication (OAuth2, MFA) using providers like Google or email-based verification codes.
- **Multi-Organization Support:** Admins can belong to multiple organizations and switch between them via a dropdown menu or create a new one.

### 3.2 User Flow: First Campaign

1. **Define Recipient List**
   - **Input Methods:** Upload (.xls, .csv, Google Sheets) or paste text (CSV, tab-delimited).
   - **Required Data:** `firstname`, `phone number`.
   - **Data Scrubbing:** Automatically sanitize phone numbers by removing non-numeric characters (e.g., `(`, `)`, `-`, `.`).
   - **Admin Opt-in:** Prompt the admin to add their own number to the list if it's not already present.

2. **Validate List & Handle Duplicates**
   - **Confirmation Screen:** Display total recipient count and a list of invalid numbers (e.g., fewer than 10 digits).
   - **Duplicate Handling:** Automatically handle duplicate first names by appending a number (e.g., `John001`, `John002`). Allow admin to override by adding a last name or nickname (e.g., `John Q`, `Johnny`).

3. **Recipient Number Scoring**
   - **Function:** Assign a quality score (1–5) to each phone number based on historical data to predict engagement.
   - **Scoring Model:**
     - **1 (Poor):** Number frequently opts out.
     - **2 (At-Risk):** Opts in, but is on >3 lists and received >3 texts from the service in the past week.
     - **3 (Neutral):** No historical data.
     - **4 (Good):** Opts in, but is on >3 lists.
     - **5 (Healthy):** Opts in, not on many lists.

4. **Compose Message**
   - **Message Type:** Choose between `text-only` or `text + link`. The link option can integrate with form builders.
   - **Sender ID:** Define a 3–5 character `orgCode` (e.g., Walgreens -> WLGRN).
   - **AI-Powered Optimization:** The service will generate 2 message recommendations to minimize character count and maximize value, using a substitution dictionary (e.g., `talk to your` -> `tty`). The AI will prioritize clear, concise communication.
   - **Final Choice:** Admin can select an AI suggestion, edit their prompt and resubmit, or write their own message manually.

5. **Schedule & Confirm**
   - **Scheduling:** Use a date/time picker with time zone support to schedule the campaign.
   - **Final Review:** Display a summary of the campaign (recipient count, message, scheduled time) for final confirmation.
   - **Execution:** Admin clicks "Send" to schedule the job.

### 3.3 Post-Campaign & Management

- **Campaign Editing:** Admins can modify any aspect of a scheduled campaign before the send time. Once sent, the campaign is locked.
- **Admin Reporting:** 24 hours after a campaign is sent, the admin receives a summary SMS: _"Hi {FirstName}! 48 sent, 2 bad numbers, 27 success, 10 optout. {shortlink to webapp}"_
- **Recipient Opt-Out:** If a recipient opts out, their status is permanently recorded with a timestamp to respect their preference in all future campaigns.

## 4. Monetization: Tiers & Packages

- **Tier 1 (Free):** Trial tier to encourage adoption. Limited to one list and a maximum of 5 messages.
- **Tier 2 ($10/month):** Subscription for increased usage.
- **Tier 3 ($30/month):** Aimed at typical small business owners.
- **Tier 4 (Enterprise):** Custom pricing for a full range of current and future services.

## 5. Sample Messages

- **Sample 1:** slideSMS.CVS - These depts are closed on THXGVG 11/24. TTY mgr nxt shift; From Spain. Txt OK to confirm, STOP to optout.
- **Sample 2:** slideSMS.YUP - Social is 11/12 @5PM to 630PM. @Location. From Spain. {Shortlink}. Txt OK to confirm, STOP to optout.

---

## How to upload this file to GitHub (for beginners)

Option A — Use the repository Wiki (simple, editable pages):
1. Go to your repository on github.com.
2. Click the "Wiki" tab.
3. Click "Create the first page" (or "New Page").
4. Copy-paste the contents of this file and save the page. The wiki uses Markdown.

Option B — Add to your repository as documentation (recommended if you want it versioned):
1. Place this file in your repo (for example in a `docs/` folder or as `README.md`).
2. Commit and push with Git. Example (powershell):

   git add ProjectSummary.md
   git commit -m "Add project summary as Markdown"
   git push

After pushing, GitHub will render the Markdown in the repo. If you want the file as the repo homepage, name it `README.md`.

If you'd like, I can also:
- Create a `README.md` wrapper or place this file in a `docs/` folder.
- Show you the exact Git commands for your repository and how to push from your Windows machine.

---

*File converted automatically from LaTeX source.*
