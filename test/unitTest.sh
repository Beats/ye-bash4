#!/bin/bash

SCRIPT_HOME=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
SCRIPT_NAME="tester"
SCRIPT_PATH="$SCRIPT_HOME/$SCRIPT_NAME"

mkdir -p $SCRIPT_HOME/actual

source "$SCRIPT_HOME/asserts.sh"

usage="$SCRIPT_HOME/expected/usage.txt"

function run() {
  $SCRIPT_PATH $@
}

function testVersion() {
  expected="$SCRIPT_HOME/expected/version.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run --version             > $actual
  assertDiff "Explicit output differs." $expected $actual
}

function testUsage() {
#  expected="$SCRIPT_HOME/expected/usage.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

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
  expected="$SCRIPT_HOME/expected/action1.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run -a            > $actual
  assertDiff "Explicit short output differs." $expected $actual

  run --action1     > $actual
  assertDiff "Explicit long  output differs." $expected $actual
}

function testAction2() {
  expected="$SCRIPT_HOME/expected/action2.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run -b            > $actual
  assertDiff "Explicit short output differs." $expected $actual

  run --action2     > $actual
  assertDiff "Explicit long  output differs." $expected $actual
}

function testAction3() {
  expected="$SCRIPT_HOME/expected/action3.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run -c            > $actual
  assertDiff "Explicit short output differs." $expected $actual

  run --action3     > $actual
  assertDiff "Explicit long  output differs." $usage $actual
}

function testAction4() {
  expected="$SCRIPT_HOME/expected/action4.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run -d            > $actual
  assertDiff "Explicit short output differs." $usage $actual

  run --action4     > $actual
  assertDiff "Explicit long  output differs." $expected $actual
}

function testDebug() {
  expected="$SCRIPT_HOME/expected/debug.txt"
  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run --debug > $actual
  assertDiff "Explicit long output differs." $expected $actual
}

function testFlagON() {
  actual=`run --debug             | grep F_ON | xargs`
  assertEquals "Implicit differs"         "F_ON:1" "$actual"

  actual=`run --debug -f          | grep F_ON | xargs`
  assertEquals "Explicit short differs"   "F_ON:0" "$actual"

  actual=`run --debug --flag-no   | grep F_ON | xargs`
  assertEquals "Explicit long  differs"   "F_ON:0" "$actual"
}

function testFlagNO() {
  actual=`run --debug             | grep F_NO | xargs`
  assertEquals "Implicit differs"          "F_NO:0" "$actual"

  actual=`run --debug -n          | grep F_NO | xargs`
  assertEquals "Explicit short differs"   "F_NO:1" "$actual"

  actual=`run --debug --flag-on   | grep F_NO | xargs`
  assertEquals "Explicit long  differs"   "F_NO:1" "$actual"
}

function testParameterOptional() {
  actual=`run --debug                             | grep P_OPTIONAL | xargs`
  assertEquals "Implicit differs"         "P_OPTIONAL:The default value"  "$actual"

  actual=`run --debug -o                    | grep P_OPTIONAL | xargs`
  assertEquals "Explicit none differs"    "P_OPTIONAL:The default value"  "$actual"

  actual=`run --debug --optional            | grep P_OPTIONAL | xargs`
  assertEquals "Implicit none differs"    "P_OPTIONAL:The default value"  "$actual"

  actual=`run --debug -oCustom              | grep P_OPTIONAL | xargs`
  assertEquals "Explicit short differs"   "P_OPTIONAL:Custom"   "$actual"

  actual=`run --debug --optional="Custom"   | grep P_OPTIONAL | xargs`
  assertEquals "Explicit long  differs"   "P_OPTIONAL:Custom"   "$actual"
}

function testParameterRequired() {
  actual=`run --debug                       | grep P_REQUIRED | xargs`
  assertEquals "Implicit differs"         "P_REQUIRED:"         "$actual"

  actual=`run --debug -rCustom              | grep P_REQUIRED | xargs`
  assertEquals "Explicit short differs"   "P_REQUIRED:Custom"   "$actual"

  actual=`run --debug --required="Custom"   | grep P_REQUIRED | xargs`
  assertEquals "Explicit long  differs"   "P_REQUIRED:Custom"   "$actual"

  actual="$SCRIPT_HOME/actual/$FUNCNAME.txt"

  run --debug -r            > $actual
  assertDiff "Explicit short output differs." $usage $actual

  run --debug --required    > $actual
  assertDiff "Explicit long output differs." $usage $actual
}

. shunit2