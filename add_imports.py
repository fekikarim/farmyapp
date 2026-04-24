import os
import re

def add_import_if_missing(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if "AppLocalizations" in content and "package:farmyapp/l10n/app_localizations.dart" not in content:
                    lines = content.split('\n')
                    # Find last import
                    last_import_idx = 0
                    for i, line in enumerate(lines):
                        if line.startswith('import '):
                            last_import_idx = i
                    
                    lines.insert(last_import_idx + 1, "import 'package:farmyapp/l10n/app_localizations.dart';")
                    
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write('\n'.join(lines))
                    print(f"Added import to {filepath}")

add_import_if_missing("lib")
