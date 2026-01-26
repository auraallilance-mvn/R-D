#!/usr/bin/env python3
import re
import os

def fix_project_navigation(file_path):
    """Fix navigation links in project pages to use absolute paths"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace navigation links with absolute paths
    content = re.sub(r'href="/#home"', 'href="/R-D/#home"', content)
    content = re.sub(r'href="/#about"', 'href="/R-D/#about"', content)
    content = re.sub(r'href="/#projects"', 'href="/R-D/#projects"', content)
    content = re.sub(r'href="/#contact"', 'href="/R-D/#contact"', content)
    
    # Also fix any logo/brand links
    content = re.sub(r'href="/"', 'href="/R-D/"', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed navigation in: {file_path}")

# Fix all project HTML files
for file in os.listdir('projects'):
    if file.endswith('.html'):
        file_path = os.path.join('projects', file)
        fix_project_navigation(file_path)

print("All project navigation links have been fixed!")