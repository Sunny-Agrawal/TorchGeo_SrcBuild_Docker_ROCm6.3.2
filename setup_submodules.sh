#!/bin/bash

# Ensure we are in the repo root
cd "$(dirname "$0")"

echo "Initializing ALL submodules recursively..."
git submodule update --init --recursive --remote

# Explicitly mark all submodules as safe to prevent dubious ownership issues
git submodule foreach --recursive git config --global --add safe.directory "$PWD"

# Checkout the correct PyTorch version before the container build
cd pytorch
echo "Checking out PyTorch v2.4.0..."
git fetch --tags
git checkout v2.4.0
git submodule update --init --recursive

# Fix psimd submodule if it is missing actual source files
if [ "$(ls -A third_party/psimd | grep -v '^\.git$' | wc -l)" -eq 0 ]; then
    echo "psimd submodule is empty! Forcing a fresh clone..."
    rm -rf third_party/psimd
    git clone https://github.com/Maratyszcza/psimd.git third_party/psimd
    cd third_party/psimd
    git checkout main
    cd ../..
fi

cd ..
echo "All submodules are now fully initialized and PyTorch is set to v2.4.0!"
