#!/bin/bash

# Get current directory and current script path
ENTRY_DIR="$HOME/xsetup"
ENTRY_SCRIPT="$ENTRY_DIR/dev.sh"

# Array to track sourced files
declare -a sourced=()

# Utility function to join array elements
join_by() {
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

alias cl='clear'

dev() {
    local funcs=("load" "code" "info") #public
    
    # Local function definitions need to use the proper bash syntax
    local check
    check() {
        if command -v "$1" &> /dev/null; then
            echo -e "\n== $1 ==> $(eval "$1 --version")"
            which "$1"
        else 
            echo -e "\n== $1 ==> Command not defined"
        fi
    }

    local init
    init() {
        # Add initialization logic here if needed
        echo "Initializing development environment..."
    }

    case "${1}" in 
        load)
            source "$ENTRY_SCRIPT"
            dev init
            ;;
        code)
            if ! command -v code &> /dev/null; then
                echo "code not installed, please install it as per: https://code.visualstudio.com/docs/setup/linux"
                return 1
            fi
            # shipped with git repo
            code "$ENTRY_DIR/dev.code-workspace" 
            ;;
        info)
            echo "== Dev ==> $ENTRY_SCRIPT  [ $(join_by " " "${sourced[@]}") ]" 
            local arr=("git" "java" "mvn" "node" "npm" "docker" "python3")
            for i in "${arr[@]}"; do
                check "$i"
            done
            ;;
        help|"")
            echo "Available commands: ${funcs[*]}"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Available commands: ${funcs[*]}"
            ;;
    esac
}

# Add this script to sourced array
sourced+=("dev.sh")