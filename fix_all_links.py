#!/usr/bin/env python3
import re
import os

def fix_all_jekyll_variables(file_path):
    """Replace all Jekyll baseurl variables with hardcoded /R-D/ paths"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace all Jekyll baseurl variables
    content = re.sub(r'\{\{\s*site\.baseurl\s*\}\}', '/R-D', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed Jekyll variables in: {file_path}")

# Fix all HTML files
for root, dirs, files in os.walk('.'):
    for file in files:
        if file.endswith('.html'):
            file_path = os.path.join(root, file)
            fix_all_jekyll_variables(file_path)

print("All Jekyll variables have been replaced with hardcoded paths!")