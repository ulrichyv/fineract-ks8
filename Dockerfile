# Étape 1 : Build du JAR Fineract
FROM eclipse-temurin:21-jdk as builder

WORKDIR /app
COPY . .

RUN chmod +x gradlew
RUN ./gradlew clean bootJar

# Étape 2 : Image finale
FROM eclipse-temurin:21-jre

WORKDIR /app

# Installation des dépendances
RUN apt-get update && \
    apt-get install -y curl netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Téléchargement du driver JDBC
RUN curl -L -o mariadb-java-client.jar \
    https://dlm.mariadb.com/4174416/Connectors/java/connector-java-3.5.2/mariadb-java-client-3.5.2.jar

# Copie du JAR généré
COPY --from=builder /app/fineract-provider/build/libs/*.jar app.jar

EXPOSE 8443

# Variables d'environnement par défaut
ENV FINERACT_DEFAULT_TENANTDB_HOST=mariadb
ENV FINERACT_DEFAULT_TENANTDB_PORT=3306
ENV FINERACT_DEFAULT_TENANTDB_USER=fineract
ENV FINERACT_DEFAULT_TENANTDB_PASSWORD=fineractpass

# Script d'entrée
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
