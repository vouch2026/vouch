# Sidebar Mapping (Permission-Based)

This document outlines the visibility requirements for the Organization Workspace Sidebar items based on the new permission-driven system.

## Common
- **Dashboard**: Available to all authenticated workspace members.
- **Calendar**: Available to all authenticated workspace members.
- **Notifications**: Available to all authenticated workspace members.

## Workspace Core (WORKSPACE: CODE)
- **Workspace Home**: Standard for all members.
- **Members**: Requires `view_members` OR `assign_roles`.
- **Events**: Standard for all members (Requires `view_events`).
- **Finance**: Requires `view_fees`, `create_fee`, OR `manage_collections`.
- **Announcements**: Standard for all members (Requires `view_announcements`).
- **Activity Cards**: Available to all members (Requires `view_activity_cards` for personal view OR `manage_activity_cards` for officer management).
- **Sanctions**: Requires `view_sanctions` for personal view OR `create_sanction_rules` / `receive_sanction_items` for officer management.

---

## Role-to-Permission Mapping (Reference)

### Governor / President
- **Permissions**: Full workspace management.
- **Visible Items**: Dashboard, Members, Officers, Events, Activity Cards (Manage), Announcements, Sanctions (Manage), Fees, Collections, Reports, Organization Settings.

### Treasurer
- **Permissions**: `view_fees`, `create_fee`, `manage_collections`, `manage_activity_cards`, `view_analytics`.
- **Visible Items**: Dashboard, Finance (Fees, Collections, Financial Reports), Activity Cards (Manage), Insights (Collection Analytics), Finance Settings.

### Secretary
- **Permissions**: `view_members`, `view_events`, `scan_event_attendance`, `view_announcements`, `manage_activity_cards`, `create_sanction_rules`, `receive_sanction_items`, `view_documents`.
- **Visible Items**: Dashboard, Members, Events, Attendance, Activity Cards (Manage), Announcements, Sanctions (Manage), Records (Documents, Meeting Minutes), Insights (Participation Reports), Secretary Settings.

### Member / Student
- **Permissions**: `view_events`, `view_announcements`, `view_fees`, `view_activity_cards`, `view_sanctions`.
- **Visible Items**: Dashboard, Events, Activity Cards (Personal), Announcements, Sanctions (Personal), My Records (Attendance, Fees).

---

## Technical Implementation
Visibility is controlled in `lib/shared/widgets/sidebar/dynamic_sidebar.dart` using:
```dart
if (activeRole?.hasPermission(AppPermissions.somePermission) ?? false) { ... }
```
Or:
```dart
if (activeRole?.hasAnyPermission([AppPermissions.p1, AppPermissions.p2]) ?? false) { ... }
```
