#!/bin/bash
set -euo pipefail

# ==============================================================================
# 1. SANITY CHECK
# ==============================================================================

check_required_env() {
    local var_name="$1"
    if [ -z "${!var_name:-}" ]; then
        echo "Erreur critique : variable '$var_name' manquante."
        exit 1
    fi
}

echo "Vérification des variables requises..."

check_required_env "BW_HOST"
check_required_env "BW_CLIENTID"
check_required_env "BW_CLIENTSECRET"
check_required_env "BW_PASSWORD"

command -v bw >/dev/null 2>&1 || {
    echo "Erreur : 'bw' n'est pas installé."
    exit 1
}

echo "Configuration validée."

# ==============================================================================
# 2. LOGIN & UNLOCK
# ==============================================================================

echo "Configuration du serveur : ${BW_HOST}"
bw config server "${BW_HOST}"

echo "Authentification via API Key..."
bw login --apikey >/dev/null

echo "Déverrouillage du coffre..."
export BW_SESSION
BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

if [ -z "$BW_SESSION" ]; then
    echo "Erreur : session introuvable ou mot de passe incorrect."
    exit 1
fi

echo "Validation du déverrouillage..."
bw unlock --check >/dev/null

echo "Coffre déverrouillé."

# ==============================================================================
# 3. SERVER
# ==============================================================================

PORT="${BW_PORT:-8087}"

echo "Démarrage du serveur Bitwarden CLI sur le port ${PORT}"
exec bw serve --hostname 0.0.0.0 --port "$PORT"