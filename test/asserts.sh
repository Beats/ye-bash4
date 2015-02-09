#!/bin/bash

assertDiff() {
  msg=''
  if [ $# -eq 3 ]; then
    msg=$1
    shift
  fi

  local expected=$1
  local actual=$2

  msg=`eval "echo \"${msg}\""`

  diff $expected $actual &>/dev/null
  assertTrue "${msg}" $?
}