FROM rocker/r-ver:4.6.0

# ---- 1. System dependencies -------------------------------------------------
# Covers the headers needed to *compile* the packages in renv.lock
# (curl, ssl, xml2, fonts/harfbuzz for text shaping, V8 for the V8 R package,
# git for renv/remotes installs from GitHub, etc).
# If renv::restore() below fails on a missing header, add the matching
# -dev package here and rebuild — the error message names the library.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    pandoc \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    libv8-dev \
    libsodium-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# install Quarto CLI (system-wide, fine to install as root)
ARG QUARTO_VERSION=1.7.31
RUN curl -Lo /tmp/quarto.deb \
      "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/quarto.deb \
    && rm -rf /tmp/quarto.deb /var/lib/apt/lists/*

# create non-root user up front
# quarto tracks tools per user -> therefore tools need to be installed as user, not as root
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} rstudio || true \
    && useradd -m -u ${UID} -g ${GID} rstudio || true

WORKDIR /project
RUN chown rstudio:rstudio /project
USER rstudio

# install TinyTeX
RUN quarto install tinytex --no-prompt

# TinyTeX's default install doesn't include German babel/hyphenation
# needed because index.qmd renders with lang: de-DE

# note to future user: add additional missing latex packages here
ENV PATH="/home/rstudio/.TinyTeX/bin/x86_64-linux:${PATH}"
RUN tlmgr update --self \
    && tlmgr install babel-german hyphen-german

# create R environment

# for live development keep renv package library outside /project.
# do not use /opt for this as it is owned by root and user might not have permissions
# if renv package library is inside /project no live development will be possible!
ENV RENV_PATHS_LIBRARY=/home/rstudio/.renv-library

# copy only the files renv needs first, so this expensive layer is cached
# and doesn't get invalidated every time an .R or .qmd file is changed
COPY --chown=rstudio:rstudio .Rprofile renv.lock ./
COPY --chown=rstudio:rstudio renv/activate.R renv/settings.json renv/

RUN R -e "options(renv.consent = TRUE); renv::restore()"

# add project files
# baked in as a fallback snapshot so the image works standalone if you
# DON'T mount anything. At runtime, mounting your live repo over /project
# (see README/usage notes) overrides these with your current work.
COPY --chown=rstudio:rstudio . .

CMD ["quarto", "render", "index.qmd", "--to", "pdf"]
