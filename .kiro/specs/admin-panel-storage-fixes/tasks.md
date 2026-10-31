# Implementation Plan: Admin Panel Storage & Access Control Fixes

## Overview
This task list implements fixes for **six interconnected bugs** in the AuraAlliance admin panel:
1. Device-specific localStorage storage (needs centralized GitHub storage)
2. Manual file path entry (needs real upload functionality)
3. No standalone save button (only generate+deploy workflow)
4. GitHub Settings visible to all users (needs role-based access control)
5. No pre-configured shared token (all users must create own PATs)
6. **Session lost on page refresh (needs session persistence)**

## Task List

---

### Bug 1: Centralized Project Storage

- [ ] 1.1 Write bug condition exploration test for localStorage storage
  - **Property 1: Bug Condition** - Device-Specific localStorage Storage
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate projects are device-specific
  - **Scoped PBT Approach**: Test concrete scenarios - Admin creates project on Device 1, Team member checks Device 2
  - Test that project saved via `saveProject()` on one browser/device is NOT visible when loading projects list on a different browser/device
  - The test assertions should match the Expected Behavior: projects ARE visible across devices after fix
  - Run test on UNFIXED code (simulating two browser sessions or clearing localStorage)
  - **EXPECTED OUTCOME**: Test FAILS (project not visible on second device - this is correct, proves bug exists)
  - Document counterexample: "Admin creates 'Test Project A' → Team member on different device sees 0 projects"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.1, 2.2, 2.3_

- [ ] 1.2 Write preservation property tests for non-storage operations (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Storage Operations Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-storage operations (login, navigation, form input, HTML generation)
  - Write property-based tests capturing observed behavior patterns:
    - Login with valid credentials → Dashboard loads with correct user name
    - Navigation clicks → Sections change with active link highlighting
    - Form text input → Fields update correctly
    - Technology tag add/remove → UI updates dynamically
    - Generate HTML button → Output section displays with code preview
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 1.3 Implement centralized GitHub storage

  - [ ] 1.3.1 Add `loadProjectsFromGitHub()` function
    - Fetch `projects/_data/projects.json` from GitHub repository using GitHub API
    - Parse base64-encoded content to JSON
    - Cache SHA for file updates
    - Return empty array if file doesn't exist (404)
    - Handle errors gracefully with user feedback
    - _Bug_Condition: isBugCondition1(storageOperation) where storageOperation.action == 'load' AND storageOperation.storageBackend == 'localStorage'_
    - _Expected_Behavior: storageOperation.storageBackend == 'github_api' AND file_path == 'projects/_data/projects.json'_
    - _Preservation: Non-storage operations (login, navigation, form input) remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4_

  - [ ] 1.3.2 Add `saveProjectToGitHub()` function
    - Load current projects list from GitHub
    - Update or add project entry with timestamp
    - Create blob with JSON content
    - Get latest commit and base tree
    - Create new tree with updated projects.json
    - Create commit and update branch ref
    - Show success/error toast notifications
    - _Bug_Condition: isBugCondition1(storageOperation) where storageOperation.action == 'save' AND storageOperation.storageBackend == 'localStorage'_
    - _Expected_Behavior: storageOperation.storageBackend == 'github_api' AND accessible_by_all_users == true_
    - _Preservation: Existing deploy workflow and HTML generation preserved_
    - _Requirements: 2.1, 2.2, 2.3, 3.5, 3.6_

  - [ ] 1.3.3 Modify `saveProject()` to use GitHub API
    - Replace `localStorage.setItem()` with call to `saveProjectToGitHub()`
    - Maintain async fire-and-forget pattern for backward compatibility
    - Update dashboard stats after save completes
    - _Bug_Condition: Direct localStorage writes in existing save function_
    - _Expected_Behavior: Transparent migration to GitHub storage_
    - _Preservation: Existing callers of saveProject() work unchanged_
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 1.3.4 Modify `updateDashboardStats()` to load from GitHub
    - Replace `localStorage.getItem('projects')` with `await loadProjectsFromGitHub()`
    - Update project count display
    - _Bug_Condition: Dashboard reads from localStorage_
    - _Expected_Behavior: Dashboard shows accurate count from centralized storage_
    - _Preservation: Dashboard UI layout and other stats unchanged_
    - _Requirements: 2.2, 3.1_

  - [ ] 1.3.5 Modify `renderProjectsList()` to load from GitHub
    - Replace `localStorage.getItem('projects')` with `await loadProjectsFromGitHub()`
    - Preserve existing rendering logic and card layout
    - _Bug_Condition: Projects list reads from localStorage_
    - _Expected_Behavior: Projects list shows all team projects from GitHub_
    - _Preservation: Existing card UI, edit/deploy buttons unchanged_
    - _Requirements: 2.2, 3.1_

  - [ ] 1.3.6 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Centralized GitHub Storage
    - **IMPORTANT**: Re-run the SAME test from task 1.1 - do NOT write a new test
    - The test from task 1.1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1.1 (cross-device visibility)
    - **EXPECTED OUTCOME**: Test PASSES (project now visible on all devices - confirms bug is fixed)
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 1.3.7 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Storage Operations Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 1.2 - do NOT write new tests
    - Run preservation property tests from step 1.2 (login, navigation, form, generation)
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions in non-storage functionality)
    - Confirm all tests still pass after fix (no regressions)

---

### Bug 2: Real File Upload Functionality

- [ ] 2.1 Write bug condition exploration test for manual file paths
  - **Property 1: Bug Condition** - Manual File Path Entry
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate no file upload buttons exist
  - **Scoped PBT Approach**: Test concrete UI elements - thumbnail field, video fields, gallery fields
  - Test that media input fields (thumbnail, video path, gallery path) have `inputType == 'text_field'` and `hasUploadButton == false`
  - Inspect DOM elements: `document.getElementById('pThumbnail')`, video path inputs, gallery path inputs
  - The test assertions should match Expected Behavior: upload buttons ARE present after fix
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (no upload buttons found - this is correct, proves bug exists)
  - Document counterexample: "Thumbnail field has type='text', no sibling <input type='file'> found"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.4, 2.5_

- [ ] 2.2 Write preservation property tests for non-upload inputs (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Media Input Fields Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-media form fields:
    - Title input accepts text correctly
    - Description textarea updates on typing
    - Technology tags can be added and removed
    - Stats fields can be dynamically added
    - Form validation works for required fields
  - Write property-based tests capturing these behaviors
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (confirms baseline non-media field behavior)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3_

- [ ] 2.3 Implement real file upload functionality

  - [ ] 2.3.1 Add `uploadFileToGitHub()` function
    - Read file as base64 using FileReader API
    - Create blob with base64 content via GitHub API
    - Get latest commit and create tree with new file
    - Commit and push to GitHub repository
    - Return GitHub URL path (`/R-D/assets/projects/{filename}` or `/R-D/assets/videos/{filename}`)
    - Show upload progress and completion toasts
    - _Bug_Condition: isBugCondition2(mediaInput) where inputType == 'text_field' AND hasUploadButton == false_
    - _Expected_Behavior: Provides file upload API that returns GitHub URL_
    - _Preservation: Existing text input still works for manual path entry_
    - _Requirements: 2.4, 2.5, 3.2_

  - [ ] 2.3.2 Add `handleThumbnailUpload()` function
    - Validate file is image type
    - Show "Uploading..." in path field
    - Call `uploadFileToGitHub()` with sanitized filename
    - Populate path field with returned GitHub URL
    - Show error if upload fails
    - _Bug_Condition: No upload handler for thumbnail field_
    - _Expected_Behavior: Auto-populates path field after successful upload_
    - _Preservation: Text field still accepts manual path entry_
    - _Requirements: 2.4, 2.5_

  - [ ] 2.3.3 Add `handleVideoUpload()` function
    - Validate file is video type
    - Show "Uploading..." status
    - Upload to `assets/videos/` directory
    - Populate corresponding video path field
    - _Bug_Condition: No upload handler for video fields_
    - _Expected_Behavior: Auto-populates vPath{N} field_
    - _Requirements: 2.4, 2.5_

  - [ ] 2.3.4 Add `handleImageUpload()` function
    - Validate file is image type
    - Upload to `assets/projects/` directory
    - Populate corresponding gallery path field
    - _Bug_Condition: No upload handler for gallery fields_
    - _Expected_Behavior: Auto-populates gPath{N} field_
    - _Requirements: 2.4, 2.5_

  - [ ] 2.3.5 Update HTML thumbnail field with upload button
    - Add `<label>` wrapper with hidden `<input type="file" accept="image/*">`
    - Add "📤 Upload" button text
    - Set thumbnail path field to `readonly`
    - Add onchange handler calling `handleThumbnailUpload()`
    - _Bug_Condition: Thumbnail field has no upload button_
    - _Expected_Behavior: Upload button visible and functional_
    - _Preservation: Existing field layout and styling preserved_
    - _Requirements: 2.4, 2.5, 3.2_

  - [ ] 2.3.6 Modify `addVideoField()` to include upload button
    - Add file input with "📤 Upload" button to each video field
    - Set path field to `readonly`
    - Wire up `handleVideoUpload()` handler with field ID
    - _Bug_Condition: addVideoField() creates text-only input_
    - _Expected_Behavior: Each video field has upload capability_
    - _Preservation: Dynamic field addition logic unchanged_
    - _Requirements: 2.4, 2.5, 3.2_

  - [ ] 2.3.7 Modify `addGalleryField()` to include upload button
    - Add file input with "📤 Upload" button to each gallery field
    - Set path field to `readonly`
    - Wire up `handleImageUpload()` handler with field ID
    - _Bug_Condition: addGalleryField() creates text-only input_
    - _Expected_Behavior: Each gallery field has upload capability_
    - _Requirements: 2.4, 2.5, 3.2_

  - [ ] 2.3.8 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - File Upload Buttons Present
    - **IMPORTANT**: Re-run the SAME test from task 2.1 - do NOT write a new test
    - Run bug condition exploration test from step 2.1 (upload button existence check)
    - **EXPECTED OUTCOME**: Test PASSES (upload buttons found for thumbnail, video, gallery - confirms fix)
    - _Requirements: 2.4, 2.5_

  - [ ] 2.3.9 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Media Input Fields Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2.2 - do NOT write new tests
    - Run preservation tests from step 2.2 (title, description, tags, stats, validation)
    - **EXPECTED OUTCOME**: Tests PASS (confirms non-media fields unchanged)

---

### Bug 3: Dedicated Save Button

- [ ] 3.1 Write bug condition exploration test for save button absence
  - **Property 1: Bug Condition** - No Standalone Save Functionality
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate no save button exists
  - **Scoped PBT Approach**: Test concrete scenario - user wants to save draft without generating HTML
  - Test that Add Project section has NO button with text matching "Save" that doesn't also trigger "Generate" or "Deploy"
  - Check available actions in UI: only "⚡ Generate HTML" exists, no "💾 Save" button
  - The test assertions should match Expected Behavior: save button IS present after fix
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (no save button found - this is correct, proves bug exists)
  - Document counterexample: "Form has generate button, no standalone save button found"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.6, 2.7_

- [ ] 3.2 Write preservation property tests for generate/deploy workflows (BEFORE implementing fix)
  - **Property 2: Preservation** - Generate and Deploy Workflows Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for existing workflows:
    - "⚡ Generate HTML" produces project page and card snippet
    - Output section displays with code preview
    - Copy to clipboard functionality works
    - "🚀 Deploy to Live Site" executes GitHub API sequence
    - Deploy log shows blob/tree/commit creation steps
    - Toast notifications appear for success/error states
  - Write property-based tests capturing these workflows
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (confirms baseline generate/deploy behavior)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.4, 3.5, 3.6_

- [ ] 3.3 Implement dedicated save button

  - [ ] 3.3.1 Add `saveProjectDraft()` function
    - Call `collectFormData()` to gather current form state
    - Validate minimum required fields (title and slug)
    - Call `saveProjectToGitHub()` with collected data
    - Show "Saving project..." info toast
    - Update dashboard stats on success
    - Do NOT generate HTML or trigger deployment
    - _Bug_Condition: isBugCondition3(userAction) where intent == 'save_project_draft' AND availableActions NOT_CONTAINS 'save_button'_
    - _Expected_Behavior: Saves to GitHub without generating or deploying_
    - _Preservation: Existing generate and deploy functions unchanged_
    - _Requirements: 2.6, 2.7, 3.1, 3.5, 3.6_

  - [ ] 3.3.2 Update Add Project section HTML with save button
    - Add "💾 Save Project" button before "⚡ Generate HTML" button
    - Style as secondary button (distinct from primary generate button)
    - Wire up `onclick="saveProjectDraft()"`
    - Update section description text to mention "save progress"
    - _Bug_Condition: UI has no save button_
    - _Expected_Behavior: Save button visible and accessible_
    - _Preservation: Generate button position and styling unchanged_
    - _Requirements: 2.6, 2.7, 3.1_

  - [ ] 3.3.3 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Standalone Save Button Available
    - **IMPORTANT**: Re-run the SAME test from task 3.1 - do NOT write a new test
    - Run bug condition exploration test from step 3.1 (save button existence check)
    - **EXPECTED OUTCOME**: Test PASSES (save button found, independent of generate/deploy - confirms fix)
    - _Requirements: 2.6, 2.7_

  - [ ] 3.3.4 Verify preservation tests still pass
    - **Property 2: Preservation** - Generate and Deploy Workflows Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 3.2 - do NOT write new tests
    - Run preservation tests from step 3.2 (generate HTML, output display, deploy workflow, toasts)
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions in existing workflows)

---

### Bug 4: Role-Based Access Control

- [ ] 4.1 Write bug condition exploration test for unrestricted settings access
  - **Property 1: Bug Condition** - No Role-Based Access Control
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate settings are visible to non-admin users
  - **Scoped PBT Approach**: Test concrete scenario - admin or team user tries to access GitHub Settings
  - Test that when `currentUser == 'admin'` or `currentUser == 'team'`:
    - GitHub Settings navigation link IS visible in sidebar (isVisible == true)
    - Clicking settings link successfully navigates to settings section (isFunctional == true)
    - Settings modification functions (saveToken, clearToken) execute without role check
  - The test assertions should match Expected Behavior: settings hidden for non-pavan users after fix
  - Run test on UNFIXED code (log in as admin, check settings visibility)
  - **EXPECTED OUTCOME**: Test FAILS (settings visible to admin - this is correct, proves bug exists)
  - Document counterexample: "Admin user sees 'GitHub Settings' in navigation and can access it"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.8, 2.9, 2.10_

- [ ] 4.2 Write preservation property tests for pavan settings access (BEFORE implementing fix)
  - **Property 2: Preservation** - Pavan Settings Access Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code when `currentUser == 'pavan'`:
    - GitHub Settings link is visible in sidebar
    - Clicking settings navigates successfully
    - Token can be saved and cleared
    - Repository settings can be modified
    - All settings functions work without errors
  - Write property-based tests capturing pavan's full settings access
  - Run tests on UNFIXED code with pavan login
  - **EXPECTED OUTCOME**: Tests PASS (confirms pavan's baseline settings access)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.4_

- [ ] 4.3 Implement role-based access control

  - [ ] 4.3.1 Hide GitHub Settings navigation for non-pavan users in `doLogin()`
    - Add conditional check: `if (u !== 'pavan') document.getElementById('nav-settings').classList.add('hidden')`
    - Show settings link only when `u === 'pavan'`
    - Keep "Delete Projects 👑" button logic for pavan
    - _Bug_Condition: isBugCondition4(userAccess) where userRole IN ['admin', 'team'] AND settings_visible == true_
    - _Expected_Behavior: Settings link hidden for admin and team users_
    - _Preservation: Other navigation links (dashboard, projects, add-project) unchanged_
    - _Requirements: 2.8, 2.9, 3.1, 3.2_

  - [ ] 4.3.2 Add role check to `showSection()` function
    - Check if `name === 'settings' && currentUser !== 'pavan'`
    - Show error toast: "⛔ GitHub Settings are restricted to Super Admin only"
    - Return early without showing section
    - _Bug_Condition: No function-level guard on section navigation_
    - _Expected_Behavior: Settings section blocked even if accessed via URL/console_
    - _Preservation: Other section navigation unchanged_
    - _Requirements: 2.9, 2.10, 3.2_

  - [ ] 4.3.3 Add role guard to `saveToken()` function
    - Check `if (currentUser !== 'pavan')` at function start
    - Show error toast and return early
    - Only execute token save if user is pavan
    - _Bug_Condition: No role check in token mutation function_
    - _Expected_Behavior: Only pavan can save token_
    - _Preservation: Token save logic for pavan unchanged_
    - _Requirements: 2.10, 3.2_

  - [ ] 4.3.4 Add role guard to `clearToken()` function
    - Check `if (currentUser !== 'pavan')` at function start
    - Show error toast and return early
    - _Bug_Condition: No role check in token deletion_
    - _Expected_Behavior: Only pavan can clear token_
    - _Requirements: 2.10, 3.2_

  - [ ] 4.3.5 Add role guard to `saveGitHubSettings()` function
    - Check `if (currentUser !== 'pavan')` at function start
    - Show error toast and return early
    - _Bug_Condition: No role check in repository settings mutation_
    - _Expected_Behavior: Only pavan can modify repo settings_
    - _Requirements: 2.10, 3.2_

  - [ ] 4.3.6 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Settings Restricted to Pavan
    - **IMPORTANT**: Re-run the SAME test from task 4.1 - do NOT write a new test
    - Run bug condition exploration test from step 4.1 (admin/team settings access check)
    - **EXPECTED OUTCOME**: Test PASSES (settings hidden and blocked for admin/team - confirms fix)
    - _Requirements: 2.8, 2.9, 2.10_

  - [ ] 4.3.7 Verify preservation tests still pass
    - **Property 2: Preservation** - Pavan Settings Access Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 4.2 - do NOT write new tests
    - Run preservation tests from step 4.2 (pavan login, settings visibility, token/settings modification)
    - **EXPECTED OUTCOME**: Tests PASS (confirms pavan's settings access unchanged)

---

### Bug 5: Pre-configured Shared Token

- [ ] 5.1 Write bug condition exploration test for missing shared token
  - **Property 1: Bug Condition** - No Pre-configured Team Token
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate no shared token exists
  - **Scoped PBT Approach**: Test concrete scenario - admin or team user checks token status
  - Test that when `currentUser IN ['admin', 'team']`:
    - `getGHSettings().token` returns empty string or null (requiresPersonalToken == true)
    - Token status shows "GitHub Token ❌" (no token configured)
    - Dashboard displays token warning (hasSharedToken == false)
  - The test assertions should match Expected Behavior: shared token available after fix
  - Run test on UNFIXED code (log in as admin, check token status)
  - **EXPECTED OUTCOME**: Test FAILS (no token for admin user - this is correct, proves bug exists)
  - Document counterexample: "Admin user sees 'GitHub Token ❌', no shared token configured"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.11, 2.12_

- [ ] 5.2 Write preservation property tests for pavan custom token (BEFORE implementing fix)
  - **Property 2: Preservation** - Pavan Custom Token Usage Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code when `currentUser == 'pavan'`:
    - Pavan can set custom token via GitHub Settings
    - Custom token is stored in localStorage
    - `getGHSettings()` returns pavan's custom token
    - Deploy operations use pavan's custom token
  - Write property-based tests capturing pavan's token management
  - Run tests on UNFIXED code with pavan login
  - **EXPECTED OUTCOME**: Tests PASS (confirms pavan's custom token workflow)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.4_

- [ ] 5.3 Implement pre-configured shared token

  - [ ] 5.3.1 Add `SHARED_TEAM_TOKEN` constant
    - Define constant after `GH_DEFAULTS`: `const SHARED_TEAM_TOKEN = 'ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'`
    - Add validation flag: `const TEAM_TOKEN_CONFIGURED = SHARED_TEAM_TOKEN.length > 20`
    - **IMPORTANT**: Replace placeholder with actual GitHub Personal Access Token
    - Token should have repo scope for read/write access
    - _Bug_Condition: isBugCondition5(userTokenSetup) where hasSharedToken == false_
    - _Expected_Behavior: Shared token constant defined and accessible_
    - _Preservation: Existing GH_DEFAULTS unchanged_
    - _Requirements: 2.11, 2.12, 3.1_

  - [ ] 5.3.2 Modify `getGHSettings()` to use shared token for non-pavan users
    - After retrieving localStorage token, check if empty and user is not pavan
    - If `!token && currentUser !== 'pavan' && TEAM_TOKEN_CONFIGURED`, set `token = SHARED_TEAM_TOKEN`
    - Return settings object with shared token for admin/team users
    - _Bug_Condition: No automatic token provisioning for non-admin users_
    - _Expected_Behavior: Admin and team users get shared token automatically_
    - _Preservation: Pavan can still use custom token from localStorage_
    - _Requirements: 2.11, 2.12, 3.2_

  - [ ] 5.3.3 Update `checkTokenStatus()` to show shared token indicator
    - After token check, determine token source
    - If `currentUser !== 'pavan' && token === SHARED_TEAM_TOKEN`, set suffix ` (using shared team token)`
    - Append suffix to token status messages
    - Update "no token" message for non-pavan users: "Contact pavan (Super Admin) to configure shared team token"
    - _Bug_Condition: Token status doesn't indicate source (personal vs shared)_
    - _Expected_Behavior: Users see clear indication they're using shared token_
    - _Preservation: Status display logic structure unchanged_
    - _Requirements: 2.12, 3.1_

  - [ ] 5.3.4 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Shared Token Available for Team Users
    - **IMPORTANT**: Re-run the SAME test from task 5.1 - do NOT write a new test
    - Run bug condition exploration test from step 5.1 (admin/team token status check)
    - **EXPECTED OUTCOME**: Test PASSES (admin/team users have token - confirms fix)
    - _Requirements: 2.11, 2.12_

  - [ ] 5.3.5 Verify preservation tests still pass
    - **Property 2: Preservation** - Pavan Custom Token Usage Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 5.2 - do NOT write new tests
    - Run preservation tests from step 5.2 (pavan custom token setting, localStorage, deployment)
    - **EXPECTED OUTCOME**: Tests PASS (confirms pavan's token workflow unchanged)

---

### Bug 6: Session Persistence on Page Refresh

- [ ] 6.1 Write bug condition exploration test for session loss on refresh
  - **Property 1: Bug Condition** - Session Lost on Page Refresh
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate session is not persisted
  - **Scoped PBT Approach**: Test concrete scenario - user logs in, refreshes page (F5)
  - Test that when user logs in as 'admin' and then refreshes the page (location.reload() or F5):
    - `currentUser` is reset to null (session lost)
    - User is shown login screen again (not admin panel)
    - Must re-enter credentials to access admin panel
  - The test assertions should match Expected Behavior: session persists across refreshes after fix
  - Run test on UNFIXED code (log in, refresh page, check if still logged in)
  - **EXPECTED OUTCOME**: Test FAILS (user logged out after refresh - this is correct, proves bug exists)
  - Document counterexample: "Admin logs in → refreshes page (F5) → sees login screen (logged out)"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: Session persistence requirement_

- [ ] 6.2 Write preservation property tests for login/logout behavior (BEFORE implementing fix)
  - **Property 2: Preservation** - Login and Logout Flows Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for authentication:
    - Login with valid credentials shows admin panel
    - Login with invalid credentials shows error message
    - Logout button returns to login screen and clears currentUser
    - Each user role (admin, team, pavan) displays correct name and role badge
  - Write property-based tests capturing authentication behavior
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (confirms baseline login/logout behavior)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: Preserve existing authentication_

- [ ] 6.3 Implement session persistence

  - [ ] 6.3.1 Store currentUser in localStorage on successful login
    - In `doLogin()` function, after setting `currentUser = u`
    - Add `localStorage.setItem('currentUser', u)` to persist session
    - Store only username (password should NOT be stored)
    - _Bug_Condition: Session not persisted (currentUser only in memory)_
    - _Expected_Behavior: currentUser stored in localStorage on login_
    - _Preservation: Login flow logic and UI updates unchanged_
    - _Requirements: Session persistence requirement_

  - [ ] 6.3.2 Clear currentUser from localStorage on logout
    - In `doLogout()` function, add `localStorage.removeItem('currentUser')`
    - Ensure session is fully cleared when user explicitly logs out
    - _Bug_Condition: Logout doesn't clear persisted session_
    - _Expected_Behavior: Logout removes stored session_
    - _Preservation: Logout UI transition unchanged_
    - _Requirements: Session persistence requirement_

  - [ ] 6.3.3 Add session restoration on page load
    - Add initialization code before `doLogout()` definition or at script start
    - Check if `localStorage.getItem('currentUser')` exists
    - If exists and is valid user (exists in USERS object), restore session:
      - Set `currentUser = localStorage.getItem('currentUser')`
      - Hide login section: `document.getElementById('loginSection').classList.add('hidden')`
      - Show admin section: `document.getElementById('adminSection').classList.remove('hidden')`
      - Update sidebar user display
      - Update dashboard user display
      - Apply role-based navigation visibility (settings link for pavan only)
      - Initialize dashboard stats and token status
    - If invalid or doesn't exist, show login screen (default behavior)
    - _Bug_Condition: No session check on page load (always shows login)_
    - _Expected_Behavior: Auto-restore session if valid user stored_
    - _Preservation: Fresh login flow unchanged for new users_
    - _Requirements: Session persistence requirement_

  - [ ] 6.3.4 Add session validation
    - In session restoration code, validate stored user exists in USERS object
    - If stored user is invalid or USERS object changed, clear invalid session
    - Show login screen for invalid sessions
    - _Bug_Condition: Could restore session for deleted/invalid users_
    - _Expected_Behavior: Only restore valid, existing users_
    - _Preservation: Security - don't restore invalid sessions_
    - _Requirements: Session persistence requirement_

  - [ ] 6.3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Session Persists on Page Refresh
    - **IMPORTANT**: Re-run the SAME test from task 6.1 - do NOT write a new test
    - Run bug condition exploration test from step 6.1 (login → refresh → check session)
    - **EXPECTED OUTCOME**: Test PASSES (user still logged in after refresh - confirms fix)
    - _Requirements: Session persistence requirement_

  - [ ] 6.3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Login and Logout Flows Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 6.2 - do NOT write new tests
    - Run preservation tests from step 6.2 (login success, login error, logout, role display)
    - **EXPECTED OUTCOME**: Tests PASS (confirms authentication flows unchanged)
    - Verify logout still works and clears session properly

---

### Integration Testing

- [ ] 7.1 End-to-end multi-user collaboration test
  - Admin user logs in and creates "Project A", saves to GitHub
  - Refresh page, verify admin still logged in (session persistence)
  - Team user logs in on different browser/device
  - Verify team user can see "Project A" in projects list (centralized storage)
  - Team user uploads thumbnail using upload button (file upload)
  - Team user creates "Project B", clicks "💾 Save Project" (dedicated save button)
  - Refresh page, verify team user still logged in (session persistence)
  - Team user attempts to access GitHub Settings (access control)
  - Verify error toast and blocked access
  - Verify team user has token status "✅ (using shared team token)" (pre-configured token)
  - _Requirements: All bugs fixed and integrated_

- [ ] 7.2 End-to-end pavan admin workflow test
  - Pavan logs in
  - Navigate to GitHub Settings (visible to pavan)
  - Update shared team token via `SHARED_TEAM_TOKEN` constant
  - Create new project with file uploads
  - Save project using "💾 Save Project" button
  - Generate HTML and deploy to GitHub
  - Logout
  - Refresh page
  - Verify login screen shown (session cleared on logout)
  - _Requirements: Pavan workflows preserved, all fixes working_

- [ ] 7.3 Checkpoint - Ensure all tests pass
  - Run all exploration tests (tasks 1.1, 2.1, 3.1, 4.1, 5.1, 6.1) - verify all now PASS
  - Run all preservation tests (tasks 1.2, 2.2, 3.2, 4.2, 5.2, 6.2) - verify all still PASS
  - Run integration tests (tasks 7.1, 7.2) - verify complete workflows work
  - Verify no regressions in existing functionality
  - Ensure all six bugs are fixed and validated
  - Ask the user if any questions or issues arise

---

## Task Annotations Reference

**Bug_Condition Specifications** (from design.md):
- **C1**: `storageOperation.action IN ['save', 'load', 'list'] AND storageOperation.storageBackend == 'localStorage'`
- **C2**: `mediaInput.inputType == 'text_field' AND fieldName IN ['pThumbnail', 'vPath', 'gPath'] AND hasUploadButton == false`
- **C3**: `userAction.intent == 'save_project_draft' AND availableActions NOT_CONTAINS 'save_button'`
- **C4**: `userAccess.targetSection == 'github_settings' AND userRole IN ['admin', 'team'] AND isVisible == true`
- **C5**: `userTokenSetup.userRole IN ['admin', 'team'] AND requiresPersonalToken == true AND hasSharedToken == false`
- **C6**: `sessionState.persistenceEnabled == false AND pageAction == 'refresh' AND currentUser != null BEFORE refresh`

**Expected Behavior Properties** (from design.md):
- **P1**: Centralized GitHub storage at `projects/_data/projects.json` accessible by all users
- **P2**: File upload buttons that use GitHub API and auto-populate path fields
- **P3**: Standalone "💾 Save Project" button that saves without generating or deploying
- **P4**: GitHub Settings hidden and blocked for admin/team users, visible only to pavan
- **P5**: Shared team token auto-configured for admin/team users via `SHARED_TEAM_TOKEN` constant
- **P6**: Session persists across page refreshes using localStorage for currentUser

**Preservation Requirements** (from design.md):
- Login authentication (all users), navigation, form inputs, technology tags, dynamic fields
- Generate HTML functionality and output display
- Deploy to GitHub workflow (blob/tree/commit sequence)
- Toast notification system
- Edit modal and manage projects list
- Logout functionality
- Dashboard statistics display
- Theme toggle and clipboard copy features

## Requirements Coverage

- **2.1, 2.2, 2.3**: Centralized GitHub storage (Bug 1)
- **2.4, 2.5**: Real file upload functionality (Bug 2)
- **2.6, 2.7**: Dedicated save button (Bug 3)
- **2.8, 2.9, 2.10**: Role-based access control (Bug 4)
- **2.11, 2.12**: Pre-configured shared token (Bug 5)
- **Session persistence requirement**: Session persists on refresh (Bug 6)
- **3.1, 3.2, 3.3, 3.4**: Preservation of existing functionality
- **3.5, 3.6**: Preservation of deploy workflow
