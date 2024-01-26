#!/bin/bash

dotfiles_path=$(pwd)

# apt

sudo add-apt-repository ppa:maveonair/helix-editor -y
sudo apt update -y
sudo apt upgrade -y

sudo apt install zsh helix git tmux git-lfs gh -y

# zsh & omz

rm -rf $HOME/.oh-my-zsh
rm -rf $HOME/.zshrc
rm -rf $HOME/.zshenv
rm -rf $HOME/.p10k.zsh

git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

rm -rf $HOME/.zshrc
rm -rf $HOME/.zshenv

sudo ln -s $dotfiles_path/.zshrc $HOME/.zshrc
sudo ln -s $dotfiles_path/.zshenv $HOME/.zshenv
sudo ln -s $dotfiles_path/.p10k.zsh $HOME/.p10k.zsh

# helix

sudo apt install helix -y

# .config/

rm -rf $HOME/.config/cava
rm -rf $HOME/.config/helix
rm -rf $HOME/.config/neofetch

sudo ln -s $dotfiles_path/.config/cava $HOME/.config/cava
sudo ln -s $dotfiles_path/.config/helix $HOME/.config/helix
sudo ln -s $dotfiles_path/.config/neofetch $HOME/.config/neofetch

# nvm, node & npm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

nvm install --lts

# git

rm -rf $HOME/.gitconfig

sudo ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig

# git lfs

git-lfs install

# rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
~/.cargo/env
rustup toolchain install nightly

# installing font

font_name='JetBrainsMono Nerd Font.ttf'

curl -o $font_name https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf

cp $font_name $HOME/.fonts/$font_name
sudo cp $font_name /usr/local/share/fonts/$font_name
sudo fc-cache -fv

# cleanup

sudo apt autoremove -y
