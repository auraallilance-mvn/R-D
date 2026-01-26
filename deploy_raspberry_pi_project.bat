@echo off
echo ========================================
echo Deploying Raspberry Pi GPIO Project
echo ========================================

echo.
echo Step 1: Adding all files to git...
"C:\Program Files\Git\bin\git.exe" add .

echo.
echo Step 2: Committing changes...
"C:\Program Files\Git\bin\git.exe" commit -m "Add Raspberry Pi GPIO LED Control project with complete Python source code"

echo.
echo Step 3: Pushing to GitHub...
"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo Your Raspberry Pi GPIO project should be live at:
echo https://auraallilance-mvn.github.io/R-D/
echo.
echo Wait 2-3 minutes for GitHub Pages to update.
echo.
pause