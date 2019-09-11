# CyTOF pipe install
FROM continuumio/miniconda3:4.3.27p0

RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND='noninteractive' apt-get install -y \
               build-essential \
               libhdf5-serial-dev \
               libcairo2-dev

# Establish an R-worthy environment
RUN conda install -c conda-forge r-base=3.6.1 \
                                 r-essentials=3.6 \
                                 r-devtools=2.2.0 \
                                 r-biocmanager=1.30.4 \
                                 python=3.7


# Rhdf5 does some weird stuff looking for zlib. This comment looks like it has a fix:
# https://github.com/grimbough/Rhdf5lib/issues/21#issuecomment-515640255
RUN R -e "devtools::install_github('grimbough/Rhdf5lib@8799fb0')"

RUN conda install -c conda-forge r-xml=3.98_1.20

# Now we have an environment capable of supporting the CATALYST package

RUN R -e "BiocManager::install('CATALYST')" 
RUN R -e "BiocManager::install('HDCytoData')" 

# Now lets set up the rest of the environment we may want

RUN pip install cython cmake && \
    pip install tables pandas numpy scipy scikit-learn h5py openpyxl MulticoreTSNE umap-learn matplotlib plotnine[all] seaborn jupyterlab

RUN mkdir .local \
    && chmod -R 777 .local \
    && mkdir .jupyter \
    && chmod -R 777 .jupyter \
    && chmod -R o=u /opt/conda/lib/R/library \
    && mkdir /work

WORKDIR /work


CMD ["jupyter","lab","--ip=0.0.0.0","--port=8888","--allow-root"]