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
    "daysAgo": "{count}d ago",
    "@daysAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    },
    "couldNotOpenHashScan": "Could not open HashScan",
    "minutesAgo": "{count}m ago",
    "@minutesAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    },
    "hoursAgo": "{count}h ago",
    "@hoursAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    }
}

fr_keys = {
    "daysAgo": "il y a {count}j",
    "@daysAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    },
    "couldNotOpenHashScan": "Impossible d'ouvrir HashScan",
    "minutesAgo": "il y a {count}m",
    "@minutesAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    },
    "hoursAgo": "il y a {count}h",
    "@hoursAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    }
}

es_keys = {
    "daysAgo": "hace {count}d",
    "@daysAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    },
    "couldNotOpenHashScan": "No se pudo abrir HashScan",
    "minutesAgo": "hace {count}m",
    "@minutesAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    },
    "hoursAgo": "hace {count}h",
    "@hoursAgo": {
        "placeholders": {
            "count": { "type": "String" }
        }
    }
}

add_keys("lib/l10n/app_en.arb", en_keys)
add_keys("lib/l10n/app_fr.arb", fr_keys)
add_keys("lib/l10n/app_es.arb", es_keys)
