This is a good decision. Your new attendance structure is much cleaner:

| Event Name | Date | Status | Verified By |
| ---------- | ---- | ------ | ----------- |

Where an event can be considered **Completed** through:

1. ✅ Attended the event (Time In + Time Out)
2. ✅ Completed the assigned sanction
3. ✅ Approved excuse request

Now let's design the **Excuse Request Flow**.

---

# Excuse Request Flow

## Step 1: Student views an event

Example:

```txt
Leadership Seminar
Date: Aug 15, 2026

Status: Absent

Actions:
[Submit Excuse]
```

The **Submit Excuse** button only appears when:

```txt
Attendance Status != Completed
AND
No existing approved excuse
```

---

# Step 2: Student submits an excuse

Student clicks:

```txt
Submit Excuse
```

Modal/Page:

## Excuse Request Form

```txt
Event
Leadership Seminar

Reason Type *
[ Dropdown ]

Reason Description *
[ Text Area ]

Supporting Document *
[ Upload ]

Declaration
☑ I certify that the information provided is true.

[ Cancel ] [ Submit Request ]
```

---

## Suggested Reason Types

```txt
Medical Reason
Family Emergency
Official University Activity
Academic Requirement
Religious Activity
Personal Emergency
Others
```

---

# Step 3: Student uploads evidence

Allowed attachments:

```txt
Medical Certificate
Official Letter
Certificate of Participation
Funeral Notice
University Memorandum
Photo Evidence
PDF
Image
```

Accepted formats:

```txt
PDF
PNG
JPG
JPEG
```

---

# Step 4: Request Status

After submission:

```txt
Status: Pending Review
```

Student can track:

```txt
My Excuse Requests

Leadership Seminar
Status: Pending

General Assembly
Status: Approved

Community Extension
Status: Rejected
```

---

# Step 5: Secretary Reviews Request

Secretary Sidebar:

```txt
Student Affairs
    Excuse Requests
```

Table:

| Student | Event | Reason | Submitted | Status |
| ------- | ----- | ------ | --------- | ------ |

Actions:

```txt
View
Approve
Reject
Request More Information
```

---

# Step 6: Secretary opens request

Detailed View

```txt
Student Information

Student Name
Program
Year Level

Event Information

Event Name
Date

Reason Type
Medical Reason

Description
"I was hospitalized due to fever."

Supporting Documents
[ View Attachment ]

Attendance Record
No Time In
No Time Out
```

---

# Step 7: Decision

## Approve

Secretary clicks:

```txt
Approve Request
```

Optional remarks:

```txt
Remarks:
Medical certificate validated.
```

System executes:

```txt
Excuse Status = Approved

Attendance Status = Excused

Event Requirement = Completed

Absence Equivalent = 0

No Sanction Generated
```

Activity Clearance updates:

```txt
Leadership Seminar

Status: Excused
Verified By: Secretary Juan Dela Cruz
```

---

## Reject

Secretary clicks:

```txt
Reject Request
```

Remarks required:

```txt
Reason for rejection:
Submitted document is invalid.
```

System executes:

```txt
Excuse Status = Rejected

Attendance Status remains Absent

Absence Equivalent = 1
```

Sanction engine runs.

Example:

```txt
Total Absence = 1

Generate sanction:
School Supplies worth ₱50
```

---

# Step 8: Request More Information (Optional but recommended)

Secretary:

```txt
Request More Information
```

Example:

```txt
Please upload a clearer medical certificate.
```

Student receives notification.

Status:

```txt
Needs Revision
```

Student resubmits.

---

# Suggested Excuse Statuses

```txt
Draft
Pending Review
Needs Revision
Approved
Rejected
Cancelled
```

---

# Event Attendance Statuses

I recommend:

```txt
Completed
Partial
Absent
Excused
Sanction Completed
Pending Review
```

---

# Activity Clearance Computation

An event is considered **Completed** when:

```txt
(Time In + Time Out)

OR

Excuse Request Approved

OR

Sanction Completed
```

---

# UI Recommendation for Activity Clearance

| Event              | Date   | Status             | Verified By     |
| ------------------ | ------ | ------------------ | --------------- |
| General Assembly   | Aug 1  | Completed          | QR Attendance   |
| Leadership Seminar | Aug 15 | Excused            | Secretary Maria |
| Outreach Program   | Sept 5 | Sanction Completed | Secretary Maria |

---

# Recommended Database Tables

## excuse_requests

```txt
id
student_id
organization_id
event_id

reason_type
description
attachment_url

status
remarks

reviewed_by
reviewed_at

submitted_at
updated_at
```

---

## attendance_records

Add:

```txt
attendance_status

Possible values:

present
partial
absent
excused
sanction_completed
```

---

# Final Flow Diagram

```txt
Student Absent
        ↓
Submit Excuse Request
        ↓
Secretary Review
        ↓
 ┌───────────────┬───────────────┐
 │ Approve       │ Reject        │
 ↓               ↓
Event Cleared    Generate Sanction
No Sanction      Student Complies
                 ↓
          Sanction Verified
                 ↓
           Event Cleared
```

This architecture is scalable, user-friendly, and closely mirrors how real universities process excused absences.
