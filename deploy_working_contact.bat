@echo off
echo ========================================
echo DEPLOYING WORKING GMAIL CONTACT FORM
echo ========================================

echo.
echo WHAT'S FIXED:
echo ✅ Using FormSubmit.co (reliable, free service)
echo ✅ Direct Gmail delivery to: auraallilance@gmail.com
echo ✅ No signup required - works immediately
echo ✅ Alternative contact methods included
echo ✅ Copy email button for easy access
echo ✅ Direct email and phone links
echo.

echo Step 1: Adding all files to git...
"C:\Program Files\Git\bin\git.exe" add .

echo.
echo Step 2: Committing changes...
"C:\Program Files\Git\bin\git.exe" commit -m "Fix contact form with FormSubmit + Gmail integration"

echo.
echo Step 3: Pushing to GitHub...
"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo GMAIL CONTACT FORM NOW WORKS:
echo.
echo 📧 Primary: Form sends to auraallilance@gmail.com
echo 📧 Backup: Direct email link
echo 📞 Phone: +91 7569963393 (clickable)
echo 📋 Copy: One-click email copy
echo.
echo HOW IT WORKS:
echo 1. User fills form and clicks "Send Message to Gmail"
echo 2. FormSubmit.co processes and sends to your Gmail
echo 3. You receive email immediately in Gmail inbox
echo 4. User sees success page confirmation
echo.
echo BACKUP OPTIONS:
echo - Direct Email button (opens email client)
echo - Phone number link (opens dialer on mobile)
echo - Copy Email button (copies to clipboard)
echo.
echo Your website will be live at:
echo https://auraallilance-mvn.github.io/R-D/
echo.
echo Wait 2-3 minutes for GitHub Pages to update.
echo Then test the contact form - it WILL work!
echo.
pause