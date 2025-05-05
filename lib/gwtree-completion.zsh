#compdef gwtree
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
      branches=(
        ${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"}
        ${(f)"$(git branch -r --format='%(refname:short)' 2>/dev/null | grep -v 'HEAD' | sed 's#origin/##')"}
      )
      _describe 'branches' branches
      ;;
    second_arg)
      case $words[2] in
        -b|-d)
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
compdef _gwtree gwtree 