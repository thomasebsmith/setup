# Setup
Setup is a simple framework for setting up your environment (configuration
files, installed commands, installed applications, etc.) via a minimal set of
shell commands.

## Requirements
Currently, Setup expects to be run on a POSIX-compliant computer with support
for colors (`colors`, `sgr0`, and `setaf`) via `tput`.

## Usage
```sh
$ git clone https://github.com/thomasebsmith/setup.git
$ ./setup/run.sh
```

## Sources
You can specify one or more repositories from which to obtain setup information
in `sources`. Each line should contain a fully-qualified Git repository URL.

### Source Repository Structure
A source repository should be structured as follows:
```
├── default_features
└── features
    └── [feature name]
        ├── dependencies
        └── run.sh
```

- `default_features`: A text file in which each line is the name of a feature
  to be installed by default with this source.
- `dependencies`: A text file in which each line is the name of a feature that
  this feature depends on.
- `run.sh`: A shell script that installs the feature, given that its
  dependencies are already installed. This script can assume POSIX compliance.
