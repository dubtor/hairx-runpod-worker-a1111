#!/usr/bin/env bash

echo "Worker Initiated"

# comment out those 3 lines if you don't use the network volume, but use a docker image with everything pre-installed
echo "Symlinking files from Network Volume"
rm -rf /workspace && \
  ln -s /runpod-volume /workspace

# boot up Stable Diffusion WebUI
if [ -f "/workspace/venv/bin/activate" ]; then
    echo "Starting WebUI API"
    echo "(this continues in the background and can take quite some time)"
    source /workspace/venv/bin/activate
    TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
    export LD_PRELOAD="${TCMALLOC}"
    export PYTHONUNBUFFERED=true
    export HF_HOME="/workspace"
    python3 /workspace/stable-diffusion-webui/webui.py \
      --xformers \
      --no-half-vae \
      --skip-python-version-check \
      --skip-torch-cuda-test \
      --skip-install \
      --lowram \
      --opt-sdp-attention \
      --disable-safe-unpickle \
      --port 3000 \
      --api \
      --nowebui \
      --skip-version-check \
      --no-hashing \
      --no-download-sd-model > /workspace/logs/webui.log 2>&1 &
    deactivate
else
    echo "ERROR: The Python Virtual Environment (/workspace/venv/bin/activate) could not be activated"
    echo "1. Ensure that you have followed the instructions at: https://github.com/ashleykleynhans/runpod-worker-a1111/blob/main/docs/installing.md"
    echo "2. Ensure that you have used the Pytorch image for the installation and NOT a Stable Diffusion image."
    echo "3. Ensure that you have attached your Network Volume to your endpoint."
    echo "4. Ensure that you didn't assign any other invalid regions to your endpoint."
fi

# boot up RunPod handler, which keeps running and talks to WebUI locally
echo "Starting RunPod Handler"
python3 -u /rp_handler.py
