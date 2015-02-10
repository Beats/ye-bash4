#!/bin/bash
##
# Beats BASH Framework
##

[ ${BASH_VERSINFO[0]} -lt 4 ] && >&2 echo "Requires Bash v4" && exit 2

[ "$0" = "$BASH_SOURCE" ]
YE_BASH4_BUILDER=$?

YE_BASH4_SCRIPT_FILE=$(cd `dirname "$0"` && pwd)/`basename "$0"`
YE_BASH4_SCRIPT_NAME=${YE_BASH4_SCRIPT_FILE##*/}
YE_BASH4_SCRIPT_HOME=${YE_BASH4_SCRIPT_FILE%/*}
YE_BASH4_SCRIPT_VERSION="0.1"

##
# Constants
##
declare -r YE_BASH4_VERSION="0.1"
declare -r YE_BASH4_TYPE_F=-1
declare -r YE_BASH4_TYPE_C=-2
declare -r YE_BASH4_TYPE_A=1
declare -r YE_BASH4_TYPE_P=2

##
# Parameters
##
declare -A YE_BASH4_OPTIONS
declare -A YE_BASH4_OPTION_USAGE

declare -A YE_BASH4_PARAMETER
declare -A YE_BASH4_PARAMETER_TYPE

declare -a YE_BASH4_COMPONENT_C
declare -a YE_BASH4_COMPONENT_F
declare -a YE_BASH4_COMPONENT_P

declare -a YE_BASH4_ARGS
YE_BASH4_COMMAND=

##
# Utilities
##
ye_bash4_is_function() {
  declare -f "$1" > /dev/null;
  return $((1 -$?))
}

ye_bash4_parse_register_args() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --*) __optL="$arg";;
      -*) __optS="$arg";;
      *) __text="$arg";;
    esac
  done
}

ye_bash4_register_C() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  ye_bash4_parse_register_args "$@"
  ye_bash4_register "$YE_BASH4_TYPE_C" "$__name" "$__optS" "$__optL" "$__text"
}

ye_bash4_register_F() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  ye_bash4_parse_register_args "$@"
  ye_bash4_register "$YE_BASH4_TYPE_F" "$__name" "$__optS" "$__optL" "$__text"
}

ye_bash4_register_P() {
  local __name="$1"
  local __optS=""
  local __optL=""
  local __text=""
  shift;
  ye_bash4_parse_register_args "$@"
  ye_bash4_register "$YE_BASH4_TYPE_P" "$__name" "$__optS" "$__optL" "$__text"
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
    >&2 echo "Invalid option registration for: $__name"
    exit 1;
  fi

  case "$__type" in
    "$YE_BASH4_TYPE_C")
      YE_BASH4_COMPONENT_C+=($__name)
    ;;
    "$YE_BASH4_TYPE_F")
      YE_BASH4_COMPONENT_F+=($__name)
    ;;
    "$YE_BASH4_TYPE_P")
      YE_BASH4_COMPONENT_P+=($__name)
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
ye_bash4_register $YE_BASH4_TYPE_F "YE_BASH4_VERBOSE" "-v" "--verbose" "Explain what is being done"
YE_BASH4_VERBOSE=0

ye_bash4_register $YE_BASH4_TYPE_F "YE_BASH4_DEBUG" "" "--debug" "Display debugging information"
YE_BASH4_DEBUG=0

##
# Default actions
##
ye_bash4_register $YE_BASH4_TYPE_C "ye_bash4_version" "" "--version" "Display the script version"
ye_bash4_is_function "ye_bash4_version"
if [ $? -eq 0 ]; then
  ye_bash4_version() {
    echo "$YE_BASH4_SCRIPT_NAME v$YE_BASH4_SCRIPT_VERSION"
    echo
  }
fi

ye_bash4_register $YE_BASH4_TYPE_C "ye_bash4_usage" "-h" "--help" "Display this usage text"
ye_bash4_is_function "ye_bash4_usage"
if [ $? -eq 0 ]; then
  ye_bash4_usage() {
    local __name=
    echo "Usage: $YE_BASH4_SCRIPT_NAME"
    echo "Options:"
    for __name in "${YE_BASH4_COMPONENT_P[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
    for __name in "${YE_BASH4_COMPONENT_F[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
    for __name in "${YE_BASH4_COMPONENT_C[@]}"; do
      echo "${YE_BASH4_OPTION_USAGE[$__name]}"
    done
  }
fi

ye_bash4_is_function "ye_bash4_debug"
if [ $? -eq 0 ]; then
  ye_bash4_debug() {
    local __i=0
    local __name=
    echo "$YE_BASH4_SCRIPT_NAME: $YE_BASH4_SCRIPT_VERSION"
    echo "Beats Ye-Bash4: $YE_BASH4_VERSION"
    echo "Command: $YE_BASH4_COMMAND"
    echo "Flags:"
    for __name in "${YE_BASH4_COMPONENT_F[@]}"; do
      echo -n "  $__name:"; eval echo \$$__name
    done
    echo "Parameters:"
    for __name in "${YE_BASH4_COMPONENT_P[@]}"; do
      echo -n "  $__name:"; eval echo \$$__name
    done
    echo "Arguments:"
    for __name in "${YE_BASH4_ARGS[@]}"; do
      echo "  ARG[$__i]:$__name"; ((__i++));
    done
    if [ $YE_BASH4_VERBOSE -ne 0 ]; then
      echo "Script:"
      echo "  Name: $YE_BASH4_SCRIPT_NAME"
      echo "  Home: $YE_BASH4_SCRIPT_HOME"
      echo "  File: $YE_BASH4_SCRIPT_FILE"
    fi;
  }
fi

ye_bash4_collect_garbage() {
  local __name
  for __name in "${YE_BASH4_COMPONENT_P[@]}"; do
    unset -v "$__name"
  done
  for __name in "${YE_BASH4_COMPONENT_F[@]}"; do
    unset -v "$__name"
  done
  for __name in "${YE_BASH4_COMPONENT_C[@]}"; do
    unset -f "$__name"
  done
}

##
# Parses the registered components
##
ye_bash4_parser() {
  unset -f ye_bash4_normalize_options ye_bash4_is_function ye_bash4_format_usage
  unset -f ye_bash4_parse_register_args ye_bash4_register ye_bash4_register_C ye_bash4_register_F ye_bash4_register_P

  ye_bash4_option_parser() {

    ye_bash4_join() {
      local IFS="$1"; shift; echo "$*";
    }

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
            YE_BASH4_OPTS_S+=("${__option:1}$__modifier")
          ;;
          --*)
            YE_BASH4_OPTS_L+=("${__option:2}$__modifier")
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
        "$YE_BASH4_TYPE_C")
          __handler="ye_bash4_action"
          __modifier=""
        ;;
        "$YE_BASH4_TYPE_F")
          __handler="ye_bash4_flag"
          __modifier=""
        ;;
        "$YE_BASH4_TYPE_P")
          __handler="ye_bash4_parameter"
          __modifier=":"
        ;;
      esac

      ye_bash4_option_processor "$__component" "$__opts" "$__handler" "$__modifier"
    }

    local __key=
    for __key in "${!YE_BASH4_PARAMETER[@]}"; do
      ye_bash4_option_processor_p "$__key" "${YE_BASH4_PARAMETER[$__key]}" "${YE_BASH4_PARAMETER_TYPE[$__key]}"
    done

    YE_BASH4_OPTS_S=`ye_bash4_join "" "${YE_BASH4_OPTS_S[@]}"`
    YE_BASH4_OPTS_L=`ye_bash4_join , "${YE_BASH4_OPTS_L[@]}"`

    unset -f ye_bash4_join ye_bash4_option_processor ye_bash4_option_processor_p

    unset -v YE_BASH4_PARAMETER YE_BASH4_PARAMETER_TYPE
  }

  local YE_BASH4_OPTS_L=()
  local YE_BASH4_OPTS_S=()

  ye_bash4_option_parser

  YE_BASH4_GETOPT="getopt -o "$YE_BASH4_OPTS_S" -l "$YE_BASH4_OPTS_L" -n "$YE_BASH4_SCRIPT_NAME" --"

  unset -f ye_bash4_option_parser
  unset -v YE_BASH4_OPTS_L YE_BASH4_OPTS_S

}

##
# Processes the scipt input
##
ye_bash4_processor() {
  eval set -- "$YE_BASH4_GETOPT"
  unset -v YE_BASH4_GETOPT

  ye_bash4_action() {
    if [ -z "$YE_BASH4_COMMAND" ]; then
      YE_BASH4_COMMAND="$1"
      return 1
    else
      YE_BASH4_COMMAND="ye_bash4_usage"
      return 0
    fi
  }

  ye_bash4_parameter() {
    local __name=$1
    if [ ! -z "$2" ]; then
      eval "$__name=\"$2\""
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

    local __pattern=${YE_BASH4_OPTIONS["$__option"]}
    local __options=(${__pattern//\|/ })
    local __component=${__options[0]}
    local __handler=${__options[1]}

    $__handler $__component "$2"
    __return=$?
    unset YE_BASH4_OPTIONS[$__option]

    return $__return
  }

  local __loop=
  while true; do
    if [[ "$1" == "--" ]]; then
      shift
      break
    fi
    ye_bash4_option_handler "$1" "$2"
    __loop=$?
    if [ $__loop -gt 0 ]; then
      shift $__loop
    elif [ $__loop -eq 0 ]; then
      break
    fi
  done
  unset -v YE_BASH4_OPTIONS

  for __loop do
    YE_BASH4_ARGS+=("$__loop")
  done

  unset -f ye_bash4_action ye_bash4_flag ye_bash4_parameter ye_bash4_option_handler

  if [ -z "$YE_BASH4_COMMAND" ]; then
    YE_BASH4_COMMAND="ye_bash4_usage"
  fi
}

ye_bash4_runner() {

  YE_BASH4_GETOPT=`$YE_BASH4_GETOPT "$@"`
  if [ $? -ne 0 ]; then
    ye_bash4_usage
    exit 1
  fi

  ye_bash4_processor
  unset -f ye_bash4_processor

  if [ $YE_BASH4_DEBUG -ne 0 ]; then
    ye_bash4_debug
  else
    $YE_BASH4_COMMAND
  fi

  unset -f ye_bash4_usage ye_bash4_debug ye_bash4_version
  unset -v YE_BASH4_OPTION_USAGE
  unset -v YE_BASH4_COMMAND YE_BASH4_ARGS YE_BASH4_DEBUG YE_BASH4_VERBOSE
  unset -v YE_BASH4_SCRIPT_FILE YE_BASH4_SCRIPT_NAME YE_BASH4_SCRIPT_HOME YE_BASH4_SCRIPT_VERSION
}

##
# Default execution loop
##
ye_bash4_run() {

  local YE_BASH4_GETOPT
  ye_bash4_parser
  unset -f ye_bash4_parser

  ye_bash4_runner "$@"

  ye_bash4_collect_garbage
  unset -f ye_bash4_collect_garbage ye_bash4_run
  unset -v YE_BASH4_COMPONENT_C YE_BASH4_COMPONENT_F YE_BASH4_COMPONENT_P
}

if [ "$YE_BASH4_BUILDER" -eq 0 ]; then
  ye_bash4_make() {
    local __source="$1"
    local __target="$2"
    echo "Building script from $__source into $__target"

    cp $__source $__target

    source $__source

    YE_BASH4_SCRIPT_FILE=$__target
    YE_BASH4_SCRIPT_NAME=${YE_BASH4_SCRIPT_FILE##*/}
    YE_BASH4_SCRIPT_HOME=${YE_BASH4_SCRIPT_FILE%/*}

    local YE_BASH4_GETOPT
    ye_bash4_parser

    sed -i '/ye_bash4_register.*/d' $__target

    echo >> $__target
    set | grep ^YE_BASH4_VERSION >> $__target
    echo >> $__target

    echo 'YE_BASH4_SCRIPT_FILE=$(cd `dirname "$0"` && pwd)/`basename "$0"`' >> $__target
    echo 'YE_BASH4_SCRIPT_NAME=${YE_BASH4_SCRIPT_FILE##*/}' >> $__target
    echo 'YE_BASH4_SCRIPT_HOME=${YE_BASH4_SCRIPT_FILE%/*}' >> $__target
    set | grep ^YE_BASH4_SCRIPT_VERSION >> $__target
    echo >> $__target

    set | grep ^YE_BASH4_GETOPT >> $__target
    echo "declare -A YE_BASH4_OPTIONS" >> $__target
    echo "declare -A YE_BASH4_OPTION_USAGE" >> $__target
    set | grep ^YE_BASH4_OPTIONS >> $__target
    set | grep -Pzo "(?s)^(\s*)YE_BASH4_OPTION_USAGE=\(.*?\" \)$" >> $__target
    echo >> $__target

    echo "declare -A YE_BASH4_COMPONENT_C" >> $__target
    echo "declare -A YE_BASH4_COMPONENT_F" >> $__target
    echo "declare -A YE_BASH4_COMPONENT_P" >> $__target
    set | grep ^YE_BASH4_COMPONENT_C >> $__target
    set | grep ^YE_BASH4_COMPONENT_F >> $__target
    set | grep ^YE_BASH4_COMPONENT_P >> $__target
    echo >> $__target

    echo "declare -a YE_BASH4_ARGS" >> $__target
    echo "YE_BASH4_COMMAND=" >> $__target
    echo "YE_BASH4_VERBOSE=0" >> $__target
    echo "YE_BASH4_DEBUG=0" >> $__target
    echo >> $__target

    set | grep -Pzo "(?s)^(\s*)ye_bash4_usage *\(\).*?{.*?^\1}" >> $__target
    set | grep -Pzo "(?s)^(\s*)ye_bash4_debug *\(\).*?{.*?^\1}" >> $__target
    set | grep -Pzo "(?s)^(\s*)ye_bash4_version *\(\).*?{.*?^\1}" >> $__target
    echo >> $__target

    set | grep -Pzo "(?s)^(\s*)ye_bash4_processor *\(\).*?{.*?^\1}" >> $__target
    set | grep -Pzo "(?s)^(\s*)ye_bash4_runner *\(\).*?{.*?^\1}" >> $__target
    echo >> $__target

    echo 'ye_bash4_runner "$@"' >> $__target

  }

  ye_bash4_make "$@"

fi