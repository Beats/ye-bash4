#!/bin/bash
##
# Beats BASH Framework
##

[ ${BASH_VERSINFO[0]} -lt 4 ] && echo "Requires Bash4 to be used" && exit 2

YE_BASH4_VERSION="0.1"

SCRIPT_FILE=$(cd `dirname "$0"` && pwd)/`basename "$0"`
SCRIPT_NAME=${0##*/}
SCRIPT_HOME=${0%/*}

VERSION=
##
# Constants
##
declare -r YE_BASH4_TYPE_A=-1
declare -r YE_BASH4_TYPE_F=0
declare -r YE_BASH4_TYPE_R=1
declare -r YE_BASH4_TYPE_O=2

##
# Parameters
##
declare -A YE_BASH4_OPTIONS
declare -A YE_BASH4_OPTION_USAGE

declare -A YE_BASH4_PARAMETER
declare -A YE_BASH4_PARAMETER_TYPE

declare -a YE_BASH4_COMPONENT_A
declare -a YE_BASH4_COMPONENT_F
declare -a YE_BASH4_COMPONENT_R
declare -a YE_BASH4_COMPONENT_O

YE_BASH4_ACTION=

##
# Utilities
##
function join {
  local IFS="$1"; shift; echo "$*";
}

ye_bash4_is_function() {
  declare -f "$1" > /dev/null;
  return $((1 -$?))
}

ye_bash4_register_a() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  for arg in "$@"; do
    case "$arg" in
      --*) __optL="$arg";;
      -*) __optS="$arg";;
      *) __text="$arg";;
    esac
  done

  ye_bash4_register "$YE_BASH4_TYPE_A" "$__name" "$__optS" "$__optL" "$__text"
}

ye_bash4_register_f() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  for arg in "$@"; do
    case "$arg" in
      --*) __optL="$arg";;
      -*) __optS="$arg";;
      *) __text="$arg";;
    esac
  done

  ye_bash4_register "$YE_BASH4_TYPE_F" "$__name" "$__optS" "$__optL" "$__text"
}

ye_bash4_register_r() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  for arg in "$@"; do
    case "$arg" in
      --*) __optL="$arg";;
      -*) __optS="$arg";;
      *) __text="$arg";;
    esac
  done

  ye_bash4_register "$YE_BASH4_TYPE_R" "$__name" "$__optS" "$__optL" "$__text"
}

ye_bash4_register_o() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  for arg in "$@"; do
    case "$arg" in
      --*) __optL="$arg";;
      -*) __optS="$arg";;
      *) __text="$arg";;
    esac
  done

  ye_bash4_register "$YE_BASH4_TYPE_O" "$__name" "$__optS" "$__optL" "$__text"
}

ye_bash4_register() {
  local __type="$1"
  local __name="$2"
  local __optS="$3"
  local __optL="$4"
  local __text="$5"

  ye_bash4_normalize_options() {
    local __optS="$1"
    local __optL="$2"
    local __delimiter="$3"
    if [ -z "$__delimiter" ]; then
      __delimiter="|"
    fi

      if [ -z "$__optS" ]; then
      printf "%s" "$__optL"
    elif [ -z "$__optL" ]; then
      printf "%s" "$__optS"
    else
      printf "%s" "$__optS$__delimiter$__optL"
    fi
  }

  ye_bash4_format_usage() {
    local __optS="$1"
    local __optL="$2"
    local __text="$3"
    local __opts=`ye_bash4_normalize_options "$__optS" "$__optL" ", "`
    echo -e "  $__opts\n      $__text\n"
  }

  if [ -z "$__optS" -a -z "$__optL" ]; then
    echo "Invalid option registration for: $__name" && exit 1;
  fi

  case "$__type" in
    "$YE_BASH4_TYPE_A")
      YE_BASH4_COMPONENT_A+=($__name)
    ;;
    "$YE_BASH4_TYPE_F")
      YE_BASH4_COMPONENT_F+=($__name)
    ;;
    "$YE_BASH4_TYPE_R")
      YE_BASH4_COMPONENT_R+=($__name)
    ;;
    "$YE_BASH4_TYPE_O")
      YE_BASH4_COMPONENT_O+=($__name)
    ;;
  esac

  YE_BASH4_PARAMETER[$__name]="`ye_bash4_normalize_options "$__optS" "$__optL"`"
  YE_BASH4_PARAMETER_TYPE[$__name]=$__type
  YE_BASH4_OPTION_USAGE[$__name]="`ye_bash4_format_usage "$__optS" "$__optL" "$__text"`
"
}

##
# Flags
##
ye_bash4_register $YE_BASH4_TYPE_F "F_VERBOSE" "-v" "--verbose" "Explain what is being done"
F_VERBOSE=0

ye_bash4_register $YE_BASH4_TYPE_F "F_DEBUG" "" "--debug" "Display debugging information"
F_DEBUG=0

##
# Default actions
##
ye_bash4_register $YE_BASH4_TYPE_A "version" "" "--version" "Display the script version"
ye_bash4_is_function "version"
if [ $? -eq 0 ]; then
  version() {
    echo "$SCRIPT_NAME v$VERSION"
    echo
  }
fi

ye_bash4_register $YE_BASH4_TYPE_A "usage" "-h" "--help" "Display this usage text"
ye_bash4_is_function "usage"
if [ $? -eq 0 ]; then
  usage() {
    local __name=
    echo "Usage: $SCRIPT_NAME"
    echo "Options:"
    for __name in "${YE_BASH4_COMPONENT_R[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
    for __name in "${YE_BASH4_COMPONENT_O[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
    for __name in "${YE_BASH4_COMPONENT_F[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
    for __name in "${YE_BASH4_COMPONENT_A[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
  }
fi

ye_bash4_is_function "debug"
if [ $? -eq 0 ]; then
  debug() {
    local __name=
    echo "$SCRIPT_NAME: $VERSION"
    echo "Beats Ye-Bash4: $YE_BASH4_VERSION"
    echo "Action: $YE_BASH4_ACTION"
    echo "Flags:"
    for __name in "${YE_BASH4_COMPONENT_F[@]}"; do
      echo -n "  $__name:"; eval echo \$$__name
    done
    echo "Required:"
    for __name in "${YE_BASH4_COMPONENT_R[@]}"; do
      echo -n "  $__name:"; eval echo \$$__name
    done
    echo "Optional:"
    for __name in "${YE_BASH4_COMPONENT_O[@]}"; do
      echo -n "  $__name:"; eval echo \$$__name
    done
    if [ $F_VERBOSE -ne 0 ]; then
      echo "Script:"
      echo "  Name: $SCRIPT_NAME"
      echo "  Home: $SCRIPT_HOME"
      echo "  File: $SCRIPT_FILE"
    fi;
  }
fi

##
# Default execution loop
##
ye_bash4_run() {

  ye_bash4_option_parser() {

    ye_bash4_option_processor() {
      local __component=$1
      local __opts=$2
      local __handler=$3
      local __modifier=$4


      local __option=
      local __options=(${__opts//\|/ })

      for __option in "${__options[@]}"; do
        YE_BASH4_OPTIONS[$__option]="$__component|$__handler"
        case "$__option" in
          -?)
            OPTS_S+=("${__option:1}$__modifier")
          ;;
          --*)
            OPTS_L+=("${__option:2}$__modifier")
          ;;
        esac
      done
    }

    ye_bash4_option_processor_p() {
      local __component=$1
      local __opts=$2
      local __type=$3
      local __handler=
      local __modifier=""

      case "$__type" in
        "$YE_BASH4_TYPE_A")
          __handler="ye_bash4_action"
          __modifier=""
        ;;
        "$YE_BASH4_TYPE_F")
          __handler="ye_bash4_flag"
          __modifier=""
        ;;
        "$YE_BASH4_TYPE_R")
          __handler="ye_bash4_parameter"
          __modifier=":"
        ;;
        "$YE_BASH4_TYPE_O")
          __handler="ye_bash4_parameter"
          __modifier="::"
        ;;
      esac

      ye_bash4_option_processor "$__component" "$__opts" "$__handler" "$__modifier"
    }

    local __key=
    for __key in "${!YE_BASH4_PARAMETER[@]}"; do
      ye_bash4_option_processor_p "$__key" "${YE_BASH4_PARAMETER[$__key]}" "${YE_BASH4_PARAMETER_TYPE[$__key]}"
    done

    OPTS_S=`join "" "${OPTS_S[@]}"`
    OPTS_L=`join , "${OPTS_L[@]}"`
  }

  OPTS_L=()
  OPTS_S=()
  ye_bash4_option_parser

  local ARGUMENTS=

  ARGUMENTS=`getopt -o "$OPTS_S" -l "$OPTS_L" -n "$SCRIPT_NAME" -q -- "$@"`
  if [ $? -ne 0 ]; then
    usage
    return 0
  fi

  eval set -- "$ARGUMENTS"

  ye_bash4_action() {
    if [ -z "$YE_BASH4_ACTION" ]; then
      YE_BASH4_ACTION="$1"
      return 1
    else
      YE_BASH4_ACTION="usage"
      return 0
    fi
  }

  ye_bash4_parameter() {
    local __param=$1
    if [ ! -z "$2" ]; then
      eval "$__param=\"$2\""
    fi
    return 2
  }

  ye_bash4_flag() {
    local __param=$1
    eval $__param=$((1 - $__param))
    return 1
  }

  ye_bash4_option_handler() {
    local __option="$1"
    local __return=0

    if [[ "$__option" == "--" ]]; then
      __return=0
    else
      local __pattern=${YE_BASH4_OPTIONS["$__option"]}
      local __options=(${__pattern//\|/ })
      local __component=${__options[0]}
      local __handler=${__options[1]}

      $__handler $__component "$2"
      __return=$?
      unset YE_BASH4_OPTIONS[$__option]
    fi

    return $__return
  }

  ACTION=
  local __loop=
  while true; do

    ye_bash4_option_handler "$1" "$2"
    __loop=$?
    if [ $__loop -gt 0 ]; then
      shift $__loop
    elif [ $__loop -eq 0 ]; then
      break
    fi

  done

  if [ -z "$YE_BASH4_ACTION" ]; then
    YE_BASH4_ACTION="usage"
  fi

  if [ $F_DEBUG -ne 0 ]; then
    debug
  else
    $YE_BASH4_ACTION
  fi
}

