#!/bin/bash

# Colors
MAGENTA="\033[0;35m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
NC="\033[0m"

C_HEADING=$YELLOW
C_SUBHEADING=$MAGENTA
C_PROMPT=$CYAN


function log_pwd() {
    printf "Now in %s\n" $PWD
}

function log_with_space() {
    color="$1"
    content="$2"

    printf "${color}$content${NC} "
}

function log_with_newline() {
    color="$1"
    content="$2"

    printf "${color}$content${NC}\n"
}

function log_heading() {
    content="$1"

    log_with_newline $C_HEADING "$content"
}

function log_subheading() {
    content="$1"

    log_with_newline $C_SUBHEADING "$content"
}

function log_prompt() {
    content="$1"

    log_with_space $C_PROMPT "$content"
}
