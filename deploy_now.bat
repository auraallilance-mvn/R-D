@echo off
echo ========================================
echo DEPLOYING CONTACT FIXES + RASPBERRY PI PROJECT
echo ========================================

echo.
echo Adding all files to git...
git add .

echo.
echo Committing changes...
git commit -m "Fix contact section with direct methods + Add Raspberry Pi GPIO project"

echo.
echo Pushing to GitHub Pages...
git push origin main

echo.
echo ========================================
echo DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo Changes will be live in 2-3 minutes at:
echo https://auraallilance-mvn.github.io/R-D/
echo.
echo What you'll see:
echo ✅ New contact section with 4 direct methods
echo ✅ Raspberry Pi GPIO project card
echo ✅ No more broken contact form
echo.
pause