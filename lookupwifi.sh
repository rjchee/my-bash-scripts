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
        if [ -e "$CONNECTIONS_DIR/$1" ]
        then
            _lookupwifi $1
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
            _lookupwifi $ssid
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
    pass=$(set -o pipefail && sudo cat "$CONNECTIONS_DIR/$1" | ag "psk=" | cut -d'=' -f2)
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
    local CONNECTIONS_DIR=/etc/NetworkManager/system-connections
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$(ls $CONNECTIONS_DIR)" -- $cur) )
}

complete -o filenames -F _lookupwificompletion lookupwifi
