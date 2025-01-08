#!/bin/bash

# Function to detect shell type
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Function to create and update user config
create_user_config() {
    local shell=$1
    local config_dir="$HOME/.xsetup"
    local config_file="$config_dir/config.json"
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Create initial config JSON
    cat > "$config_file" << EOF
{
    "shell": "$shell",
    "install_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    echo "Created user configuration at $config_file"
}

# Function to add source line to shell rc file
add_to_rc() {
    local shell=$1
    local rc_file=""
    local source_line="source ~/xsetup/dev.sh"
    
    case $shell in
        "zsh")
            rc_file="$HOME/.zshrc"
            ;;
        "bash")
            rc_file="$HOME/.bashrc"
            ;;
        *)
            echo "Unsupported shell"
            exit 1
            ;;
    esac
    
    # Check if source line already exists
    if ! grep -q "source ~/xsetup/dev.sh" "$rc_file"; then
        echo "$source_line" >> "$rc_file"
        echo "Added source line to $rc_file"
    else
        echo "Source line already exists in $rc_file"
    fi
}

# Main installation
main() {
    # Clone repository
    if [ ! -d "$HOME/xsetup" ]; then
        git clone https://github.com/psuzzi/xsetup.git "$HOME/xsetup"
    else
        echo "xsetup directory already exists"
        # Optionally update the repository
        cd "$HOME/xsetup" && git pull
    fi
    
    # Detect shell and store configuration
    shell_type=$(detect_shell)
    create_user_config "$shell_type"
    
    # Add to rc file
    add_to_rc "$shell_type"
    
    echo "Installation complete!"
    echo "Please restart your shell or run 'source ~/.${shell_type}rc' to apply changes"
}

# Execute main function
main