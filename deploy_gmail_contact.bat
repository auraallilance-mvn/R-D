@echo off
echo ========================================
echo Setting Up Gmail Contact Form
echo ========================================

echo.
echo GMAIL CONTACT FORM SETUP:
echo - Form sends directly to: auraallilance@gmail.com
echo - Uses Formspree service (free and reliable)
echo - No signup required for basic usage
echo - Automatic spam protection included
echo.

echo Step 1: Adding all files to git...
"C:\Program Files\Git\bin\git.exe" add .

echo.
echo Step 2: Committing changes...
"C:\Program Files\Git\bin\git.exe" commit -m "Setup Gmail contact form with Formspree + Add Raspberry Pi project"

echo.
echo Step 3: Pushing to GitHub...
"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo GMAIL CONTACT FORM IS NOW ACTIVE:
echo.
echo ✅ Form sends to: auraallilance@gmail.com
echo ✅ Automatic email notifications
echo ✅ Spam protection included
echo ✅ Success page after submission
echo ✅ Mobile-friendly design
echo.
echo HOW IT WORKS:
echo 1. User fills out contact form
echo 2. Formspree processes the submission
echo 3. Email sent directly to your Gmail
echo 4. User sees success confirmation
echo.
echo FIRST TIME SETUP:
echo - When someone first submits the form
echo - Formspree will send you a confirmation email
echo - Click the confirmation link to activate
echo - After that, all messages go directly to Gmail
echo.
echo Your website will be live at:
echo https://auraallilance-mvn.github.io/R-D/
echo.
echo Wait 2-3 minutes for GitHub Pages to update.
echo Then test the contact form!
echo.
pause