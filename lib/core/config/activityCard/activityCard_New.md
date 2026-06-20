**Completely locking the faculty-based Activity Clearance until the program-based clearance is finished will frustrate students.**

Imagine this scenario:

```txt id="mqq7w0"
Faculty Organization: ACES

Mandatory Events:
- Acquaintance Party
- General Assembly
- Outreach Program

Mandatory Fees:
- Membership Fee
- Shirt Fee
```

If the student cannot even see these requirements because their program-based clearance is incomplete, they may:

* Miss mandatory events
* Forget to pay fees
* Be unaware of sanctions
* Be surprised near the end of the semester

This creates a poor user experience.

# Recommended Approach

## Use Visibility + Restriction

Students should be able to:

```txt id="6g0m7e"
✓ View requirements
✓ Attend events
✓ Pay fees
✓ Submit excuse requests
✓ Comply with sanctions
✓ Track progress
```

But they cannot:

```txt id="i6k2zx"
✗ Request clearance
✗ Receive Governor signature
✗ Receive Adviser signature
✗ Become CLEARED
```

until the lower-level organization is cleared.

---

# Suggested Workflow

Suppose the hierarchy is:

```txt id="85ocit"
Campus-Based
    ↓
Faculty-Based
    ↓
Program-Based
```

Example:

```txt id="n0z6pw"
USC
↓
ACES
↓
BSIT Society
```

The student opens ACES Activity Clearance.

They can see:

```txt id="pntf7x"
Mandatory Events
Mandatory Fees
Attendance Status
Sanctions
Payment Status
Progress Tracker
```

At the top of the page:

```txt id="h92oc4"
⚠ Clearance Request Locked

You must first complete and clear your BSIT Society Activity Clearance before requesting clearance for ACES.
```

---

# UI Example

```txt id="swnvok"
ACES Activity Clearance

Status: LOCKED

Reason:
Program-Based Clearance (BSIT Society) is incomplete.

Requirements Progress

Events
✓ 4/5 Completed

Fees
✓ 2/2 Paid

Sanctions
✓ None

Secretary Approval
Pending

Treasurer Approval
Pending

Governor Approval
Locked

Adviser Approval
Locked
```

---

# Automatic Pre-Compliance

This is important.

The system should still allow:

## Secretary

to verify:

```txt id="rqtl4h"
Attendance
Excuse Requests
Sanctions
```

and sign.

---

## Treasurer

to verify:

```txt id="lrpt8x"
Payments
```

and sign.

---

But:

## Governor

cannot sign until:

```txt id="1epwyo"
Program-Based Clearance = CLEARED
```

---

# Recommended Approval Rule

## Secretary Approval

Requirements:

```txt id="5hiv18"
Events completed
OR

Excused
OR

Sanctions completed
```

---

## Treasurer Approval

Requirements:

```txt id="uzr4fu"
All mandatory fees paid
```

---

## Governor Approval

Requirements:

```txt id="zv6twy"
Secretary Signed
AND
Treasurer Signed
AND
Lower-Level Clearance Cleared
```

Only then:

```txt id="jqurjc"
Governor Sign button becomes enabled.
```

---

# Final Formula

```txt id="k5gaf5"
Student can PREPARE higher-level clearances anytime.

Student cannot COMPLETE higher-level clearances until lower-level clearances are cleared.
```

This is exactly how many universities handle prerequisites:

```txt id="iwjyqf"
You can view future subjects.

You cannot enroll until prerequisites are passed.
```

# Recommendation

Use three states:

```txt id="3x6ulr"
Open
Locked
Cleared
```

## Open

Student can comply with requirements.

---

## Locked

Final approval is unavailable due to hierarchy dependency.

---

## Cleared

All approvals completed.

---

# My Recommendation for VOUCH

Allow students to fully manage and prepare all Activity Clearances regardless of hierarchy.

Only restrict:

```txt id="kt9qoc"
Governor Approval
Adviser Approval
Final Clearance Status
```

through hierarchy validation.

This gives students maximum visibility while preserving organizational hierarchy and will greatly reduce confusion and complaints.
