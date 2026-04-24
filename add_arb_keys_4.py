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
    "messageWorker": "Message Worker",
    "viewReviews": "View Reviews",
    "inviteToLand": "Invite to Land",
    "worker": "Worker",
    "amountPerHour": "${amount}/h",
    "@amountPerHour": {
        "placeholders": {
            "amount": { "type": "String" }
        }
    },
    "ratingLabel": "Rating",
    "onTimeLabel": "On-Time",
    "disputesLabel": "Disputes",
    "skills": "Skills",
    "about": "About",
    "performance": "Performance",
    "performanceGraphComingSoon": "Performance Graph Coming Soon",
    "tndMo": "TND/mo",
    "cancel": "Cancel",
    "watering": "Watering",
    "harvesting": "Harvesting",
    "planting": "Planting",
    "animalCare": "Animal Care",
    "machineOperation": "Machine Operation",
    "soilManagement": "Soil Management",
    "thisWorker": "this worker"
}

fr_keys = {
    "messageWorker": "Contacter le travailleur",
    "viewReviews": "Voir les avis",
    "inviteToLand": "Inviter sur le terrain",
    "worker": "Travailleur",
    "amountPerHour": "{amount}$/h",
    "@amountPerHour": {
        "placeholders": {
            "amount": { "type": "String" }
        }
    },
    "ratingLabel": "Évaluation",
    "onTimeLabel": "À l'heure",
    "disputesLabel": "Litiges",
    "skills": "Compétences",
    "about": "À propos",
    "performance": "Performance",
    "performanceGraphComingSoon": "Graphique de performance bientôt disponible",
    "tndMo": "TND/mois",
    "cancel": "Annuler",
    "watering": "Arrosage",
    "harvesting": "Récolte",
    "planting": "Plantation",
    "animalCare": "Soin des animaux",
    "machineOperation": "Utilisation des machines",
    "soilManagement": "Gestion des sols",
    "thisWorker": "ce travailleur"
}

es_keys = {
    "messageWorker": "Contactar trabajador",
    "viewReviews": "Ver reseñas",
    "inviteToLand": "Invitar al terreno",
    "worker": "Trabajador",
    "amountPerHour": "${amount}/h",
    "@amountPerHour": {
        "placeholders": {
            "amount": { "type": "String" }
        }
    },
    "ratingLabel": "Calificación",
    "onTimeLabel": "A tiempo",
    "disputesLabel": "Disputas",
    "skills": "Habilidades",
    "about": "Acerca de",
    "performance": "Rendimiento",
    "performanceGraphComingSoon": "Gráfico de rendimiento próximamente",
    "tndMo": "TND/mes",
    "cancel": "Cancelar",
    "watering": "Riego",
    "harvesting": "Cosecha",
    "planting": "Plantación",
    "animalCare": "Cuidado de animales",
    "machineOperation": "Operación de máquinas",
    "soilManagement": "Gestión de suelos",
    "thisWorker": "este trabajador"
}

add_keys("lib/l10n/app_en.arb", en_keys)
add_keys("lib/l10n/app_fr.arb", fr_keys)
add_keys("lib/l10n/app_es.arb", es_keys)
