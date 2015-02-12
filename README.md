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

# Include the Ye-Bash4 Framework
source "./ye-bash4.sh"

# CODE HERE

# Start the engine
ye_bash4_run "$@"
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

The **Ye-Bash4** framework differentiates 4 types of input every script can handle:
- Commands
- Flags
- Parameters
- Arguments

### Commands

A command is a named functionality your script can perform. It is most commonly viewed as a script function.
If you want to register a function as a command that can be chosen by the user with a **flag** like option
all you have to do is register it as a command

```bash
function my_command() {
# here goes your code
}
ye_bash4_register_C "my_command" "-a" "--my-command" "This is the description of what this command does"
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
P_PARAMETER=
ye_bash4_register_P "P_PARAMETER" "-p" "--parameter" "This is the description of the parameter"
```

### Arguments

An arguments is any parameter that was provided by the user to the script that was not associated with an option.
The only way you can distinguish between arguments is by their position.
Here are some examples of passing arguments to a script

```bash
./run-me argument
./run-me "this is also a single argument"
./run-me "and these" are "three arguments"
./run-me --a-flag -o "A parameter" "An argument" -a "Another parameter" "Yet another argument"
```

You can access all the passed arguments using the ```YE_BASH4_ARGS``` array.
To access the first argument just call ```"$YE_BASH4_ARGS[0]"```

## Summary

All options have to be registered by making a call to a ```ye_bash4_register_X NAME OPTION [OPTION [DESCRIPTION]]``` function in your script
where **X** is either an:

* C - Command
* F - Flag
* P - Parameter

The first parameter is required and it must match the component name.
For an command it must be the same as the command function and for all others it must be the same as the variable name where the value is stored
The all other parameters are optional and can be either:
* an option definition in its short form
* an option definition in its long form
* the description of the command/parameter/flag

## Standard features

The framework provides with the following standard components:

* **Commands**
    * *Version* (--version) displays the current version of the script
        * override by creating a function called ```ye_bash4_version```
    * *Usage*   (-h|--help)displays the scripts help text
        * override by creating a function called ```ye_bash4_usage```
* **Flags**
    * *Debug*   (--debug) if set no command will be executed, instead all the script relevant data will be dumped so that the user can d-bug the script
        * override by creating a function called ```ye_bash4_debug```
    * *Verbose* (-v|--verbose) a simple flag that can be used for regulating the script output level

* **Variables** - All of which can be used within any command code
    * *Flags*
        * YE_BASH4_DEBUG    is the ```--debug```   flag on *(0 is false)*
        * YE_BASH4_VERBOSE  is the ```--verbose``` flag on *(0 is false)*
    * *Parameters*
        * YE_BASH4_COMMAND          the currently invoked command *(function name)*
        * YE_BASH4_DEFAULT          the default           command *(function name)*
        * YE_BASH4_SCRIPT_FILE      the executed script file absolute path
        * YE_BASH4_SCRIPT_HOME      the executed script directory absolute path
        * YE_BASH4_SCRIPT_NAME      the executed script name
        * YE_BASH4_SCRIPT_VERSION   the executed script version
        * YE_BASH4_COMPONENT_C      an array that contains all script registered commands
        * YE_BASH4_COMPONENT_F      an array that contains all script registered flags
        * YE_BASH4_COMPONENT_P      an array that contains all script registered parameters
        * YE_BASH4_OPTION_USAGE     an dictionary that contains all registered component usage text
        * YE_BASH4_BUILDER          is the framework in builder or interpreter mode
    * *Constants*
        * YE_BASH4_VERSION          the **Ye-Bash4** framework version
        * *Option Types*
            * YE_BASH4_TYPE_C       Command
            * YE_BASH4_TYPE_F       Flag
            * YE_BASH4_TYPE_P       Parameter
            * YE_BASH4_TYPE_A       Argument  (not used at the moment but reserved for future use)
