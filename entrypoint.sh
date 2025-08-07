#!/bin/bash

set -e

wait_for_db() {
    echo "⏳ Vérification de la connexion à MariaDB (${FINERACT_DEFAULT_TENANTDB_HOST}:${FINERACT_DEFAULT_TENANTDB_PORT})..."
    local timeout=${FINERACT_DB_CONNECTION_TIMEOUT:-30}
    local end=$((SECONDS+timeout))

    while [ $SECONDS -lt $end ]; do
        if nc -zw1 "$FINERACT_DEFAULT_TENANTDB_HOST" "$FINERACT_DEFAULT_TENANTDB_PORT"; then
            echo "✅ MariaDB est accessible."
            return 0
        fi
        echo "⌛ En attente de MariaDB..."
        sleep 2
    done

    echo "❌ Échec de connexion à MariaDB après $timeout secondes."
    return 1
}

wait_for_db || exit 1

echo "🚀 Lancement de Fineract..."
exec java ${JAVA_OPTS} -Dloader.path=. -jar app.jar
