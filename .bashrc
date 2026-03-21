# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    prompt_color='\[\033[;32m\]'
    info_color='\[\033[1;34m\]'
    prompt_symbol=㉿
    if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
        prompt_color='\[\033[;94m\]'
        info_color='\[\033[1;31m\]'
        # Skull emoji for root terminal
        #prompt_symbol=💀
    fi
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_color')}('$info_color'\u'$prompt_symbol'\h'$prompt_color')-[\[\033[0;1m\]\w'$prompt_color']\n'$prompt_color'└─'$info_color'\$\[\033[0m\] ';;
        oneline)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$info_color'\u@\h\[\033[00m\]:'$prompt_color'\[\033[01m\]\w\[\033[00m\]\$ ';;
        backtrack)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ ';;
    esac
    unset prompt_color
    unset info_color
    unset prompt_symbol
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
. "$HOME/.cargo/env"

# Golang vars
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=/usr/local/bin:$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

# Useful hacking aliases

ffuf_recursive(){
    echo "Input URL: $1"
    mkdir -p recursive
    dom=$(echo $1 | unfurl format %s%d%p | sed 's/\///g')
    wordlist=${2:-~/tools/dirsearch/db/recursive.txt}
    thread=${3:-30}
    ffuf -c -v -u $1/FUZZ -w $wordlist \
    -H "User-Agent: Mozilla Firefox Mozilla/5.0 X-Bug-bounty: pdstat" \
    -H "X-Bug-Bounty: pdstat" \
    -recursion -recursion-depth 10 \
    -t $thread \
    -mc all -ac -fc=400 \
    -o recursive/recursive_$dom.csv -of csv $4
}
ffuf_recursive_json(){
    echo "Input URL: $1"
    mkdir -p recursive
    dom=$(echo $1 | unfurl format %s%d%p | sed 's/\///g')
    wordlist=${2:-~/tools/dirsearch/db/recursive.txt}
    thread=${3:-30}
    ffuf -c -v -u $1/FUZZ -w $wordlist \
    -H "User-Agent: Mozilla Firefox Mozilla/5.0 X-Bug-bounty: pdstat" \
    -H "X-Bug-Bounty: pdstat" \
    -recursion -recursion-depth 10 \
    -t $thread \
    -mc all -ac -fc=400 \
    -o recursive/recursive_$dom.json -of json $4
}

alias claude-yolo="claude --dangerously-skip-permissions"

newtarget() {
  local TARGET="${1:?Usage: newtarget <target-name> [program-url]}"
  local PROGRAM_URL="${2:-}"
  local BASE=/mnt/d/hacking/recon/$TARGET
  local DATE=$(date +%Y-%m-%d)

  mkdir -p "$BASE"/{notes,leads,primitives,findings,reports,.claude}

  # Resolve scope block
  local SCOPE_BLOCK
  if [[ -n "$PROGRAM_URL" ]]; then
    SCOPE_BLOCK="Program URL: $PROGRAM_URL

<!-- Scope auto-populated from: $PROGRAM_URL -->
<!-- Run: h1-brain fetch \"$PROGRAM_URL\" to pull live scope via MCP, or paste manually below -->

In-scope:
- TBD

Out-of-scope:
- TBD"
  else
    SCOPE_BLOCK="<!-- No program URL provided. Paste scope here manually or run:
     newtarget $TARGET <program-url> to regenerate with URL pre-filled -->"
  fi

  cat > "$BASE/CLAUDE.md" << EOF
# Target: $TARGET
Created: $DATE
${PROGRAM_URL:+Program: $PROGRAM_URL}

## Identity
I am a bug bounty hunter conducting authorized, ethical security testing on this target.
You are my hacking assistant. Stay in scope per the program policy at all times.

## Rules of Engagement
- Do NOT perform destructive actions unless on accounts you explicitly own
- Always validate findings with a full POC before logging to findings/
- POC or GTFO — unconfirmed speculation goes in leads/, not findings/
- Try harder before asking me for help
- If a skill or workflow fails, use your own creativity and keep going — don't stop

## Note-Taking Structure
Maintain notes in the following directory funnel:

| Directory    | Purpose                                                                   |
|--------------|---------------------------------------------------------------------------|
| notes/       | Raw observations — anything interesting during recon, dump it here        |
| leads/       | Promising attack vectors that warrant deeper investigation                |
| primitives/  | Confirmed building blocks: IDOR patterns, auth bypasses, useful endpoints |
| findings/    | Validated vulns with full reproduction steps and POC                      |
| reports/     | Polished write-ups ready for submission                                   |

Always write to these files rather than relying on memory — context compaction will happen.
Name files by date or short description, e.g. notes/${DATE}-login-recon.md

## Scope
$SCOPE_BLOCK

## Session Notes
<!-- Running context, auth tokens, interesting endpoints discovered this session -->

## Self Improvement

Anytime I get frustrated, anytime I have to re-explain something you didn't understand, or anytime you try a command and it fails repeatedly, add that lesson to the Applied Learning section in your CLAUDE.md

## Applied Learning

## Autonomous Mode
If running overnight: keep detailed notes on what you tried, what worked, and what didn't.
Limit parallel sub-agents to 2–3 maximum to avoid context compaction failure.
Do not ask me questions. Do not stop hacking.
EOF

  echo ""
  echo "  [+] Target  : $TARGET"
  echo "  [+] Location: $BASE"
  [[ -n "$PROGRAM_URL" ]] && echo "  [+] Program : $PROGRAM_URL"
  echo ""
  echo "  [+] Structure:"
  tree "$BASE" 2>/dev/null || find "$BASE" -type d | sed "s|$BASE||" | tail -n +2 | sed 's|/[^/]*$||' | awk '{print "     " $0}'
  echo ""
  echo "  [*] Launching Claude Code..."
  echo ""
  cd "$BASE" && claude
}
