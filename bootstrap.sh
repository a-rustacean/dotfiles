#!/bin/bash

dotfiles_path=$(pwd)

# utility functions

create_dir() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

install_font() {
  font_name="$1.ttf"
  font_path=$2

  curl -L -o $font_name "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/$font_path.ttf"

  create_dir "$HOME/.fonts"
  create_dir "$HOME/.local/share/fonts"

  cp $font_name $HOME/.fonts/
  cp $font_name $HOME/.local/share/fonts/
  sudo cp $font_name /usr/local/share/fonts/
  sudo cp $font_name /usr/share/fonts/

  sudo fc-cache -fv
  rm -rf $font_name
}

# apt

sudo apt update -y
sudo apt upgrade -y

sudo apt install zsh git tmux git-lfs gh cmake libssl-dev pkg-config \
  libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
  python3 gzip scdoc gcc g++ gnome-tweaks openjdk-11-jdk openjdk-11-jre \
  clangd-12 libglfw3 libglfw3-dev python3-pip -y

# tmux

rm -rf $HOME/.tmux.conf

sudo ln -s $dotfiles_path/.tmux.conf $HOME/.tmux.conf

# zsh & omz

rm -rf $HOME/.oh-my-zsh
rm -rf $HOME/.zshrc
rm -rf $HOME/.zshenv
rm -rf $HOME/.p10k.zsh
rm -rf $HOME/.zfunc

git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

rm -rf $HOME/.zshrc
rm -rf $HOME/.zshenv

sudo ln -s $dotfiles_path/.zshrc $HOME/.zshrc
sudo ln -s $dotfiles_path/.zshenv $HOME/.zshenv
sudo ln -s $dotfiles_path/.p10k.zsh $HOME/.p10k.zsh

mkdir $HOME/.zfunc
chsh -s $(which zsh)

# .config/

rm -rf $HOME/.config/cava
rm -rf $HOME/.config/helix
rm -rf $HOME/.config/neofetch
rm -rf $HOME/.config/alacritty
rm -rf $HOME/.config/helix-lite

sudo ln -s $dotfiles_path/.config/cava $HOME/.config/cava
sudo ln -s $dotfiles_path/.config/helix $HOME/.config/helix
sudo ln -s $dotfiles_path/.config/neofetch $HOME/.config/neofetch
sudo ln -s $dotfiles_path/.config/alacritty $HOME/.config/alacritty
sudo ln -s $dotfiles_path/.config/helix-lite $HOME/.config/helix-lite

# nvm, node & npm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

nvm install --lts

# git

rm -rf $HOME/.gitconfig

sudo ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig

# git-lfs

git-lfs install

# Rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

. $HOME/.cargo/env

rustup toolchain install nightly
rustup completions zsh cargo > $HOME/.zfunc/_cargo
rustup component add rust-analyzer
cargo install cargo-binstall
cargo binstall typos-cli cargo-watch cargo-expand ripgrep hexyl -y
## binstall does NOT work
cargo install gitui --locked
## Need `lsp` feature
cargo install taplo-cli -F lsp --locked

# installing font

cd $HOME

install_font "JetBrainsMono-Nerd-Font" "JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular"

# Firefox for devs

cd $HOME
rm -rf firefox
wget "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" -O firefox-dev.tar.bz2
tar xjf firefox-dev.tar.bz2 -C $HOME
rm -r firefox-dev.tar.bz2
sudo rm -rf /usr/local/bin/firefox-dev
sudo ln -s $HOME/firefox/firefox /usr/local/bin/firefox-dev

sudo cat <<EOT > $HOME/firefox/firefox-dev.desktop
[Desktop Entry]
Name=Firefox Developer Edition
Exec=/usr/local/bin/firefox-dev
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Comment=browser
Type=Application
Terminal=false
Encoding=UTF-8
Categories=Utility;
EOT

sudo desktop-file-install $HOME/firefox/firefox-dev.desktop

# Helix

rm -rf $HOME/helix
git clone https://github.com/helix-editor/helix $HOME/helix
cd $HOME/helix
cargo install --path helix-term --locked
rm -rf $HOME/.config/helix/runtime
ln -Ts $HOME/helix/runtime $HOME/.config/helix/runtime

# Alacritty

rm -rf $HOME/alacritty
git clone https://github.com/alacritty/alacritty $HOME/alacritty
cd $HOME/alacritty
cargo build --release --no-default-features --features=x11
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info

sudo cp target/release/alacritty /usr/local/bin/
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null

sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 50

cp extra/completions/_alacritty $HOME/.zfunc/_alacritty

# GitHub cli

gh completion -s zsh > $HOME/.zfunc/_gh
gh extension install yusukebe/gh-markdown-preview
gh extension install dlvhdr/gh-dash
gh extension install vilmibm/gh-screensaver
gh extension install meiji163/gh-notify

# obsidian

curl -L -o "$HOME/obsidian.AppImage" "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/Obsidian-1.6.7.AppImage"
chmod u+x "$HOME/obsidian.AppImage"

# Discord

flatpak install flathub com.discordapp.Discord

# pnpm

corepack enable pnpm
pnpm setup
source $HOME/.zshrc

# LSPs & formatter

pnpm i -g vscode-langservers-extracted typescript typescript-language-server prettier
sudo snap install marksman

# cleanup

sudo apt autoremove -y
