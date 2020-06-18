#! /usr/bin/env bash
set -e

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${TOPDIR}/scripts/apollo.bashrc"

function clean() {
    local stage="$1"; shift

    if ! "${APOLLO_IN_DOCKER}" ; then
        error "The clean operation must be run from within docker container"
        exit 1
    fi
    bazel clean --async

    docs_sh="${TOPDIR}/scripts/apollo_docs.sh"
    if [ -f "${docs_sh}" ]; then
        bash "${docs_sh}" clean "${stage}"
    fi

    if [ "${stage}" != "dev" ]; then
        success "Apollo cleanup done."
        return
    fi

    # Remove bazel cache in associated directories
    if [ -d /apollo-simulator ]; then
        pushd /apollo-simulator >/dev/null
            bazel clean --async
        popd >/dev/null
    fi
    success "Done $0 ${stage}."
}

function main() {
    local stage="${1:-dev}"
    clean "${stage}"
}

main "$@"
