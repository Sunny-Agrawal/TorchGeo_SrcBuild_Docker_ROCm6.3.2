#!/bin/bash

# Ensure necessary directories exist
mkdir -p /opt/venv
mkdir -p /usr/local/ML_Repo/public_datasets
mkdir -p /usr/local/ML_Repo/base_models
mkdir -p /usr/local/ML_Repo/custom_models
mkdir -p /usr/local/ML_Repo/custom_datasets

# Ensure root is in video and render groups
usermod -aG video,render root

# Reload group permissions without needing to restart the container
exec sg video newgrp `id -gn`

echo "User 'root' is now part of video and render groups."

# Check if the virtual environment exists
if [ ! -d "/opt/venv/bin" ]; then
    echo "Virtual environment does not exist. Creating..."
    python3 -m venv /opt/venv
    source /opt/venv/bin/activate
    echo "Installing dependencies from requirements.txt..."
    pip install --upgrade pip
    pip install --no-cache-dir -r /tmp/requirements.txt
else
    echo "Virtual environment exists. Activating..."
    source /opt/venv/bin/activate
    echo "Checking for dependency updates..."
    pip install --no-cache-dir -r /tmp/requirements.txt
fi

# Mark the entire repo as safe to prevent "dubious ownership" error
git config --global --add safe.directory /usr/local/ML_Repo
# Mark PyTorch repo as safe
git config --global --add safe.directory /usr/local/ML_Repo/pytorch

# Ensure PyTorch submodules are fully initialized
cd /usr/local/ML_Repo/pytorch
# git submodule update --init --recursive

# Checkout the correct PyTorch version (v2.5.0)
# echo "Checking out PyTorch v2.5.0..."
# git fetch --tags
# git checkout v2.5.0

# Build PyTorch from source if not already built
if [ ! -f "/opt/venv/lib/python3.10/site-packages/torch/__init__.py" ]; then
    echo "PyTorch not found. Building from source..."
    pip install --no-cache-dir -r requirements.txt
    export PYTORCH_ROCM_ARCH="gfx1100" # Change this to match your GPU
    export CMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH:/opt/rocm-6.3.2" # Change this to match your ROCm installation. This is the default path for the rocm-6.3.2 installation
    python tools/amd_build/build_amd.py
    python setup.py develop
    
    if [ $? -eq 0 ]; then
        echo "PyTorch build successful!"
    else
        echo "PyTorch build failed!"
        exit 1
    fi
else
    echo "PyTorch is already installed. Skipping build."
fi

# Short delay to ensure PyTorch is fully recognized
sleep 5  
python -c "import torch; print('PyTorch version:', torch.__version__)"

# Uncomment the following lines if you need torchvision and torchaudio built from source

# echo "Building torchvision from source..."
# cd /usr/local/ML_Repo
# git clone --recursive https://github.com/pytorch/vision.git torchvision
# cd torchvision
# git checkout v0.15.0  # Match with PyTorch 2.5
# python setup.py install

# echo "Building torchaudio from source..."
# cd /usr/local/ML_Repo
# git clone --recursive https://github.com/pytorch/audio.git torchaudio
# cd torchaudio
# git checkout v2.5.0  # Match with PyTorch 2.5
# python setup.py install

echo "Building PyG from source..."
cd /usr/local/ML_Repo/pyg-rocm-build
bash build_and_install_pyg.sh
echo "PyG build complete."

echo "entrypoint script finished. Container ready for use!"

# Pass control to CMD or keep container running
exec "$@"
