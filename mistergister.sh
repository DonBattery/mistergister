#!/bin/bash
#
# +----------------------------+
# | DonBattery's Mister Gister |
# +----------------------------+
#
# Mister Gister is a CLI Client for your GitHub Gists
#

# Set basic variables
scriptName=`basename $0` #Set Script Name variable
scriptBasename="$(basename ${scriptName} .sh)" # Strips '.sh' from scriptName
version="0.1.0"
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set Flags
quiet=false
verbose=false
debug=false
args=()

# Set more flags
listGists=false

# Styles
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)
cyan=$(tput setaf 14)

# Main printer function
function _alert() {
  if [ "${1}" = "emergency" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "warning" ]; then local color="${red}"; fi
  if [ "${1}" = "success" ]; then local color="${green}"; fi
  if [ "${1}" = "debug" ]; then local color="${purple}"; fi
  if [ "${1}" = "header" ]; then local color="${bold}""${tan}"; fi
  if [ "${1}" = "input" ]; then local color="${bold}"; printLog="false"; fi
  if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then local color=""; fi

  # Don't use colors on pipes or non-recognized terminals
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then color=""; reset=""; fi

  # Print to console when script is not 'quiet'
  if [[ "${quiet}" = "true" ]] || [ "${quiet}" == "1" ]; then
   return
  else
   echo -e "$(date +"%r") ${color}$(printf "[%9s]" "${1}") ${_message}${reset}";
  fi
}

function safeExit() {
  trap - INT TERM EXIT
  exit
}

function die ()       { local _message="${*} Exiting."; echo "$(_alert emergency)"; safeExit; }
function error ()     { local _message="${*}"; echo "$(_alert error)"; }
function warning ()   { local _message="${*}"; echo "$(_alert warning)"; }
function notice ()    { local _message="${*}"; echo "$(_alert notice)"; }
function info ()      { local _message="${*}"; echo "$(_alert info)"; }
function debug ()     { local _message="${*}"; echo "$(_alert debug)"; }
function success ()   { local _message="${*}"; echo "$(_alert success)"; }
function input()      { local _message="${*}"; echo -n "$(_alert input)"; }
function header()     { local _message="========== ${*} ==========  "; echo "$(_alert header)"; }

# Log messages when verbose is set to "true"
verbose() {
  if [[ "${verbose}" = "true" ]] || [ "${verbose}" == "1" ]; then
    debug "$@"
  fi
}

listMyGists() {
  curl -s https://api.github.com/users/DonBattery/gists | jq -r '.[] | {ID: .id, Description: .description}'
}

mainScript() {
  if [[ "${listGists}" = "true" ]] || [ "${listGists}" == "1" ]; then
    listMyGists
  fi
}

# Print usage
usage() {
  echo -n "
${cyan}${bold}Mister Gister
  the GitHub Gist helper${reset}

${scriptName} [OPTION]... [FILE]...

 ${bold}Options:${reset}
  -h, --help        Display this help and exit
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -q, --quiet       Quiet (no output)

  -l, --list        List Gists

      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
[[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    --version) echo "Mister Gister ${version}"; safeExit ;;
    -v|--verbose) verbose=true ;;
    -q|--quiet) quiet=true ;;
    -d|--debug) debug=true ;;
    -l|--list) listGists=true ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$'\n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Run your script
mainScript

# Exit cleanlyd
safeExit