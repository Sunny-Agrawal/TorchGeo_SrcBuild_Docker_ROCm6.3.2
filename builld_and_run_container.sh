# Ensure we are in the repo root
cd "$(dirname "$0")"

# Initialize all submodules recursively
bash setup_submodules.sh

#build and run the container
#NOTE: docker compose up will call entrypoint.sh
#entrypoin.sh sets up python env, perform source builds, and runs pip installs *inside the container*
docker compose build --no-cache
docker compose up