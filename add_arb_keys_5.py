import json

def add_keys(filepath, translations):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, value in translations.items():
        if key not in data:
            data[key] = value
            
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

en_keys = {
    "manager": "Manager",
    "pendingLabel": "Pending",
    "inactiveLabel": "Inactive"
}

fr_keys = {
    "manager": "Manager",
    "pendingLabel": "En attente",
    "inactiveLabel": "Inactif"
}

es_keys = {
    "manager": "Gerente",
    "pendingLabel": "Pendiente",
    "inactiveLabel": "Inactivo"
}

add_keys("lib/l10n/app_en.arb", en_keys)
add_keys("lib/l10n/app_fr.arb", fr_keys)
add_keys("lib/l10n/app_es.arb", es_keys)
