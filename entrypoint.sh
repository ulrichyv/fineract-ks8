#!/bin/bash

# Vérification alternative si netcat échoue
wait_for_db() {
    echo "⏳ Vérification de la connexion à MariaDB..."
    local timeout=${FINERACT_DB_CONNECTION_TIMEOUT:-30}
    local end=$((SECONDS+timeout))
    
    while [ $SECONDS -lt $end ]; do
        if nc -zw1 mariadb 3306; then
            echo "✅ Connecté à MariaDB"
            return 0
        fi
        echo "⌛ En attente de MariaDB..."
        sleep 2
    done
    
    echo "❌ Échec de connexion à MariaDB après $timeout secondes"
    return 1
}

wait_for_db || exit 1

echo "🚀 Lancement de Fineract..."
exec java -Dloader.path=. -jar app.jar