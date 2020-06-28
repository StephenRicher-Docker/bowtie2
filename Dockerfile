#################### BASE IMAGE ######################

FROM python:3.8-slim AS download

#################### METADATA ########################

LABEL base.image="python:3.8-slim"
LABEL version="1"
LABEL software="Bowtie2"
LABEL software.version="2.4.1"
LABEL about.summary="Bowtie 2: fast and sensitive read alignment."
LABEL about.home="https://github.com/BenLangmead/bowtie2"
LABEL about.documentation="https://github.com/BenLangmead/bowtie2/blob/master/README.md"
LABEL license="https://github.com/BenLangmead/bowtie2/blob/master/LICENSE"
LABEL about.tags="Genomics"

#################### MAINTAINER ######################

MAINTAINER Stephen Richer <sr467@bath.ac.uk>

#################### DOWNLOAD ########################

ENV URL=https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.1/bowtie2-2.4.1-source.zip/download

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl unzip
RUN curl -L $URL > bowtie2.zip && \
    unzip bowtie2.zip && \
    rm bowtie2.zip

#################### BUILD ###########################

FROM python:3.8-slim AS build

COPY --from=download /tmp /tmp

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libtbb-dev \
      libperl-dev \
      zlib1g-dev
RUN cd /tmp/* && \
    make && \
    make install

#################### FINALISE ########################

FROM python:3.8-slim

COPY --from=build /usr/local/bin /usr/local/bin

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libtbb-dev \
      libperl-dev \
      zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --home-dir /home/guest \
      --uid 1000 --gid 100 --shell /bin/bash guest

USER guest

CMD ["bowtie2"]
