#!/usr/bin/env python3
import os
import sys
import regex

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <directory-to-scan>")
    sys.exit(2)

IGNORE_DIRS = {'.git', '__pycache__'}

def should_skip(path: str) -> bool:
    parts = path.split('/')
    return any(part in IGNORE_DIRS for part in parts)


start_dir = sys.argv[1]
if not os.path.isdir(start_dir):
    print(f"Error: '{start_dir}' is not a directory or does not exist.")
    sys.exit(2)

cyr_pattern      = regex.compile(r'\p{Cyrillic}')
emoji_pattern    = regex.compile(r'\p{Extended_Pictographic}')
emoticon_pattern = regex.compile(r'[:;=8][\-~^]?[)(DPp]')

found = False

for root, dirs, files in os.walk(start_dir):
    # skip directories
    if should_skip(root):
        continue

    for name in files:
        path = os.path.join(root, name)
        if should_skip(path):
            continue

        rel = os.path.relpath(path, start_dir)
        
        if cyr_pattern.search(name):
            print(f"::error file={rel}::filename contains Cyrillic")
            found = True

        # check file content
        try:
            with open(path, encoding='utf-8', errors='ignore') as f:
                for num, line in enumerate(f, 1):
                    if (cyr_pattern.search(line)
                        or emoji_pattern.search(line)
                        or emoticon_pattern.search(line)):
                        msg = line.strip().replace('%', '%%')
                        print(f"::error file={rel},line={num}::{msg}")
                        found = True
        except OSError:
            continue

if found:
    sys.exit(1)
else:
    print("::notice:: No Cyrillic or emoji found")
    sys.exit(0)