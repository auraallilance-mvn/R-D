# Admin Panel Storage & Access Control Fixes Design

## Overview

The AuraAlliance admin panel currently stores all project data in localStorage, making it device-specific and preventing team collaboration. Additionally, file uploads are simulated via manual path entry, there's no dedicated save functionality separate from deployment, no role-based access control exists for sensitive settings, and no pre-configured token setup is available for team members.

This design fixes **five interconnected bugs** by:
1. **Centralizing project storage** in a GitHub-backed JSON file (`projects/_data/projects.json`)
2. **Adding real file upload functionality** that uses GitHub API to upload to `assets/projects/` and `assets/videos/`
3. **Implementing a dedicated Save button** separate from Generate/Deploy actions
4. **Restricting GitHub Settings access** to pavan (Super Admin 👑) based on user role
5. **Pre-configuring a shared team token** for team members to use

The fix preserves existing functionality for non-affected inputs (mouse interactions, existing deploys, login flows) while enabling true multi-user collaboration and proper file management.

## Glossary

- **Bug_Condition_1 (C1)**: Project storage using localStorage - data is device-specific and not shared across team
- **Bug_Condition_2 (C2)**: File upload via manual path entry instead of actual file upload buttons
- **Bug_Condition_3 (C3)**: No dedicated save functionality - only generate+deploy workflow exists
- **Bug_Condition_4 (C4)**: GitHub Settings visible to all users (admin, team, pavan) without role checking
- **Bug_Condition_5 (C5)**: No pre-configured token - all users must obtain and enter their own GitHub token
- **Property (P)**: The desired behavior when bugs are fixed - centralized storage, real uploads, save button, access control, shared token
- **Preservation**: Existing login, navigation, generate HTML, deploy workflows must remain unchanged for non-buggy interactions
- **localStorage**: Browser-based storage (device-specific) - currently used incorrectly for shared project data
- **projects/_data/projects.json**: New centralized JSON file on GitHub repository containing all project metadata
- **GitHub API**: REST API used for file operations (read, create, update, upload blobs)
- **User Roles**: pavan (Super Admin 👑), admin (Team Member), team (Team Member)
- **Access Control**: Role-based UI visibility and function-level guards
- **Blob API**: GitHub API endpoint for uploading binary files (images, videos)
- **Base64 Encoding**: Required format for file content when uploading via GitHub API

## Bug Details

### Bug Condition 1: Device-Specific localStorage Storage

Projects are stored in `localStorage` via the `saveProject()` function, making them visible only on the device where they were created. Team members cannot see each other's projects or collaborate.

**Formal Specification:**
```
FUNCTION isBugCondition1(storageOperation)
  INPUT: storageOperation of type StorageAction
  OUTPUT: boolean
  
  RETURN storageOperation.action IN ['save', 'load', 'list']
         AND storageOperation.storageBackend == 'localStorage'
         AND storageOperation.dataType == 'project_metadata'
END FUNCTION
```

**Examples:**
- Admin creates "Seven Segment Display" project → saved to their browser's localStorage
- Team member logs in on different device → cannot see admin's project
- Pavan tries to review all projects → must physically access each team member's device
- Browser cache cleared → all projects lost permanently

### Bug Condition 2: No Real File Upload Functionality

Users must manually upload files to GitHub via git/web interface, then copy-paste paths into the admin panel. No actual file upload buttons exist.

**Formal Specification:**
```
FUNCTION isBugCondition2(mediaInput)
  INPUT: mediaInput of type MediaFieldInput
  OUTPUT: boolean
  
  RETURN mediaInput.inputType == 'text_field'
         AND mediaInput.fieldName IN ['pThumbnail', 'vPath', 'gPath']
         AND mediaInput.acceptsFilePath == true
         AND mediaInput.hasUploadButton == false
END FUNCTION
```

**Examples:**
- User wants to add thumbnail → must manually upload to GitHub, get URL, paste into text field
- User adds demo video → no "Choose File" button, must upload separately and enter path
- Gallery images → same manual process for each image
- Workflow is error-prone (typos in paths, wrong directory, incorrect file format)

### Bug Condition 3: No Dedicated Save Functionality

Projects can only be saved implicitly when generating HTML or deploying. No standalone "Save Project" button exists for work-in-progress projects.

**Formal Specification:**
```
FUNCTION isBugCondition3(userAction)
  INPUT: userAction of type AdminPanelAction
  OUTPUT: boolean
  
  RETURN userAction.intent == 'save_project_draft'
         AND userAction.availableActions NOT_CONTAINS 'save_button'
         AND userAction.mustUse IN ['generate_html', 'deploy']
         AND userAction.wantsToDeploy == false
END FUNCTION
```

**Examples:**
- User fills half the form, wants to save progress → must click "Generate HTML" even though not ready
- Team member wants to save without generating page → no option available
- Draft project data → only persists if user generates or deploys
- Form data loss risk if user accidentally navigates away

### Bug Condition 4: No Role-Based Access Control

GitHub Settings section is visible and accessible to all users (admin, team, pavan). This exposes sensitive configuration and token management to non-admin users.

**Formal Specification:**
```
FUNCTION isBugCondition4(userAccess)
  INPUT: userAccess of type UserAccessAttempt
  OUTPUT: boolean
  
  RETURN userAccess.targetSection == 'github_settings'
         AND userAccess.userRole IN ['admin', 'team']
         AND userAccess.isVisible == true
         AND userAccess.isFunctional == true
         AND requiredRole == 'pavan'
END FUNCTION
```

**Examples:**
- Team member logs in → sees "GitHub Settings" in sidebar navigation
- Admin clicks "GitHub Settings" → can view and modify repo owner, branch, token
- Team member could change repository settings → affects entire team's deployments
- No warning or restriction → anyone can overwrite shared configuration

### Bug Condition 5: No Pre-configured Token

All users must obtain their own GitHub Personal Access Token. No shared team token configuration exists for non-admin users.

**Formal Specification:**
```
FUNCTION isBugCondition5(userTokenSetup)
  INPUT: userTokenSetup of type TokenConfiguration
  OUTPUT: boolean
  
  RETURN userTokenSetup.userRole IN ['admin', 'team']
         AND userTokenSetup.requiresPersonalToken == true
         AND userTokenSetup.hasSharedToken == false
         AND userTokenSetup.tokenSource == 'user_must_create'
END FUNCTION
```

**Examples:**
- New team member joins → must create GitHub account, generate PAT, enter manually
- Admin user logs in → sees "Token not set" warning, must configure own token
- Shared team token exists → not accessible or pre-configured in admin panel
- Onboarding friction → new users blocked until token setup complete

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Login authentication with existing users object (admin, pavan, team) and passwords
- Navigation between dashboard, add-project, projects, settings, manage sections
- Generate HTML functionality producing project pages and card snippets
- Deploy to GitHub workflow (create blobs, commit, push) for existing projects
- Project form UI and data collection (title, description, technologies, videos, stats)
- Dashboard statistics display (project count, token status, deploy time estimate)
- Toast notification system for user feedback
- Edit modal for updating project details
- Manage projects list showing deployed projects from GitHub

**Scope:**
All inputs and interactions that do NOT involve the five bug conditions should be completely unaffected by this fix. This includes:
- Mouse clicks on sidebar navigation buttons
- Form field text entry (title, description, overview, etc.)
- Technology tag addition/removal
- Dynamic field addition (videos, gallery, stats)
- Copy to clipboard functionality
- Theme toggle button behavior
- Logout functionality
- Modal open/close interactions

## Hypothesized Root Cause

Based on the bug descriptions and current implementation analysis, the root causes are:

1. **Incorrect Architecture Decision**: localStorage was chosen for project storage, treating the admin panel as a single-user desktop application rather than a collaborative web tool. The `saveProject()` function in line ~850 writes directly to localStorage without any GitHub sync.

2. **Missing Upload Implementation**: File input UI components were never implemented. Text fields were used as placeholders with manual path entry instructions. The `addVideoField()` and `addGalleryField()` functions create only `<input type="text">` elements, not `<input type="file">`.

3. **Incomplete Feature Set**: Save functionality was deprioritized in favor of the generate→deploy pipeline. The workflow assumes users always want to publish immediately. No intermediate save state exists between "form data" and "deployed project".

4. **No Access Control Layer**: All UI sections are rendered for all authenticated users. The sidebar navigation shows all links regardless of role. No JavaScript function checks `currentUser` role before showing "GitHub Settings". Only the "Delete Projects 👑" button has role-based visibility (pavan-only) in line ~153-158.

5. **Security Through Obscurity**: The design assumed individual users would create their own tokens. No shared token configuration was planned. The settings page instructs every user to generate a Personal Access Token, creating unnecessary complexity for team members who only need read/write access to one shared repository.

## Correctness Properties

Property 1: Bug Condition - Centralized Project Storage

_For any_ storage operation where projects are being saved, loaded, or listed (isBugCondition1 returns true), the fixed system SHALL read from and write to `projects/_data/projects.json` on the GitHub repository, ensuring all team members see the same shared project list regardless of which device or browser they use.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Bug Condition - Real File Upload Functionality

_For any_ media input field where files need to be added (isBugCondition2 returns true), the fixed system SHALL provide a file upload button that accepts file selection from the user's device, uploads the file content as a blob to GitHub API at the correct path (`assets/projects/` or `assets/videos/`), and auto-populates the path field with the GitHub URL.

**Validates: Requirements 2.4, 2.5**

Property 3: Bug Condition - Dedicated Save Button

_For any_ user action where project data needs to be saved without generating or deploying (isBugCondition3 returns true), the fixed system SHALL provide a dedicated "💾 Save Project" button that saves project metadata to `projects/_data/projects.json` via GitHub API, allowing users to save work-in-progress without triggering HTML generation or deployment.

**Validates: Requirements 2.6, 2.7**

Property 4: Bug Condition - Role-Based Access Control

_For any_ user access attempt to GitHub Settings section (isBugCondition4 returns true), the fixed system SHALL hide the "GitHub Settings" navigation link for admin and team users, show it only for pavan (Super Admin 👑), and add function-level guards to all token/settings mutation functions that verify `currentUser === 'pavan'` before executing.

**Validates: Requirements 2.8, 2.9, 2.10**

Property 5: Bug Condition - Pre-configured Team Token

_For any_ token configuration attempt by non-admin users (isBugCondition5 returns true), the fixed system SHALL automatically use a pre-configured shared team token stored in a JavaScript constant, eliminating the need for admin and team users to create their own Personal Access Tokens, while still allowing pavan to update the token via GitHub Settings.

**Validates: Requirements 2.11, 2.12**

Property 6: Preservation - Non-Storage Operations

_For any_ user interaction that does NOT involve project storage operations (isBugCondition1 returns false), the fixed system SHALL produce exactly the same behavior as the original system, preserving login flows, navigation, form interactions, HTML generation, toast notifications, and all other existing functionality.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

Property 7: Preservation - Existing Deploy Workflow

_For any_ deployment action that uses the existing `deployToGitHub()` function, the fixed system SHALL preserve the complete deployment workflow including blob creation, tree creation, commit creation, and branch ref update, ensuring that projects created with the new save functionality can still be deployed using the existing mechanism.

**Validates: Requirements 3.5, 3.6**

## Fix Implementation

### Changes Required

**File**: `admin/index.html`

**Function**: Multiple functions require modification and new functions need to be added

**Specific Changes**:

#### 1. Add Shared Team Token Configuration

**Location**: JavaScript constants section (after `const GH_DEFAULTS`)

**Implementation**:
```javascript
// Shared team token for admin and team users
const SHARED_TEAM_TOKEN = 'ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // Replace with actual token
const TEAM_TOKEN_CONFIGURED = SHARED_TEAM_TOKEN.length > 20; // Validation flag
```

**Purpose**: Pre-configure a shared token that admin/team users can use automatically without creating their own PATs.

#### 2. Modify `getGHSettings()` Function

**Location**: Line ~520 (current implementation)

**Change**: Add logic to use shared token for non-pavan users:
```javascript
function getGHSettings() {
  let token = localStorage.getItem('gh_token') || '';
  
  // Auto-use shared token for non-pavan users if configured
  if (!token && currentUser !== 'pavan' && TEAM_TOKEN_CONFIGURED) {
    token = SHARED_TEAM_TOKEN;
  }
  
  return {
    token: token,
    owner: localStorage.getItem('gh_owner') || GH_DEFAULTS.owner,
    repo: localStorage.getItem('gh_repo') || GH_DEFAULTS.repo,
    branch: localStorage.getItem('gh_branch') || GH_DEFAULTS.branch,
  };
}
```

**Purpose**: Automatically provide shared token to admin/team users while allowing pavan to use custom token.

#### 3. Add Role-Based Access Control to Navigation

**Location**: `showSection()` function (line ~505)

**Change**: Add role check before showing settings:
```javascript
function showSection(name) {
  // Role-based access control
  if (name === 'settings' && currentUser !== 'pavan') {
    showToast('⛔ GitHub Settings are restricted to Super Admin only', 'error');
    return;
  }
  
  // Existing navigation logic...
  ['dashboard','add-project','projects','settings','manage','pavan-delete'].forEach(s => {
    document.getElementById('section-' + s)?.classList.add('hidden');
    document.getElementById('nav-' + s)?.classList.remove('active');
  });
  document.getElementById('section-' + name)?.classList.remove('hidden');
  document.getElementById('nav-' + name)?.classList.add('active');
  
  // Existing section-specific logic...
}
```

**Purpose**: Prevent non-admin users from accessing GitHub Settings via function calls or URL manipulation.

#### 4. Hide GitHub Settings Navigation for Non-Pavan Users

**Location**: `doLogin()` function (line ~475)

**Change**: Add conditional hiding of settings link:
```javascript
function doLogin() {
  const u = document.getElementById('loginUser').value.trim();
  const p = document.getElementById('loginPass').value;
  if (USERS[u] && USERS[u] === p) {
    currentUser = u;
    document.getElementById('loginSection').classList.add('hidden');
    document.getElementById('adminSection').classList.remove('hidden');
    document.getElementById('sidebarUser').textContent = u.charAt(0).toUpperCase() + u.slice(1);
    document.getElementById('sidebarRole').textContent = u === 'pavan' ? 'Super Admin 👑' : 'Team Member';
    document.getElementById('dashUser').textContent = u.charAt(0).toUpperCase() + u.slice(1);
    
    // Role-based navigation visibility
    if (u === 'pavan') {
      document.getElementById('nav-pavan-delete').classList.remove('hidden');
      document.getElementById('nav-settings').classList.remove('hidden');
    } else {
      document.getElementById('nav-settings').classList.add('hidden'); // NEW
    }
    
    addVideoField(); addStatField();
    updateDashboardStats();
    checkTokenStatus();
  } else {
    document.getElementById('loginError').classList.remove('hidden');
  }
}
```

**Purpose**: Hide GitHub Settings link from sidebar for admin and team users.

#### 5. Add New Function: `loadProjectsFromGitHub()`

**Location**: After `saveProject()` function (line ~850)

**Implementation**:
```javascript
async function loadProjectsFromGitHub() {
  const { token, owner, repo, branch } = getGHSettings();
  if (!token) {
    console.warn('No token available for loading projects');
    return [];
  }
  
  const api = `https://api.github.com/repos/${owner}/${repo}`;
  const headers = { 
    Authorization: `token ${token}`, 
    Accept: 'application/vnd.github+json' 
  };
  
  try {
    const response = await fetch(
      `${api}/contents/projects/_data/projects.json?ref=${branch}`, 
      { headers }
    );
    
    if (!response.ok) {
      if (response.status === 404) {
        // File doesn't exist yet - return empty array
        console.log('projects.json not found - will create on first save');
        return [];
      }
      throw new Error(`Failed to load projects: ${response.status}`);
    }
    
    const data = await response.json();
    const content = atob(data.content.replace(/\n/g, ''));
    const projects = JSON.parse(content);
    
    // Cache SHA for updates
    localStorage.setItem('projects_json_sha', data.sha);
    
    return projects;
  } catch (err) {
    console.error('Error loading projects from GitHub:', err);
    showToast('Could not load projects from GitHub', 'error');
    return [];
  }
}
```

**Purpose**: Load shared project list from GitHub repository instead of localStorage.

#### 6. Add New Function: `saveProjectToGitHub()`

**Location**: After `loadProjectsFromGitHub()` function

**Implementation**:
```javascript
async function saveProjectToGitHub(projectData) {
  const { token, owner, repo, branch } = getGHSettings();
  if (!token) {
    showToast('GitHub token not configured', 'error');
    return false;
  }
  
  const api = `https://api.github.com/repos/${owner}/${repo}`;
  const headers = { 
    Authorization: `token ${token}`, 
    'Content-Type': 'application/json',
    Accept: 'application/vnd.github+json' 
  };
  
  try {
    // Load current projects list
    const projects = await loadProjectsFromGitHub();
    
    // Update or add project
    const idx = projects.findIndex(p => p.slug === projectData.slug);
    const entry = { ...projectData, savedAt: new Date().toISOString() };
    if (idx >= 0) {
      projects[idx] = entry;
    } else {
      projects.unshift(entry);
    }
    
    // Get current SHA if file exists
    const currentSHA = localStorage.getItem('projects_json_sha');
    
    // Create blob
    const blobRes = await fetch(`${api}/git/blobs`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ 
        content: JSON.stringify(projects, null, 2), 
        encoding: 'utf-8' 
      })
    });
    
    if (!blobRes.ok) throw new Error(`Blob creation failed: ${blobRes.status}`);
    const blobData = await blobRes.json();
    
    // Get latest commit
    const refRes = await fetch(`${api}/git/ref/heads/${branch}`, { headers });
    if (!refRes.ok) throw new Error(`Failed to get branch ref: ${refRes.status}`);
    const refData = await refRes.json();
    const latestSHA = refData.object.sha;
    
    // Get base tree
    const commitRes = await fetch(`${api}/git/commits/${latestSHA}`, { headers });
    if (!commitRes.ok) throw new Error(`Failed to get commit: ${commitRes.status}`);
    const commitData = await commitRes.json();
    const baseTreeSHA = commitData.tree.sha;
    
    // Create new tree
    const treeRes = await fetch(`${api}/git/trees`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        base_tree: baseTreeSHA,
        tree: [
          { 
            path: 'projects/_data/projects.json', 
            mode: '100644', 
            type: 'blob', 
            sha: blobData.sha 
          }
        ]
      })
    });
    
    if (!treeRes.ok) throw new Error(`Tree creation failed: ${treeRes.status}`);
    const treeData = await treeRes.json();
    
    // Create commit
    const newCommitRes = await fetch(`${api}/git/commits`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        message: `Save project: ${projectData.title}`,
        tree: treeData.sha,
        parents: [latestSHA]
      })
    });
    
    if (!newCommitRes.ok) throw new Error(`Commit failed: ${newCommitRes.status}`);
    const newCommitData = await newCommitRes.json();
    
    // Update branch ref
    const pushRes = await fetch(`${api}/git/refs/heads/${branch}`, {
      method: 'PATCH',
      headers,
      body: JSON.stringify({ sha: newCommitData.sha, force: false })
    });
    
    if (!pushRes.ok) throw new Error(`Push failed: ${pushRes.status}`);
    
    showToast(`✅ Project "${projectData.title}" saved to GitHub`, 'success');
    return true;
    
  } catch (err) {
    console.error('Error saving project to GitHub:', err);
    showToast(`Failed to save project: ${err.message}`, 'error');
    return false;
  }
}
```

**Purpose**: Save project metadata to centralized GitHub JSON file instead of localStorage.

#### 7. Add New Function: `uploadFileToGitHub()`

**Location**: After `saveProjectToGitHub()` function

**Implementation**:
```javascript
async function uploadFileToGitHub(file, targetPath) {
  const { token, owner, repo, branch } = getGHSettings();
  if (!token) {
    showToast('GitHub token not configured', 'error');
    return null;
  }
  
  const api = `https://api.github.com/repos/${owner}/${repo}`;
  const headers = { 
    Authorization: `token ${token}`, 
    'Content-Type': 'application/json',
    Accept: 'application/vnd.github+json' 
  };
  
  try {
    // Read file as base64
    const base64Content = await new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const base64 = reader.result.split(',')[1]; // Remove data:mime;base64, prefix
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
    
    // Create blob
    const blobRes = await fetch(`${api}/git/blobs`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ 
        content: base64Content, 
        encoding: 'base64' 
      })
    });
    
    if (!blobRes.ok) throw new Error(`Blob creation failed: ${blobRes.status}`);
    const blobData = await blobRes.json();
    
    // Get latest commit
    const refRes = await fetch(`${api}/git/ref/heads/${branch}`, { headers });
    if (!refRes.ok) throw new Error(`Failed to get branch ref: ${refRes.status}`);
    const refData = await refRes.json();
    const latestSHA = refData.object.sha;
    
    // Get base tree
    const commitRes = await fetch(`${api}/git/commits/${latestSHA}`, { headers });
    if (!commitRes.ok) throw new Error(`Failed to get commit: ${commitRes.status}`);
    const commitData = await commitRes.json();
    const baseTreeSHA = commitData.tree.sha;
    
    // Create new tree
    const treeRes = await fetch(`${api}/git/trees`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        base_tree: baseTreeSHA,
        tree: [
          { 
            path: targetPath, 
            mode: '100644', 
            type: 'blob', 
            sha: blobData.sha 
          }
        ]
      })
    });
    
    if (!treeRes.ok) throw new Error(`Tree creation failed: ${treeRes.status}`);
    const treeData = await treeRes.json();
    
    // Create commit
    const newCommitRes = await fetch(`${api}/git/commits`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        message: `Upload file: ${file.name}`,
        tree: treeData.sha,
        parents: [latestSHA]
      })
    });
    
    if (!newCommitRes.ok) throw new Error(`Commit failed: ${newCommitRes.status}`);
    const newCommitData = await newCommitRes.json();
    
    // Update branch ref
    const pushRes = await fetch(`${api}/git/refs/heads/${branch}`, {
      method: 'PATCH',
      headers,
      body: JSON.stringify({ sha: newCommitData.sha, force: false })
    });
    
    if (!pushRes.ok) throw new Error(`Push failed: ${pushRes.status}`);
    
    // Return GitHub URL
    const githubUrl = `/R-D/${targetPath}`;
    showToast(`✅ File "${file.name}" uploaded successfully`, 'success');
    return githubUrl;
    
  } catch (err) {
    console.error('Error uploading file to GitHub:', err);
    showToast(`Failed to upload file: ${err.message}`, 'error');
    return null;
  }
}
```

**Purpose**: Upload files directly to GitHub via API instead of manual path entry.

#### 8. Modify Dynamic Field Functions to Include Upload Buttons

**Location**: `addVideoField()`, `addGalleryField()` functions (lines ~545-575)

**Change for `addVideoField()`**:
```javascript
function addVideoField() {
  videoCount++;
  const c = document.getElementById('videosContainer');
  const div = document.createElement('div');
  div.className = 'video-entry'; div.id = 'video-' + videoCount;
  div.innerHTML = `<div class="flex gap-3 items-start">
    <div class="flex-1 space-y-2">
      <input class="field-input" type="text" placeholder="Title (e.g. Clock Demonstration)" id="vTitle${videoCount}" />
      <div class="flex gap-2">
        <input class="field-input flex-1" type="text" placeholder="Path (e.g. /R-D/assets/videos/demo.mp4)" id="vPath${videoCount}" readonly />
        <label class="btn-primary cursor-pointer text-sm px-3">
          📤 Upload
          <input type="file" accept="video/*" onchange="handleVideoUpload(this, ${videoCount})" style="display:none" />
        </label>
      </div>
      <input class="field-input" type="text" placeholder="Caption (optional)" id="vCaption${videoCount}" />
    </div>
    <button class="btn-danger mt-1" onclick="document.getElementById('video-${videoCount}').remove()">✕</button>
  </div>`;
  c.appendChild(div);
}
```

**Change for `addGalleryField()`**:
```javascript
function addGalleryField() {
  galleryCount++;
  const c = document.getElementById('galleryContainer');
  const div = document.createElement('div');
  div.className = 'img-entry'; div.id = 'gallery-' + galleryCount;
  div.innerHTML = `<div class="flex gap-3 items-center">
    <input class="field-input flex-1" type="text" placeholder="Path (e.g. /R-D/assets/images/photo.jpg)" id="gPath${galleryCount}" readonly />
    <input class="field-input flex-1" type="text" placeholder="Alt text" id="gAlt${galleryCount}" />
    <label class="btn-primary cursor-pointer text-sm px-3">
      📤 Upload
      <input type="file" accept="image/*" onchange="handleImageUpload(this, ${galleryCount})" style="display:none" />
    </label>
    <button class="btn-danger" onclick="document.getElementById('gallery-${galleryCount}').remove()">✕</button>
  </div>`;
  c.appendChild(div);
}
```

**Purpose**: Add file upload buttons to video and image fields.

#### 9. Add Upload Handler Functions

**Location**: After `uploadFileToGitHub()` function

**Implementation**:
```javascript
async function handleVideoUpload(inputElement, fieldId) {
  const file = inputElement.files[0];
  if (!file) return;
  
  if (!file.type.startsWith('video/')) {
    showToast('Please select a valid video file', 'error');
    return;
  }
  
  // Show loading state
  const pathField = document.getElementById(`vPath${fieldId}`);
  pathField.value = 'Uploading...';
  
  // Upload to GitHub
  const filename = file.name.replace(/[^a-zA-Z0-9.-]/g, '-');
  const targetPath = `assets/videos/${filename}`;
  const githubUrl = await uploadFileToGitHub(file, targetPath);
  
  if (githubUrl) {
    pathField.value = githubUrl;
  } else {
    pathField.value = '';
  }
}

async function handleImageUpload(inputElement, fieldId) {
  const file = inputElement.files[0];
  if (!file) return;
  
  if (!file.type.startsWith('image/')) {
    showToast('Please select a valid image file', 'error');
    return;
  }
  
  // Show loading state
  const pathField = document.getElementById(`gPath${fieldId}`);
  pathField.value = 'Uploading...';
  
  // Upload to GitHub
  const filename = file.name.replace(/[^a-zA-Z0-9.-]/g, '-');
  const targetPath = `assets/projects/${filename}`;
  const githubUrl = await uploadFileToGitHub(file, targetPath);
  
  if (githubUrl) {
    pathField.value = githubUrl;
  } else {
    pathField.value = '';
  }
}

async function handleThumbnailUpload(inputElement) {
  const file = inputElement.files[0];
  if (!file) return;
  
  if (!file.type.startsWith('image/')) {
    showToast('Please select a valid image file', 'error');
    return;
  }
  
  // Show loading state
  const pathField = document.getElementById('pThumbnail');
  pathField.value = 'Uploading...';
  
  // Upload to GitHub
  const filename = file.name.replace(/[^a-zA-Z0-9.-]/g, '-');
  const targetPath = `assets/projects/${filename}`;
  const githubUrl = await uploadFileToGitHub(file, targetPath);
  
  if (githubUrl) {
    pathField.value = githubUrl;
  } else {
    pathField.value = '';
  }
}
```

**Purpose**: Handle file upload interactions and auto-populate path fields.

#### 10. Add Thumbnail Upload Button to UI

**Location**: In the HTML section for thumbnail input (line ~235 in Media card)

**Change**: Replace text-only input with upload button:
```html
<div class="mb-4">
  <label class="field-label">Thumbnail Image Path *</label>
  <div class="flex gap-2">
    <input id="pThumbnail" class="field-input flex-1" type="text" placeholder="/R-D/assets/projects/your-image.jpg" readonly />
    <label class="btn-primary cursor-pointer">
      📤 Upload
      <input type="file" accept="image/*" onchange="handleThumbnailUpload(this)" style="display:none" />
    </label>
  </div>
  <p class="text-xs text-gray-400 mt-1">Click "Upload" to select an image from your device.</p>
</div>
```

**Purpose**: Add upload button for thumbnail selection.

#### 11. Add Save Button to Add Project Section

**Location**: After "Generate HTML" button in Add Project section (line ~224)

**Change**: Add dedicated save button:
```html
<div class="mb-6 flex items-center justify-between flex-wrap gap-3">
  <div>
    <h1 class="text-2xl font-bold text-gray-800">Add New Project</h1>
    <p class="text-gray-500 text-sm mt-1">Fill in details, save progress, generate HTML, then deploy.</p>
  </div>
  <div class="flex gap-2">
    <button class="btn-secondary" onclick="saveProjectDraft()">💾 Save Project</button>
    <button class="btn-primary" onclick="generateHTML()">⚡ Generate HTML</button>
  </div>
</div>
```

**Purpose**: Add standalone save button separate from generate/deploy.

#### 12. Add `saveProjectDraft()` Function

**Location**: After `collectFormData()` function (line ~640)

**Implementation**:
```javascript
async function saveProjectDraft() {
  const d = collectFormData();
  if (!d.title || !d.slug) {
    showToast('Enter at least a title and slug before saving', 'error');
    return;
  }
  
  showToast('Saving project...', 'info');
  const success = await saveProjectToGitHub(d);
  
  if (success) {
    await updateDashboardStats(); // Refresh project count
  }
}
```

**Purpose**: Save project draft without generating HTML or deploying.

#### 13. Modify `saveProject()` Function to Use GitHub

**Location**: Line ~850 (current localStorage implementation)

**Change**: Replace localStorage with GitHub API:
```javascript
function saveProject(data) {
  // Async save to GitHub - fire and forget for backward compatibility
  saveProjectToGitHub(data).then(() => {
    updateDashboardStats();
  });
}
```

**Purpose**: Transparently migrate existing save calls to use GitHub storage.

#### 14. Modify `updateDashboardStats()` Function

**Location**: Line ~855

**Change**: Load from GitHub instead of localStorage:
```javascript
async function updateDashboardStats() {
  const projects = await loadProjectsFromGitHub();
  document.getElementById('statProjects').textContent = projects.length;
}
```

**Purpose**: Display accurate project count from centralized storage.

#### 15. Modify `renderProjectsList()` Function

**Location**: Line ~860

**Change**: Load from GitHub instead of localStorage:
```javascript
async function renderProjectsList() {
  const projects = await loadProjectsFromGitHub();
  const c = document.getElementById('projectsList');
  
  if (!projects.length) {
    c.innerHTML = '<div class="card text-center text-gray-400 py-12"><p>No projects saved yet.</p><button class="btn-primary mt-4" onclick="showSection(\'add-project\')">+ Add New Project</button></div>';
    return;
  }
  
  // Rest of existing rendering logic...
  c.innerHTML = projects.map(p => `
    <div class="card">
      <div class="flex items-start justify-between mb-3">
        <div>
          <h3 class="font-bold text-gray-800">${p.title}</h3>
          <p class="text-sm text-gray-500">${p.slug}</p>
        </div>
        <span class="badge badge-blue">${p.category}</span>
      </div>
      <p class="text-gray-600 text-sm mb-3">${p.desc}</p>
      <div class="flex gap-2">
        <button class="btn-primary text-sm" onclick="redeployProject('${p.slug}')">🚀 Deploy</button>
        <button class="btn-secondary text-sm" onclick="editProject('${p.slug}')">✏️ Edit</button>
      </div>
    </div>
  `).join('');
}
```

**Purpose**: Display projects from centralized GitHub storage.

#### 16. Add Function Guards to Settings Mutations

**Location**: `saveToken()`, `clearToken()`, `saveGitHubSettings()` functions

**Change**: Add role checks:
```javascript
function saveToken() {
  if (currentUser !== 'pavan') {
    showToast('⛔ Only Super Admin can modify GitHub token', 'error');
    return;
  }
  
  const t = document.getElementById('ghToken').value.trim();
  if (!t) { showToast('Enter a token first', 'error'); return; }
  localStorage.setItem('gh_token', t);
  checkTokenStatus();
  showToast('✅ Token saved!', 'success');
}

function clearToken() {
  if (currentUser !== 'pavan') {
    showToast('⛔ Only Super Admin can modify GitHub token', 'error');
    return;
  }
  
  localStorage.removeItem('gh_token');
  document.getElementById('ghToken').value = '';
  checkTokenStatus();
  showToast('Token cleared', 'info');
}

function saveGitHubSettings() {
  if (currentUser !== 'pavan') {
    showToast('⛔ Only Super Admin can modify GitHub settings', 'error');
    return;
  }
  
  localStorage.setItem('gh_owner', document.getElementById('ghOwner').value.trim());
  localStorage.setItem('gh_repo', document.getElementById('ghRepo').value.trim());
  localStorage.setItem('gh_branch', document.getElementById('ghBranch').value.trim());
  showToast('✅ Settings saved!', 'success');
}
```

**Purpose**: Prevent non-admin users from modifying GitHub configuration even if they bypass UI restrictions.

#### 17. Update Token Status Display for Team Users

**Location**: `checkTokenStatus()` function

**Change**: Show different message for team token:
```javascript
function checkTokenStatus() {
  const { token } = getGHSettings();
  const statusEl = document.getElementById('tokenStatus');
  const dashWarn = document.getElementById('dashTokenWarn');
  const deployWarn = document.getElementById('deployTokenWarn');
  const statTokenEl = document.getElementById('statToken');
  
  if (token) {
    const tokenSource = (currentUser !== 'pavan' && token === SHARED_TEAM_TOKEN) 
      ? ' (using shared team token)' 
      : '';
    
    if (statusEl) statusEl.innerHTML = `<div class="token-ok">✅ GitHub token is set and ready${tokenSource}.</div>`;
    if (dashWarn) dashWarn.classList.add('hidden');
    if (deployWarn) deployWarn.classList.add('hidden');
    if (statTokenEl) { statTokenEl.textContent = '✅'; statTokenEl.style.color = '#16a34a'; }
  } else {
    if (statusEl) statusEl.innerHTML = '<div class="token-warning">⚠️ No token set. Contact pavan (Super Admin) to configure the shared team token.</div>';
    if (dashWarn) dashWarn.classList.remove('hidden');
    if (deployWarn) deployWarn.classList.remove('hidden');
    if (statTokenEl) { statTokenEl.textContent = '❌'; statTokenEl.style.color = '#dc2626'; }
  }
}
```

**Purpose**: Inform users about token source (personal vs shared team token).

### JSON Schema for projects/_data/projects.json

**File Path**: `projects/_data/projects.json` in repository root

**Schema**:
```json
[
  {
    "title": "string - Project title",
    "slug": "string - Filename slug (kebab-case)",
    "desc": "string - Short description for cards",
    "category": "string - IoT|Robotics|Computer Vision|etc.",
    "status": "string - Completed|In Progress|Planning",
    "thumbnail": "string - Path to thumbnail image",
    "overview": "string - Detailed project description",
    "mentor": "string - Mentor/supervisor name (optional)",
    "components": ["string - Component name"],
    "learnings": ["string - Learning outcome"],
    "results": "string - Results and impact",
    "github": "string - GitHub repo URL (optional)",
    "technologies": ["string - Technology name"],
    "videos": [
      {
        "title": "string - Video title",
        "path": "string - Video file path",
        "caption": "string - Video caption (optional)"
      }
    ],
    "gallery": [
      {
        "path": "string - Image file path",
        "alt": "string - Alt text"
      }
    ],
    "stats": [
      {
        "value": "string - Stat value (e.g. 92%)",
        "label": "string - Stat label"
      }
    ],
    "savedAt": "string - ISO 8601 timestamp",
    "deployedAt": "string - ISO 8601 timestamp (optional)",
    "liveUrl": "string - Public URL after deployment (optional)"
  }
]
```

**Example**:
```json
[
  {
    "title": "Seven Segment Display Clock",
    "slug": "seven-segment-display",
    "desc": "Real-time clock using Arduino and multiplexed seven segment displays",
    "category": "Electronics",
    "status": "Completed",
    "thumbnail": "/R-D/assets/projects/seven-segment-thumb.jpg",
    "overview": "Built a digital clock using Arduino Uno and four 7-segment displays with multiplexing to reduce pin usage...",
    "mentor": "Prof. M.V. Narayana Sir, HOD ECE",
    "components": ["Arduino Uno", "4× Seven Segment Displays", "5V Power supply"],
    "learnings": ["Seven segment display fundamentals", "Multiplexing techniques"],
    "results": "Successfully displays time with 99% accuracy",
    "github": "https://github.com/auraallilance-mvn/seven-segment-clock",
    "technologies": ["Arduino", "C++", "Electronics"],
    "videos": [
      {
        "title": "Clock Demonstration",
        "path": "/R-D/assets/videos/seven-segment-demo.mp4",
        "caption": "Real-time display of hours and minutes"
      }
    ],
    "gallery": [
      {
        "path": "/R-D/assets/images/seven-segment-circuit.jpg",
        "alt": "Circuit diagram showing connections"
      }
    ],
    "stats": [
      {
        "value": "99%",
        "label": "Time Accuracy"
      },
      {
        "value": "4",
        "label": "Displays"
      }
    ],
    "savedAt": "2024-01-15T10:30:00.000Z",
    "deployedAt": "2024-01-15T11:00:00.000Z",
    "liveUrl": "https://auraallilance-mvn.github.io/R-D/projects/seven-segment-display.html"
  }
]
```

**Purpose**: Single source of truth for all project metadata across the team.

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bugs on unfixed code, then verify the fixes work correctly and preserve existing behavior. Given that this is a multi-bug fix (5 interconnected issues), each bug will be tested independently before testing their integration.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate all five bugs BEFORE implementing the fix. Confirm the root cause analysis for each bug. If we refute any root cause, we will need to re-hypothesize.

**Test Plan**: Create test scenarios for each bug condition, run them on UNFIXED code to observe failures, then analyze the failure patterns to confirm root causes.

**Test Cases**:

1. **localStorage Device Isolation Test**: 
   - Admin user creates "Test Project A" on Device 1
   - Log in as team user on Device 2
   - Check if "Test Project A" is visible in Saved Projects section
   - **Expected failure**: Project not visible (localStorage is device-specific)
   - **Confirms**: Bug Condition 1 - projects stored locally, not shared

2. **Manual File Path Entry Test**: 
   - Navigate to Add New Project → Thumbnail & Media section
   - Look for "Choose File" or "Upload" button next to thumbnail path field
   - Look for upload buttons in video and gallery sections
   - **Expected failure**: No upload buttons exist, only text input fields
   - **Confirms**: Bug Condition 2 - no file upload functionality

3. **Save Without Generate Test**: 
   - Fill project form halfway (title, description only)
   - Look for "Save Project" or "Save Draft" button (not Generate/Deploy)
   - Try to navigate away and return to form
   - **Expected failure**: No save button exists, form data lost
   - **Confirms**: Bug Condition 3 - no standalone save functionality

4. **Access Control Test**: 
   - Log in as "admin" user (password: aura2024)
   - Check sidebar navigation for "GitHub Settings" link
   - Click GitHub Settings if visible
   - **Expected failure**: Settings visible and accessible to non-admin user
   - **Confirms**: Bug Condition 4 - no role-based access control

5. **Token Configuration Test**: 
   - Log in as "team" user (password: team2024)
   - Navigate to Dashboard
   - Check token status indicator
   - **Expected failure**: Shows "GitHub Token ❌" requiring manual token creation
   - **Confirms**: Bug Condition 5 - no pre-configured shared token

**Expected Counterexamples**:
- Projects saved on one device/browser are invisible to other users
- File paths must be manually typed with no upload assistance
- Partial project data cannot be saved without generating HTML
- Sensitive GitHub Settings accessible to all authenticated users
- Every user must create their own GitHub Personal Access Token

### Fix Checking

**Goal**: Verify that for all inputs where bug conditions hold, the fixed system produces the expected behavior.

**Bug 1 - Centralized Storage:**
```
FOR ALL storage_operation WHERE isBugCondition1(storage_operation) DO
  result := perform_storage_operation_fixed(storage_operation)
  ASSERT result.backend == 'github_api'
  ASSERT result.file_path == 'projects/_data/projects.json'
  ASSERT result.accessible_by_all_users == true
END FOR
```

**Bug 2 - File Upload:**
```
FOR ALL media_input WHERE isBugCondition2(media_input) DO
  result := render_media_input_fixed(media_input)
  ASSERT result.has_upload_button == true
  ASSERT result.upload_button_functional == true
  ASSERT result.auto_populates_path == true
END FOR
```

**Bug 3 - Save Button:**
```
FOR ALL user_action WHERE isBugCondition3(user_action) DO
  result := check_available_actions_fixed(user_action)
  ASSERT 'save_project' IN result.available_actions
  ASSERT result.save_independent_of_generate == true
  ASSERT result.save_independent_of_deploy == true
END FOR
```

**Bug 4 - Access Control:**
```
FOR ALL user_access WHERE isBugCondition4(user_access) DO
  result := check_section_access_fixed(user_access)
  ASSERT result.settings_visible == false
  ASSERT result.settings_functional == false
  ASSERT result.shows_error_message == true
END FOR
```

**Bug 5 - Shared Token:**
```
FOR ALL token_setup WHERE isBugCondition5(token_setup) DO
  result := get_token_config_fixed(token_setup)
  ASSERT result.uses_shared_token == true
  ASSERT result.requires_personal_token == false
  ASSERT result.token_valid == true
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where bug conditions do NOT hold, the fixed system produces the same result as the original system.

**Pseudocode:**
```
FOR ALL user_interaction WHERE NOT (isBugCondition1 OR isBugCondition2 OR isBugCondition3 OR isBugCondition4 OR isBugCondition5) DO
  ASSERT behavior_original(user_interaction) = behavior_fixed(user_interaction)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs
- With 5 bugs fixed simultaneously, regression risk is high without comprehensive testing

**Test Plan**: Observe behavior on UNFIXED code first for non-buggy interactions, then write property-based tests capturing that behavior.

**Test Cases**:

1. **Login Flow Preservation**: 
   - Observe that login with valid credentials works on unfixed code
   - Test all three user types (admin, pavan, team)
   - Verify dashboard loads with correct user name and role
   - **Property**: Login flow produces identical results in fixed vs unfixed code

2. **Navigation Preservation**: 
   - Observe that clicking sidebar links navigates between sections on unfixed code
   - Test all navigation paths (Dashboard → Projects → Add Project → Manage → Dashboard)
   - Verify active link highlighting updates correctly
   - **Property**: Navigation behavior identical for all non-Settings sections

3. **Form Input Preservation**: 
   - Observe that typing in text fields (title, description, overview) works on unfixed code
   - Test technology tag addition/removal
   - Verify dynamic field addition (add video, add stat, add gallery image)
   - **Property**: All form interactions produce same UI updates in fixed code

4. **Generate HTML Preservation**: 
   - Observe that clicking "⚡ Generate HTML" creates project page on unfixed code
   - Verify output section displays with code preview
   - Check that card snippet is generated correctly
   - **Property**: HTML generation logic produces identical output

5. **Deploy Workflow Preservation**: 
   - Observe that clicking "🚀 Deploy to Live Site" executes GitHub API calls on unfixed code
   - Verify blob creation, tree creation, commit creation sequence
   - Check deploy log messages match expected pattern
   - **Property**: Deploy workflow steps execute in same order with same API calls

6. **Toast Notifications Preservation**: 
   - Observe toast messages appear for various actions on unfixed code
   - Test success toasts (save, deploy), error toasts (validation failures), info toasts
   - Verify toast auto-dismiss timing
   - **Property**: Toast system behavior unchanged

7. **Edit Modal Preservation**: 
   - Observe that clicking edit button opens modal on unfixed code
   - Verify modal pre-populates with existing project data
   - Test modal close button and cancel button
   - **Property**: Modal interaction flow identical

8. **Logout Preservation**: 
   - Observe that logout button returns to login screen on unfixed code
   - Verify session state is cleared
   - Check that attempting to access admin sections redirects to login
   - **Property**: Logout flow produces same result

### Unit Tests

**Storage Tests**:
- Test `loadProjectsFromGitHub()` with empty repository (404 response)
- Test `loadProjectsFromGitHub()` with existing projects.json file
- Test `saveProjectToGitHub()` creating new file (first project)
- Test `saveProjectToGitHub()` updating existing file (adding second project)
- Test `saveProjectToGitHub()` with invalid token (401 response)

**Upload Tests**:
- Test `uploadFileToGitHub()` with valid image file
- Test `uploadFileToGitHub()` with valid video file
- Test `uploadFileToGitHub()` with invalid file type
- Test `handleVideoUpload()` sets path field correctly after upload
- Test `handleImageUpload()` shows error for non-image files

**Access Control Tests**:
- Test `showSection('settings')` called by admin user → blocked
- Test `showSection('settings')` called by pavan user → allowed
- Test `saveToken()` called by team user → blocked with error message
- Test `getGHSettings()` returns shared token for admin user
- Test `getGHSettings()` returns personal token for pavan user

**Save Button Tests**:
- Test `saveProjectDraft()` with empty form → error toast
- Test `saveProjectDraft()` with title and slug only → saves successfully
- Test `saveProjectDraft()` with complete form → saves all fields
- Test save button visible in Add Project section UI

**Token Configuration Tests**:
- Test `SHARED_TEAM_TOKEN` constant is defined and non-empty
- Test `getGHSettings()` uses shared token when no personal token set
- Test `checkTokenStatus()` shows "(using shared team token)" for admin/team users
- Test pavan can still set personal token in localStorage

### Property-Based Tests

**Property 1: Storage Idempotency**
- Generate random project data
- Save project to GitHub twice with same data
- Verify second save doesn't create duplicate entries
- Verify project count increases by 1, not 2

**Property 2: Upload Path Correctness**
- Generate random valid filenames
- Upload files to GitHub
- Verify returned path matches pattern `/R-D/assets/{type}/{sanitized-filename}`
- Verify path field contains correct URL

**Property 3: Access Control Invariant**
- Generate random sequences of user logins (admin, team, pavan)
- For each login, attempt to access GitHub Settings
- Verify only pavan user can access settings across all sequences

**Property 4: Save vs Deploy Independence**
- Generate random project data
- Save project without generating HTML
- Verify project exists in GitHub storage
- Verify no HTML file created in projects/ directory
- Verify no index.html modification occurred

**Property 5: Shared Token Distribution**
- Generate random user login sequences (admin, team)
- For each non-pavan login, retrieve token via `getGHSettings()`
- Verify all non-pavan users receive identical `SHARED_TEAM_TOKEN` value
- Verify pavan user can use custom token if set

### Integration Tests

**End-to-End New Project Flow**:
1. Admin user logs in
2. Navigates to Add New Project
3. Fills in project title and slug
4. Clicks "Upload" for thumbnail, selects image file
5. Waits for upload to complete
6. Clicks "💾 Save Project" button
7. Navigates to Saved Projects section
8. Verifies project appears in list
9. Team user logs in on different browser/device
10. Navigates to Saved Projects section
11. Verifies admin's project is visible

**End-to-End Access Control Flow**:
1. Team user logs in
2. Checks sidebar - GitHub Settings link hidden
3. Manually calls `showSection('settings')` via browser console
4. Verifies error toast appears and settings don't load
5. Attempts to call `saveToken()` via console
6. Verifies error toast blocks the action
7. Pavan user logs in
8. Checks sidebar - GitHub Settings link visible
9. Navigates to GitHub Settings
10. Successfully modifies and saves token

**End-to-End File Upload Flow**:
1. Admin user creates new project
2. Clicks "📤 Upload" button next to thumbnail field
3. Selects image file from local device (test.jpg)
4. Observes "Uploading..." status in path field
5. Waits for GitHub API upload to complete
6. Verifies path field shows `/R-D/assets/projects/test.jpg`
7. Adds video using upload button
8. Verifies video path auto-populated correctly
9. Generates HTML
10. Verifies project page uses correct uploaded file paths

**End-to-End Multi-User Collaboration**:
1. Pavan configures shared team token in SHARED_TEAM_TOKEN constant
2. Admin user logs in - sees token status "✅" (using shared team token)
3. Admin creates "Project A" and saves
4. Team user logs in - sees token status "✅" (using shared team token)
5. Team user sees "Project A" in Saved Projects list
6. Team user creates "Project B" and deploys
7. Admin refreshes Saved Projects - sees both projects
8. Verify projects/_data/projects.json contains both projects
9. Verify both HTML files exist in repository

**Backward Compatibility Integration**:
1. Simulate existing project in localStorage (from old system)
2. Fixed code loads - attempts to migrate localStorage projects to GitHub
3. Verify migration creates projects/_data/projects.json
4. Verify localStorage projects appear in new GitHub-backed list
5. New saves go to GitHub, not localStorage
6. Verify old `deployToGitHub()` function still works with new storage
