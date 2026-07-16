# Terms and Conditions

**Effective Date:** July 16, 2026

Welcome to Vouch (the "Application"). By creating an account or using the Application, you agree to be bound by these Terms and Conditions. If you do not agree to these Terms, please do not use the Application.

### 1. Description of Service
Vouch is a centralized student governance, multi-tiered clearance, attendance mapping, and organization fee tracking platform designed for institutional campuses, faculties, and student programs. The platform offers multi-tenant workspaces handling localized requirements via distinct organizational roles.

### 2. User Accounts and Verification
* **Registration:** Users must register using an authentic, institutionally aligned email address and provide precise personal details.
* **Required Information:** You agree to provide accurate information upon registration, including your legal name, official student ID number, institutional campus, faculty, and program affiliation.
* **Account Security:** You are entirely responsible for all interactions performed by your account. You must notify platform administration immediately if you suspect unauthorized access.

### 3. Role-Based Access Controls (RBAC) and Governance
The Application employs strict Role-Based Access Controls linked to structural scopes (Program, Faculty, or Institutional).
* **User Designations:** Roles include Super Admin, Faculty Dean, Program Head, Instructor, Adviser, Comselec Chair, Commissioner, organizational officers (e.g., Governor, Treasurer, Secretary), and standard Students/Voters.
* **Scope Compliance:** Administrative capabilities (creating events, tracking fees, signing clearance slots, enforcing sanction rules, or collecting items) are governed purely by permission sets mapping to your scope.
* **Abuse Policy:** Attempting to manipulate metadata or circumvent row-level security policies to perform ungranted actions will result in immediate termination of account access and referral to institutional disciplinary committees.

### 4. Payment Management and Digital Ledgers
* **Platform Role:** Vouch acts purely as an administrative registration ledger for organizing fees, payment targets, and financial compliance.
* **Verification:** Organizational Treasurers or authorized officers verify receipts, reference numbers, and photos submitted by students to clear administrative fee lines.
* **Liability Disclaimer:** Vouch does not process digital financial transactions directly and carries no liability for actual cash handling or bank transfer discrepancies executed outside the framework of the application.

### 5. Attendance Recording and Excuse Processing
* **Attendance Tracking:** The app logs event attendance metrics via authorized scanning mechanisms.
* **Excuses:** Students may upload legitimate documentation to support an excuse request if they fail to log presence. Officers retain complete authority over review parameters.
* **Sanctions:** Failure to fulfill minimum attendance records triggers automatic sanction records requiring designated items as configured by organizational bylaws.

### 6. Prohibited Activities
You agree not to upload corrupted files, distribute malicious software through storage buckets, forge reference numbers, submit fraudulent imagery as payment validation, or falsify documentation inside the clearance workflow.

### 7. Account and System Data Deletion
* **User-Initiated Deletion:** In compliance with Google Play Store policies, users retain the right to have their data removed from the system completely.
* **Non-Instant Deletion / Pending Review:** In order to maintain the integrity of institutional student clearances, event attendance accountability, and fee collections, account deletion is not instantaneous.
* **Review Period:** Submitting a deletion request initiates a 14-day administrative hold. During this window, school administrators (Super Admins, Deans, or Program Heads) will review your academic record for any unresolved clearances, unpaid fees, or pending sanctions.
* **Right of Denial:** The institution reserves the right to deny, hold, or delay an account deletion request if the user has outstanding clearance requirements or unfulfilled sanction obligations.
* **Administrative Deletion:** The system provides a dedicated mechanism (`delete_user_entirely`) to purge an individual's database profile and core authentication profile completely upon verified requests.
* **Academic Lifecycle Resets:** Users acknowledge that structural data, including attendance signatures, clearance files, payment verifications, and sanction histories, are systematically purged during cyclical academic year transitions via automated system resets (`reset_academic_year_data`).