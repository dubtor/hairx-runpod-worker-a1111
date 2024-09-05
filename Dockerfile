FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ===== install general and worker-related stuff ======

WORKDIR /

# Upgrade apt packages and install required dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      python3-dev \
      python3-pip \
      python3.10-venv \
      fonts-dejavu-core \
      rsync \
      git \
      jq \
      moreutils \
      aria2 \
      wget \
      curl \
      libglib2.0-0 \
      libsm6 \
      libgl1 \
      libxrender1 \
      libxext6 \
      ffmpeg \
      bc \
      libgoogle-perftools4 \
      libtcmalloc-minimal4 \
      procps && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Install Worker dependencies
RUN pip install requests runpod huggingface_hub

# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./
COPY schemas /schemas

# ===== Install stable diffusion + Auto1111 (only if NOT using a network volume)======

# Enable all lines below to install models and extensions directly in the container rather
# installing them separately into a network volume. This approach is valid if no network volume
# is to be used, however it will bloat the container size and make it much slower to boot up.

#WORKDIR /workspace

# Clone the Stable Diffusion Web UI repository
#RUN git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui

# Fix a bug in the Stable Diffusion repo
#RUN sed -i "s|latent_mask = self.latent_mask if self.latent_mask is not None else image_mask|latent_mask = self.latent_mask if self.latent_mask is not None and self.latent_mask!='' else image_mask|" /workspace/stable-diffusion-webui/modules/processing.py
# see fix from @quanwuji at https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/9779

# Create and activate a virtual environment
#RUN python3 -m venv /workspace/venv && \
#    . /workspace/venv/bin/activate && \
#    pip install --no-cache-dir torch==2.1.2+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
#    pip install --no-cache-dir xformers==0.0.23.post1 --index-url https://download.pytorch.org/whl/cu118

# Install A1111 Web UI
#COPY install-automatic.py /workspace/stable-diffusion-webui/install-automatic.py
#WORKDIR /workspace/stable-diffusion-webui
#RUN python3 -m install-automatic --skip-torch-cuda-test
#WORKDIR /workspace

# Clone ControlNet extension repo and install dependencies
#git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet && \
#pip install -r /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet/requirements.txt && \
# Install RunPod Serverless dependencies
#pip install huggingface_hub runpod && \
# Download Stable Diffusion models and VAEs
#aria2c -d /workspace/stable-diffusion-webui/models/Stable-diffusion -o stable-diffusion-inpainting-1.5.safetensors https://huggingface.co/webui/stable-diffusion-inpainting/resolve/main/sd-v1-5-inpainting.safetensors && \
#aria2c -d /workspace/stable-diffusion-webui/models/VAE -o vae-ft-mse-840000-ema-pruned.safetensors https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors && \
# Download ControlNet models
#mkdir -p /workspace/stable-diffusion-webui/models/ControlNet && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v11p_sd15_openpose.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v11p_sd15_canny.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v11f1p_sd15_depth.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v11p_sd15_inpaint.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v11p_sd15_lineart.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v1p_sd15_brightness.safetensors https://huggingface.co/ioclab/ioc-controlnet/resolve/main/models/control_v1p_sd15_brightness.safetensors && \
#aria2c -d /workspace/stable-diffusion-webui/models/ControlNet -o control_v11f1e_sd15_tile.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth && \
# Download Upscalers
#mkdir -p /workspace/stable-diffusion-webui/models/ESRGAN && \
#aria2c -d /workspace/stable-diffusion-webui/models/ESRGAN -o 4x-UltraSharp.pth https://huggingface.co/ashleykleynhans/upscalers/resolve/main/4x-UltraSharp.pth && \
#aria2c -d /workspace/stable-diffusion-webui/models/ESRGAN -o lollypop.pth https://huggingface.co/ashleykleynhans/upscalers/resolve/main/lollypop.pth && \
# Write Stable Diffusion config files
#cp /webui-user.sh /workspace/stable-diffusion-webui/webui-user.sh && \
#cp /config.json /workspace/stable-diffusion-webui/config.json && \
#cp /ui-config.json /workspace/stable-diffusion-webui/ui-config.json; \

# Creating log directory
RUN mkdir -p /workspace/logs

# ===== Run container ======

WORKDIR /

# Start the container
RUN chmod +x /start.sh
ENTRYPOINT /start.sh
