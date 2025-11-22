# Étape 1 : Utilisation de Node.js LTS sur Alpine
FROM node:24-alpine

# Déclaration de la version
ARG BW_VERSION

# 1. Installation des dépendances nécessaires
# On ajoute 'sed' pour nettoyer l'entrypoint si besoin
RUN apk add --no-cache libc6-compat git bash sed

# 2. Installation de Bitwarden CLI via NPM
RUN npm install -g @bitwarden/cli@${BW_VERSION}

# 3. VÉRIFICATION DE L'INSTALLATION
RUN echo "🔍 Vérification de l'installation..." \
    && bw --version > /dev/null \
    && echo "Bitwarden CLI fonctionne correctement."

# 4. Gestion du script d'entrée
COPY entrypoint.sh /entrypoint.sh

# On rend exécutable et on nettoie les retours chariot Windows (\r) au cas où
RUN chmod +x /entrypoint.sh \
    && sed -i 's/\r$//' /entrypoint.sh

# 5. Configuration de l'environnement
WORKDIR /bw

ENV HOME=/bw
ENV BW_HOST="https://api.bitwarden.com"
ENV TZ="Europe/Paris"
ENV BW_PORT="8087"

# 🆕 CRÉATION DU DOSSIER DE CONFIGURATION
# Les guillemets sont importants car il y a un espace dans "Bitwarden CLI"
RUN mkdir -p "/bw/.config/Bitwarden CLI"

# 🆕 GESTION DES PERMISSIONS
# On donne tout à l'utilisateur 'node' (natif dans l'image)
RUN chown -R node:node /bw \
    && chown node:node /entrypoint.sh

# On passe en utilisateur non-root pour la sécurité
USER node

# Commande d'entrée
ENTRYPOINT ["/entrypoint.sh"]