#!/usr/bin/env bash
# log-simple.sh — minimal logging helpers with millisecond timestamps.
# Output: 2026-11-14--14-36-25-123 INFO:  message
#
#   trace "message"   # TRACE:  dim grey  stderr
#   debug "message"   # DEBUG:  cyan      stderr
#   info  "message"   # INFO:   blue      stdout
#   warn  "message"   # WARN:   yellow    stderr  + saved in WARNINGS
#   error "message"   # ERROR:  red       stderr  + saved in ERRORS
#   fatal "message"   # FATAL:  red bg    stderr  + saved in FATALS
#
# fatal does NOT exit. Stop the script yourself, e.g.:
#   [[ -d $dir ]] || { fatal "Missing $dir"; exit 1; }
#
# LOG_LEVEL sets the minimum level shown (default INFO):
#   TRACE | DEBUG | INFO | WARN | ERROR | FATAL   (upper or lower case)
# Hidden messages are still saved in WARNINGS / ERRORS / FATALS.
#
# Colour only when writing to a terminal; set NO_COLOR=1 to disable.

WARNINGS=()
ERRORS=()
FATALS=()

# _ts — sets TS to YYYY-mm-dd--hh-mm-ss-fff
# Bash 5+: no external command. Older Bash: falls back to date.
_ts() {
    if [[ -n ${EPOCHREALTIME:-} ]]; then
        local sec=${EPOCHREALTIME%[.,]*} usec=${EPOCHREALTIME#*[.,]}
        printf -v TS '%(%Y-%m-%d--%H-%M-%S)T-%s' "$sec" "${usec:0:3}"
    else
        TS=$(date +%Y-%m-%d--%H-%M-%S-%3N)
        [[ $TS =~ -[0-9]{3}$ ]] || TS=$(date +%Y-%m-%d--%H-%M-%S)   # no %N support: drop ms
    fi
}

# _enabled <level-number> — true if that level is at or above LOG_LEVEL
_enabled() {
    local min
    case "${LOG_LEVEL:-INFO}" in
        TRACE|trace) min=0 ;;
        DEBUG|debug) min=1 ;;
        WARN|warn)   min=3 ;;
        ERROR|error) min=4 ;;
        FATAL|fatal) min=5 ;;
        *)           min=2 ;;   # INFO, or anything unrecognised
    esac
    (( $1 >= min ))
}

# _out <level-number> <fd> <colour> <label> <message>
_out() {
    _enabled "$1" || return 0
    _ts
    local label
    printf -v label '%-6s' "$4"          # pad so messages line up
    if [[ -z ${NO_COLOR:-} && -t $2 ]]; then
        printf '%s \033[%sm%s\033[0m %s\n' "$TS" "$3" "$label" "$5" >&"$2"
    else
        printf '%s %s %s\n' "$TS" "$label" "$5" >&"$2"
    fi
}

trace() { _out 0 2 '2;37' 'TRACE:' "$*"; }
debug() { _out 1 2 '0;36' 'DEBUG:' "$*"; }
info()  { _out 2 1 '1;34' 'INFO:'  "$*"; }
warn()  { WARNINGS+=("$*"); _out 3 2 '1;33' 'WARN:'  "$*"; }
error() { ERRORS+=("$*");   _out 4 2 '1;91' 'ERROR:' "$*"; }
fatal() { FATALS+=("$*");   _out 5 2 '1;31' 'FATAL:' "$*"; }

# --- Demo: runs only when this file is executed, not when sourced ------------
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    LOG_LEVEL=${LOG_LEVEL:-TRACE}
    trace "this is a trace"
    debug "this is a debug"
    info  "this is an info"
    warn  "this is a warn"
    error "this is an error"
    fatal "this is a fatal (script keeps running)"
    info  "still running after fatal"
fi
