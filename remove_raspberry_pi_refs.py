#!/usr/bin/env python3
import re
import os

def remove_raspberry_pi_project_card(file_path):
    """Remove Raspberry Pi GPIO project cards from project pages"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to match the entire Raspberry Pi GPIO project card
    pattern = r'<div class="project-card">\s*<div class="project-image">\s*<img src="[^"]*raspberry-pi[^"]*"[^>]*>\s*<div class="project-overlay">\s*<a href="[^"]*raspberry-pi-gpio\.html"[^>]*>.*?</a>\s*</div>\s*</div>\s*<div class="p-6">.*?</div>\s*</div>'
    
    # Remove the pattern (with DOTALL flag to match across newlines)
    content = re.sub(pattern, '', content, flags=re.DOTALL | re.IGNORECASE)
    
    # Also remove any standalone references
    content = re.sub(r'<a href="[^"]*raspberry-pi-gpio\.html"[^>]*>.*?</a>', '', content, flags=re.DOTALL)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Removed Raspberry Pi GPIO references from: {file_path}")

# Process all project HTML files
for file in os.listdir('projects'):
    if file.endswith('.html'):
        file_path = os.path.join('projects', file)
        remove_raspberry_pi_project_card(file_path)

print("All Raspberry Pi GPIO project references have been removed!")