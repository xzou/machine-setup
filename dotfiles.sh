#!/bin/bash

# Sets up version controlled dotfiles

. ./common.sh

set -eu

BACKUP_DIR=$HOME/.dotfiles_backup
DOTFILES_DIR=$HOME/.dotfiles

POTENTIAL_EXISTING_FILES=(
    ".zshrc"
    ".bashrc"
    ".bash_profile"
    ".vimrc"
    ".p10k.zsh"
    ".gitignore"
    ".gitconfig"
)

CUSTOM_FILES=(
    ".zshrc_custom"
    ".zshrc_funcs"
)


function create() {
    log_subheading "Creating .dotfiles directory"
    mkdir -p $DOTFILES_DIR
    cd $DOTFILES_DIR
    log_pwd
    git init
    echo
}

function back_up_file() {
    source_path=$1
    dest_path=$2

    mkdir -p $BACKUP_DIR
    printf "Backing up %s to %s\n" $source_path $dest_path
    cp $source_path $dest_path
}

function copy_file_to_dotfiles() {
    source_path=$1
    dest_path=$2

    printf "Copying %s to %s directory\n" $source_path $dest_path
    cp $source_path $dest_path
}

function delete_file() {
    file=$1

    if [[ ! -z $file ]]; then
        printf "Deleting %s\n" $file
        rm $file
    fi
}

function create_sym_link() {
    source_file=$1
    sym_link=$2

    printf "Creating symlink from %s to %s\n" $source_file $sym_link
    ln -sv $source_file $sym_link
}

function add_existing_file() {
    filename=$1
    original_path=$HOME/$filename
    dotfiles_path=$DOTFILES_DIR/$filename
    backup_path=$BACKUP_DIR/$filename

    log_subheading "$(printf "Adding existing file %s to source control" $filename)"

    if [[ -f $original_path ]]; then
        back_up_file $original_path $backup_path
        copy_file_to_dotfiles $original_path $dotfiles_path
        delete_file $original_path
        create_sym_link $dotfiles_path $original_path
    fi
}

function add_new_file() {
    filename=$1
    filepath=$DOTFILES_DIR/$filename

    log_subheading "$(printf "Adding new file %s to source control" $filepath)"
    touch $filepath
    create_sym_link $filepath $HOME/$filename
}

function prompt_add_file() {
    filename=$1

    echo
    if [[ -f $HOME/$filename ]]; then
        log_prompt "$(printf "Add existing file %s to version control? (y/n)" $filename)"
        read choice
        case $choice in
            y|Y ) add_existing_file $filename;;
            n|N ) log_subheading "$(printf "Skipping %s" $filename)";;
        esac
    else
        log_prompt "$(printf "Add new file %s to version control? (y/n)" $filename)"
        read choice
        case $choice in
            y|Y ) add_new_file $filename;;
            n|N ) log_subheading "$(printf 'Skipping %s' $filename)";;
        esac
    fi
    echo
}

function prompt_add_files() {
    files=("$@")

    for file in "${files[@]}"; do
        prompt_add_file $file
    done
}

function override_file() {
    original_path=$1
    dotfiles_path=$2
    backup_path=$3

    log_subheading "$(printf "Overriding existing file %s" $original_path)"
    back_up_file $original_path $backup_path
    delete_file $original_path
    create_sym_link $dotfiles_path $original_path
}

function prompt_override_file() {
    filename=$1
    home_path=$HOME/$filename
    dotfiles_path=$DOTFILES_DIR/$filename
    backup_path=$BACKUP_DIR/$filename
    
    echo
    if [[ -f $HOME/$filename ]]; then
        log_prompt "$(printf "Override existing file %s? (y/n)" $filename)"
        read choice
        case $choice in
            y|Y ) override_file $home_path $dotfiles_path $backup_path;;
            n|N ) log_subheading "$(printf "Skipping file %s" $filename)";;
        esac
    else
        log_prompt "$(printf "Copy file %s from .dotfiles directory? (y/n)" $filename)"
        read choice
        case $choice in
            y|Y ) create_sym_link $dotfiles_path $home_path;;
            n|N ) log_subheading "$(printf "Skipping file %s" $filename)";;
        esac
    fi
    echo
}

function init() {
	log_heading "Initializing version control for dotfiles from scratch"; echo
    create
    prompt_add_files "${POTENTIAL_EXISTING_FILES[@]}"
    prompt_add_files "${CUSTOM_FILES[@]}"
}

function clone() {
    log_heading "Cloning existing dotfiles"
    if [[ -d $DOTFILES_DIR ]]; then
        rm -rf $DOTFILES_DIR
    fi
    git clone git@github.com:xzou/dotfiles $DOTFILES_DIR
    cd $DOTFILES_DIR
    log_pwd

    for file in .[^.]* *; do
        if [[ $file != ".git" && $file != "*" ]]; then
            prompt_override_file $file
        fi
    done
}

function append_custom_zshrc() {
    if [[ -f "$HOME/.zshrc" && -f $HOME/.zshrc_custom ]]; then
        log_subheading "Appending to existing zshrc"
        echo "source $HOME/.zshrc_custom" >> $HOME/.zshrc
    fi
}


log_heading "Starting dotfiles setup"; echo

log_prompt "Do you want to initialize version control for dotfiles from scratch? (y/n/q)"
read choice
case $choice in
	y|Y ) init;;
	n|N ) clone;;
    q|Q ) log_heading "Quitting dotfiles setup";;
esac

log_prompt "Do you want to append to an existing .zshrc? (y/n/q)"
read choice
case $choice in
    y|Y ) append_custom_zshrc;;
    n|N ) log_heading "Skipping append";;
    q|Q ) log_heading "Quitting dotfiles setup";;
esac
