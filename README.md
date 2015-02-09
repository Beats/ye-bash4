# Ye-Bash4

**Ye-Bash4** is a Bash4 framework for creating simple bash script's

It allows you to organize your script into coherent segments and register all the script options flags and parameters

The only limitation is that it is dependent on Bash4 (and since it is with us since 2009, it has become a *de facto* standard)

## Usage

In order to start using Ye-Bash4 all you need to do is download the script [ye-bash.sh](https://raw.githubusercontent.com/Beats/ye-bash4/master/ye-bash4.sh)
and include it in your script:

```bash
#!/bin/bash
# The description of your script

# Beats Ye-Bash4 Framework
source "./ye-bash4.sh"
```
Once that is done you can go on and write your script

### Options

Every script can be called with a set of options. These options are used to modify the execution control of the script.
Options can be set in it's short format like ```-s``` and ```-v``` or they can be set in their corresponding long format like ```--version``` or ```--status```

Every option can have a value associated with which is a way the user can pass values to the script
Here are some examples of passing values to a script:

```bash
./run-me -aSimple
./run-me -c "Simple"
./run-me -b"Complex value"
./run-me -d "Complex value"
./run-me --long-a "Simple"
./run-me --long-b "Complex value"
./run-me --long-c="Simple"
./run-me --long-d="Complex value"
```

The **Ye-Bash4** framework differentiates 4 types of components every script can handle:
- Actions
- Flags
- Parameters

### Actions

An action is a named functionality your script can perform. It is most commonly viewed as a script function.
If you want to register a function as an action that can be chosen by the user with a **flag** like option
all you have to do is register it as an action

```bash
function my_action() {
# here goes your code
}
ye_bash4_register_A "my_action" "-a" "--my-action" "This is the description of what this action does"
```

### Flags

Flags are boolean parameters that can be switched on or off with an option.
To register a **flag** simply define and call the following function

```bash
F_FLAG=1
ye_bash4_register_F "F_FLAG" "-f" "--flag" "This is the description of the flag"
```
Being a boolean value the flag value is inverted by calling the appropriate option, so mind your flag initialization

### Parameters

A parameter is a variable that can be changed by the user, using the associated option with a value.
To register a parameters simply call

```bash
P_DEFAULT=
ye_bash4_register_P "P_PARAMETER" "-p" "--parameter" "This is the description of the parameter"
```

### Summary

All options have to be registered by making a call to a ```ye_bash4_register_X NAME OPTION [OPTION [DESCRIPTION]]``` function in your script
where **X** is either an:

* A - Action
* F - Flag
* P - Parameter

The first parameter is required and it must match the component name.
For an action it must be the same as the action function and for all others it must be the same as the variable name where the value is stored
The all other parameters are optional and can be either:
* an option definition in its short form
* an option definition in its long form
* the description of the action

## Extra features

The framework provides with the following extra actions and flags:

* Actions
    * **Version** (--version) displays the current version of the script
    * **Usage**   (-h|--help)displays the scripts help text
* Flags
    * **Debug**   (--debug) if set no action will be executed, instead all the script relevant data will be dumped so that the user can d-bug the script
    * **Verbose** (-v|--verbose) a simple flag that can be used for regulating the script output level

