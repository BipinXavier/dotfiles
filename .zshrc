plugins=(zsh-autosuggestions git zsh-syntax-highlighting)

# There is a little bit of junk in this file. It is still under construction with moving stuff to zsh_profile.
export ZSH=$HOME/.oh-my-zsh
export XDG_CONFIG_HOME=$HOME/.config
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/Code/kotlin-language-server/server/build/install/server/bin
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh  # This needs to go away
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh


plugins=(zsh-autosuggestions)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh_profile

export PATH=/opt/homebrew/bin:$PATH;
PATH="${PATH}:${HOME}/go/bin"
export JAVA_OPTS=-Xmx12g
COMPLETION_WAITING_DOTS="true"
DISABLE_AUTO_UPDATE="true"
CASE_SENSITIVE="true"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export GITHUB_USERNAME=BipinXavier
#Aliases
alias codeplace="cd $HOME/CodePlace/"
alias tf_modules="cd $HOME/CodePlace/terraform-modules/"
alias services_repos="cd $HOME/CodePlace/service-repos"
alias tgrunt_repos="cd /$HOME/CodePlace/Bitbucket"
alias ll="ls -la"


alias gdb="git branch | grep -v "main" | xargs git branch -D"
alias gcb="git checkout -b"
alias gcm="git checkout main"
alias gc="git checkout"
alias guap="git add -u && git commit --amend && git push -f"
alias gucm="git add -u && git commit"
alias gs="git status"
alias gaa="git add ."
alias gca="git clean -f -x"

# =============================================================================
# Utility functions for zoxide.
# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function cd() {
    __zoxide_z "$@"
}

function cdi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _files -/
        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Send '\e[0n' to console input.
            \builtin printf '\e[5n'
        fi

        # Report that the completion was successful, so that we don't fall back
        # to another completion function.
        return 0
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="cd ${(q-)__zoxide_result}"
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete cd
fi

# =============================================================================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"