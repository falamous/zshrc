# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source /usr/share/zsh/share/antigen.zsh

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$XDG_CACHE_HOME/zsh/history

TOP_LEFT_ANGLE=$(echo -ne "\ue0bc")
TOP_RIGHT_ANGLE=$(echo -ne "\ue0be")
LEFT_TRIANGLE=$(echo -ne "\ue0b2")
RIGHT_TRIANGLE=$(echo -ne "\ue0b0")

# source ~/scripts/alias.sh


function vi_mode() {
	if [[ -z $ZSH_DONT_USE_VI_MODE ]] then
		# vi mode
		antigen bundle jeffreytse/zsh-vi-mode
	else
		bindkey -e
	fi
}

# The plugin will auto execute this `zvm_after_select_vi_mode` function
function zvm_after_select_vi_mode() {
    case $ZVM_MODE in
        $ZVM_MODE_NORMAL)
            local bg_color=red
            local fg_color=white
            local text=N
            # Something you want to do...
            ;;
        $ZVM_MODE_INSERT) 
            local bg_color=cyan
            local fg_color=white
            local text=I
            # Something you want to do...
            ;;
        $ZVM_MODE_VISUAL)
            local bg_color=green
            local fg_color=black
            local text=V
            # Something you want to do...
            ;;
        $ZVM_MODE_VISUAL_LINE)
            local bg_color=green
            local fg_color=black
            local text=VL
            # Something you want to do...
            ;;
    esac
    VI_MODE=""
    VI_MODE+="%K{normal}%F{$bg_color}$LEFT_TRIANGLE"
    VI_MODE+="%K{$bg_color}%F{$fg_color}$text"
    VI_MODE+="%K{normal}%F{$bg_color}$RIGHT_TRIANGLE"
    VI_MODE+="%K{normal}%F{normal}"
}

function auto_completion() {
	# completion
	autoload -U compinit
	zstyle ':completion:*' menu select
	zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache
	zmodload zsh/complist
	compinit -d $XDG_CACHE_HOME/zsh/zcompdump
	_comp_options+=(globdots)		# Include hidden files.
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555555"
}

function install_plugins() {
	antigen bundle zsh-users/zsh-syntax-highlighting
}

function set_opts() {
	# options
	setopt autocd
	setopt prompt_subst
	setopt interactive_comments
	setopt hist_ignore_dups
	setopt hist_reduce_blanks
}

function bind_keys() {
	# home end fix
	local bound_keys=()

	declare -A bound_keys
	key='\e[1~'; bound_keys[$key]=beginning-of-line # Linux console
	key='\e[H' ; bound_keys[$key]=beginning-of-line # xterm
	key='\eOH' ; bound_keys[$key]=beginning-of-line # gnome-terminal
	key='\e[2~'; bound_keys[$key]=overwrite-mode    # Linux console, xterm, gnome-terminal
	key='\e[3~'; bound_keys[$key]=delete-char       # Linux console, xterm, gnome-terminal
	key='\e[P' ; bound_keys[$key]=delete-char      
	key='\e[3~'; bound_keys[$key]=delete-char      
	key='\e[4~'; bound_keys[$key]=end-of-line       # Linux console
	key='\e[F' ; bound_keys[$key]=end-of-line       # xterm
	key='\eOF' ; bound_keys[$key]=end-of-line       # gnome-terminal
	modes=(
		command
		emacs
		isearch
		main
		vicmd
		viins
		viopp
		visual
	)
	for key in ${(k)bound_keys}
	do
		for mode in $modes
		do
			bindkey -M "$mode" "$key" "$bound_keys[$key]"
		done
	done
}

function setup_vcs() {
	autoload -U vcs_info
	precmd_vcs_info() { vcs_info }
	precmd_functions+=( precmd_vcs_info )
	zstyle ':vcs_info:git:*' formats ' %F{yellow}%s(%b)'
	zstyle ':vcs_info:svn:*' formats ' %F{red}%s(%b)'
	zstyle ':vcs_info:hg:*' formats ' %F{grey}%s(%b)'
}

function setup_alias() {
	# Color aliases
	alias grep='grep --color=auto'
	alias egrep='grep -E --color=auto'
	alias fgrep='grep -F --color=auto'
	alias grep='grep --color=auto'
	alias ls='lsd'
	alias l='lsd -al'
	alias cat='bat --style=plain --paging=never'
	# alias cp='rsync -aP'
	alias tokei="tokei "$@" | sed 's/=/─/g;s/|/│/g;s/-/─/g;s/^/│/;s/─$//;s/$/│/;s/│─/├─/g;s/─│/─┤/;1s/├/┌/;1s/┤/┐/;/ Total /,\$s/├/└/g;/ Total /,\$s/┤/┘/g'"
	alias rg='rg --binary -n -H --no-heading'
	alias m='ncmpcpp -S visualizer'

	# Confing aliases
	alias dosbox='dosbox -conf "$XDG_CONFIG_HOME"/dosbox/dosbox.conf'
	alias mongo='mongo --norc'

	# System alises
	alias poweroff='sudo poweroff'
	alias reboot='sudo reboot'
	alias hibernate='sudo systemctl suspend'
	alias halt='sudo halt'
	alias ss='sudo systemctl'
	alias ssu='sudo su'
	alias suka='sudo'
	alias ydl='youtube-dl'
	alias gc='git clone'
	alias logout='pkill xinit'
	alias tor='sudo systemctl restart tor && sudo systemctl restart privoxy'


	# Abbreviations
	alias py='ipython -i'
	alias py2='python2 -i'
	alias py3='ipython3 -i'
	alias v='nvim'
	alias vim='nvim'
	alias pathfiles='find $(echo $PATH | sed "s|:|/ |g") -type f 2>/dev/null'
	alias dl='http_proxy=http://localhost:8118 https_proxy=http://localhost:8118 ftp_proxy=http://localhost:8118 ftps_proxy=http://localhost:8118 rsync_proxy=http://localhost:8118 aria2c -x 16'
	alias recordscreen='ffmpeg -video_size 1920x1080 -framerate 60 -f x11grab -i :0.0'

}

function chpwd_tokei() {
    if test -d .git || test -f docker-compose.yml; then
        timeout 1 tokei 2>/dev/null | sed 's/=/─/g;s/|/│/g;s/-/─/g;s/^/│/;s/─$//;s/$/│/;s/│─/├─/g;s/─│/─┤/;1s/├/┌/;1s/┤/┐/;/ Total /,$s/├/└/g;/ Total /,$s/┤/┘/g'
    fi
}

function de() {
    # docker enter
    container_name=$1
    shift
    if [[ -z "$@" ]] then
        case $container_name in
            *mongo* )
                docker exec -it $(docker ps | grep $container_name | cut -d' ' -f'1' | sed q) mongo
                ;;
            *python* )
                docker exec -it $(docker ps | grep $container_name | cut -d' ' -f'1' | sed q) python
                ;;
            * )
                docker exec -it $(docker ps | grep $container_name | cut -d' ' -f'1' | sed q) bash
                ;;
        esac
    else
        docker exec -it $(docker ps | grep $container_name | cut -d' ' -f'1' | sed q) "$@"
    fi
}

function set_proxies(){
        export proxy=socks5://localhost:9050
        export http_proxy=http://localhost:8118
        export https_proxy=$http_proxy
        export ftp_proxy=$http_proxy
        export rsync_proxy=$http_proxy
}

PS1='%F{magenta}%T %(0?..%F{normal}%K{red}%?%K{normal} )%F{cyan}%~${vcs_info_msg_0_} %F{blue}> %F{normal}'
if [[ -z $ZSH_DONT_USE_VI_MODE ]] then
     PS1='%a${VI_MODE}'"$PS1"
fi


autoload -U colors && colors

chpwd_functions=("${chpwd_functions[@]}" chpwd_tokei)
set_opts
setup_alias
auto_completion
setup_vcs
install_plugins
vi_mode
bind_keys
antigen apply
