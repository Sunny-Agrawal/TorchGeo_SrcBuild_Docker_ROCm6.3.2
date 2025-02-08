# ---------------------------------------------------------------------------
# Base Image: ROCm for GPU acceleration (dev-ubuntu-22.04:6.3.2-complete)
# ---------------------------------------------------------------------------
    FROM rocm/dev-ubuntu-22.04:6.3.2-complete

    # ---------------------------------------------------------------------------
    # Install basic dependencies
    # ---------------------------------------------------------------------------
    RUN apt-get update && apt-get install -y \
        build-essential \
        bash-completion \
        cmake \
        git \
        wget \
        python3 \
        python3-pip \
        python3-venv \
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
    