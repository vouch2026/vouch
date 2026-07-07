# Recommended Workspace Types

Every workspace has a type.

| Workspace Type | Example               | Managed By                      |
| -------------- | --------------------- | ------------------------------- |
| Personal       | Personal Hub          | Everyone                        |
| Campus         | DORSU Main Campus     | Super Admin / Campus Admin      |
| Faculty        | Faculty of Computing  | Dean                            |
| Program        | BSIT Program          | Program Head                    |
| Organization   | ACES                  | Governor, Secretary, Adviser    |
| Administration | System Administration | Super Admin                     |
| COMSELEC       | University COMSELEC   | COMSELEC Chairman/Commissioners |

Notice that Faculty and Program are just different workspace types.

## Example Users & Multi-Context Scenarios

### Suppose Dr. Juan Santos is:
- Dean of Faculty of Computing
- Adviser of ACES
- Adviser of Google Developer Student Club

His workspace list becomes:
- **PERSONAL HUB**
- **WORKSPACES**
  - 🏫 Faculty of Computing (Role: Dean)
  - 👥 ACES (Role: Adviser)
  - 👥 Google Developer Student Club (Role: Adviser)

He doesn't need multiple accounts.

### Program Head Example
- **PERSONAL HUB**
- **WORKSPACES**
  - 💻 BSIT Program (Role: Program Head)
  - 👥 BSIT Society (Role: Adviser)

Again, two workspaces.

### Student Example
- **PERSONAL HUB**
- **WORKSPACES**
  - 👥 ACES (Role: Governor)
  - 👥 USC (Role: Member)
  - 👥 BSIT Society (Role: Secretary)

Exactly the same architecture.

---

## Sidebar Changes Based on Workspace

### Faculty Workspace
- **WORKSPACE**: Faculty of Computing
- **Role**: Dean
  - Dashboard
  - Organizations
  - Students
  - Events
  - **Student Affairs**
    - Activity Clearances
  - Reports
  - Analytics

### Program Workspace
- **WORKSPACE**: BSIT Program
- **Role**: Program Head
  - Dashboard
  - Students
  - Organizations
  - Events
  - **Student Affairs**
    - Activity Clearances
  - Reports

### Organization Workspace
- **WORKSPACE**: ACES
- **Role**: Adviser
  - Dashboard
  - People
  - Operations
  - Student Affairs
  - Finance
  - Reports
  - Governance

The sidebar changes dynamically based on the active workspace type.

---

## Even Better Architecture

Instead of storing:
- `Role = Dean`

Store:
- **Workspace**: Faculty of Computing
- **Workspace Type**: Faculty
- **Role**: Dean

Likewise:
- **Workspace**: ACES
- **Workspace Type**: Organization
- **Role**: Adviser

### Why This Is Powerful
Suppose next year DORSU adds:
- Graduate School
- Research Centers
- Extension Office
- Alumni Association

You don't redesign the system. You simply add another workspace type (e.g., `Research Center`) with a corresponding role (e.g., `Director`). Everything still works because the application is built around contexts (workspaces) rather than fixed user types.

---

## Workspace Switcher Design

### My Workspaces (UI List)
- **PERSONAL HUB**
- **My Workspaces**
  - 🏫 DORSU Main Campus (Campus)
  - 🏫 Faculty of Computing (Dean)
  - 💻 BSIT Program (Program Head)
  - 👥 ACES (Adviser)
  - 👥 USC (Member)
  - 🗳 COMSELEC (Commissioner)
  - ⚙ System Administration (Super Admin)

This communicates that a user can belong to many different contexts at once. The selected workspace determines the available modules, permissions, and data, making the system scalable and intuitive for users with multiple responsibilities.
