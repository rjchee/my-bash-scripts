#!/bin/bash

# look up the password of a WIFI network. if no arguments are given, it looks
# up the password of the wifi network the computer is currently connected to.
# Otherwise, you can pass in an argument to specify which WIFI network's
# password to look up
lookupwifi () {
    local CONNECTIONS_DIR=/etc/NetworkManager/system-connections
    # check for an argument and act accordingly
    if [ -n "$1" ]
    then
        if [ -e "$CONNECTIONS_DIR/$1.nmconnection" ]
        then
            _lookupwifi "$1"
            # $? is the error code returned by the previous function
            return $?
        else
            echo No record for network $1 found!
            return 1
        fi
    else
        # successfully declaring a local variable clobbers the result from the
        # command substitution $(iwgetid -r), so assign it in a different line
        # from the declaration
        local ssid
        local ssid=$(iwgetid -r)
        # if iwgetid -r failed, there is no connection to a WIFI network
        if [ $? -eq 0 ]
        then
            _lookupwifi "$ssid"
            return $?
        else
            echo Not connected to WIFI. Please specify a network to look up.
            return 1
        fi
    fi
}

# helper method to perform the actual lookup of the password
_lookupwifi () {
    local CONNECTIONS_DIR=/etc/NetworkManager/system-connections
    local pass
    echo $1
    pass=$(set -o pipefail && sudo cat "$CONNECTIONS_DIR/$1.nmconnection" | ag "psk=" | cut -d'=' -f2)
    if [ $? -eq 0 ]
    then
        echo $pass
    else
        echo Network $1 does not have a password!
        return 1
    fi
}

_lookupwificompletion () {
    # set autocompletion for existing networks in the system-connections file
    local _COMPREPLY f filename cur
    _COMPREPLY=()
    for f in /etc/NetworkManager/system-connections/*
    do
        filename="$(basename "$f")"
        # filter out the .nmconnection suffix to get the wifi network name
        _COMPREPLY+=( "${filename%.*}" )
    done
    cur=${COMP_WORDS[COMP_CWORD]}
    # set the field separator to \n since spaces could be in the network name,
    # and [*] expansion will separate entries with \n
    local IFS=$'\n'
    COMPREPLY=( $(compgen -W "${_COMPREPLY[*]}" -- $cur) )
}

complete -o filenames -F _lookupwificompletion lookupwifi
