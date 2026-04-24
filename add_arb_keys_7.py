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
    "landDetails": "Land Details",
    "amountPerMonth": "${amount}/mo",
    "@amountPerMonth": {
        "placeholders": {
            "amount": { "type": "String" }
        }
    }
}

fr_keys = {
    "landDetails": "Détails du terrain",
    "amountPerMonth": "{amount}$/mois",
    "@amountPerMonth": {
        "placeholders": {
            "amount": { "type": "String" }
        }
    }
}

es_keys = {
    "landDetails": "Detalles del terreno",
    "amountPerMonth": "${amount}/mes",
    "@amountPerMonth": {
        "placeholders": {
            "amount": { "type": "String" }
        }
    }
}

add_keys("lib/l10n/app_en.arb", en_keys)
add_keys("lib/l10n/app_fr.arb", fr_keys)
add_keys("lib/l10n/app_es.arb", es_keys)
