# Bugfix Requirements Document

## Introduction

The AuraAlliance Admin Panel (`admin/index.html`) currently has five critical defects that prevent proper multi-user collaboration and centralized project management. The panel was designed to enable team members (admin, team, pavan) to collaboratively manage portfolio projects, but currently stores all data in browser localStorage, making projects device-specific rather than shared. Additionally, media upload functionality is incomplete (text-only fields instead of actual file uploads), there's no dedicated save button for work-in-progress projects, and GitHub configuration settings are exposed to all users instead of being restricted to the super admin (pavan).

These bugs prevent the admin panel from fulfilling its core purpose: **centralized, collaborative project management with proper access controls**.

---

## Bug Analysis

### Current Behavior (Defect)

#### 1. Projects Not Shared Across Users/Devices

1.1 WHEN user "team" saves a project on laptop A THEN the system stores the project in laptop A's browser localStorage only

1.2 WHEN user "team" logs in on laptop B with the same credentials THEN the system shows zero projects (because localStorage is device-specific)

1.3 WHEN user "admin" saves a project THEN user "pavan" cannot see it (even though they should share the same centralized project list)

1.4 WHEN any user clicks "Saved Projects" THEN the system displays only projects saved in that specific browser's localStorage

#### 2. Media Upload Fields Are Text-Only

1.5 WHEN user enters thumbnail path in "Thumbnail Image Path" field THEN the system accepts only text input like `/R-D/assets/projects/image.jpg`

1.6 WHEN user wants to upload a new image or video THEN the system provides no file upload button or mechanism

1.7 WHEN user needs to add media THEN they must manually upload files to GitHub first via external tools, then return to paste the path

1.8 WHEN user clicks "Add Video" or "Add Image" THEN the system shows another text-only path input field instead of a file uploader

#### 3. No Save Button for Work-in-Progress Projects

1.9 WHEN user fills the "Add New Project" form completely THEN the system provides only "Generate HTML" and "Deploy to Live Site" buttons

1.10 WHEN user wants to save a draft project for later completion THEN the system provides no save/draft functionality

1.11 WHEN user clicks "Generate HTML" THEN the system only generates preview HTML without saving project metadata to any persistent storage

1.12 WHEN user partially completes a project form and navigates away THEN all entered data is lost

#### 4. GitHub Settings Visible to All Users

1.13 WHEN user "admin" (Team Member) logs in THEN the system displays the "GitHub Settings" menu item in the sidebar

1.14 WHEN user "team" (Team Member) logs in THEN the system shows GitHub repository owner, name, branch, and personal access token fields

1.15 WHEN any logged-in user navigates to "GitHub Settings" THEN they can view and modify the GitHub Personal Access Token field

1.16 WHEN user "admin" or "team" accesses GitHub Settings THEN they can change repository configuration that should be restricted to pavan only

#### 5. GitHub Token Not Pre-configured

1.17 WHEN user "team" logs in for the first time THEN the system shows "GitHub Token not set" warning and empty token field

1.18 WHEN the shared "team" account is used across multiple devices THEN each device requires manual token entry (token not synchronized)

1.19 WHEN user expects to deploy immediately THEN they must first navigate to GitHub Settings and paste the token manually

1.20 WHEN the token expires or is rotated THEN every user must update it individually on their respective devices

---

### Expected Behavior (Correct)

#### 1. Projects Shared via GitHub Backend

2.1 WHEN user "team" saves a project on laptop A THEN the system SHALL store project metadata in `projects/_data/projects.json` on GitHub

2.2 WHEN user "team" logs in on laptop B with the same credentials THEN the system SHALL fetch and display all projects from GitHub's `projects/_data/projects.json`

2.3 WHEN user "admin" saves a project THEN the system SHALL commit it to GitHub so all users (admin, team, pavan) see the same project list

2.4 WHEN any user clicks "Saved Projects" THEN the system SHALL load projects from the centralized GitHub repository, not localStorage

#### 2. Real File Upload Functionality

2.5 WHEN user sees "Thumbnail Image Path" field THEN the system SHALL provide a file upload button that uploads directly to GitHub's `assets/projects/` folder

2.6 WHEN user clicks the file upload button and selects an image THEN the system SHALL upload the file to GitHub and auto-populate the path field

2.7 WHEN user needs to add media THEN the system SHALL handle the entire upload workflow (file selection → GitHub upload → path insertion) automatically

2.8 WHEN user clicks "Add Video" or "Add Image" THEN the system SHALL display a file upload button with accompanying path field (auto-filled after upload)

#### 3. Dedicated Save Project Button

2.9 WHEN user fills the "Add New Project" form THEN the system SHALL provide three action buttons: "Save Project", "Generate HTML", and "Deploy to Live Site"

2.10 WHEN user clicks "Save Project" THEN the system SHALL store project metadata to GitHub's `projects/_data/projects.json` without generating HTML or deploying

2.11 WHEN user clicks "Generate HTML" THEN the system SHALL generate preview HTML and auto-save project metadata simultaneously

2.12 WHEN user navigates to "Saved Projects" THEN they SHALL see all saved drafts and can resume editing any project

#### 4. GitHub Settings Restricted to Pavan Only

2.13 WHEN user "admin" (Team Member) logs in THEN the system SHALL hide the "GitHub Settings" menu item from the sidebar

2.14 WHEN user "team" (Team Member) logs in THEN the system SHALL not display GitHub repository configuration or token fields

2.15 WHEN user "pavan" (Super Admin 👑) logs in THEN the system SHALL display the "GitHub Settings" menu item and allow full access to all configuration fields

2.16 WHEN user "admin" or "team" attempts to access `/admin/index.html#settings` directly THEN the system SHALL redirect them to the dashboard or show an access denied message

#### 5. Pre-configured GitHub Token for Team Accounts

2.17 WHEN user "team" logs in for the first time THEN the system SHALL load a pre-configured GitHub token (stored securely for shared accounts)

2.18 WHEN the shared "team" account is used across multiple devices THEN the system SHALL use the centralized token from GitHub or secure configuration

2.19 WHEN user "team" or "admin" needs to deploy THEN the system SHALL automatically use the pre-configured token without requiring manual entry

2.20 WHEN token rotation is needed THEN only user "pavan" SHALL have the ability to update the token, and it SHALL apply to all team users immediately

---

### Unchanged Behavior (Regression Prevention)

#### General Project Workflow

3.1 WHEN user fills out project form fields (title, description, category, etc.) THEN the system SHALL CONTINUE TO validate and accept the same input formats

3.2 WHEN user clicks "Generate HTML" THEN the system SHALL CONTINUE TO generate project page HTML with the same structure and styling

3.3 WHEN user clicks "Deploy to Live Site" THEN the system SHALL CONTINUE TO push changes to GitHub and trigger deployment

3.4 WHEN user is logged out THEN the system SHALL CONTINUE TO show the login screen and deny access to admin features

#### User Authentication

3.5 WHEN user enters username "pavan" and password "pavan123" THEN the system SHALL CONTINUE TO authenticate as Super Admin 👑

3.6 WHEN user enters username "admin" and password "aura2024" THEN the system SHALL CONTINUE TO authenticate as Team Member

3.7 WHEN user enters username "team" and password "team2024" THEN the system SHALL CONTINUE TO authenticate as Team Member

3.8 WHEN user enters incorrect credentials THEN the system SHALL CONTINUE TO show "Invalid username or password" error

#### UI/UX Elements

3.9 WHEN user navigates between sections (Dashboard, Add New Project, Saved Projects, etc.) THEN the system SHALL CONTINUE TO show/hide sections and update active sidebar state

3.10 WHEN user adds technology tags THEN the system SHALL CONTINUE TO display them as removable chips

3.11 WHEN user adds video/image fields THEN the system SHALL CONTINUE TO allow dynamic addition and removal of multiple media entries

3.12 WHEN user logs out THEN the system SHALL CONTINUE TO return to the login screen and clear the current session

#### Pavan-Only Features

3.13 WHEN user "pavan" logs in THEN the system SHALL CONTINUE TO show the "Delete Projects 👑" menu item

3.14 WHEN user "admin" or "team" logs in THEN the system SHALL CONTINUE TO hide the "Delete Projects 👑" menu item

3.15 WHEN user "pavan" accesses the delete section THEN they SHALL CONTINUE TO have the ability to permanently delete projects from GitHub

3.16 WHEN non-pavan users attempt to delete projects THEN the system SHALL CONTINUE TO prevent the action (no change to existing permission model for deletion)

#### GitHub API Integration

3.17 WHEN deploy operation commits to GitHub THEN the system SHALL CONTINUE TO use the same GitHub API endpoints and authentication method

3.18 WHEN GitHub token is valid THEN the system SHALL CONTINUE TO show green "✅" status indicator on dashboard

3.19 WHEN GitHub token is missing or invalid THEN the system SHALL CONTINUE TO show "❌" status and display warning messages

3.20 WHEN deployment completes successfully THEN the system SHALL CONTINUE TO show success toast notification and deployment log output
