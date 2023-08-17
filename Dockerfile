FROM rocker/r-base:4.2.2

USER root

ENV REMOTES_VERSION 2.4.2
ENV RENV_VERSION 0.17.3
ENV BIOCMANAGER_VERSION 1.30.20
ENV BIOCONDUCTOR_VERSION 3.16

ENV RENV_CONFIG_CONNECT_TIMEOUT=120
ENV RENV_CONFIG_CONNECT_RETRY=5
RUN R -e "options('download.file.method'='curl', 'timeout'=120)"

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
       libssl-dev libxml2-dev libcurl4-openssl-dev libmagick++-dev libharfbuzz-dev \
       libfribidi-dev cmake libpoppler-cpp-dev libv8-dev libnlopt-dev \
       unattended-upgrades && \
    unattended-upgrade -d -v && \
    apt-get remove -yq unattended-upgrades && \
    apt-get autoremove -yq && \
    rm -rf /var/lib/apt/lists/*

ENV OPT="/opt/rbase"
ENV PATH="${OPT}/bin:$PATH"

RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/remotes/remotes_${REMOTES_VERSION}.tar.gz', repos=NULL, type='source')"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
RUN R -e "remotes::install_version(package = 'BiocManager', version = '${BIOCMANAGER_VERSION}')"

ENV RENV_PATHS_ROOT="${OPT}"
WORKDIR "${OPT}"

COPY renv.lock renv.lock
RUN R -e "renv::init(bioconductor = '${BIOCONDUCTOR_VERSION}', force = TRUE, settings = list(use.cache = TRUE), bare = TRUE, restart = TRUE)"
RUN R -e "renv::restore()"

RUN useradd rbase --shell /bin/bash --create-home --home-dir /home/rbase

RUN chmod a+rw /usr/local/lib/R/site-library
RUN chown rbase /home/rbase

USER rbase
ENV RENV_PATHS_ROOT="${OPT}"
WORKDIR /home/rbase
COPY renv.lock renv.lock
RUN R -e "renv::restore()"

RUN R --version && \
    R --slave -e 'packageVersion("BiocManager")' && \
    R --slave -e 'packageVersion("biomaRt")' && \
    R --slave -e 'packageVersion("BSgenome")' && \
    R --slave -e 'packageVersion("chimeraviz")' && \
    R --slave -e 'packageVersion("colourpicker")' && \
    R --slave -e 'packageVersion("cowplot")' && \
    R --slave -e 'packageVersion("data.table")' && \
    R --slave -e 'packageVersion("devtools")' && \
    R --slave -e 'packageVersion("ensembldb")' && \
    R --slave -e 'packageVersion("extrafont")' && \
    R --slave -e 'packageVersion("GenomicRanges")' && \
    R --slave -e 'packageVersion("GetoptLong")' && \
    R --slave -e 'packageVersion("ggpubr")' && \
    R --slave -e 'packageVersion("ggrepel")' && \
    R --slave -e 'packageVersion("ggsci")' && \
    R --slave -e 'packageVersion("ggvenn")' && \
    R --slave -e 'packageVersion("gridBase")' && \
    R --slave -e 'packageVersion("gridExtra")' && \
    R --slave -e 'packageVersion("IRanges")' && \
    R --slave -e 'packageVersion("markdown")' && \
    R --slave -e 'packageVersion("optparse")' && \
    R --slave -e 'packageVersion("pdftools")' && \
    R --slave -e 'packageVersion("pheatmap")' && \
    R --slave -e 'packageVersion("plotly")' && \
    R --slave -e 'packageVersion("randomcoloR")' && \
    R --slave -e 'packageVersion("RColorBrewer")' && \
    R --slave -e 'packageVersion("reshape2")' && \
    R --slave -e 'packageVersion("rmarkdown")' && \
    R --slave -e 'packageVersion("scales")' && \
    R --slave -e 'packageVersion("tidyverse")' && \
    R --slave -e 'packageVersion("viridis")' && \
    R --slave -e 'packageVersion("XML")' && \
    R --slave -e 'packageVersion("xml2")' && \
    R --slave -e 'packageVersion("org.Hs.eg.db")' && \
    R --slave -e 'packageVersion("BSgenome.Hsapiens.NCBI.GRCh38")'

USER root

RUN chmod -R a+rwx /home/rbase
RUN chmod -R a+rwx /opt/rbase

USER rbase

CMD ["/bin/bash"]
