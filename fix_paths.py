#!/usr/bin/env python3
import os
import re

def fix_asset_paths(file_path):
    """Fix asset paths in HTML files to use Jekyll baseurl"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace absolute asset paths with Jekyll baseurl
    content = re.sub(r'"/assets/', r'"{{ site.baseurl }}/assets/', content)
    content = re.sub(r"'/assets/", r"'{{ site.baseurl }}/assets/", content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed paths in: {file_path}")

# Find all HTML files
for root, dirs, files in os.walk('.'):
    for file in files:
        if file.endswith('.html'):
            file_path = os.path.join(root, file)
            fix_asset_paths(file_path)

print("All asset paths have been fixed!")