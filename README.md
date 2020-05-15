# Setup
Setup is a simple framework for setting up your environment (configuration
files, installed commands, installed applications, etc.) via a minimal set of
shell commands.

## Requirements
Currently, Setup expects to be run on a POSIX-compliant computer.

## Usage
```sh
$ git clone https://github.com/thomasebsmith/setup.git
$ ./setup/run.sh
```

## Sources
You can specify one or more repositories from which to obtain setup information
in `sources`. Each line specifies one Git repository.
