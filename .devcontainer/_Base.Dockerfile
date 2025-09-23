# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Software versions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Ruby version to use
ARG RUBY_VERSION=3.4.3-bookworm

# https://nodejs.org/en/download
ARG NODE_VERSION=22.15.0
# https://www.npmjs.com/package/npm
ARG NPM_VERSION=11.3.0
# https://github.com/nvm-sh/nvm/releases
ARG NVM_VERSION=0.40.3

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | MAIN
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM --platform=$BUILDPLATFORM ruby:${RUBY_VERSION}

ARG TARGETARCH
ARG BUILDPLATFORM
ARG RUBY_VERSION
ARG NODE_VERSION
ARG NPM_VERSION
ARG NVM_VERSION

RUN echo "$BUILDPLATFORM" > /BUILDPLATFORM
RUN echo "$TARGETARCH" > /TARGETARCH
RUN echo "$RUBY_VERSION" > /RUBY_VERSION

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install all required packages:
#
# Build tools:
#   - build-essential: Essential compilation tools (gcc, make, etc.)
#
# Network tools:
#   - wget: Tool for non-interactive file downloads
#   - curl: Command line for transferring data with URL syntax
#   - telnet: Telnet client for network debugging
#
# Shell:
#   - bash: Bourne Again SHell
#
# System tools:
#   - cron: Process scheduling daemon
#   - vim: Improved vi text editor
#   - procps: System and process monitoring utilities
#   - tree: Displays directory structure in a tree-like format
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    # Network tools
    wget \
    curl \
    telnet \
    # Shell
    bash \
    # System tools
    cron \
    vim \
    procps \
    tree \
    sudo \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "--login", "-c"]

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# NODE.JS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

ENV NVM_DIR="/opt/.nvm"
RUN mkdir -p /opt/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && npm install -g npm@${NPM_VERSION}
RUN . "$NVM_DIR/nvm.sh" && npm install -g yarn@latest
RUN . "$NVM_DIR/nvm.sh" && npm install -g svgo

# Add NVM binaries to PATH
ENV PATH="/opt/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Rails User Setup
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Create rails user and group with ID 1000
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Set ownership for Ruby and Node.js
RUN chown -R rails:rails /usr/local/bundle
RUN chown -R rails:rails /opt/.nvm

# Create app directory and set ownership
RUN mkdir -p /app && chown -R rails:rails /app

# Set editor for rails credentials
ENV EDITOR="vim"

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# ENVIRONMENT CHECKS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# copy ruby environment check script
COPY ruby-env.sh /root/ruby-env.sh
COPY ruby-env.sh /home/rails/ruby-env.sh
RUN chown rails:rails /home/rails/ruby-env.sh

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# FINAL CONFIGURATION
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Switch to rails user
USER rails:rails
WORKDIR /app/crypto-tracker