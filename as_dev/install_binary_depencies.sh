#!/bin/bash
set -o errexit
set -o pipefail

# update in case of containers which have had no update run at all
apt-get update
# fetch required components for custom package repositories
apt-get install -y apt-transport-https gnupg ca-certificates wget
wget https://dl.secondarymetabolites.org/antismash-bullseye.list -P /etc/apt/sources.list.d
wget https://dl.secondarymetabolites.org/antismash.asc -P /etc/apt/trusted.gpg.d
# update with the newly added repo
apt-get update
# then install everything
apt-get install -y \
    curl \
    diamond-aligner \
    fasttree \
    git \
    glimmerhmm \
    hmmer \
    hmmer2 \
    meme-suite \
    ncbi-blast+ \
    openmpi-bin \
    prodigal \
    python3-venv \
    python3-dev \
    python3-pip
