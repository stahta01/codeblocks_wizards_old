#!/bin/bash

# Arduino CodeBlocks Installer

function log () {
    echo -e "$@"
}
function logn () {
    echo -n "$@"
}
function log_error() {
  echo -n "ERROR:  " >&2
  echo $1 >&2
  echo "" >&2
  exit 1
}
function makedir() {
  log "mkdir $1"
  mkdir -p $1
}

function acbi_usage() {
  log "install.sh OPTIONS"
  log ""
  log "OPTIONS are:"
  log ""
  log "\t-a \t --arduino \t Arduino IDE directory, Absolute path"
  log "\t-s \t --share \t share directory"
  log "\t-c \t --codeblock \t .codeblocks directory, Absolute path default:~/.codeblocks"
  log "\t-d \t --this \t Path to this git cloned repo directory, default to ./ whatever it is"
  log "\t-k \t --skecthes \t Path to sketches directory"
  log "\t-m \t --home \t User home directory, default to \$HOME"
  log "\t-h \t --help \t Prints usage and help"
  log ""
  log "-a and -s are mandatory options."
  log ""
}

log ""

while [[ $# -gt 0 ]]; do
    opt="$1"
    shift;
    current_arg="$1"
    if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
        log_error "WARNING: You may have left an argument blank. Double check your command."
    fi
    case "$opt" in
        "-a"|"--arduino"    ) ARDUINO_DIR="$1"; shift;;
        "-s"|"--share"      ) SHARE_DIR="$1"; shift;;
        "-k"|"--skecthes"   ) SKETCHES_DIR="$1"; shift;;
        "-c"|"--codeblock"  ) DOT_DIR="$1"; shift;;
        "-d"|"--def-conf"   ) THIS_DIR="$1"; shift;;
        "-p"|"--helpers"    ) HELPERS_DIR="$1"; shift;;
        "-m"|"--home"       ) HOME_DIR="$1"; shift;;
        "-h"|"--help"       ) acbi_usage; exit 0; shift;;
        *                   ) log_error "ERROR: Invalid option: \""$opt"\""
    esac
done

HOME_DIR=${HOME_DIR-$HOME}

DOT_DIR=${DOT_DIR-"$HOME/.codeblocks"}
THIS_DIR=${THIS_DIR-"."}
HELPERS_DIR=${HELPERS_DIR-"./helpers"}
SKETCHES_DIR=${SKETCHES_DIR-"$HOME/sketches"}

has_error=0
if [[ "$ARDUINO_DIR" == "" ]]; then
    log "Arduino IDE directory not specified, use -a option to specify it."
    has_error=1
fi
if [[ "$SHARE_DIR" == "" ]]; then
    log "share directory not specified, use -s command to specify it."
    has_error=1
fi
if [[ $has_error -eq 1 ]]; then
    log_error "exiting due to error."
fi

log ""
log "OPTIONS are:"
log ""
log " THIS_DIR\t$THIS_DIR"
log " HOME_DIR\t$HOME_DIR"
log " DOT_DIR\t$DOT_DIR"
log " SKETCHES_DIR\t$SKETCHES_DIR"
log " ARDUINO_DIR\t$ARDUINO_DIR"
log " SHARE_DIR\t$SHARE_DIR"

log ""
logn "y if it is ok: "
read ok
if ! [[ $ok == "y" ]]; then
    log_error "canceled by user."
fi

log ""

log "?> $DOT_DIR"
mkdir -p "$DOT_DIR" || log_error "failed"

log "-> $ARDUINO_DIR"
ln -s "$ARDUINO_DIR/" "$DOT_DIR/arduino" || log_error "failed"

log "-> $SKETCHES_DIR"
ln -s "$SKETCHES_DIR/" "$DOT_DIR/sketches" || log_error "failed"

log "=> $THIS_DIR/helpers"
cp -rn "$THIS_DIR/helpers" "$DOT_DIR/helpers" || log_error "failed"

log "=> $THIS_DIR/default.conf"
cp -rn "$THIS_DIR/default.conf" "$DOT_DIR/default.conf" || log_error "failed"

log "?> /share/codeblocks/templates/wizard"
sudo mkdir -p "/share/codeblocks/templates/wizard" || log_error "failed"

log "=> $THIS_DIR/wizards/arduino"
sudo cp -rvn "$THIS_DIR/wizards/arduino" /share/codeblocks/templates/wizard || log_error "failed"

log ""
log "All done, if you don't see any errors everything is OK."
log ""
