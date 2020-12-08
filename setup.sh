#!/bin/bash

. ./common.sh

# Install zsh
if [[ ! $(which zsh) ]]; then
    log_heading "Installing zsh"
	brew install zsh
    echo
fi


# Change default shell to zsh
if [[ ! "$SHELL" = "/bin/zsh" ]]; then
    log_heading "Changing default shell to zsh"
	chsh -s /bin/zsh
    echo
fi


# Install oh-my-zsh
if [[ ! -d $HOME/.oh-my-zsh ]]; then
    log_heading "Installing oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	chmod 755 /usr/local/share/zsh
	chmod 755 /usr/local/share/zsh/site-functions
    echo
fi


# Install plugins for zsh
PLUGINS_PATH=${ZSH_CUSTOM:-$HOME}/.oh-my-zsh/custom

log_heading "Installing plugins for zsh"

if [[ ! $PLUGINS_PATH/themes/powerlevel10k ]]; then
    log_subheading "Installing Powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $PLUGINS_PATH/themes/powerlevel10k
    echo
fi

if [[ ! $PLUGINS_PATH/plugins/zsh-autosuggestions ]]; then
    log_subheading "Installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions $PLUGINS_PATH/plugins/zsh-autosuggestions
    echo
fi

echo


# Set up version controlled dotfiles
log_heading "Please respond to the following prompts:"
echo

log_prompt "Do you want to set up source controlled dotfiles? (y/n)"
read choice
case $choice in
	y|Y ) source ./dotfiles.sh;;
	n|N ) log_heading "Skipping dotfiles setup";;
esac
