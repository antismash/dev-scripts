#!/bin/bash
set -o errexit
set -o pipefail

PYTHON=python3
AS_ENV="${AS_ENV:-env}"
AS_DATA="${AS_DATA:-$AS_ENV/antismash/databases}"

SCRIPT_DIR=$(dirname $0)

ensure_env() {
    env=$1
    if [[ -d $env ]]; then
        echo "> > > Using existing environment $env"
    else
        echo "> > > Creating new environment $env"
        ${PYTHON} -m venv "${env}"
    fi  
}

# glimmerhmm is the most awkward dependency, so if it's present, then assume
# the rest are present
which glimmerhmm || sudo $SCRIPT_DIR/install_binary_dependencies.sh

# build the environment if not already in one
if [[ -z $VIRTUAL_ENV ]]; then
    ensure_env $AS_ENV
    source $AS_ENV/bin/activate
fi

# grab the source
git clone https://github.com/antismash/antismash.git src

# copy the git hooks into the source
cp $SCRIPT_DIR/git_hooks/* src/.git/hooks/.

# install the source
pushd src
pip install -U pip
pip install -e .[testing]
download-antismash-databases --data $AS_DATA
popd

# save the database path to an instance config file
antismash --write-config-file src/antismash/config/instance.cfg --data $AS_DATA

# ensure everything is fine
antismash --check-prereqs
