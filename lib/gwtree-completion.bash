_gwtree()
{
  local cur prev opts branches
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-b -d config"
  branches=$(git branch --format='%(refname:short)' 2>/dev/null)
  if [[ ${cur} == -* ]] ; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
  fi
  if [[ ${prev} == "-b" || ${prev} == "-d" ]]; then
    COMPREPLY=( $(compgen -W "${branches}" -- ${cur}) )
    return 0
  fi
  COMPREPLY=( $(compgen -W "${opts} ${branches}" -- ${cur}) )
}
complete -F _gwtree gwtree 