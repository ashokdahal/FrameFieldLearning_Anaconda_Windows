
#FROM pytorch/pytorch:1.2-cuda10.0-cudnn7-devel
# FROM pytorch/pytorch:1.4-cuda10.1-cudnn7-devel
FROM  pytorch/pytorch:1.7.0-cuda11.0-cudnn8-devel

MAINTAINER Nicolas Girard <nicolas.jp.girard@gmail.com>

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    apt-get install -y git

RUN apt-get install -y \
    libgtk2.0 \
    fish

RUN pip install pyproj

# nano
RUN apt-get install nano

# Install gdal
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository ppa:ubuntugis/ubuntugis-unstable
RUN apt-get update
RUN apt-get install -y libgdal-dev
# See https://gist.github.com/cspanring/5680334:
RUN pip install gdal==$(gdal-config --version) --global-option=build_ext --global-option="-I/usr/include/gdal/"

# Install overpy
RUN pip install overpy

# Install shapely
RUN pip install Shapely

RUN pip install jsmin

# Install tqdm for terminal progress bar
RUN pip install tqdm

# Install Jupyter notebook
RUN pip install jupyterlab

# Install sklearn
RUN pip install scikit-learn

# Install multiprocess in replacement to the standard multiprocessing which does not allow methods to be serialized
RUN pip install multiprocess

# Instal Kornia: Open Source Differentiable Computer Vision Library for PyTorchp
RUN pip install git+https://github.com/Lydorn/kornia@7bcb52125917eedee867ec93ed56c289019bd7d2

# Install rasterio
RUN pip install rasterio

# Install skimage
RUN pip install scikit-image

# Install Tensorboard
#RUN conda install -c anaconda absl-py
RUN pip install tensorboard

# Install geojson
RUN pip install geojson

# Install fiona
RUN pip install fiona

# Install pycocotools
RUN pip install -U --no-cache-dir cython
RUN pip install --no-cache-dir "git+https://github.com/cocodataset/cocoapi.git#egg=pycocotools&subdirectory=PythonAPI"

# Install pip install tifffile
RUN pip install tifffile

# Downgrade Pillow so that it works with PyTorch 1.1
# RUN pip install "Pillow<7.0.0"
RUN pip install Pillow

# Install future for tensorboard
RUN pip install future

# Descartes for plotting shapely polygons
RUN pip install descartes

# OpenCV:
RUN apt-get install -y libgl1-mesa-glx
RUN conda update -n base -c defaults conda
RUN conda install -c conda-forge opencv=4.5.0

# Skan
RUN conda install -c conda-forge skan

# Numba
RUN conda install -c anaconda numba=0.48.0
# torch-scatter
RUN pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-1.7.0+cu110.html

#install apex

WORKDIR /tmp/unique_for_apex
# uninstall Apex if present, twice to make absolutely sure :)
RUN pip uninstall -y apex || :
RUN pip uninstall -y apex || :
# SHA is something the user can touch to force recreation of this Docker layer,
# and therefore force cloning of the latest version of Apex
RUN SHA=ToUcHMe git clone https://github.com/NVIDIA/apex.git
WORKDIR /tmp/unique_for_apex/apex
RUN pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .

# Cleanup
RUN apt-get clean && \
    apt-get autoremove

COPY start_jupyter.sh /

#WORKDIR /app

# Create mountpoints and tempfolders for using blobfuse
RUN mkdir /mnt/blobfusetmp-tilesbron -p \
        && mkdir /tilesbron -p \
        && mkdir /mnt/blobfusetmp-tilesin -p \
        && mkdir /tilesin -p \
        && mkdir /mnt/blobfusetmp-tilesout -p \
        && mkdir /tilesout -p

WORKDIR /usr/src/app

#ADD requirements.txt ./

#RUN pip3 install --no-cache-dir -r requirements.txt

ADD . ./

ENV AZURE_STORAGE_ACCOUNT=beeldmateriaal
ENV AZURE_STORAGE_ACCESS_KEY=Rr1XipIE4C0bfmKMrOZsSLbRw5wJrV4TxVsUliPbG6F2a6PX4PLgR9O+PPr7J6qnsuvytZRJTNICQ0I3Lxa1mA==

CMD fish
