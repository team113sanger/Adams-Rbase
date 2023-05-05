FROM rocker/r-base:4.2.2

USER  root

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
       libssl-dev libxml2-dev libcurl4-openssl-dev libmagick++-dev libharfbuzz-dev libfribidi-dev cmake libpoppler-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

ENV RENV_VERSION 0.17.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /project
COPY renv.lock renv.lock
RUN R -e "renv::init(bioconductor = '3.16')"
RUN R -e "renv::restore()"
