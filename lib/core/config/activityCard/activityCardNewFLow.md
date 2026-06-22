Your Activity Clearance module is now becoming one of the core features of VOUCH. Since there are now **three ways to satisfy a mandatory event requirement**, the workflow should be clear and transparent to both students and officers.

Here's the recommended enterprise-grade flow.

# Activity Clearance Overall Flow

```txt id="4q9x1w"
Student joins Organization
            ↓
Organization creates:
- Mandatory Events
- Mandatory Fees
            ↓
Student participates throughout the semester
            ↓
System evaluates compliance
            ↓
Secretary Review
            ↓
Treasurer Review
            ↓
Governor/President Review
            ↓
Optional Adviser Review
            ↓
CLEARED
```

---

# Phase 1 — Mandatory Event Compliance

Every mandatory event must be satisfied.

An event can be considered **Complied** in three ways.

---

## Path A — Direct Attendance

### Description

The student physically attended the event.

### Flow

```txt id="g8m2ra"
Student attends event
        ↓
Time In recorded
        ↓
Time Out recorded
        ↓
System automatically marks:

Status = Completed
Verified By = Attendance System
```

Example:

| Event            | Date  | Status    | Verified By   |
| ---------------- | ----- | --------- | ------------- |
| General Assembly | Aug 1 | Completed | QR Attendance |

---

## Path B — Excused Absence

### Description

The student was absent but has a valid excuse approved by the Secretary.

### Flow

```txt id="j3p7un"
Student absent
        ↓
Submit Excuse Request
        ↓
Upload supporting document
        ↓
Secretary reviews request
        ↓
Approve
        ↓
Event Status = Excused
        ↓
Requirement considered complied
```

Example:

| Event              | Date   | Status  | Verified By     |
| ------------------ | ------ | ------- | --------------- |
| Leadership Seminar | Aug 15 | Excused | Secretary Maria |

---

## Path C — Sanction Compliance

### Description

The student was absent and the excuse request was rejected or not submitted.

The student must complete an assigned sanction.

### Flow

```txt id="t9k5zd"
Student absent
        ↓
No approved excuse
        ↓
Absence count computed
        ↓
System determines sanction
        ↓
Student completes sanction
        ↓
Secretary verifies sanction
        ↓
Event Status = Sanction Cleared
```

Example:

| Event              | Date   | Status           | Verified By     |
| ------------------ | ------ | ---------------- | --------------- |
| Community Outreach | Sept 5 | Sanction Cleared | Secretary Maria |

---

# Event Compliance Formula

A mandatory event is considered satisfied if:

```txt id="w2q8fe"
Completed
OR
Excused
OR
Sanction Cleared
```

---

# Phase 2 — Secretary Review

## Description

The Secretary verifies whether all mandatory events have been complied with.

The Secretary checks:

```txt id="r7m1cs"
Attendance Records
Excuse Requests
Sanctions
```

### Flow

```txt id="6d4vjy"
All mandatory events complied?
        ↓
YES
        ↓
Secretary signs clearance

NO
        ↓
Secretary cannot sign
```

---

# Phase 3 — Treasurer Review

## Description

The Treasurer verifies all mandatory fees.

Mandatory fees may include:

```txt id="u5k8mx"
Membership Fee
Organization Fee
Event Contribution
Shirt Fee
```

### Flow

```txt id="4b2nza"
All mandatory fees paid?
        ↓
YES
        ↓
Treasurer signs

NO
        ↓
Treasurer cannot sign
```

---

# Phase 4 — Governor/President Review

## Description

The Governor performs final organizational validation.

Checks:

```txt id="h6y9tr"
Secretary Signed
Treasurer Signed
Lower Hierarchy Clearance Completed
```

Example:

```txt id="s1w4cf"
BSIT Society
↓
ACES
↓
USC
```

USC cannot be cleared until:

```txt id="7e3xkn"
BSIT Society = Cleared
ACES = Cleared
```

### Flow

```txt id="c8p5lo"
Secretary Signed?
        ↓

Treasurer Signed?
        ↓

Lower-level clearance completed?
        ↓

YES
        ↓
Governor signs
```

---

# Phase 5 — Adviser Review (Optional)

## Description

Some organizations may require adviser approval.

This should be configurable.

Organization Setting:

```txt id="z4m7qh"
Require Adviser Signature

ON/OFF
```

### Flow

```txt id="k9n2db"
Adviser signature required?
        ↓

NO
        ↓
CLEARED

YES
        ↓
Adviser reviews
        ↓
Signs
        ↓
CLEARED
```

---

# Final Clearance Formula

```txt id="n5r8pu"
For every Mandatory Event:

Completed
OR
Excused
OR
Sanction Cleared

AND

All Mandatory Fees Paid

AND

Secretary Signed

AND

Treasurer Signed

AND

Lower Hierarchy Clearance Completed

AND

Governor Signed

AND

(Optional) Adviser Signed

=

ACTIVITY CLEARANCE STATUS = CLEARED
```

---

# Suggested Statuses

## Event Status

```txt id="m2v6xt"
Completed
Excused
Sanction Cleared
Absent
Pending Review
```

---

## Clearance Status

```txt id="q7f3yn"
Draft
In Progress
Secretary Review
Treasurer Review
Governor Review
Adviser Review
Cleared
Rejected
```

---

# Complete Student Journey

```txt id="x4c8kr"
Semester Starts
       ↓
Student attends events
       ↓
Student pays fees
       ↓
System evaluates attendance

┌──────────────────────────────┐
│ Event Completed             │
│ OR                          │
│ Excuse Approved             │
│ OR                          │
│ Sanction Completed          │
└──────────────────────────────┘

       ↓

Secretary signs
       ↓

Treasurer signs
       ↓

Lower-level organizations cleared
       ↓

Governor signs
       ↓

Optional Adviser signs
       ↓

🎉 ACTIVITY CLEARANCE CLEARED
```

This flow is scalable, easy for students to understand, and closely resembles real-world university clearance processes.
