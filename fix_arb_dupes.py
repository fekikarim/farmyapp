import json

def fix_duplicates(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We will manually replace the first occurrence of paymentFailed with paymentFailedWithError
    content = content.replace('"paymentFailed": "Payment failed: {error}"', '"paymentFailedWithError": "Payment failed: {error}"')
    content = content.replace('"@paymentFailed": {', '"@paymentFailedWithError": {', 1)
    
    # Replace second occurrence (if exists)
    content = content.replace('"paymentFailed": "Payment could not be completed."', '"paymentFailedGeneric": "Payment could not be completed."')
    
    # Replace third occurrence
    content = content.replace('"paymentFailed": "Payment failed or cancelled."', '"paymentFailedCancelled": "Payment failed or cancelled."')
    
    # Same for FR and ES
    content = content.replace('"paymentFailed": "Paiement échoué : {error}"', '"paymentFailedWithError": "Paiement échoué : {error}"')
    content = content.replace('"paymentFailed": "Le paiement n\'a pas pu être effectué."', '"paymentFailedGeneric": "Le paiement n\'a pas pu être effectué."')
    content = content.replace('"paymentFailed": "Paiement échoué ou annulé."', '"paymentFailedCancelled": "Paiement échoué ou annulé."')
    
    content = content.replace('"paymentFailed": "Pago fallido: {error}"', '"paymentFailedWithError": "Pago fallido: {error}"')
    content = content.replace('"paymentFailed": "El pago no pudo ser completado."', '"paymentFailedGeneric": "El pago no pudo ser completado."')
    content = content.replace('"paymentFailed": "Pago fallido o cancelado."', '"paymentFailedCancelled": "Pago fallido o cancelado."')
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_duplicates("lib/l10n/app_en.arb")
fix_duplicates("lib/l10n/app_fr.arb")
fix_duplicates("lib/l10n/app_es.arb")
