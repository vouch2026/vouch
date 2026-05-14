# VOUCH
## University Governance & Organization Management Ecosystem

---

# PROJECT OVERVIEW

VOUCH is a modern enterprise-grade university governance ecosystem designed to centralize and digitize organization operations, student governance workflows, event attendance, elections, finance monitoring, announcements, and activity card processing.

The platform is designed for:
- Universities
- Colleges
- Student Governments
- Academic Organizations
- COMSELEC Operations
- Campus Governance

VOUCH supports:
- Web Platform
- Mobile Platform
- Multi-Organization Architecture
- Role-Based Access Control (RBAC)
- Real-Time Governance Workflows

---

# PROJECT OBJECTIVES

The project aims to:

- Digitize organization governance workflows
- Centralize attendance and activity tracking
- Streamline student organization management
- Automate approval processes
- Improve transparency and accountability
- Provide real-time organization operations
- Create a scalable governance ecosystem

---

# TARGET USERS

## Administrative Roles
- Super Admin
- COMSELEC Chairman
- COMSELEC Commissioner

---

## Organization Roles
- Society Adviser
- Governor / President
- Secretary
- Treasurer
- PIO
- Staff

---

## General Users
- Students

---

# CORE FEATURES

## Governance System
- Organization management
- Officer management
- Membership management
- Approval workflows
- Audit logs

---

## Election Management
- Candidate filing
- Election setup
- Voting management
- Election analytics
- Result publishing

---

## Attendance System
- QR attendance
- Attendance analytics
- Attendance monitoring
- Event participation tracking

---

## Activity Card System
- Digital activity card
- Signature approvals
- Participation tracking
- Clearance preparation

---

## Finance System
- Fee management
- Payment verification
- Financial reports
- Payment tracking

---

## Communication System
- Announcements
- Notifications
- Organization feed
- Media gallery

---

# TECH STACK

# FRONTEND

## Flutter
Used for:
- Web Application
- Android Application
- iOS Application

---

# BACKEND

## Supabase
Used for:
- PostgreSQL Database
- Authentication
- Realtime Features
- Storage
- Row-Level Security (RLS)

---

# STATE MANAGEMENT

## Riverpod
Used for:
- scalable state management
- dependency injection
- reactive architecture

---

# ROUTING

## GoRouter
Used for:
- declarative routing
- protected routes
- nested navigation

---

# LOCAL STORAGE

## Hive / SharedPreferences
Used for:
- session caching
- offline persistence
- local settings

---

# FORM VALIDATION

## Formz / Validator Architecture
Used for:
- scalable form validation
- reusable validation logic

---

# UI SYSTEM

## Material 3
Customized with:
- enterprise design system
- VOUCH branding
- responsive layouts

---

# DESIGN SYSTEM

# COLOR PALETTE

## Primary Colors
- Royal Blue (#1D4ED8)
- Deep Royal Blue (#1E3A8A)

---

## Accent Colors
- Gold (#F59E0B)
- Soft Gold (#FCD34D)

---

## Neutral Colors
- White (#FFFFFF)
- Slate Background (#F8FAFC)
- Dark Text (#0F172A)

---

# TYPOGRAPHY

## Font Family
- Poppins

---

# DESIGN STYLE

The UI should feel:
- premium
- enterprise-grade
- minimal
- modern
- scalable
- governance-oriented

Inspired by:
- Stripe
- Linear
- Notion
- Clerk
- Vercel

---

# SYSTEM ARCHITECTURE

The platform follows:

# ORGANIZATION-CENTRIC ARCHITECTURE

Every operational module is scoped by:
- organization
- role
- permissions

---

# AUTHENTICATION SYSTEM

Authentication uses:
- Supabase Auth
- JWT Sessions
- Secure Route Guards

---

# ACCOUNT STATUS FLOW

Accounts support:
- Pending
- Approved
- Rejected
- Suspended
- Archived

---

# ROLE-BASED ACCESS CONTROL

The platform uses:
- Roles
- Permissions
- Organization Memberships

A user may:
- belong to multiple organizations
- have different roles per organization

Example:
- Treasurer in CSS Society
- Staff in COMSELEC

---
# RESPONSIVE UI/UX REQUIREMENTS

VOUCH must implement a fully responsive and adaptive user interface across:
- Desktop
- Laptop
- Tablet
- Mobile Devices

The platform should provide a seamless enterprise-grade user experience regardless of screen size or device type.

---

# SUPPORTED SCREEN TYPES

## Desktop / Windows Layout
Target:
- large monitors
- laptops
- ultrawide displays

Features:
- expanded sidebar navigation
- dashboard analytics layout
- multi-column content
- advanced data tables
- enterprise workspace experience

Minimum Width:
- 1024px+

---

## Tablet Layout
Target:
- iPads
- Android tablets
- medium-sized screens

Features:
- collapsible sidebar
- adaptive grid layouts
- responsive cards
- touch-friendly interactions

Target Width:
- 768px – 1023px

---

## Mobile Layout
Target:
- Android phones
- iPhones
- small mobile screens

Features:
- mobile drawer navigation
- bottom sheets
- stacked layouts
- responsive forms
- optimized touch targets
- mobile attendance scanning

Target Width:
- below 768px

---

# RESPONSIVE DESIGN PRINCIPLES

The UI must:
- adapt fluidly to screen sizes
- maintain consistent spacing
- preserve usability across devices
- avoid horizontal overflow
- maintain readable typography
- optimize touch interactions

---

# ENTERPRISE UX REQUIREMENTS

The interface should feel:
- modern
- clean
- premium
- scalable
- institution-ready

Inspired by:
- Stripe
- Notion
- Linear
- Vercel
- Microsoft Fluent UI

---

# RESPONSIVE NAVIGATION SYSTEM

## Desktop
Use:
- persistent sidebar
- expanded navigation groups
- analytics-focused layout

---

## Tablet
Use:
- collapsible sidebar
- adaptive navigation drawer

---

## Mobile
Use:
- drawer navigation
- bottom navigation (optional)
- floating actions
- simplified dashboard layouts

---

# RESPONSIVE COMPONENT REQUIREMENTS

All components must support:
- adaptive sizing
- dynamic spacing
- responsive typography
- breakpoint-based layouts

Components include:
- tables
- forms
- cards
- analytics charts
- dashboards
- dialogs
- modals

---

# RESPONSIVE TABLE STRATEGY

Desktop:
- full data tables

Tablet:
- compact tables

Mobile:
- card-based data representation

IMPORTANT:
Avoid horizontal scrolling whenever possible.

---

# RESPONSIVE DASHBOARD STRATEGY

Desktop:
- multi-column analytics
- sidebar-expanded layout

Tablet:
- reduced analytics grid

Mobile:
- stacked dashboard cards
- simplified widgets

---

# FLUTTER RESPONSIVE IMPLEMENTATION

The project should use:
- LayoutBuilder
- MediaQuery
- ResponsiveBuilder
- Adaptive Layouts
- Breakpoint-based UI rendering

---

# BREAKPOINT SYSTEM

Recommended breakpoints:

```txt
Mobile: 0 – 767px
Tablet: 768px – 1023px
Desktop: 1024px+

---

# APPLICATION MODULES

# 1. Authentication Module
Features:
- Login
- Register
- Forgot Password
- Session Persistence
- Protected Routes

---

# 2. Dashboard Module
Features:
- KPI analytics
- Organization overview
- Pending approvals
- Activity summaries

---

# 3. Organization Module
Features:
- Organization profiles
- Member management
- Officer management
- Organization analytics

---

# 4. Event Module
Features:
- Event creation
- Event management
- Attendance tracking
- Event staff assignment

---

# 5. Attendance Module
Features:
- QR attendance
- Attendance logs
- Participation analytics

---

# 6. Election Module
Features:
- Election setup
- Candidate management
- Voting process
- Election analytics

---

# 7. Finance Module
Features:
- Fee management
- Payment verification
- Collection monitoring
- Financial reports

---

# 8. Announcement Module
Features:
- Announcement posting
- Organization feed
- Notification broadcasting

---

# 9. Activity Card Module
Features:
- Digital activity cards
- Signature tracking
- Compliance monitoring

---

# 10. Sanction Module
Features:
- Sanction rules
- Absence monitoring
- Violation tracking

---

# DEVELOPMENT PHASES

# PHASE 1
UI Foundation & Design System

Includes:
- layouts
- reusable widgets
- responsive UI
- navigation architecture

---

# PHASE 2
Authentication & Backend Foundation [IN PROGRESS]

Includes:
- Supabase integration [DONE]
- auth flows (Login, Register) [DONE]
- RBAC foundation (Roles, Profiles, Triggers) [DONE]
- protected routing [IN PROGRESS]

---

# PHASE 3
Core Governance Modules

Includes:
- organizations
- events
- attendance
- announcements
- approvals

---

# PHASE 4
Advanced Governance Features

Includes:
- elections
- finance
- sanctions
- analytics

---

# PHASE 5
Optimization & Production Readiness

Includes:
- performance optimization
- testing
- deployment
- security hardening

---

# PROJECT STRUCTURE

```txt
lib/
├── main.dart
│
├── config/
│   ├── app_config.dart
│   ├── env.dart
│   ├── supabase_config.dart
│   ├── navigation_config.dart
│   ├── app_constants.dart
│   └── app_assets.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── role_constants.dart
│   │   ├── permission_constants.dart
│   │   ├── storage_constants.dart
│   │   └── validation_constants.dart
│   │
│   ├── enums/
│   │   ├── user_status_enum.dart
│   │   ├── attendance_status_enum.dart
│   │   ├── approval_status_enum.dart
│   │   ├── payment_status_enum.dart
│   │   └── sanction_status_enum.dart
│   │
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── auth_exception.dart
│   │   ├── database_exception.dart
│   │   ├── network_exception.dart
│   │   └── failure.dart
│   │
│   ├── guards/
│   │   ├── auth_guard.dart
│   │   ├── role_guard.dart
│   │   ├── permission_guard.dart
│   │   └── organization_guard.dart
│   │
│   ├── network/
│   │   ├── network_service.dart
│   │   ├── connectivity_service.dart
│   │   └── api_client.dart
│   │
│   ├── permissions/
│   │   ├── app_permissions.dart
│   │   ├── role_permissions.dart
│   │   └── permission_manager.dart
│   │
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── secure_storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── file_upload_service.dart
│   │   └── qr_service.dart
│   │
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   └── app_shadows.dart
│   │
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── currency_formatter.dart
│   │   ├── validators.dart
│   │   ├── snackbar_helper.dart
│   │   ├── dialog_helper.dart
│   │   ├── logger.dart
│   │   └── extensions.dart
│   │
│   └── widgets/
│       ├── loaders/
│       │   ├── app_loader.dart
│       │   ├── page_loader.dart
│       │   └── skeleton_loader.dart
│       │
│       ├── dialogs/
│       │   ├── confirmation_dialog.dart
│       │   ├── success_dialog.dart
│       │   └── error_dialog.dart
│       │
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   └── icon_button_widget.dart
│       │
│       └── states/
│           ├── empty_state.dart
│           ├── error_state.dart
│           └── no_data_state.dart
│
├── shared/
│   ├── layouts/
│   │   ├── dashboard_layout.dart
│   │   ├── auth_layout.dart
│   │   └── public_layout.dart
│   │
│   ├── widgets/
│   │   ├── sidebar/
│   │   │   ├── app_sidebar.dart
│   │   │   ├── sidebar_item.dart
│   │   │   ├── sidebar_group.dart
│   │   │   └── sidebar_footer.dart
│   │   │
│   │   ├── navbar/
│   │   │   ├── app_navbar.dart
│   │   │   ├── profile_dropdown.dart
│   │   │   ├── notification_dropdown.dart
│   │   │   └── organization_switcher.dart
│   │   │
│   │   ├── cards/
│   │   │   ├── stat_card.dart
│   │   │   ├── analytics_card.dart
│   │   │   ├── info_card.dart
│   │   │   └── action_card.dart
│   │   │
│   │   ├── tables/
│   │   │   ├── app_table.dart
│   │   │   ├── table_search.dart
│   │   │   ├── table_pagination.dart
│   │   │   └── table_filters.dart
│   │   │
│   │   ├── forms/
│   │   │   ├── app_text_field.dart
│   │   │   ├── password_field.dart
│   │   │   ├── dropdown_field.dart
│   │   │   └── search_field.dart
│   │   │
│   │   └── badges/
│   │       ├── role_badge.dart
│   │       ├── status_badge.dart
│   │       └── notification_badge.dart
│   │
│   ├── models/
│   │   ├── api_response_model.dart
│   │   ├── pagination_model.dart
│   │   └── dropdown_option_model.dart
│   │
│   ├── enums/
│   │   └── app_theme_enum.dart
│   │
│   └── extensions/
│       ├── context_extension.dart
│       ├── string_extension.dart
│       └── date_extension.dart
│
├── routes/
│   ├── app_router.dart
│   ├── route_names.dart
│   ├── route_paths.dart
│   ├── route_redirects.dart
│   └── route_guards.dart
│
├── services/
│   ├── supabase/
│   │   ├── supabase_client.dart
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   ├── realtime_service.dart
│   │   └── storage_service.dart
│   │
│   └── local/
│       ├── hive_service.dart
│       └── preferences_service.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   │
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── login_model.dart
│   │   │   └── register_model.dart
│   │   │
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   │
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   │
│   │   ├── services/
│   │   │   └── auth_api_service.dart
│   │   │
│   │   ├── views/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   ├── forgot_password_page.dart
│   │   │   ├── reset_password_page.dart
│   │   │   ├── pending_approval_page.dart
│   │   │   └── suspended_page.dart
│   │   │
│   │   └── widgets/
│   │       ├── login_form.dart
│   │       ├── register_form.dart
│   │       └── auth_header.dart
│   │
│   ├── dashboard/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   │   └── dashboard_page.dart
│   │   └── widgets/
│   │       ├── dashboard_stats.dart
│   │       ├── recent_activities.dart
│   │       ├── analytics_chart.dart
│   │       └── approval_overview.dart
│   │
│   ├── organizations/
│   │   ├── controllers/
│   │   │   └── organization_controller.dart
│   │   │
│   │   ├── models/
│   │   │   ├── organization_model.dart
│   │   │   ├── organization_member_model.dart
│   │   │   └── organization_role_model.dart
│   │   │
│   │   ├── providers/
│   │   │   └── organization_provider.dart
│   │   │
│   │   ├── repositories/
│   │   │   └── organization_repository.dart
│   │   │
│   │   ├── services/
│   │   │   └── organization_service.dart
│   │   │
│   │   ├── views/
│   │   │   ├── organizations_page.dart
│   │   │   ├── organization_details_page.dart
│   │   │   ├── organization_members_page.dart
│   │   │   └── organization_settings_page.dart
│   │   │
│   │   └── widgets/
│   │       ├── organization_card.dart
│   │       ├── member_table.dart
│   │       └── organization_banner.dart
│   │
│   ├── events/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── attendance/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── elections/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── finance/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── announcements/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── sanctions/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── notifications/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── profile/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   │
│   └── settings/
│       ├── controllers/
│       ├── models/
│       ├── providers/
│       ├── repositories/
│       ├── services/
│       ├── views/
│       └── widgets/
│
└── assets/
    ├── images/
    ├── icons/
    ├── logos/
    ├── fonts/
    ├── animations/
    └── mock/