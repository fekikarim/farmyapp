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
    "tasksLabelShort": "Tasks",
    "assignToLand": "Assign to Land",
    "invitationSentTo": "Invitation sent to {worker}",
    "@invitationSentTo": {
        "placeholders": {
            "worker": { "type": "String" }
        }
    },
    "failedToSendInvitation": "Failed to send invitation",
    "inviteWorker": "Invite Worker",
    "inviteWorkerMessage": "Invite {worker} to {landName}",
    "@inviteWorkerMessage": {
        "placeholders": {
            "worker": { "type": "String" },
            "landName": { "type": "String" }
        }
    },
    "optionalMessageHint": "Optional message...",
    "sendInvite": "Send Invite",
    "workerAssignedToLand": "{worker} assigned to {landName}",
    "@workerAssignedToLand": {
        "placeholders": {
            "worker": { "type": "String" },
            "landName": { "type": "String" }
        }
    },
    "failedToAssignWorker": "Failed to assign worker",
    "directMessagingDescription": "Direct messaging description",
    "readReviewsDescription": "Read reviews description"
}

fr_keys = {
    "tasksLabelShort": "Tâches",
    "assignToLand": "Assigner au terrain",
    "invitationSentTo": "Invitation envoyée à {worker}",
    "@invitationSentTo": {
        "placeholders": {
            "worker": { "type": "String" }
        }
    },
    "failedToSendInvitation": "Échec de l'envoi de l'invitation",
    "inviteWorker": "Inviter un travailleur",
    "inviteWorkerMessage": "Inviter {worker} à {landName}",
    "@inviteWorkerMessage": {
        "placeholders": {
            "worker": { "type": "String" },
            "landName": { "type": "String" }
        }
    },
    "optionalMessageHint": "Message optionnel...",
    "sendInvite": "Envoyer l'invitation",
    "workerAssignedToLand": "{worker} assigné à {landName}",
    "@workerAssignedToLand": {
        "placeholders": {
            "worker": { "type": "String" },
            "landName": { "type": "String" }
        }
    },
    "failedToAssignWorker": "Échec de l'assignation du travailleur",
    "directMessagingDescription": "Description de la messagerie directe",
    "readReviewsDescription": "Description de la lecture des avis"
}

es_keys = {
    "tasksLabelShort": "Tareas",
    "assignToLand": "Asignar al terreno",
    "invitationSentTo": "Invitación enviada a {worker}",
    "@invitationSentTo": {
        "placeholders": {
            "worker": { "type": "String" }
        }
    },
    "failedToSendInvitation": "Error al enviar la invitación",
    "inviteWorker": "Invitar trabajador",
    "inviteWorkerMessage": "Invitar a {worker} a {landName}",
    "@inviteWorkerMessage": {
        "placeholders": {
            "worker": { "type": "String" },
            "landName": { "type": "String" }
        }
    },
    "optionalMessageHint": "Mensaje opcional...",
    "sendInvite": "Enviar invitación",
    "workerAssignedToLand": "{worker} asignado a {landName}",
    "@workerAssignedToLand": {
        "placeholders": {
            "worker": { "type": "String" },
            "landName": { "type": "String" }
        }
    },
    "failedToAssignWorker": "Error al asignar trabajador",
    "directMessagingDescription": "Descripción de mensajería directa",
    "readReviewsDescription": "Descripción de leer reseñas"
}

add_keys("lib/l10n/app_en.arb", en_keys)
add_keys("lib/l10n/app_fr.arb", fr_keys)
add_keys("lib/l10n/app_es.arb", es_keys)
