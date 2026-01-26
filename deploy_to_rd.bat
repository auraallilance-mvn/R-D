@echo off
echo Cleaning up git...
taskkill /f /im git.exe 2>nul
rmdir /s /q .git 2>nul

echo Initializing fresh git repository...
"C:\Program Files\Git\bin\git.exe" init

echo Configuring git...
"C:\Program Files\Git\bin\git.exe" config user.name "Pavan"
"C:\Program Files\Git\bin\git.exe" config user.email "pavan@example.com"

echo Adding files...
"C:\Program Files\Git\bin\git.exe" add .

echo Committing...
"C:\Program Files\Git\bin\git.exe" commit -m "Deploy portfolio to R-D repository"

echo Adding remote...
"C:\Program Files\Git\bin\git.exe" remote add origin https://github.com/auraallilance-mvn/R-D.git

echo Pushing to GitHub...
"C:\Program Files\Git\bin\git.exe" push -u origin main --force

echo Done! Your website should be deployed to https://github.com/auraallilance-mvn/R-D
pause