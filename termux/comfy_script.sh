#!/usr/bin/env bash
# comfy bash env for Termux (native, no proot)

pkg install -y \
  neovim \
  bash-completion \
  bat \
  fzf \
  git \
  make \
  gawk \
  fastfetch \
  screen

mkdir -p "$HOME/workdir"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.config/nvim"

git clone https://github.com/akinomyoga/ble.sh.git "$HOME/workdir/ble.sh"
cd "$HOME/workdir/ble.sh" && make install INSDIR="$HOME/.local/lib/blesh"

cat <<- 'BASHRC' > "$HOME/.bashrc"
# exports paths and other variables first
export PATH="$PATH:$HOME/bin"
export HISTTIMEFORMAT="%F %T "
export HISTSIZE="100000"
export LS_OPTIONS='--color=auto'

if [[ $- == *i* ]] # execute if in interactive shell
then
  PS1='\[\033[1;37m\][`date +%H:%M:%S`]\[\033[1;36m\][\[\033[1;31m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;36m\]]\[\033[1;31m\]\\$\[\033[0m\] '
  shopt -s extglob
  source -- "$HOME/.local/lib/blesh/ble.sh" --attach=none
  if [[ -f "$PREFIX/share/bash-completion/bash_completion" ]]; then
    source "$PREFIX/share/bash-completion/bash_completion"
  fi
  if [[ -f "$PREFIX/share/fzf/key-bindings.bash" ]]; then
    source "$PREFIX/share/fzf/key-bindings.bash"
  fi
  alias cat='bat --style=plain --paging=never'
fi

umask 022
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='nvim'

if [[ $- == *i* ]] # execute if in interactive shell
then
  [[ ! ${BLE_VERSION-} ]] || ble-attach
  fastfetch
fi
BASHRC

cat <<- 'BLESHRC' > "$HOME/.blerc"
ble-bind -f 'M-B' 'backward-cword'
ble-bind -f 'M-F' 'forward-cword'
bleopt complete_auto_complete=
bleopt complete_auto_history=
bleopt complete_ambiguous=
bleopt prompt_eol_mark=''
bleopt complete_menu_filter=
bleopt history_share=1
# bash-completion pre-escapes rsync/scp local paths (scp style), ble.sh would quote them a second time
function my/scp-dequote-compreply {
  case ${COMP_WORDS[0]} in (rsync|scp) ;; (*) return 0 ;; esac
  ((${#COMPREPLY[@]})) || return 0
  # fzf wrapper calls the advised original -> runs twice per request
  [[ $_my_scp_dequoted == "$COMP_LINE:$COMP_POINT" ]] && return 0
  _my_scp_dequoted=$COMP_LINE:$COMP_POINT
  local i ret
  for i in "${!COMPREPLY[@]}"; do
    ble/syntax:bash/simple-word/eval "${COMPREPLY[i]% }" && COMPREPLY[i]=$ret
  done
}
function my/adjust-scp-completions {
  case $comp_func in
  (_comp_cmd_rsync|_comp_cmd_scp|_rsync|_scp|_fzf_path_completion)
    ble/function#advice after "$comp_func" my/scp-dequote-compreply ;;
  esac
}
blehook complete_load!='ble/function#advice after ble/complete/progcomp/adjust-third-party-completions my/adjust-scp-completions'

# complete_requote_threshold compares the quoted length with the escaped one; a single special char loses by one -> discount the two quotes
function my/patch-requote-threshold {
  local def; def=$(declare -f ble/complete/action/requote-final-insert)
  builtin eval -- "${def/'((${#ret}+threshold<=${#ins}))'/'((${#ret}-2+threshold<=${#ins}))'}"
}

# ambiguous completion inserts the common prefix backslash-escaped, requote as an open '...
function my/requote-common-insert {
  [[ " ${ADVICE_FUNCNAME[*]} " == *' ble/complete/insert-common '* ]] && ((cand_count>1)) || return 0
  local word=${ADVICE_WORDS[3]}
  [[ $word != "$COMPS" && $word == *\\* && $COMPS != *[\\\$\`~=:{]* && $comps_flags != *[SEDI]* ]] || return 0
  local ret simple_flags simple_ibrace count
  ble/syntax:bash/simple-word/reconstruct-incomplete-word "$word" &&
    ble/complete/source/eval-simple-word "$ret" single:count && ((count==1)) || return 0
  local q=\' Q="'\\''"
  ADVICE_WORDS[3]=$q${ret//$q/$Q}
}
blehook complete_load!='my/patch-requote-threshold; ble/function#advice before ble/complete/insert my/requote-common-insert'

# menu-complete (tab-tab cycling) inserts the raw escaped candidate, requote like the final insert
function my/requote-menu-selection {
  local nsel=${ADVICE_WORDS[1]}
  ((nsel>=0)) && [[ :$bleopt_complete_menu_complete_opts: == *:insert-selection:* ]] || return 0
  local COMP1=${_ble_complete_menu0_comp[0]} COMP2=${_ble_complete_menu0_comp[1]}
  local COMPS=${_ble_complete_menu0_comp[2]} COMPV=${_ble_complete_menu0_comp[3]}
  local comp_type=${_ble_complete_menu0_comp[4]} comps_flags=${_ble_complete_menu0_comp[5]} comps_fixed=${_ble_complete_menu0_comp[6]}
  local "${_ble_complete_cand_varnames[@]/%/=}"
  ble/complete/cand/unpack "${_ble_complete_menu_items[nsel]}"
  local insert=$INSERT insert_flags= suffix=
  ble/complete/action/requote-final-insert
  [[ $insert != "$INSERT" ]] || return 0
  ble-edit/content/replace-limited "$_ble_complete_menu0_beg" "$_ble_edit_ind" "$insert"
  ((_ble_edit_ind=_ble_complete_menu0_beg+${#insert}))
}
blehook complete_load!='ble/function#advice after ble/complete/menu-complete.class/onselect my/requote-menu-selection'
ble-import -d integration/fzf-completion
ble-import -d integration/fzf-key-bindings
BLESHRC

cat <<- 'INITVIM' > "$HOME/.config/nvim/init.vim"
set number
set expandtab ts=2 sw=2 ai
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list
set mouse=
INITVIM

cat <<- 'SCREENRC' > "$HOME/.screenrc"
termcapinfo xterm* ti@:te@
logfile "screenlog_%S.log"
deflog on
SCREENRC

rm -rf "$HOME/workdir/ble.sh"
