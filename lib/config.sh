#!/usr/bin/env zsh

# Default configuration
GWTREE_WORKTREE_PATH="../alternate-worktrees"
GWTREE_PROTECTED_BRANCHES=("master" "quality" "main" "develop")

# Load user configuration if exists
if [[ -f "$HOME/.gwtreerc" ]]; then
    source "$HOME/.gwtreerc"
fi

# Function to set up initial configuration
setup_gwtree_config() {
    local config_file="$HOME/.gwtreerc"
    
    echo "Welcome to gwtree configuration!"
    echo "--------------------------------"
    
    # Ask for worktree path
    echo "\nWhere would you like to store your worktrees?"
    echo "Default: ../alternate-worktrees (relative to your repository)"
    echo "You can use absolute path (e.g., /path/to/worktrees) or relative path (e.g., ../worktrees)"
    echo -n "Worktree path [../alternate-worktrees]: "
    read worktree_path
    
    # Use default if empty
    worktree_path=${worktree_path:-"../alternate-worktrees"}
    
    # Ask for protected branches
    echo "\nWhich branches would you like to protect from deletion?"
    echo "Default: master quality main develop"
    echo "Enter branch names separated by spaces"
    echo -n "Protected branches [master quality main develop]: "
    read protected_branches
    
    # Use default if empty
    protected_branches=${protected_branches:-"master quality main develop"}
    
    # Create or update configuration file
    echo "# gwtree configuration file" > "$config_file"
    echo "GWTREE_WORKTREE_PATH=\"$worktree_path\"" >> "$config_file"
    echo "GWTREE_PROTECTED_BRANCHES=(${protected_branches})" >> "$config_file"
    
    echo "\nConfiguration saved to $config_file"
    echo "You can edit this file directly to update your configuration."
    
    # Source the new configuration
    source "$config_file"
} 