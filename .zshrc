ZSHDIR="$HOME/.zsh"
setopt prompt_subst # aktualizace promtu

[ ! -d $ZSHDIR ] && mkdir -p $ZSHDIR
[ ! -e $ZSHDIR/local ] && touch $ZSHDIR/local

# autoloads, precmds
autoload -U compinit # "standard" competion rules
compinit
autoload -U colors # who don't like colors :)
colors
autoload -U edit-command-line # use editor for actual command
autoload -Uz vcs_info # show versions of repositories

kube_cluster_info() {
    context_info=$(kubectl config get-contexts | grep '*' | awk '{print $3"/"$5}' | sed 's/^kube//g' | sed 's/\/sklik-/\//g')
    context_cluster=${context_info%/*}
    context_namespace=${context_info#*/}
    echo "$context_cluster/$context_namespace"
}


precmd () {
 KUBE_NS=$(kube_cluster_info)
 psvar=()
 vcs_info
 [[ -n $vcs_info_msg_0_ ]] && psvar[1]="$vcs_info_msg_0_"
 psvar[2]=("$KUBE_NS")
}


# Shell functions
setenv() { export $1=$2 }    # compatible with csh
psg() { ps auxwww | grep $* | grep -v grep }
hsr() { grep $* $HISTFILE }

# Set prompts

if [[ "$USER" = "root" ]] || [[ "$HOME" = "/root" ]]
 then
  USERCOLOR="%B%{$fg[red]%}"
  HOSTCOLOR="%B%{$fg[green]%}"
  alias hs="cd /home/${HOME}"
  alias mc='mc --skin=modarin256root-defbg'
else
  USERCOLOR="%B%{$fg[white]%}"
  HOSTCOLOR="%B%{$fg[green]%}"
  alias mc='mc --skin=modarin256-defbg'
fi

RETURN_CODE="%B%{$fg[yellow]%}%(0?..[%?%\] )%{$reset_color%}"
JOBS="%B%{$fg[yellow]%}%(1j.[%j] .)"
GIT_REVISIONS="%(1v.%F{yellow}%1v%f.)"
KUBERNETES="%(2v.%F{yellow}%2v%f.)"
PROMPT="$RETURN_CODE%{$reset_color%}${KUBERNETES}%{$reset_color%} $HOSTCOLOR%#%b%{$reset_color%} "
RPROMPT=" $JOBS%B$USERCOLOR%n%{$reset_color%}@$HOSTCOLOR%m%{$reset_color%}:%{$fg[green]%}%~%b$GIT_REVISIONS%{$reset_color%}"

source <(kubectl completion zsh)

# Basic aliases
alias l="ls -G"
alias ls="ls -ahG"
alias ll="ls -alhG"
alias lt="ls -ltG"
alias lsa="ls -Gld .*" # List only file beginning with "."
alias lsd="ls -Gld *(/)" # only directories
alias lss="du -a | sort -nr | head -30" # Display the current directory's 30 largest files
alias info="info --vi-keys"
alias chrome="chromium"

# no spelling corrections
alias mv="nocorrect mv"
alias cp="nocorrect cp"
alias man="nocorrect man"
alias convert="nocorrect convert"
alias mkdir="nocorrect mkdir"
alias ln="nocorrect ln"
alias grep="nocorrect grep"
alias git="nocorrect git"
alias svn="nocorrect svn"
alias ssh="nocorrect ssh"
alias sshx="nocorrect sshX"
alias sshX="nocorrect sshX"
alias docker="nocorrect docker"
alias sudo="nocorrect sudo"
alias curl='noglob curl'
# other universal aliases
alias less="less -r"
alias grep="grep --colour=auto"
alias h="history -fD 1" # Display the command-history stack.
alias c=clear
alias e=exit
alias d="dirs -v"  # Display the directory stack.
alias j="jobs -l"  # Display all jobs currently running.
alias sr="screen -D -R"
alias srj="screen -D -R jarek"
alias sd="screen -d"
alias sx="screen -x"
alias sl="screen -list"
alias -s txt=vim
alias -s html=links
alias -s htm=links
alias log="cd /var/log"
alias linksg="links www.google.com"
alias linksl="links 127.0.0.1"
alias linksc="links 127.0.0.1:631/printers"
alias gpg2="gpg"

alias bi="bundle install"
alias be="bundle exec"
alias bu="bundle update"

alias fixterm="stty sane"
alias fixaudio="sudo pkill coreaudiod"

alias k="kubectl"

alias xmlrpc-netcat='docker run -i docker.dev.dszn.cz/martin.junk/xmlrpc-netcat'

case $OSTYPE in
 linux*)
  #alias ls="ls -F --color"
  alias etc="cd /etc"
  alias rfcomm="nocorrect rfcomm"
  alias dfh="df -h"
  if [ -f /etc/gentoo-release ] ; then 
   alias emerge="nocorrect emerge" 
   alias eix="nocorrect eix"
  fi
 ;;

 freebsd*)
  alias prt="cd /usr/ports"
  alias www="cd /usr/local/www"
  alias zfs="nocorrect zfs"
  alias portmaster="portmaster -d"
  alias fp=psearch
  [[ ${$(uname -r)%%-*} -ge 7.1 ]] && alias top="top -CHP"
  if [[ $USER = "root" ]] || [[ "$HOME" = "/root" ]] ; then
   alias pgr="portupgrade -N"
   alias upd="pkg_version -vl '<' >! /tmp/upd && cat /tmp/upd"
  fi
  #alias ls="ls -G"
  #alias ll="ls -alo"
  alias etc="cd /usr/local/etc"
  alias dfh='df -h | egrep -v "devfs|fdescfs|procfs|basejail"'
  [ $(egrep '^ifconfig_.*="*DHCP"*' /etc/rc.conf) ] || export FTP_PASSIVE_MODE=NO
  [ $(sysctl -n security.jail.jailed) -eq 1 ] && export PORTSDIR=/usr/ports
 ;;

 darwin*)
  alias dfh="df -h"
  export MANPATH=/opt/local/share/man:$MANPATH
  export DISPLAY=:0.0
 ;;

esac

# Global aliases -- These do not have to be
# at the beginning of the command line.
#alias -g 

#export LANG="en_US.UTF-8";
export VISUAL="vim"
export EDITOR="vim"
export TERM="xterm-256color"
export WATCH="all"

# Set options
HISTFILE="$HOME/.zsh/history"
SAVEHIST="9999"
export HISTSIZE="9999"

setopt interactivecomments   # hash in command is just comment
setopt EXTENDED_GLOB
setopt NO_CLOBBER            # safe redirects
setopt CORRECT_ALL           # automatically correct the spelling of each word on the command line
setopt NO_BEEP               # never ever beep ever :)
setopt NO_LIST_BEEP          # don't beep for completion
setopt AUTO_CD               # cd without cd command
setopt AUTO_PUSHD            # automatically append dirs to the push/pop list
setopt CDABLE_VARS           # try cd to ~
setopt RM_STAR_SILENT        # Do not query the user before executing `rm *' or `rm path/*'

setopt HIST_IGNORE_SPACE     # Remove command lines from the history list when the first character on the line is a space
setopt HIST_IGNORE_ALL_DUPS  # no duplicates in history
setopt EXTENDED_HISTORY      # Save each command's beginning timestamp and the duration
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line
setopt INC_APPEND_HISTORY    # new history lines are added to the $HISTFILE  incrementally
setopt SHARE_HISTORY         # use the same history file for all sessions
setopt BRACECCL              # {a..z} to gen an alpha sequence

setopt auto_param_keys      # remove trailing spaces after completion if needed
setopt auto_param_slash     # add slash for directories
setopt auto_remove_slash    # remove slash on dirs if word separator added
setopt auto_resume          # simgle word resume if possible
setopt check_jobs           # check jobs on exit
setopt monitor              # job control

setopt hash_cmds            # do not always search through path, hash cmds
setopt hash_dirs            # hash directories holding commands too
setopt hash_list_all        # verify path hash on completion

# File completion
setopt AUTOLIST              # enable list of options
setopt NO_LIST_AMBIGUOUS     # no tab-key hell
setopt LIST_PACKED           # smaller completion  list
setopt COMPLETE_IN_WORD      # allow tab completion in the middle of a word
setopt ALWAYS_TO_END         # tab completion moves to end of word
zmodload -i zsh/complist     # we like colors, who not?
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# remove duplicates & add locations in paths
typeset -U path cdpath manpath fpath PATH="/usr/local/git/bin:$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/pkg/bin:/usr/pkg/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/opt/local/bin:/opt/local/sbin:/usr/games:/usr/games/bin:/opt/bin:${HOME}/bin:${HOME}/.gem/ruby/2.0/bin"

# remove nonexistent directories from $PATH
path=($^path(N))

# Fuzzy matching of completions for when you mistype them:
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Cache completions:
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.zsh/cache

# Ignore completion functions for commands you don't have:
zstyle ':completion:*:functions' ignored-patterns '_*'

# Prevent CVS files/directories from being completed:
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'

# run vcs_info_printsys
zstyle ':vcs_info:*' enable svn git

# Bindkeys
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^N' history-incremental-search-forward
bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word

# completion system
zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )' # allow one error for every three characters typed in approximate completer
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~' # don't complete backup files as executables
zstyle ':completion:*:correct:*'       insert-unambiguous true             # start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:corrections'     format $'%{\e[0;32m%}%d (errors: %e)%{\e[0m%}' #
zstyle ':completion:*:correct:*'       original true                       #
zstyle ':completion:*:descriptions'    format $'%{\e[0;32m%}completing %B%d%b%{\e[0m%}'  # format on completion
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select              # complete 'cd -<tab>' with menu
zstyle ':completion:*:expand:*'        tag-order all-expansions            # insert all expansions for expand completer
zstyle ':completion:*:history-words'   list false                          #
zstyle ':completion:*:history-words'   menu yes                            # activate menu
zstyle ':completion:*:history-words'   remove-all-dups yes                 # ignore duplicate entries
zstyle ':completion:*:history-words'   stop yes                            # 
zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'        # match uppercase from lowercase
zstyle ':completion:*:matches'         group 'yes'                         # separate matches into groups
zstyle ':completion:*'                 group-name '' 
if [[ -z "$NOMENU" ]] ; then
  zstyle ':completion:*'               menu select=2                       # if there are more than 5 options allow selecting from a menu
else
  setopt no_auto_menu # don't use any menus at all
fi
zstyle ':completion:*:messages'        format '%d'                         #
zstyle ':completion:*:options'         auto-description '%d'               #
zstyle ':completion:*:options'         description 'yes'                   # describe options in full
zstyle ':completion:*:processes'       command 'ps -au$USER'               # on processes completion complete all user processes
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters        # offer indexes before parameters in subscripts
zstyle ':completion:*'                 verbose true                        # provide verbose completion information
zstyle ':completion:*:warnings'        format $'Nothing found' # set format for warnings
zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'       # define files to ignore for zcompile
zstyle ':completion:correct:'          prompt 'correct to: %e'             #
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'    # Ignore completion functions for commands you don't have:

zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' list-colors ''

unsetopt MENU_COMPLETE
setopt AUTO_MENU

zstyle ':completion:*:*:*:*:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) 
([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"
# end of completion system
zstyle -e ':completion:*:(ssh|scp|sftp|rsh):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

. $HOME/.zsh/local

#function cd_improved
#{
#  previous=`pwd`
#  cd $1
#  current=`pwd`
#  echo "$previous -> $current"
#  echo
#  ls -G
#}

#alias cd="cd_improved"

PATH=$PATH:/Users/navry/szn/bin/
PATH=$PATH:/usr/local/opt/go/bin/src/github.com/projectatomic/skopeo
PATH=$PATH:/Users/navry/.bin/
#function csshX_screen (){
#  echo `system_profiler SPDisplaysDataType | grep Resolution | wc -l`
#}
#alias csshX="csshX --screen=$(csshX_screen)"

#function csshX_screen (){
#/usr/bin/swift - <<END
#import AppKit;
#let screenArray : [AnyObject] = NSScreen.screens()!
#let screenArraysize = screenArray.count
#print(screenArraysize)
#END
#}
#alias csshX="csshX --screen=$(csshX_screen)"

function g_function(){
    name="$1"
    repodir="${HOME}/zoznam/gitlab/"
    repos=$(find ${repodir} -path "*/*${name}*/.git" -prune | sed 's/\/.git$//g')
    repo_count=$(echo "$repos" | wc -l)

    if [ "$repos" = "" ]; then
        echo "> no repo '$name' found"
        return
    fi

    if [ $repo_count -eq 1 ]; then
        echo "> $repos"
        cd "$repos"
        return
    fi
    IFS=$'\n'
    emulate -L zsh
    setopt sh_word_split
    export COLUMNS=1
    select dir in $repos; do
        echo "> $dir"
        cd "$dir"
        break
    done
    unset IFS
}

alias g="g_function"

function vimdiff_3_way_merge(){
  vimdiff -d $1 -M $2 $3 -c "wincmd J" -c "set modifiable" -c "set write" -c "set wrap" -c "diffget $2" -c "diffupdate"
}

alias vdiff="vimdiff_3_way_merge"

#eval "$(rbenv init -)"

LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

function _g { _values 'git dir' $( find ~/zoznam/gitlab -path "*/.git" | sed -r 's/git\/.*\/(.*\/.*)\/.git/\1/g')}
compdef _g g

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/navry/Downloads/tmp/gcloud/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/navry/Downloads/tmp/gcloud/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/navry/Downloads/tmp/gcloud/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/navry/Downloads/tmp/gcloud/google-cloud-sdk/completion.zsh.inc'; fi
