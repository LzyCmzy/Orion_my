# CUDA 11.8 + cuDNN8 + Ubuntu 20.04
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 1) 基础工具 + Python3.8
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    python3.8 \
    python3.8-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# 2) 设置 python 默认版本为 3.8 并升级 pip 工具链
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 \
 && python -m pip install --upgrade pip setuptools wheel

# 3) 工作目录
WORKDIR /workspace

# 4) 克隆 Orion（浅克隆）
RUN git clone --depth=1 https://github.com/xiaomi-mlab/Orion.git .

# 5) 安装 PyTorch CUDA 11.8
RUN python -m pip install --no-cache-dir \
    torch==2.4.1+cu118 \
    torchvision==0.19.1+cu118 \
    torchaudio==2.4.1+cu118 \
    --index-url https://download.pytorch.org/whl/cu118

# 6) 安装 Orion 项目 (editable)
RUN python -m pip install -v -e .

# 7) 安装 Orion 项目额外依赖
RUN if [ -f requirements.txt ]; then python -m pip install --no-cache-dir -r requirements.txt; fi

# 8) 安装 CARLA 0.9.15
RUN python -m pip install --no-cache-dir carla==0.9.15

CMD ["/bin/bash"]

