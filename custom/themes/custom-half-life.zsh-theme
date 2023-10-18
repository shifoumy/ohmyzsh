# prompt style and colors based on Steve Losh's Prose theme:
# https://github.com/sjl/oh-my-zsh/blob/master/themes/prose.zsh-theme
#
# vcs_info modifications from Bart Trojanowski's zsh prompt:
# http://www.jukie.net/bart/blog/pimping-out-zsh-prompt
#
# git untracked files modification from Brian Carper:
# https://briancarper.net/blog/570/git-info-in-your-zsh-prompt

#use extended color palette if available
if [[ $TERM = (*256color|*rxvt*|alacritty) ]]; then
  turquoise="%{${(%):-"%F{81}"}%}"
  orange="%{${(%):-"%F{166}"}%}"
  purple="%{${(%):-"%F{135}"}%}"
  hotpink="%{${(%):-"%F{161}"}%}"
  limegreen="%{${(%):-"%F{118}"}%}"
else
  turquoise="%{${(%):-"%F{cyan}"}%}"
  orange="%{${(%):-"%F{yellow}"}%}"
  purple="%{${(%):-"%F{magenta}"}%}"
  hotpink="%{${(%):-"%F{red}"}%}"
  limegreen="%{${(%):-"%F{green}"}%}"
fi

autoload -Uz vcs_info
# enable VCS systems you use
zstyle ':vcs_info:*' enable git svn

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*:prompt:*' check-for-changes true

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stagedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
#FMT_BRANCH=" on ${turquoise}%b%u%c${PR_RST}"
#FMT_ACTION=" performing a ${limegreen}%a${PR_RST}"
#FMT_UNSTAGED="${orange} ✘"
#FMT_STAGED="${limegreen} ✔"

#zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
#zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
#zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
#zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
#zstyle ':vcs_info:*:prompt:*' nvcsformats   ""


function steeef_chpwd {
  PR_GIT_UPDATE=1
}

function steeef_preexec {
  case "$2" in
  *git*|*svn*) PR_GIT_UPDATE=1 ;;
  esac
}

function virtualenv_prompt_info {
  [[ -n ${VIRTUAL_ENV} ]] || return
  echo "${ZSH_THEME_VIRTUALENV_PREFIX:=[}${VIRTUAL_ENV:t}${ZSH_THEME_VIRTUALENV_SUFFIX:=]}"
}
local virtualenv_info='$(virtualenv_prompt_info)'
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%} on branch ${turquoise}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="${orange} ✘✘✘"
# ZSH_THEME_GIT_PROMPT_CLEAN="${limegreen} ✔"
# ZSH_THEME_GIT_PROMPT_DIRTY="${orange} 😡"
ZSH_THEME_GIT_PROMPT_DIRTY="%B %F{red} 😡 %b"
ZSH_THEME_GIT_PROMPT_CLEAN="%B ${limegreen} 😃 %b"

function steeef_precmd {
  (( PR_GIT_UPDATE )) || return

  # check for untracked files or updated submodules, since vcs_info doesn't
  if [[ -n "$(git ls-files --other --exclude-standard 2>/dev/null)" ]]; then
    PR_GIT_UPDATE=1
    FMT_BRANCH="${PM_RST} on ${turquoise}%b%u%c${hotpink} ●${PR_RST}"
  else
    FMT_BRANCH="${PM_RST} on ${turquoise}%b%u%c${PR_RST}"
  fi
  zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"

  vcs_info 'prompt'
  PR_GIT_UPDATE=
}

# vcs_info running hooks
PR_GIT_UPDATE=1

autoload -U add-zsh-hook
add-zsh-hook chpwd steeef_chpwd
add-zsh-hook precmd steeef_precmd
add-zsh-hook preexec steeef_preexec

# ruby prompt settings
ZSH_THEME_RUBY_PROMPT_PREFIX="with%F{red} "
ZSH_THEME_RUBY_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_RVM_PROMPT_OPTIONS="v g"

if [ "$EUID" -eq 0 ]; then
  user_color=${hotpink}
else
  user_color=${purple}
fi

setopt prompt_subst
PROMPT="╭─● ${user_color}%n%{$reset_color%} in ${limegreen}%~%{$reset_color%}${git_info}
╰─➤${virtualenv_info} ${orange}λ%{$reset_color%} "

export VIRTUAL_ENV_DISABLE_PROMPT=1
ZSH_THEME_VIRTUALENV_PREFIX=" ${FG[239]}using${FG[243]} «"
ZSH_THEME_VIRTUALENV_SUFFIX="»%{$reset_color%}${FG[239]} python virtual env${FG[243]}"
