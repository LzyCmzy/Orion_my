# syntax=docker/dockerfile:1.6

# CUDA 11.8 + cuDNN8 + Ubuntu 20.04
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    # 将临时文件聚合到一个位置，便于挂 cache
    TMPDIR=/workspace/.build/tmp \
    # 减小目标文件体积（去掉调试符号）
    CFLAGS="-O2 -g0" \
    CXXFLAGS="-O2 -g0" \
    # 避免高并发导致写入峰值过大
    MAX_JOBS=1 \
    # 限制编译的 CUDA 架构，按需修改（例如 7.5 为 T4）
    TORCH_CUDA_ARCH_LIST="7.5"

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
#    关键：把 pip 缓存和 build 目录挂到 BuildKit cache，聚合临时目录并减重
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/workspace/.build \
    bash -lc 'mkdir -p /workspace/.build/tmp && python -m pip install -v -e . && rm -rf build'

# 7) 安装 Orion 项目额外依赖
RUN --mount=type=cache,target=/root/.cache/pip \
    bash -lc 'if [ -f requirements.txt ]; then python -m pip install -r requirements.txt; fi'

# 8) 安装 CARLA 0.9.15
RUN python -m pip install --no-cache-dir carla==0.9.15

# 清理可能的残留缓存（进一步减小层）
RUN rm -rf /root/.cache/pip /root/.cache/torch_extensions || true

CMD ["/bin/bash"]

