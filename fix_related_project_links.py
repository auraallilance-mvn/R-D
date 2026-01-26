#!/usr/bin/env python3
import re
import os

def fix_related_project_links(file_path):
    """Fix related project links in project pages to use absolute paths"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace project links with absolute paths
    content = re.sub(r'href="/projects/', 'href="/R-D/projects/', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed related project links in: {file_path}")

# Fix all project HTML files
for file in os.listdir('projects'):
    if file.endswith('.html'):
        file_path = os.path.join('projects', file)
        fix_related_project_links(file_path)

print("All related project links have been fixed!")