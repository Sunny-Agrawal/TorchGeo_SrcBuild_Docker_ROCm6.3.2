# ---------------------------------------------------------------------------
# Base Image: Ubuntu with CUDA/cuDNN for GPU acceleration (CUDA 12.8.0-cudnn-devel-ubuntu22.04)
# ---------------------------------------------------------------------------
    FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

    # ---------------------------------------------------------------------------
    # Install basic dependencies
    # ---------------------------------------------------------------------------
    RUN apt-get update && apt-get install -y \
        build-essential \
        bash-completion \
        cmake \
        cudnn-cuda-12 \
        git \
        wget \
        python3 \
        python3-pip \
        python3-venv \
        nvidia-container-toolkit \
        && rm -rf /var/lib/apt/lists/*
    
    # ---------------------------------------------------------------------------
    # Set up Python virtual environment
    # ---------------------------------------------------------------------------
    RUN python3 -m venv /opt/venv
    ENV PATH="/opt/venv/bin:$PATH"
    
    # ---------------------------------------------------------------------------
    # Install Python dependencies
    # ---------------------------------------------------------------------------
    COPY requirements.txt /tmp/requirements.txt
    RUN pip install --upgrade pip && \
        pip install --no-cache-dir -r /tmp/requirements.txt
    
    # ---------------------------------------------------------------------------
    # Copy Entrypoint Script and Make It Executable
    # ---------------------------------------------------------------------------
    COPY entrypoint.sh /usr/local/bin/entrypoint.sh
    RUN chmod +x /usr/local/bin/entrypoint.sh
    
    # ---------------------------------------------------------------------------
    # Use Entrypoint Script and Default Command
    # ---------------------------------------------------------------------------
    ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
    CMD ["/bin/bash"]
    