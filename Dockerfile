# 使用 NVIDIA 官方 CUDA 11.8 + Ubuntu20.04 基础镜像
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# 环境变量设置（避免交互安装，保证Python输出直接刷新）
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TORCH_CUDA_VERSION=cu118

# 1. 基础工具安装
RUN apt-get update && apt-get install -y \
    git \
    python3.8 \
    python3.8-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. 设置 python3.8 为默认 python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# 3. 工作目录
WORKDIR /workspace

# 4. 克隆 Orion 项目 (直接从上游仓库拉取代码)
RUN git clone https://github.com/xiaomi-mlab/Orion.git .

# 5. 安装 PyTorch GPU 版本（与 cu118 匹配）
RUN pip install --no-cache-dir torch==2.4.1+cu118 torchvision==0.19.1+cu118 torchaudio==2.4.1 \
    --index-url https://download.pytorch.org/whl/cu118

# 6. 安装 Orion 项目 (editable mode)
RUN pip install -v -e .

# 7. 安装项目额外依赖
RUN pip install --no-cache-dir -r requirements.txt

# 8. 容器默认启动命令（可以进入 bash 交互）
CMD ["/bin/bash"]

