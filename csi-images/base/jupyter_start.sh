#!/bin/bash
# start-jupyter.sh - Launch JupyterLab inside an Apptainer container
# Handles port conflicts and provides connection info

set -euo pipefail

# ============================================
# Configuration
# ============================================
START_PORT="${JUPYTER_PORT:-8888}"
MAX_PORT=$((START_PORT + 50))  # Search up to 50 ports
NOTEBOOK_DIR="/media/work/$USER"


# ============================================
# Find an available port
# ============================================
find_free_port() {
    local port=$START_PORT
    while [ $port -le $MAX_PORT ]; do
        if ! ss -tln "sport = :$port" | grep -q ":$port" 2>/dev/null; then
            echo $port
            return 0
        fi
        port=$((port + 1))
    done
    echo "Error: No free ports between $START_PORT and $MAX_PORT" >&2
    return 1
}

PORT=$(find_free_port)
if [ $? -ne 0 ]; then
    exit 1
fi

# ============================================
# Display connection info
# ============================================
echo ""
echo "                Iniciando JupyterLab               "
echo ""
echo "  Server:   $(hostname)                            "
echo "  Port:     $PORT                                  "
echo "                                                   "
echo "  Acesso Remoto (SSH tunnel):                      "
echo "  ssh -L 8891:localhost:$PORT -J bridge $USER@$(hostname)"
echo "                                                   "
echo "  Local URL:                                       "
echo "  http://localhost:8891                            "
echo ""

# ============================================
# Launch JupyterLab
# ============================================
jupyter lab \
    --ip=0.0.0.0 \
    --port="$PORT" \
    --no-browser \
    --ServerApp.token='' \
    --ServerApp.password='' \
    --notebook-dir="$NOTEBOOK_DIR" \
    > /home/$USER/.jupyter.log 2>&1 &

JUPYTER_PID=$!
echo $JUPYTER_PID > /tmp/jupyter_"$JUPYTER_PID".pid

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # Guardião: mata o Jupyter quando o shell atual ($$) desaparecer
    (
        # Garante que o PID file será removido mesmo que o subshell seja morto abruptamente
        trap 'rm -f /tmp/jupyter.pid' EXIT
        while kill -0 $$ 2>/dev/null; do sleep 1; done
        kill -9 "$JUPYTER_PID" 2>/dev/null
    ) &
    GUARDIAN_PID=$!
    disown $GUARDIAN_PID

    # Trap para saída normal (complementar)
    trap 'kill -9 '"$JUPYTER_PID"' 2>/dev/null; rm -f /tmp/jupyter_'"$JUPYTER_PID"'.pid; wait '"$JUPYTER_PID"' 2>/dev/null' EXIT

    echo "Trap configurado: Jupyter será encerrado ao sair do shell."
fi
