FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    CONDA_DIR=/opt/conda \
    PYTHONPATH=/sd/

WORKDIR /sd

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y libglib2.0-0 wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda
RUN wget -O ~/miniconda.sh -q --show-progress --progress=bar:force https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

COPY . /sd/

# Install the conda environment
RUN conda env create -f /sd/environment.yaml && echo "source activate ldm" > /root/.bashrc && conda clean --all

# Download the models
RUN ./download_models.sh

# Install font for prompt matrix
COPY ./data/DejaVuSans.ttf /usr/share/fonts/truetype/

EXPOSE 7860 8501

ENTRYPOINT conda run -n ldm python /sd/scripts/webui.py
CMD