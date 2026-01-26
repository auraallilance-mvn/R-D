@echo off
echo ========================================
echo Fixing Contact Form + Deploying Changes
echo ========================================

echo.
echo Step 1: Adding all files to git...
"C:\Program Files\Git\bin\git.exe" add .

echo.
echo Step 2: Committing changes...
"C:\Program Files\Git\bin\git.exe" commit -m "Fix contact form with Netlify Forms + Add Raspberry Pi GPIO project"

echo.
echo Step 3: Pushing to GitHub...
"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo CONTACT FORM FIXED:
echo - Now uses Netlify Forms (no external service needed)
echo - Includes success page at /R-D/success.html
echo - Form submissions will appear in Netlify dashboard
echo.
echo RASPBERRY PI PROJECT ADDED:
echo - Project card visible on main page
echo - Complete project page with Python code
echo - Working links and navigation
echo.
echo Your website should be live at:
echo https://auraallilance-mvn.github.io/R-D/
echo.
echo Wait 2-3 minutes for GitHub Pages to update.
echo Then test the contact form!
echo.
pause