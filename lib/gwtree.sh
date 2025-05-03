#!/usr/bin/env zsh

# Source configuration
source "${0:A:h}/config.sh"

gwtree() {
  # Define paths to commands (removed unused MKDIR)
  GIT="/usr/bin/git"
  TR="/usr/bin/tr"
  ECHO="/bin/echo"
  GREP="/usr/bin/grep"
  HEAD="/usr/bin/head"
  AWK="/usr/bin/awk"

  # Save current PATH
  OLD_PATH="$PATH"

  # Check if configuration needs to be set up
  if [[ ! -f "$HOME/.gwtreerc" ]]; then
    setup_gwtree_config
  fi

  # Ensure we're inside a Git repository
  if ! $GIT rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    $ECHO "❌ Not inside a Git repository"
    return 1
  fi

  # Get the main repository directory (not the worktree)
  current_dir=$($GIT rev-parse --show-toplevel)
  # Find the main repository by looking for paths that don't contain the configured worktree path
  repo_root=$($GIT worktree list | $GREP -v "$GWTREE_WORKTREE_PATH" | $AWK '{print $1}' | $HEAD -n 1)
  
  # If repo_root is empty (shouldn't happen), fallback to current directory
  if [ -z "$repo_root" ]; then
    repo_root=$current_dir
  fi

  # Utility: convert branch name to folder format
  convert_branch_to_folder() {
    $ECHO "$1" | $TR '/:' '-'
  }

  # Function to get repository name from remote URL
  get_repo_name() {
    local remote_url=$($GIT config --get remote.origin.url)
    local raw_name
    if [ -n "$remote_url" ]; then
      # Extract repo name from URL and remove .git extension if present
      raw_name=$($ECHO "$remote_url" | $GREP -o '[^/]*$' | sed 's/\.git$//')
    else
      # Fallback to current directory name if no remote URL
      raw_name=$(basename "$($GIT rev-parse --show-toplevel)")
    fi
    # Convert the repo name using the same function used for branch names
    convert_branch_to_folder "$raw_name"
  }

  # Function to change directory and restore PATH
  change_dir() {
    cd "$1"
    export PATH="$OLD_PATH"
  }

  # Function to check for uncommitted changes
  check_uncommitted_changes() {
    if ! $GIT diff-index --quiet HEAD -- 2>/dev/null; then
      return 1
    fi
    if [ -n "$($GIT ls-files --others --exclude-standard)" ]; then
      return 1
    fi
    return 0
  }

  # Function to safely switch branch
  safe_switch_branch() {
    local target_branch=$1
    local main_repo_path=$2

    # First ensure we're in the main repository
    change_dir "$main_repo_path"
    
    local current_branch=$($GIT branch --show-current)

    if [ "$current_branch" = "$target_branch" ]; then
      return 2  # Special return code for "already on branch"
    fi

    if ! check_uncommitted_changes; then
      $ECHO "❌ Cannot switch to $target_branch: You have uncommitted changes in the main repository"
      $ECHO "Please commit or stash your changes first"
      return 1
    fi

    if ! $GIT switch "$target_branch" 2>/dev/null; then
      $ECHO "❌ Failed to switch to branch: $target_branch"
      return 1
    fi

    return 0
  }

  # Function to check if current directory is a worktree
  is_in_worktree() {
    if $GIT rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      local git_dir=$($GIT rev-parse --git-dir)
      if [[ $git_dir == *".git/worktrees/"* ]]; then
        return 0
      fi
    fi
    return 1
  }

  # Function to verify and fix worktree branch
  verify_worktree_branch() {
    local expected_branch=$1
    local worktree_path=$2
    
    # Save current directory
    local original_dir=$(pwd)
    
    # Change to worktree
    change_dir "$worktree_path"
    
    local current_branch=$($GIT branch --show-current)
    
    # Convert branch names to folder format for comparison
    local current_branch_folder=$(convert_branch_to_folder "$current_branch")
    local expected_branch_folder=$(convert_branch_to_folder "$expected_branch")
    
    if [ "$current_branch_folder" != "$expected_branch_folder" ]; then
      if ! check_uncommitted_changes; then
        $ECHO "❌ Cannot fix branch mismatch: You have uncommitted changes in the worktree"
        $ECHO "Please commit or stash your changes first"
        change_dir "$original_dir"
        return 1
      fi
      
      if ! $GIT switch "$expected_branch" 2>/dev/null; then
        $ECHO "❌ Failed to switch worktree to correct branch: $expected_branch"
        change_dir "$original_dir"
        return 1
      fi
      $ECHO "✅ Fixed worktree branch: switched from $current_branch to $expected_branch"
    fi
    
    change_dir "$original_dir"
    return 0
  }

  # Function to check if we're already in the correct worktree
  is_current_worktree() {
    local branch=$1
    local current_branch=$($GIT branch --show-current)
    local current_path=$($GIT rev-parse --show-toplevel)
    
    # Convert both branch names to folder format for comparison
    local current_branch_folder=$(convert_branch_to_folder "$current_branch")
    local expected_branch_folder=$(convert_branch_to_folder "$branch")
    
    if [ "$current_branch_folder" = "$expected_branch_folder" ] && [ "$current_path" = "$current_dir" ]; then
      return 0
    fi
    return 1
  }

  # Utility: convert branch name to folder name and worktree path
  parse_branch() {
    local repo_folder=$(convert_branch_to_folder "$(get_repo_name)")
    local branch_folder=$(convert_branch_to_folder "$1")
    folder="$repo_folder/$branch_folder"
    worktree_path="$GWTREE_WORKTREE_PATH/$folder"
  }

  # Show configuration command
  if [ "$1" = "config" ]; then
    setup_gwtree_config
    return
  fi

  # No argument → list all worktrees
  if [ -z "$1" ]; then
    $GIT worktree list
    return
  fi

  # Handle -b flag for new branches
  if [ "$1" = "-b" ]; then
    shift
    branch="$1"
    parse_branch "$branch"

    if [ -d "$worktree_path" ]; then
      change_dir "$worktree_path"
      $ECHO "✅ Switched to branch: $branch at $GWTREE_WORKTREE_PATH/$folder"
    else
      $GIT worktree add -b "$branch" "$worktree_path" origin/main && change_dir "$worktree_path"
      $ECHO "✅ Created and switched to branch: $branch at $GWTREE_WORKTREE_PATH/$folder"
    fi
    return
  fi

  # Handle -d flag for deleting worktrees
  if [ "$1" = "-d" ]; then
    shift
    branch="$1"
    
    # Check if branch is protected
    for protected in "${GWTREE_PROTECTED_BRANCHES[@]}"; do
      if [ "$branch" = "$protected" ]; then
        $ECHO "🚫 Cannot delete protected branch: $branch"
        return 1
      fi
    done

    parse_branch "$branch"

    if [ -d "$worktree_path" ]; then
      $GIT worktree remove "$worktree_path" --force && $ECHO "✅ Removed worktree for branch: $branch"
    else
      $ECHO "⚠️  No worktree found for branch: $branch"
    fi
    return
  fi

  # Get the target branch
  branch="$1"

  # Special handling for main and master branches
  if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    # Always change to main repository first, regardless of where we are
    change_dir "$repo_root"
    
    # Now try to switch branch safely
    safe_switch_branch "$branch" "$repo_root"
    local switch_status=$?
    
    case $switch_status in
      0) $ECHO "✅ Switched to branch: $branch in main repository" ;;
      2) $ECHO "✅ Already on branch: $branch in main repository" ;;
    esac
    return
  fi

  # Handle regular branch switching in worktrees
  parse_branch "$branch"

  # Check if we're already in the correct worktree and branch
  if is_current_worktree "$branch"; then
    $ECHO "✅ Already on branch: $branch at $GWTREE_WORKTREE_PATH/$folder"
    return
  fi

  if [ -d "$worktree_path" ]; then
    # Verify and fix branch if needed before switching
    if ! verify_worktree_branch "$branch" "$worktree_path"; then
      return 1
    fi
    change_dir "$worktree_path"
    $ECHO "✅ Switched to branch: $branch at $GWTREE_WORKTREE_PATH/$folder"
  else
    $GIT worktree add "$worktree_path" "$branch" 2>/dev/null && change_dir "$worktree_path"
    $ECHO "✅ Created and switched to branch: $branch at $GWTREE_WORKTREE_PATH/$folder"
  fi
}

# Completion function for gwtree
_gwtree() {
  local state
  local -a subcommands
  local -a branches
  
  subcommands=('-b:Create new worktree with new branch' '-d:Delete a worktree' 'config:Configure gwtree settings')
  
  _arguments \
    '1: :->first_arg' \
    '2: :->second_arg'
    
  case $state in
    first_arg)
      _describe 'command' subcommands
      # Get both local and remote branches, excluding HEAD and remote HEAD
      branches=(
        ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"}
        ${(f)"$(git branch -r --format='%(refname:short)' 2>/dev/null | grep -v 'HEAD' | sed 's#origin/##')"}
      )
      _describe 'branches' branches
      ;;
    second_arg)
      case $words[2] in
        -b|-d)
          # Get both local and remote branches, excluding HEAD and remote HEAD
          branches=(
            ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"}
            ${(f)"$(git branch -r --format='%(refname:short)' 2>/dev/null | grep -v 'HEAD' | sed 's#origin/##')"}
          )
          _describe 'branches' branches
          ;;
      esac
      ;;
  esac
}

# Register the completion function
compdef _gwtree gwtree 