import re
import os

def remove_const_from_file(file_path, lines_to_check):
    if not os.path.exists(file_path):
        return
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    modified = False
    for line_num in lines_to_check:
        idx = line_num - 1
        if 0 <= idx < len(lines):
            # Check current line for 'const '
            if 'const ' in lines[idx]:
                lines[idx] = lines[idx].replace('const ', '')
                modified = True
            else:
                # search upwards for up to 5 lines for a 'const ' that starts a widget
                for up in range(1, 6):
                    up_idx = idx - up
                    if up_idx >= 0 and 'const ' in lines[up_idx]:
                        lines[up_idx] = lines[up_idx].replace('const ', '')
                        modified = True
                        break
                        
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)

with open('analyze_const_errors.txt', 'r', encoding='utf-16') as f:
    content = f.read()

errors = re.findall(r'error - .*? - (.*?):(\d+):\d+ - (?:invalid_constant|non_constant_list_element|const_with_non_constant_argument|non_constant_map_value)', content)
# deduplicate
file_lines = {}
for filepath, linenum in errors:
    filepath = filepath.strip()
    if filepath not in file_lines:
        file_lines[filepath] = set()
    file_lines[filepath].add(int(linenum))

for filepath, linenum_set in file_lines.items():
    remove_const_from_file(filepath, linenum_set)
    print(f"Fixed {filepath}: {linenum_set}")
