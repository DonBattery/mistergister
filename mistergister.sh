#!/bin/bash

# +--------------------------+
# |DonBattery's Mister Gister|
# +--------------------------+
#
# A collection of BASH functions to help you manage your GitHub Gists
# from the commandline


# Return if Mister Gister is already sourced
# [ -n "${MRGISTER_VERSION:-}" ] && return 0
MRGISTER_VERSION="0.1.0"

MRGISTER_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
