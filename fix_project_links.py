#!/usr/bin/env python3
import re

def fix_project_links(file_path):
    """Fix project links to use Jekyll baseurl"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace absolute project paths with Jekyll baseurl
    content = re.sub(r'href="/projects/', r'href="{{ site.baseurl }}/projects/', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed project links in: {file_path}")

# Fix index.html
fix_project_links('index.html')
print("All project links have been fixed!")