#!/bin/bash

set -o errexit
set -o pipefail

# Commands
GIT="${GIT:-git}"
PODMAN="${PODMAN:-podman}"
PYTHON="${PYTHON:-python3}"

# Directories
ASDB_ENV="${ASDB_ENV:-asdb_env}"
BOOTSTRAP_DIR=$(dirname -- "$(readlink -f -- "$0")")


if [[ -z $VIRTUAL_ENV ]]; then
    if [[ -d $ASDB_ENV ]]; then
        echo "> > > Using existing environment $ASDB_ENV"
        source "${ASDB_ENV}/bin/activate"
    else
        echo "> > > Creating new environment $ASDB_ENV"
        ${PYTHON} -m venv "${ASDB_ENV}"
        source "${ASDB_ENV}/bin/activate"
    fi
else
    echo "> > > Using the currently active virtual environment $VIRTUAL_ENV"
fi

fetch_if_missing() {
    DIRNAME="$1"
    REPO="$2"
    if [[ ! -d $DIRNAME ]]; then
        echo "> > > Cloning $REPO"
        ${GIT} clone "$REPO" "$DIRNAME"
    fi
}

fetch_if_missing antismash git@github.com:antismash/antismash.git
fetch_if_missing schema git@github.com:antismash/db-schema.git
fetch_if_missing import git@github.com:antismash/db-import.git
fetch_if_missing api git@github.com:antismash/db-api.git
fetch_if_missing ui git@github.com:antismash/db-ui-components.git

pushd antismash > /dev/null
echo "> > > Installing antiSMASH"
pip install -e ".[testing]"
popd > /dev/null

echo "> > > Installing db-import"
pip install -r import/requirements.txt

pushd api > /dev/null
echo "> > > Installing asdb API"
pip install -e "."
popd > /dev/null

pushd ui > /dev/null
echo "> > > Installing asdb ui"
yarn install
popd > /dev/null

if [ "$(${PODMAN} pod ps | grep -c asdb )" == "0" ]; then
    echo "> > > Starting PostgreSQL pod"
    ${PODMAN} play kube "${BOOTSTRAP_DIR}/postgres.yml"
else
    echo "asdb pod is already running. Re-create it? Y/N"
    read -r input
    if [[ $input == "Y" ]] || [[ $input == "y" ]]; then
        ${PODMAN} pod rm asdb -f
        ${PODMAN} play kube "${BOOTSTRAP_DIR}/postgres.yml"
    else
        echo "Leaving the bootstrap flow"
        exit 0
    fi
fi

echo "> > > Waiting for PostgreSQL to start"
until ${PODMAN} exec asdb-postgres psql -U postgres -c '\list'
do
    echo "> > > > PostgreSQL is not ready, waiting..."
    sleep 1
done
