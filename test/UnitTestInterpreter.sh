#!/bin/bash

SCRIPT_NAME="interpreter"
SCRIPT_HOME=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
SCRIPT_PATH="$SCRIPT_HOME/$SCRIPT_NAME"

source "$SCRIPT_HOME/asserts.sh"

EXPECTED="$SCRIPT_HOME/expected/$SCRIPT_NAME"
ACTUAL="$SCRIPT_HOME/actual/$SCRIPT_NAME"

mkdir -p $ACTUAL

usage="$EXPECTED/usage.txt"

function run() {
  $SCRIPT_PATH "$@"
}

function var() {
  local __var="$1"
  shift;
  $SCRIPT_PATH --debug "$1" "$2" | grep $__var | xargs
}

function testVersion() {
  expected="$EXPECTED/version.txt"
  actual="$ACTUAL/$FUNCNAME.txt"

  run --version             > $actual
  assertDiff "Explicit output differs." $expected $actual
}

function testUsage() {
  actual="$ACTUAL/$FUNCNAME.txt"

  run                       > $actual
  assertDiff "Implicit       output differs." $usage $actual

  run -h                    > $actual
  assertDiff "Explicit short output differs." $usage $actual

  run --help                > $actual
  assertDiff "Explicit long  output differs." $usage $actual

  run -n                    > $actual
  assertDiff "Invalid  short output differs." $usage $actual

  run --none                > $actual
  assertDiff "Invalid  long  output differs." $usage $actual

  run -a -b                 > $actual
  assertDiff "Multiple short output differs." $usage $actual

  run --action1 --action2   > $actual
  assertDiff "Multiple long  output differs." $usage $actual

  run -a --action2          > $actual
  assertDiff "Multiple both  output differs." $usage $actual

  run --action1 -b          > $actual
  assertDiff "Multiple both  output differs." $usage $actual

}

function testAction1() {
  expected="$EXPECTED/yb4_action1.txt"
  actual="$ACTUAL/$FUNCNAME.txt"

  run -a            > $actual
  assertDiff "Explicit short output differs." $expected $actual

  run --action1     > $actual
  assertDiff "Explicit long  output differs." $expected $actual
}

function testAction2() {
  expected="$EXPECTED/yb4_action2.txt"
  actual="$ACTUAL/$FUNCNAME.txt"

  run -b            > $actual
  assertDiff "Explicit short output differs." $expected $actual

  run --action2     > $actual
  assertDiff "Explicit long  output differs." $expected $actual
}

function testAction3() {
  expected="$EXPECTED/yb4_action3.txt"
  actual="$ACTUAL/$FUNCNAME.txt"

  run -c            > $actual
  assertDiff "Explicit short output differs." $expected $actual

  run --action3     > $actual
  assertDiff "Explicit long  output differs." $usage $actual
}

function testAction4() {
  expected="$EXPECTED/yb4_action4.txt"
  actual="$ACTUAL/$FUNCNAME.txt"

  run -d            > $actual
  assertDiff "Explicit short output differs." $usage $actual

  run --action4     > $actual
  assertDiff "Explicit long  output differs." $expected $actual
}

function testDebug() {
  expected="$EXPECTED/debug.txt"
  actual="$ACTUAL/$FUNCNAME.txt"

  run --debug --action1 Argument1 -m "Missing value" "Argument Two"         > $actual
  assertDiff "Explicit long output differs." $expected $actual

  run --debug "Argument1" -a "Argument Two" -m"Missing value"               > $actual
  assertDiff "Explicit long output differs." $expected $actual

  run --debug Argument1 "Argument Two" --action1 --missing="Missing value"  > $actual
  assertDiff "Explicit long output differs." $expected $actual

  run --debug Argument1 -a --missing "Missing value" "Argument Two"         > $actual
  assertDiff "Explicit long output differs." $expected $actual
}

function testFlagON() {
  local __var="YB4_ON"

  actual=`var $__var`
  assertEquals "Implicit differs"         "$__var:1" "$actual"

  actual=`var $__var -f`
  assertEquals "Explicit short differs"   "$__var:0" "$actual"

  actual=`var $__var --flag-no`
  assertEquals "Explicit long  differs"   "$__var:0" "$actual"
}

function testFlagNO() {
  local __var="YB4_NO"

  actual=`var $__var`
  assertEquals "Implicit differs"         "$__var:0" "$actual"

  actual=`var $__var -n`
  assertEquals "Explicit short differs"   "$__var:1" "$actual"

  actual=`var $__var --flag-on`
  assertEquals "Explicit long  differs"   "$__var:1" "$actual"
}

function testParameterDefault() {
  local __var="YB4_DEFAULT"

  actual=`var $__var`
  assertEquals "Implicit differs"         "$__var:Default value" "$actual"

  actual=`var $__var -dCustom`
  assertEquals "Explicit short 1 differs"   "$__var:Custom" "$actual"

  actual=`var $__var -d"Custom"`
  assertEquals "Explicit short 2 differs"   "$__var:Custom" "$actual"

  actual=`var $__var -d "Custom value"`
  assertEquals "Explicit short 3 differs"   "$__var:Custom value" "$actual"

  actual=`var $__var --default=Custom`
  assertEquals "Explicit long 1 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --default="Custom"`
  assertEquals "Explicit long 2 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --default="Custom value"`
  assertEquals "Explicit long 3 differs"   "$__var:Custom value" "$actual"

  actual=`var $__var --default Custom`
  assertEquals "Explicit long 4 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --default "Custom"`
  assertEquals "Explicit long 5 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --default "Custom value"`
  assertEquals "Explicit long 6 differs"   "$__var:Custom value" "$actual"
}

function testParameterMising() {
  local __var="YB4_MISSING"

  actual=`var $__var`
  assertEquals "Implicit differs"         "$__var:" "$actual"

  actual=`var $__var -mCustom`
  assertEquals "Explicit short 1 differs"   "$__var:Custom" "$actual"

  actual=`var $__var -m"Custom"`
  assertEquals "Explicit short 2 differs"   "$__var:Custom" "$actual"

  actual=`var $__var -m "Custom value"`
  assertEquals "Explicit short 3 differs"   "$__var:Custom value" "$actual"

  actual=`var $__var --missing=Custom`
  assertEquals "Explicit long 1 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --missing="Custom"`
  assertEquals "Explicit long 2 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --missing="Custom value"`
  assertEquals "Explicit long 3 differs"   "$__var:Custom value" "$actual"

  actual=`var $__var --missing Custom`
  assertEquals "Explicit long 4 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --missing "Custom"`
  assertEquals "Explicit long 5 differs"   "$__var:Custom" "$actual"

  actual=`var $__var --missing "Custom value"`
  assertEquals "Explicit long 6 differs"   "$__var:Custom value" "$actual"
}

. shunit2