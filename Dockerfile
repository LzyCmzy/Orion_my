# 基础镜像：NVIDIA 官方 CUDA + Ubuntu
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# 安装必要工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 Miniconda
ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && rm /tmp/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# 创建并激活 Conda 环境
RUN conda create -n orion python=3.8 -y
SHELL ["conda", "run", "-n", "orion", "/bin/bash", "-c"]

# 克隆项目
WORKDIR /app
RUN git clone https://github.com/xiaomi-mlab/Orion.git .
# 切换到子目录（假设项目需要）
WORKDIR /app/ORION

# 安装 PyTorch CUDA 11.8 版本
RUN conda run -n orion pip install torch==2.4.1+cu118 torchvision==0.19.1+cu118 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu118

# 安装项目（可编辑模式）
RUN conda run -n orion pip install -v -e .

# 安装 requirements.txt
RUN conda run -n orion pip install -r requirements.txt

# 设置容器启动命令（进入 Conda 环境）
CMD ["conda", "run", "-n", "orion", "python", "main.py"]
