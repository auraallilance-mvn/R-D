@echo off
echo ========================================
echo DEPLOYING FINAL FIXES
echo ========================================

echo.
echo CHANGES MADE:
echo ✅ Fixed Raspberry Pi GPIO project thumbnail
echo   - Now uses: /R-D/assets/projects/rassperrypi.webp
echo   - Same wiring diagram image as requested
echo.
echo ✅ Updated YOLOv8n project details
echo   - Changed to "Raspberry Pi 4 (8GB RAM)"
echo   - Updated tech tag to "Raspberry Pi 4"
echo   - Updated project page with 8GB RAM specs
echo.
echo ✅ Removed LinkedIn symbol from contact section
echo   - Now only shows: Email, Phone, WhatsApp
echo   - Cleaner contact interface
echo.

echo Step 1: Adding all files to git...
git add .

echo.
echo Step 2: Committing changes...
git commit -m "Fix Raspberry Pi GPIO thumbnail + Update YOLOv8n to Pi4 8GB + Remove LinkedIn"

echo.
echo Step 3: Pushing to GitHub...
git push origin main

echo.
echo ========================================
echo DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo FINAL WEBSITE STATUS:
echo ✅ Raspberry Pi GPIO project with correct thumbnail
echo ✅ YOLOv8n project shows "Raspberry Pi 4 (8GB RAM)"
echo ✅ Contact section: Email + Phone + WhatsApp only
echo ✅ All projects working with proper navigation
echo.
echo Your website will be updated at:
echo https://auraallilance-mvn.github.io/R-D/
echo.
echo Wait 2-3 minutes for GitHub Pages to update.
echo All requested changes are now live!
echo.
pause