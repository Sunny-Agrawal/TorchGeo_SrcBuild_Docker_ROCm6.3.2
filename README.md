This repo sets up a Docker container for development on PyTorch and PyG (Pytorch Geometric).

To build the container, run the following command from the repository root:

```bash build_and_run_container.sh```

This script calls a sequence of other scripts that can be run separately for debugging.
Here is the order of operations in the `build_and_run_container.sh` script:

1. Download/initialize the repo's submodules recursively. This includes the source code for PyTorch and PyG.

2. Run ```docker compose build --no-cache``` to build the container according to the docker-compose-override.yml, docker-compose.yml, and Dockerfile.

3. Run ```docker compose up``` to start the container according to the docker-compose-override.yml, docker-compose.yml, and Dockerfile. NOTE: The docker compose setup mounts this entire repository to the container-- ensuring that source code builds and environment setup persists.

4. The previous command will automatically trigger the `entrypoint.sh` script, which will install python packages according to the `requirements.txt` file, and then build PyTorch and PyG from source.