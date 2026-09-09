#!/bin/bash
# entrypoint.sh


# ---------- CSI Banner (orange) ----------
RED='\e[0;31m'
NC='\033[0m'   # No Color

echo -e "${RED}"
cat << "BANNER"
______________________________                  ______  
__  ____/_  ___/___  _/__  __/_____________________  /_ 
_  /    _____ \ __  / __  /  _  __ \_  ___/  ___/_  __ \
/ /___  ____/ /__/ /  _  /   / /_/ /  /   / /__ _  / / /
\____/  /____/ /___/  /_/    \____//_/    \___/ /_/ /_/ 
                                                        
BANNER
echo -e "${NC}"
# ------------------------



# Configure pip to always use --user and --upgrade
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[install]
user = true
EOF

# Set environment variables
export PATH="$HOME/.local/bin:$PATH"

# Pip
export PIP_CACHE_DIR="$HOME/.cache/pip"

# HuggingFace
export HF_HOME="$HOME/.cache/huggingface"
export TRANSFORMERS_CACHE="$HOME/.cache/huggingface"

# Matplotlib
export MPLCONFIGDIR="$HOME/.cache/matplotlib"

# PyTorch
export TORCH_HOME="$HOME/.cache/torch"
export PYTORCH_KERNEL_CACHE_PATH="$HOME/.cache/torch/kernels"

# TensorFlow
export KERAS_HOME="$HOME/.cache/keras"
export TFHUB_CACHE_DIR="$HOME/.cache/tfhub_modules"

# RAPIDS / CuPy
export CUPY_CACHE_DIR="$HOME/.cache/cupy"

# JAX
export JAX_COMPILATION_CACHE_DIR="$HOME/.cache/jax"

# CUDA
export CUDA_CACHE_PATH="$HOME/.cache/nv"

# Custom command line
export PROMPT_COMMAND='PS1="\[\e[1m\e[31m\]csitorch@\h\[\e[0m\]:\[\e[1m\e[34m\]\w\[\e[0m\]\$ "'

echo "Pacotes serão instalados em: ~/.local/"
echo "A sessão é efêmera. Pacotes instalados em ~/.local/ serão perdidos ao sair." 
echo "Caches são persistentes e vinculadas ao /media/data."

if [ $# -eq 0 ]; then
    exec bash
else
    exec "$@"
fi
